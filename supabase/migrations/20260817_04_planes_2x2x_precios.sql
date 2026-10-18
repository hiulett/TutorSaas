-- ═══════════════════════════════════════════════════════════════════════════
-- 04_planes_2x2x_precios.sql
-- Actualiza la estructura de planes al modelo 3 estamentos × 2 ciclos:
--   NOBLE  (PLUS)  $4.99 / $39.99  · 24,000 maná
--   REALEZA (PRO)  $9.99 / $79.99  · 60,000 maná
--   DIVINO (MAX)  $12.99 / $99.99  · 84,000 maná
-- Ejecutar en Supabase Dashboard → SQL Editor (idempotente).
-- ═══════════════════════════════════════════════════════════════════════════

-- 1) Actualizar NOBLE
UPDATE public.subscription_plans SET
  price          = '$4.99',
  price_annual   = '$39.99',
  mana_allowance = 24000,
  class_name     = 'noble',
  order_index    = 1,
  updated_at     = now()
WHERE id = 'noble';

-- 2) Actualizar REALEZA (baja de $14.99 a $9.99)
UPDATE public.subscription_plans SET
  price          = '$9.99',
  price_annual   = '$79.99',
  mana_allowance = 60000,
  class_name     = 'realeza',
  order_index    = 2,
  updated_at     = now()
WHERE id = 'realeza';

-- 3) Crear DIVINO (nuevo estamento superior)
INSERT INTO public.subscription_plans (
  id, name, price, price_annual, billing_cycle, monthly_audio_minutes_limit,
  description, badge_tag, features, is_active, order_index, class_name,
  mana_allowance, created_at, updated_at
) VALUES (
  'divino', 'DIVINO', '$12.99', '$99.99', 'monthly', 2000,
  'Estamento supremo: 84,000 maná por ciclo. Títulos de élite, prioridad total y acceso anticipado.',
  'MAX', '["84,000 maná por ciclo", "Títulos de rango hasta SSS", "Salas de voz con prioridad", "Misiones premium e incursión semanal"]'::jsonb,
  true, 3, 'divino', 84000, now(), now()
)
ON CONFLICT (id) DO UPDATE SET
  price          = EXCLUDED.price,
  price_annual   = EXCLUDED.price_annual,
  mana_allowance = EXCLUDED.mana_allowance,
  class_name     = EXCLUDED.class_name,
  order_index    = EXCLUDED.order_index,
  is_active      = true,
  updated_at     = now();

-- 4) Verificación
SELECT id, name, price, price_annual, mana_allowance, class_name, order_index
FROM public.subscription_plans
WHERE id IN ('noble','realeza','divino')
ORDER BY order_index;
