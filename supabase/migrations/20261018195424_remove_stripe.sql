-- Issue #70: retirada completa de Stripe.
--
-- Verificado antes de borrar: las cuatro columnas estaban al 100 % en NULL
-- (0 de 11 suscripciones, 0 de 8 planes) y `stripe_events` solo la usaba la
-- Edge Function `stripe-webhook`, que nunca se desplegó.

alter table public.user_subscriptions
  drop column if exists stripe_subscription_id,
  drop column if exists stripe_customer_id;

alter table public.subscription_plans
  drop column if exists stripe_price_id,
  drop column if exists stripe_price_annual_id;

drop table if exists public.stripe_events;
