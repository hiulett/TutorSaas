// sync-entitlement — Reconcilia RevenueCat con `user_subscriptions`.
//
// Issue #69: el webhook es la única vía por la que Supabase se entera de una
// compra. Si falla, el plan no se aplica nunca. Esta función la invoca la app al
// iniciar sesión y tras volver de una compra; consulta RevenueCat y aplica el
// estado real.
//
// #412: migrada a la API **v2**. Las claves nuevas `sk_` son incompatibles con
// v1 (código 7723), y la función usaba `/v1/subscribers/...`, así que devolvía
// 403 siempre. La v2 expone lo mismo vía customers + active_entitlements.
//
// Requiere el secreto REVENUECAT_SECRET_KEY (clave secreta `sk_` del proyecto).
// Si no está configurado responde 503 y la app sigue funcionando con el estado
// que ya tenga la base de datos.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const rcSecret = Deno.env.get('REVENUECAT_SECRET_KEY') ?? '';

const PROJECT_ID = 'proj845df8cf';
const RC_BASE = `https://api.revenuecat.com/v2/projects/${PROJECT_ID}`;
const PRO_ENTITLEMENT = 'DungeonsSpeak Pro';
const PRO_ENTITLEMENT_ID = 'entlcaad641edd';

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

function rcGet(path: string): Promise<Response> {
  return fetch(`${RC_BASE}${path}`, {
    headers: {
      'Authorization': `Bearer ${rcSecret}`,
      'Accept': 'application/json',
    },
  });
}

// El id de producto es la fuente canónica del plan.
function planIdForProduct(productId: string): string {
  const key = productId.toLowerCase();
  if (key.includes('divino') || key.includes('divine')) return 'divino';
  if (key.includes('realeza') || key.includes('royalty')) return 'realeza';
  return 'noble';
}

/// v2 devuelve ids internos (`prod...`); el plan se decide por el
/// `store_identifier`. Se cachea por instancia para no pedirlo en cada llamada.
let productMapPromise: Promise<Map<string, string>> | null = null;
function loadProductMap(): Promise<Map<string, string>> {
  if (!productMapPromise) {
    productMapPromise = (async () => {
      const map = new Map<string, string>();
      try {
        const res = await rcGet('/products?limit=100');
        if (!res.ok) return map;
        const data = await res.json();
        for (const product of data?.items ?? []) {
          if (product?.id && product?.store_identifier) {
            map.set(String(product.id), String(product.store_identifier));
          }
        }
      } catch (e) {
        console.error('revenuecat products error:', e);
      }
      return map;
    })();
  }
  return productMapPromise;
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
      {
        error: 'not_configured',
        detail: 'Falta el secreto REVENUECAT_SECRET_KEY',
      },
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

  const deactivate = async (reason: string) => {
    const { error } = await admin.rpc('sync_entitlement', {
      p_user_id: user.id,
      p_plan_id: 'plebeyo',
      p_is_active: false,
    });
    if (error) return json({ error: 'db_error', detail: error.message }, 500);
    return json({ synced: true, active: false, reason });
  };

  // ── 1. ¿Existe el cliente? ────────────────────────────────────────────────
  let customerRes: Response;
  try {
    customerRes = await rcGet(`/customers/${encodeURIComponent(user.id)}`);
  } catch (e) {
    console.error('revenuecat fetch error:', e);
    return json({ error: 'revenuecat_unreachable' }, 502);
  }

  if (customerRes.status === 404) return deactivate('customer_not_found');

  if (!customerRes.ok) {
    const rcStatus = customerRes.status;
    const body = (await customerRes.text()).slice(0, 200);
    if (rcStatus === 401 || rcStatus === 403) {
      console.error('revenuecat_unauthorized', rcStatus, body);
      return json({ error: 'revenuecat_unauthorized', status: rcStatus }, 403);
    }
    console.error('revenuecat_error', rcStatus, body);
    return json({ error: 'revenuecat_error', status: rcStatus }, 502);
  }

  // ── 2. Entitlements activos ───────────────────────────────────────────────
  const entRes = await rcGet(
    `/customers/${encodeURIComponent(user.id)}/active_entitlements`,
  );
  if (!entRes.ok) {
    const body = (await entRes.text()).slice(0, 200);
    console.error('revenuecat entitlements error', entRes.status, body);
    return json({ error: 'revenuecat_error', status: entRes.status }, 502);
  }

  const entPayload = await entRes.json();
  const entitlements: Array<Record<string, unknown>> =
    entPayload?.items ?? [];
  const activeEnt = entitlements.find(
    (item) =>
      String(item?.entitlement_id ?? '') === PRO_ENTITLEMENT_ID ||
      String(item?.lookup_key ?? '') === PRO_ENTITLEMENT,
  ) ?? entitlements[0];

  if (!activeEnt) return deactivate('no_entitlement');

  const expiresMs = Number(activeEnt?.expires_at ?? 0);
  const expires = expiresMs > 0 ? new Date(expiresMs) : null;
  const active = !expires || expires.getTime() > Date.now();

  // ── 3. Producto para decidir el plan ──────────────────────────────────────
  const productMap = await loadProductMap();
  let productIdentifier = '';
  try {
    const subsRes = await rcGet(
      `/customers/${encodeURIComponent(user.id)}/subscriptions`,
    );
    if (subsRes.ok) {
      const subsPayload = await subsRes.json();
      const subs: Array<Record<string, unknown>> = subsPayload?.items ?? [];
      const withAccess = subs.find((s) => s?.gives_access === true) ?? subs[0];
      const internalId = String(withAccess?.product_id ?? '');
      productIdentifier =
        productMap.get(internalId) ?? internalId;
    }
  } catch (e) {
    console.error('revenuecat subscriptions error:', e);
  }

  const planId = planIdForProduct(productIdentifier || 'noble');

  const { error } = await admin.rpc('sync_entitlement', {
    p_user_id: user.id,
    p_plan_id: planId,
    p_product_id: productIdentifier || null,
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
    product_id: productIdentifier,
    expires_at: expires?.toISOString() ?? null,
  });
});
