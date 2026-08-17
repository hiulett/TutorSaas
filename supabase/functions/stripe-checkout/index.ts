// stripe-checkout — Crea una sesión de Checkout de Stripe.
//
// Tipos soportados:
//   { type: 'potion',   product_id }  -> Porción de Maná (pago único)
//   { type: 'gem_pack', product_id }  -> Pack de Gemas de Maná (pago único)
//   { type: 'subscription', plan_id } -> Estamento (suscripción recurrente)
//
// El cliente móvil envía su JWT (Authorization Bearer). La función valida el
// usuario y devuelve { url } con la URL de Checkout.
//
// Secretos requeridos (supabase secrets set ...):
//   STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, SUPABASE_URL,
//   SUPABASE_SERVICE_ROLE_KEY, PUBLIC_APP_URL
import Stripe from 'npm:stripe@17';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const appUrl = Deno.env.get('PUBLIC_APP_URL') ?? 'https://yourdomain.com';

const stripe = new Stripe(stripeSecretKey);
const supabase = createClient(supabaseUrl, supabaseAnonKey);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

function readJwt(req: Request): string {
  const auth = req.headers.get('authorization') ?? '';
  const bearer = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
  if (!bearer || bearer === supabaseAnonKey) return '';
  return bearer;
}

async function requireUser(req: Request): Promise<string | null> {
  try {
    const token = readJwt(req);
    if (!token) return null;
    const { data, error } = await supabase.auth.getUser(token);
    return !error && data.user ? data.user.id : null;
  } catch {
    return null;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return json({ ok: true });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const userId = await requireUser(req);
  if (!userId) return json({ error: 'Unauthorized' }, 401);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Invalid JSON' }, 400);
  }

  const type = String(body['type'] ?? '');
  const productId = body['product_id'] ? String(body['product_id']) : null;
  const planId = body['plan_id'] ? String(body['plan_id']) : null;

  const successUrl = `${appUrl}/checkout-success`;
  const cancelUrl = `${appUrl}/checkout-cancel`;

  try {
    // ── Pago único de Maná (porción o pack) ────────────────────────────────
    if (type === 'potion' || type === 'gem_pack') {
      const table = type === 'potion' ? 'mana_potions' : 'mana_gems';
      if (!productId) return json({ error: 'product_id requerido' }, 400);

      const { data: product, error: pErr } = await supabase
        .from(table)
        .select('id, name, mana_amount, price_usd')
        .eq('id', productId)
        .eq('is_active', true)
        .maybeSingle();
      if (pErr || !product) return json({ error: 'Producto no encontrado' }, 404);

      const manaAmount = Number(product['mana_amount'] ?? 0);
      const priceUsd = Number(product['price_usd'] ?? 0);
      if (manaAmount <= 0 || priceUsd <= 0) return json({ error: 'Producto sin precio' }, 400);

      const session = await stripe.checkout.sessions.create({
        mode: 'payment',
        client_reference_id: userId,
        metadata: { user_id: userId, type, product_id: productId, mana_amount: String(manaAmount) },
        line_items: [{
          quantity: 1,
          price_data: {
            currency: 'usd',
            product_data: { name: String(product['name'] ?? 'Maná') },
            unit_amount: Math.round(priceUsd * 100),
          },
        }],
        success_url: successUrl,
        cancel_url: cancelUrl,
      });

      return json({ url: session.url });
    }

    // ── Suscripción (estamento) ────────────────────────────────────────────
    if (type === 'subscription') {
      if (!planId) return json({ error: 'plan_id requerido' }, 400);
      const billingCycle = body['billing_cycle'] === 'annual' ? 'annual' : 'monthly';

      const { data: plan, error: planErr } = await supabase
        .from('subscription_plans')
        .select('id, name, stripe_price_id, stripe_price_annual_id')
        .eq('id', planId)
        .eq('is_active', true)
        .maybeSingle();
      if (planErr || !plan) return json({ error: 'Plan no encontrado' }, 404);

      const priceId = billingCycle === 'annual'
        ? String(plan['stripe_price_annual_id'] ?? '')
        : String(plan['stripe_price_id'] ?? '');
      if (!priceId) {
        return json({ error: 'Plan sin Price de Stripe configurado para ese ciclo' }, 400);
      }

      const session = await stripe.checkout.sessions.create({
        mode: 'subscription',
        client_reference_id: userId,
        metadata: { user_id: userId, type: 'subscription', plan_id: planId, billing_cycle: billingCycle },
        line_items: [{ price: priceId, quantity: 1 }],
        success_url: successUrl,
        cancel_url: cancelUrl,
      });

      return json({ url: session.url });
    }

    return json({ error: 'Tipo no soportado' }, 400);
  } catch (e) {
    console.error('stripe-checkout error:', e);
    return json({ error: 'Error creando el checkout' }, 500);
  }
});
