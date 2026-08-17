// stripe-webhook — Procesa eventos de Stripe de forma segura.
//
//   checkout.session.completed:
//     - type potion/gem_pack  -> grant_mana(user, mana_amount, type)  [maná]
//     - type subscription     -> activa el plan + renew_mana_cycle
//   customer.subscription.updated/deleted -> sincroniza el estado
//
// Idempotencia: cada event.id se registra en `stripe_events`; si ya existe,
// el evento no se vuelve a procesar.
//
// Secretos: STRIPE_WEBHOOK_SECRET, STRIPE_SECRET_KEY, SUPABASE_URL,
//           SUPABASE_SERVICE_ROLE_KEY, PUBLIC_APP_URL
import Stripe from 'npm:stripe@17';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? '';
const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const stripe = new Stripe(stripeSecretKey);
const supabase = createClient(supabaseUrl, serviceKey, {
  auth: { persistSession: false },
});

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

/** Registra el evento y devuelve true si es la primera vez que se procesa. */
async function isNewEvent(eventId: string, eventType: string): Promise<boolean> {
  const { data } = await supabase
    .from('stripe_events')
    .insert({ event_id: eventId, event_type: eventType })
    .onConflict('event_id')
    .select('event_id')
    .maybeSingle();
  return !!data;
}

/** Acredita maná (porción / pack). La idempotencia global la cubre stripe_events. */
async function grantMana(userId: string, manaAmount: number, source: string): Promise<boolean> {
  const { error } = await supabase.rpc('grant_mana', {
    p_user_id: userId,
    p_amount: manaAmount,
    p_source: source,
  });
  if (error) {
    console.error('grant_mana error:', error);
    return false;
  }
  return true;
}

async function activateSubscription(
  userId: string,
  planId: string,
  subscriptionId: string,
  metaBillingCycle?: string,
): Promise<boolean> {
  const { data: plan } = await supabase
    .from('subscription_plans')
    .select('id, mana_allowance')
    .eq('id', planId)
    .maybeSingle();
  if (!plan) return false;

  const allowance = Number(plan['mana_allowance'] ?? 1800);

  // Ciclo REAL desde el intervalo del Price de Stripe (autoritativo).
  let billingCycle = 'monthly';
  try {
    const sub = await stripe.subscriptions.retrieve(subscriptionId);
    const interval = sub.items?.data?.[0]?.price?.recurring?.interval;
    if (interval === 'year') billingCycle = 'annual';
  } catch (_) {
    if (metaBillingCycle === 'annual') billingCycle = 'annual';
  }

  const now = new Date();
  const expires = new Date(now);
  if (billingCycle === 'annual') expires.setFullYear(expires.getFullYear() + 1);
  else expires.setMonth(expires.getMonth() + 1);

  const { error } = await supabase.rpc('renew_mana_cycle', {
    p_user_id: userId,
    p_allowance: allowance,
    p_expires_at: expires.toISOString(),
  });
  if (error) {
    console.error('renew_mana_cycle error:', error);
    return false;
  }

  const { error: upErr } = await supabase
    .from('user_subscriptions')
    .upsert({
      user_id: userId,
      plan_id: planId,
      status: 'active',
      billing_cycle: billingCycle,
      stripe_subscription_id: subscriptionId,
      updated_at: new Date().toISOString(),
    }, { onConflict: 'user_id' });
  if (upErr) console.error('upsert subscription error:', upErr);
  return true;
}

Deno.serve(async (req: Request) => {
  const signature = req.headers.get('stripe-signature') ?? '';
  const rawBody = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(rawBody, signature, webhookSecret);
  } catch (err) {
    console.error('stripe-webhook signature error:', err);
    return json({ error: 'Invalid signature' }, 400);
  }

  // Idempotencia global por event.id.
  if (!(await isNewEvent(event.id, event.type))) {
    return json({ received: true, duplicate: true });
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        const meta = (session.metadata ?? {}) as Record<string, string>;
        const userId = meta['user_id'] ?? session.client_reference_id ?? '';
        if (!userId) break;

        if (meta['type'] === 'subscription') {
          const planId = meta['plan_id'] ?? '';
          const subId = typeof session.subscription === 'string' ? session.subscription : '';
          await activateSubscription(userId, planId, subId, meta['billing_cycle']);
        } else if (meta['type'] === 'potion' || meta['type'] === 'gem_pack') {
          const mana = Number(meta['mana_amount'] ?? 0);
          await grantMana(userId, mana, meta['type']);
        }
        break;
      }
      case 'customer.subscription.updated':
      case 'customer.subscription.deleted': {
        const sub = event.data.object as Stripe.Subscription;
        const status = sub.status; // active | canceled | unpaid | ...
        const interval = sub.items?.data?.[0]?.price?.recurring?.interval;
        const billingCycle = interval === 'year' ? 'annual' : 'monthly';
        await supabase
          .from('user_subscriptions')
          .update({ status, billing_cycle: billingCycle, updated_at: new Date().toISOString() })
          .eq('stripe_subscription_id', sub.id);
        break;
      }
      default:
        break;
    }
  } catch (e) {
    console.error('stripe-webhook processing error:', e);
    return json({ received: true, error: String(e) }, 200);
  }

  return json({ received: true });
});
