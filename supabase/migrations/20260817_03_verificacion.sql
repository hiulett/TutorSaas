-- ═══════════════════════════════════════════════════════════════════════════
-- 03_verificacion.sql
-- Verificación end-to-end del flujo RevenueCat → webhook → Supabase.
-- Ejecuta este script DESPUÉS de los 01 y 02, y tras cada compra sandbox
-- para confirmar que el plan/maná se activaron correctamente.
-- ═══════════════════════════════════════════════════════════════════════════

-- 1) ¿Existen las RPCs que usa el webhook?
SELECT proname AS rpc, pg_get_function_arguments(oid) AS args
FROM pg_proc
WHERE proname IN ('renew_mana_cycle','grant_mana','get_mana_state')
ORDER BY proname;

-- 2) ¿Existe el constraint UNIQUE en user_subscriptions?
SELECT conname, contype
FROM pg_constraint
WHERE conrelid = 'public.user_subscriptions'::regclass
  AND contype = 'u';

-- 3) ¿Están activos los planes que el webhook activa?
SELECT id, name, is_active, mana_allowance
FROM public.subscription_plans
WHERE id IN ('noble','realeza')
ORDER BY order_index;

-- 4) Ultimas suscripciones activadas (tras pruebas)
SELECT user_id, plan_id, status, billing_cycle, period_start, period_end,
       stripe_subscription_id, updated_at
FROM public.user_subscriptions
ORDER BY updated_at DESC
LIMIT 10;
