-- ============================================================================
-- TutorSaas — FASE D2: Planes coherentes (3 tiers, ciclo por compra)
-- Proyecto: sipiumfdpvnszthykyog
-- Fecha: 2026-08-13
--
-- MODELO: 3 planes (tiers) identificados por su estamento. Cada tier de pago
-- puede facturarse MENSUAL o ANUAL (el ciclo se elige al comprar; Stripe tiene
-- 2 precios por plan). El tier define el maná mensual.
--
--   id       nombre   maná/mes   mensual    anual
--   plebeyo  PLEBEYO  1 800      $0.00      —
--   noble    NOBLE    18 000     $4.99      $49.99
--   realeza  REALEZA  72 000     $14.99     $149.99
--
-- ⚠️ Aplicar desde el SQL Editor (la DB live es de solo lectura vía API).
-- ============================================================================

BEGIN;

-- 1. Precio anual + id del Price anual (el mensual son `price`/`stripe_price_id`).
ALTER TABLE public.subscription_plans
    ADD COLUMN IF NOT EXISTS price_annual           TEXT,
    ADD COLUMN IF NOT EXISTS stripe_price_annual_id TEXT;

COMMENT ON COLUMN public.subscription_plans.price_annual IS
  'Precio anual (pago único por 12 meses). NULL si el plan solo es mensual/gratis.';
COMMENT ON COLUMN public.subscription_plans.stripe_price_annual_id IS
  'ID del Price recurrente anual en Stripe.';

-- Ciclo elegido por el usuario (lo escribe el webhook de Stripe).
ALTER TABLE public.user_subscriptions
    ADD COLUMN IF NOT EXISTS billing_cycle TEXT NOT NULL DEFAULT 'monthly';

-- 2. Tiers con ids coherentes al estamento.
INSERT INTO public.subscription_plans
    (id, name, price, billing_cycle, monthly_audio_minutes_limit, description,
     badge_tag, features, is_active, order_index, class_name, mana_allowance,
     stripe_price_id, price_annual, stripe_price_annual_id)
VALUES
    ('plebeyo', 'PLEBEYO', '$0.00', 'monthly', 30,
     'Estamento gratuito: cortesía mensual de maná.',
     NULL, '[]'::jsonb, true, 1, 'plebeyo', 1800, NULL, NULL, NULL),
    ('noble', 'NOBLE', '$4.99', 'monthly', 300,
     'Estamento noble: 18,000 maná al mes. Mensual o anual.',
     'PREMIUM 1',
     '["18,000 maná/mes (300 min de IA)","Techo de prestigio: Gran Duque"]'::jsonb,
     true, 2, 'noble', 18000, NULL, '$49.99', NULL),
    ('realeza', 'REALEZA', '$14.99', 'monthly', 1200,
     'Estamento real: 72,000 maná al mes. Mensual o anual.',
     'PREMIUM 2',
     '["72,000 maná/mes (1,200 min de IA)","Techo de prestigio: Emperador + Legendario"]'::jsonb,
     true, 3, 'realeza', 72000, NULL, '$149.99', NULL)
ON CONFLICT (id) DO NOTHING;

-- 3. Migrar suscripciones existentes a los ids nuevos.
UPDATE public.user_subscriptions SET plan_id = 'plebeyo'  WHERE plan_id = 'free';
UPDATE public.user_subscriptions SET plan_id = 'noble'    WHERE plan_id = 'monthly';
UPDATE public.user_subscriptions SET plan_id = 'realeza'  WHERE plan_id = 'annual';
UPDATE public.user_subscriptions SET plan_id = 'realeza'  WHERE plan_id = 'lifetime';
UPDATE public.user_subscriptions SET plan_id = NULL       WHERE plan_id = 'premium';

-- 4. Desactivar los planes viejos (incluido lifetime).
UPDATE public.subscription_plans SET is_active = false
    WHERE id IN ('free','monthly','annual','lifetime');

COMMIT;

-- VERIFICACIÓN:
-- SELECT id, name, class_name, price, price_annual, monthly_audio_minutes_limit, mana_allowance, is_active
--   FROM public.subscription_plans ORDER BY order_index;
-- SELECT user_id, plan_id, billing_cycle, status FROM public.user_subscriptions;
