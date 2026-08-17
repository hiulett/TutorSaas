-- ============================================================================
-- TutorSaas — FASE D: Pagos reales (Stripe)
-- Proyecto: sipiumfdpvnszthykyog
-- Fecha: 2026-08-13
--
-- Habilita el checkout de Stripe para Porciones/Gemas de Maná (pago único) y
-- los estamentos (suscripción). Las RPC grant_mana / renew_mana_cycle (Fase A)
-- ya existen; aquí se añade la configuración de Stripe y la idempotencia.
--
-- ⚠️ Aplicar desde el SQL Editor (la DB live es de solo lectura vía API).
-- ============================================================================

BEGIN;

-- Precio de Stripe por plan (suscripción). Se configura desde web_admin.
ALTER TABLE public.subscription_plans
    ADD COLUMN IF NOT EXISTS stripe_price_id TEXT;

COMMENT ON COLUMN public.subscription_plans.stripe_price_id IS
  'ID del Price de Stripe para la suscripción (mode=subscription). Null = aún no configurado.';

-- IDs de Stripe por suscripción del usuario.
ALTER TABLE public.user_subscriptions
    ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
    ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT;

-- Idempotencia del webhook (un event.id se procesa una sola vez).
CREATE TABLE IF NOT EXISTS public.stripe_events (
    event_id    TEXT PRIMARY KEY,
    event_type  TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Solo service_role (edge functions) escribe en stripe_events.
REVOKE ALL ON public.stripe_events FROM PUBLIC, anon, authenticated;

COMMIT;

-- VERIFICACIÓN:
-- SELECT column_name FROM information_schema.columns
--   WHERE table_schema='public' AND table_name='subscription_plans'
--     AND column_name IN ('stripe_price_id');
-- SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename='stripe_events';
