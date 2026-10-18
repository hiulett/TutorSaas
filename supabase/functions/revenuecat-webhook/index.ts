// revenuecat-webhook — Procesa eventos de RevenueCat de forma segura.
//
// RevenueCat envía eventos (INITIAL_PURCHASE, RENEWAL, PRODUCT_CHANGE,
// TRANSFER, UNCANCELLATION, EXPIRATION, CANCELLATION, customer_info.updated)
// con firma `Authorization: Bearer <AUTH_TOKEN>`.
//
// Modelo de producto de la app (DungeonsSpeak) — matriz 2 estamentos × 2 ciclos:
//   - Entitlement: DungeonsSpeak_Pro (el único; el acceso premium).
//   - Products (NO SUBSCRIPTION LIFETIME por el costo de la IA):
//       dungeonsspeak_noble_monthly    -> plan `noble`    · ciclo monthly
//       dungeonsspeak_noble_yearly     -> plan `noble`    · ciclo annual
//       dungeonsspeak_realeza_monthly  -> plan `realeza`  · ciclo monthly
//       dungeonsspeak_realeza_yearly   -> plan `realeza`  · ciclo annual
//
// Al recibir un entitlement Pro activo:
//   - Activa el plan en `user_subscriptions` (columna stripe_subscription_id
//     reutilizada como id de entidad del store).
//   - Llama a `renew_mana_cycle` para renovar el maná (allowance del plan).
//
// Secretos requeridos (supabase secrets set ...):
//   REVENUECAT_AUTH_TOKEN, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
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
// fuente canónica (lo define el id del product en Google Play / App Store).
function planIdForProduct(productId: string): string {
  const key = productId.toLowerCase();
  if (key.includes('divino') || key.includes('divine')) return 'divino';
  if (key.includes('realeza') || key.includes('royalty')) return 'realeza';
  return 'noble'; // incluye dungeonsspeak_noble_* y cualquier default
}

// Ciclo derivado del product_id (anual si contiene 'yearly'/'annual').
function billingCycleForProduct(productId: string): string {
  const key = productId.toLowerCase();
  return key.includes('yearly') || key.includes('annual') ? 'annual' : 'monthly';
}

async function activatePlan(
  userId: string,
  productId: string,
  expiresAt?: string,
): Promise<boolean> {
  const planId = planIdForProduct(productId);
  const billingCycle = billingCycleForProduct(productId);

  const { data: plan } = await supabase
    .from('subscription_plans')
    .select('id, mana_allowance')
    .eq('id', planId)
    .maybeSingle();
  if (!plan) {
    console.error('revenuecat-webhook: plan not found', planId);
    return false;
  }

  const allowance = Number(plan['mana_allowance'] ?? 1800);
  const now = new Date();
  const end = expiresAt ? new Date(expiresAt) : new Date(now);
  if (!expiresAt) end.setMonth(end.getMonth() + (billingCycle === 'annual' ? 12 : 1));

  const { error: manaErr } = await supabase.rpc('renew_mana_cycle', {
    p_user_id: userId,
    p_allowance: allowance,
    p_expires_at: end.toISOString(),
  });
  if (manaErr) {
    console.error('renew_mana_cycle error:', manaErr);
  }

  const { error: upErr } = await supabase
    .from('user_subscriptions')
    .upsert({
      user_id: userId,
      plan_id: planId,
      status: 'active',
      billing_cycle: billingCycle,
      period_start: now.toISOString(),
      period_end: end.toISOString(),
      stripe_subscription_id: productId,
      // Issue #69: estos campos permiten que la sincronización desde la app
      // detecte que el periodo ya está aplicado y no vuelva a dar maná.
      store: 'play',
      rc_product_id: productId,
      rc_expires_at: expiresAt ?? end.toISOString(),
      updated_at: new Date().toISOString(),
    }, { onConflict: 'user_id' });
  if (upErr) {
    console.error('upsert subscription error:', upErr);
    return false;
  }
  return true;
}

async function expirePlan(userId: string): Promise<void> {
  // Issue #66: al expirar hay que bajar el plan a `plebeyo`. Antes solo se
  // cambiaba el status y, como el resto de la app decide por `plan_id`, el
  // usuario conservaba el premium indefinidamente.
  const { error } = await supabase
    .from('user_subscriptions')
    .update({
      plan_id: 'plebeyo',
      status: 'expired',
      billing_cycle: null,
      mana_expires_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('user_id', userId);
  if (error) console.error('expire subscription error:', error);
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

    const grantsPro = (entitlementIds ?? []).includes(PRO_ENTITLEMENT);

    // Eventos de compra/renovación/recuperación del entitlement Pro.
    const purchaseTypes = [
      'INITIAL_PURCHASE',
      'RENEWAL',
      'PRODUCT_CHANGE',
      'TRANSFER',
      'UNCANCELLATION',
      'SUBSCRIPTION_EXTENDED',
      'customer_info.updated',
    ];

    if (purchaseTypes.includes(type) && grantsPro) {
      const expiresAt = event['expiration_at_ms']
        ? new Date(Number(event['expiration_at_ms'])).toISOString()
        : undefined;
      await activatePlan(appUserId, productId, expiresAt);
      return json({ received: true });
    }

    if (type === 'EXPIRATION' && grantsPro) {
      // Expiración real (no renovada) = pierde premium.
      await expirePlan(appUserId);
      return json({ received: true });
    }

    // Issue #66: CANCELLATION solo desactiva la renovación; el acceso se
    // mantiene hasta `expiration_at_ms`. No se toca el plan aquí.
    if (type === 'CANCELLATION' || type === 'UNCANCELLATION') {
      return json({ received: true, deferred: type });
    }

    return json({ received: true, unhandled: type });
  } catch (e) {
    console.error('revenuecat-webhook processing error:', e);
    return json({ received: true, error: String(e) }, 200);
  }
});
