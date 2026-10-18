-- ═══════════════════════════════════════════════════════════════════════════
-- 20260818_04_fix_check_divino.sql
-- CORRECCIÓN: el CHECK constraint `subscription_plans_class_name_check` solo
-- permitía 'plebeyo'/'noble'/'realeza' y bloqueaba el INSERT de DIVINO.
--
-- Ejecutar en Supabase Dashboard → SQL Editor (idempotente).
-- ═══════════════════════════════════════════════════════════════════════════

-- 1) Reemplazar el constraint para permitir 'divino'.
ALTER TABLE public.subscription_plans
  DROP CONSTRAINT IF EXISTS subscription_plans_class_name_check;

ALTER TABLE public.subscription_plans
  ADD CONSTRAINT subscription_plans_class_name_check
  CHECK (class_name = ANY (ARRAY['plebeyo','noble','realeza','divino']));

-- 2) Aplicar los planes con los valores finales (modelo 3×2, 4/5/6 meses).
UPDATE public.subscription_plans SET
  price          = '$4.99',
  price_annual   = '$53.99',
  mana_allowance = 17000,
  class_name     = 'noble',
  order_index    = 1,
  is_active      = true,
  updated_at     = now()
WHERE id = 'noble';

UPDATE public.subscription_plans SET
  price          = '$9.99',
  price_annual   = '$107.99',
  mana_allowance = 20500,
  class_name     = 'realeza',
  order_index    = 2,
  is_active      = true,
  updated_at     = now()
WHERE id = 'realeza';

UPDATE public.subscription_plans SET
  mana_allowance = 3000,
  order_index    = 0,
  is_active      = true,
  updated_at     = now()
WHERE id = 'plebeyo';

-- 3) DIVINO (MAX): inserta o actualiza a 25,500 maná (NO 120,000).
INSERT INTO public.subscription_plans (
  id, name, price, price_annual, billing_cycle, monthly_audio_minutes_limit,
  description, badge_tag, features, is_active, order_index, class_name,
  mana_allowance, created_at, updated_at
) VALUES (
  'divino', 'DIVINO', '$12.99', '$132.99', 'monthly', 2000,
  'Estamento supremo: 25,500 maná por ciclo. Títulos de élite, prioridad total y acceso anticipado.',
  'MAX', '["25,500 maná por ciclo", "Títulos de rango hasta SSS", "Salas de voz con prioridad", "Misiones premium e incursión semanal"]'::jsonb,
  true, 3, 'divino', 25500, now(), now()
)
ON CONFLICT (id) DO UPDATE SET
  price          = EXCLUDED.price,
  price_annual   = EXCLUDED.price_annual,
  mana_allowance = EXCLUDED.mana_allowance,
  class_name     = EXCLUDED.class_name,
  order_index    = EXCLUDED.order_index,
  is_active      = true,
  updated_at     = now();

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
SELECT id, name, price, price_annual, mana_allowance, class_name, order_index
FROM public.subscription_plans
WHERE id IN ('plebeyo','noble','realeza','divino')
ORDER BY order_index;
