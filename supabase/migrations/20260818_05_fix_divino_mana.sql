-- ═══════════════════════════════════════════════════════════════════════════
-- 20260818_05_fix_divino_mana.sql
-- CORRECCIÓN: `divino` (MAX) quedó con mana_allowance = 120000; el valor
-- correcto del modelo es **25,500** (ritmo de 4 meses para completar el
-- currículo de ~102,300 maná).
--
-- Ejecutar en Supabase Dashboard → SQL Editor (idempotente).
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE public.subscription_plans SET
  mana_allowance = 25500,
  updated_at     = now()
WHERE id = 'divino';

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
SELECT id, name, price, price_annual, mana_allowance, class_name, order_index
FROM public.subscription_plans
WHERE id IN ('plebeyo','noble','realeza','divino')
ORDER BY order_index;
