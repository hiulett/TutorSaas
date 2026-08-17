-- ═══════════════════════════════════════════════════════════════════════════
-- 02_planes_activos.sql
-- Asegura que los planes que el webhook activa (noble/realeza) estén activos
-- con su mana_allowance correcto. Idempotente: se puede ejecutar varias veces.
-- El webhook mapea product_id → plan:
--   dungeonsspeak_lifetime → realeza (o noble si no contiene 'lifetime'/'royalty')
--   dungeonsspeak_yearly   → noble (default)
--   dungeonsspeak_monthly  → noble (default)
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE public.subscription_plans SET
  is_active     = true,
  mana_allowance = 18000,
  class_name    = 'noble',
  order_index   = 1,
  updated_at    = now()
WHERE id = 'noble';

UPDATE public.subscription_plans SET
  is_active     = true,
  mana_allowance = 72000,
  class_name    = 'realeza',
  order_index   = 2,
  updated_at    = now()
WHERE id = 'realeza';

-- Verificación
SELECT id, name, price, is_active, class_name, mana_allowance, order_index
FROM public.subscription_plans
WHERE id IN ('noble','realeza')
ORDER BY order_index;
