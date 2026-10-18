// revenuecat-webhook — Procesa eventos de RevenueCat de forma segura.
//
// RevenueCat envía eventos con `Authorization: Bearer <AUTH_TOKEN>`.
//
// Modelo de producto (DungeonsSpeak) — 3 estamentos × 2 ciclos:
//   dungeonsspeak_noble_*    -> plan `noble`
//   dungeonsspeak_realeza_*  -> plan `realeza`
//   dungeonsspeak_divino_*   -> plan `divino`
//
// Issue #71: este webhook ya no escribe `user_subscriptions` a mano. Delega
// todo en la RPC `sync_entitlement`, que es idempotente y no degrada (compara
// expiraciones). Así el webhook y la reconciliación de la app (#69) usan el
// mismo camino y no pueden dejarse el estado a medias.
//
// Idempotencia: cada `event.id` se registra en `revenuecat_events`; si ya
// existe, se responde 200 sin volver a aplicar nada (RevenueCat reintenta).
//
// Secretos requeridos: REVENUECAT_AUTH_TOKEN, SUPABASE_URL,
// SUPABASE_SERVICE_ROLE_KEY.
import { createClient } from 'jsr:@supabase/supabase-js@2';

const authToken = Deno.env.get('REVENUECAT_AUTH_TOKEN') ?? '';
const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const supabase = createClient(supabaseUrl, serviceKey, {
  auth: { persistSession: false },
});

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

const PRO_ENTITLEMENT = 'DungeonsSpeak Pro';

// Mapeo product_id → plan (id en subscription_plans). El product_id es la
// fuente canónica (lo define el id del product en Google Play).
function planIdForProduct(productId: string): string {
  const key = productId.toLowerCase();
  if (key.includes('divino') || key.includes('divine')) return 'divino';
  if (key.includes('realeza') || key.includes('royalty')) return 'realeza';
  return 'noble';
}

/// Aplica el estado del entitlement mediante la RPC única.
async function applyEntitlement(params: {
  userId: string;
  productId: string;
  expiresAt?: string;
  active: boolean;
}): Promise<boolean> {
  const { userId, productId, expiresAt, active } = params;
  const { error } = await supabase.rpc('sync_entitlement', {
    p_user_id: userId,
    p_plan_id: planIdForProduct(productId),
    p_product_id: productId || null,
    p_expires_at: expiresAt ?? null,
    p_store: 'play',
    p_is_active: active,
  });
  if (error) {
    console.error('sync_entitlement rpc error:', error);
    return false;
  }
  return true;
}

/// Periodo de gracia: Play reintenta el cobro, el acceso se mantiene.
async function setGrace(userId: string): Promise<void> {
  const { error } = await supabase
    .from('user_subscriptions')
    .update({ status: 'in_grace', updated_at: new Date().toISOString() })
    .eq('user_id', userId);
  if (error) console.error('set grace error:', error);
}

/// Marca/desmarca la cancelación programada sin tocar el plan.
async function setCancelAtPeriodEnd(userId: string, value: boolean): Promise<void> {
  const { error } = await supabase
    .from('user_subscriptions')
    .update({
      cancel_at_period_end: value,
      updated_at: new Date().toISOString(),
    })
    .eq('user_id', userId);
  if (error) console.error('set cancel_at_period_end error:', error);
}

Deno.serve(async (req: Request) => {
  if (req.method === 'GET') {
    return json({ received: true }); // RevenueCat valida el endpoint con GET.
  }
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  // Validación de firma: Authorization Bearer == REVENUECAT_AUTH_TOKEN.
  const auth = req.headers.get('authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
  if (!token || token !== authToken) {
    return json({ error: 'Unauthorized' }, 401);
  }

  let event: any;
  try {
    event = await req.json();
  } catch {
    return json({ error: 'Invalid JSON' }, 400);
  }

  try {
    const type = String(event['type'] ?? '');
    const appUserId = event['app_user_id']
      ? String(event['app_user_id'])
      : event['aliases']?.[0];
    const productId = event['product_id'] ? String(event['product_id']) : '';
    const entitlementIds = event['entitlement_ids'] as string[] | undefined;

    if (!appUserId || appUserId.startsWith('$')) {
      return json({ received: true, ignored: 'no app user' });
    }

    // Issue #71: idempotencia. RevenueCat reintenta; un RENEWAL repetido no
    // debe volver a reponer el maná.
    const eventId = event['id']
      ? String(event['id'])
      : `${type}:${appUserId}:${event['event_timestamp_ms'] ?? ''}`;
    const { data: seen } = await supabase
      .from('revenuecat_events')
      .select('id')
      .eq('id', eventId)
      .maybeSingle();
    if (seen) {
      return json({ received: true, duplicate: true, event_id: eventId });
    }

    const expiresAt = event['expiration_at_ms']
      ? new Date(Number(event['expiration_at_ms'])).toISOString()
      : undefined;
    const grantsPro = (entitlementIds ?? []).includes(PRO_ENTITLEMENT);

    let handled = true;

    switch (type) {
      // Compra, renovación, cambio de producto y reactivación.
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
      case 'PRODUCT_CHANGE':
      case 'UNCANCELLATION':
      case 'SUBSCRIPTION_EXTENDED':
        if (grantsPro) {
          await applyEntitlement({
            userId: appUserId,
            productId,
            expiresAt,
            active: true,
          });
        }
        await setCancelAtPeriodEnd(appUserId, false);
        break;

      // Cambio de titular: se revoca al origen y se concede al destino.
      case 'TRANSFER': {
        const from = (event['transferred_from'] ?? []) as string[];
        for (const oldUserId of from) {
          if (!oldUserId || oldUserId.startsWith('$')) continue;
          await applyEntitlement({
            userId: oldUserId,
            productId: '',
            active: false,
          });
        }
        if (grantsPro) {
          await applyEntitlement({
            userId: appUserId,
            productId,
            expiresAt,
            active: true,
          });
        }
        break;
      }

      // El usuario desactiva la renovación: conserva el acceso hasta expirar.
      case 'CANCELLATION':
        await setCancelAtPeriodEnd(appUserId, true);
        break;

      // Fin real del acceso (o reembolso).
      case 'EXPIRATION':
      case 'REFUND':
        if (type === 'REFUND' || grantsPro) {
          await applyEntitlement({
            userId: appUserId,
            productId: '',
            active: false,
          });
        }
        break;

      // Play reintenta el cobro: periodo de gracia, sin cortar el acceso.
      case 'BILLING_ISSUE':
        await setGrace(appUserId);
        break;

      default:
        handled = false;
    }

    // Registrar el evento procesado (idempotencia para reintentos).
    const { error: logErr } = await supabase
      .from('revenuecat_events')
      .upsert(
        { id: eventId, type, app_user_id: appUserId },
        { onConflict: 'id', ignoreDuplicates: true },
      );
    if (logErr) console.error('revenuecat_events insert error:', logErr);

    return json({ received: true, handled, type, event_id: eventId });
  } catch (e) {
    console.error('revenuecat-webhook processing error:', e);
    return json({ received: true, error: String(e) }, 200);
  }
});
