// sync-entitlement — Reconcilia RevenueCat con `user_subscriptions`.
//
// Issue #69: el webhook es la única vía por la que Supabase se enteraba de una
// compra. Si fallaba (como ocurrió: apuntaba a la app equivocada), el plan no
// se aplicaba nunca. Esta función la invoca la app al iniciar sesión y tras
// volver de una compra; consulta RevenueCat y aplica el estado real.
//
// Requiere el secreto REVENUECAT_SECRET_KEY (API key v1, empieza por `sk_`).
// Si no está configurado responde 503 y la app sigue funcionando con el estado
// que ya tenga en la base de datos.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const rcSecret = Deno.env.get('REVENUECAT_SECRET_KEY') ?? '';
const PRO_ENTITLEMENT = 'DungeonsSpeak Pro';

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

// Mismo mapeo que el webhook: el id de producto es la fuente canónica.
function planIdForProduct(productId: string): string {
  const key = productId.toLowerCase();
  if (key.includes('divino') || key.includes('divine')) return 'divino';
  if (key.includes('realeza') || key.includes('royalty')) return 'realeza';
  return 'noble';
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
      },
    });
  }
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  if (!rcSecret) {
    return json(
      { error: 'not_configured', detail: 'Falta el secreto REVENUECAT_SECRET_KEY' },
      503,
    );
  }

  const auth = req.headers.get('Authorization') ?? '';
  const jwt = auth.replace(/^Bearer\s+/i, '');
  if (!jwt) return json({ error: 'Unauthorized' }, 401);

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });

  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  const user = userData?.user;
  if (userErr || !user) return json({ error: 'Unauthorized' }, 401);

  let rcRes: Response;
  try {
    rcRes = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(user.id)}`,
      {
        headers: {
          'Authorization': `Bearer ${rcSecret}`,
          'Content-Type': 'application/json',
        },
      },
    );
  } catch (e) {
    console.error('revenuecat fetch error:', e);
    return json({ error: 'revenuecat_unreachable' }, 502);
  }

  if (rcRes.status === 404) {
    // RevenueCat no conoce al usuario: no hay compras.
    const { error } = await admin.rpc('sync_entitlement', {
      p_user_id: user.id,
      p_plan_id: 'plebeyo',
      p_is_active: false,
    });
    if (error) return json({ error: 'db_error', detail: error.message }, 500);
    return json({ synced: true, active: false });
  }
  if (!rcRes.ok) {
    console.error('revenuecat status', rcRes.status, await rcRes.text());
    return json({ error: 'revenuecat_error', status: rcRes.status }, 502);
  }

  const payload = await rcRes.json();
  const entitlement = payload?.subscriber?.entitlements?.[PRO_ENTITLEMENT];

  if (!entitlement) {
    const { error } = await admin.rpc('sync_entitlement', {
      p_user_id: user.id,
      p_plan_id: 'plebeyo',
      p_is_active: false,
    });
    if (error) return json({ error: 'db_error', detail: error.message }, 500);
    return json({ synced: true, active: false });
  }

  const expires = entitlement.expires_date ? new Date(entitlement.expires_date) : null;
  const active = !expires || expires.getTime() > Date.now();
  const productId = String(entitlement.product_identifier ?? '');
  const planId = planIdForProduct(productId);

  const { error } = await admin.rpc('sync_entitlement', {
    p_user_id: user.id,
    p_plan_id: planId,
    p_product_id: productId,
    p_expires_at: expires ? expires.toISOString() : null,
    p_store: 'play',
    p_is_active: active,
  });
  if (error) {
    console.error('sync_entitlement rpc error:', error);
    return json({ error: 'db_error', detail: error.message }, 500);
  }

  return json({
    synced: true,
    active,
    plan: planId,
    expires_at: expires?.toISOString() ?? null,
  });
});
