-- ═══════════════════════════════════════════════════════════════════════════
-- 01_unique_user_subscriptions.sql
-- CRÍTICO: el webhook revenuecat-webhook hace
--   .upsert({...}, { onConflict: 'user_id' })
-- y eso REQUIERE un constraint UNIQUE en user_subscriptions.user_id.
-- Sin esto, la activación del plan falla silenciosamente.
-- ═══════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'user_subscriptions_user_id_key'
      AND conrelid = 'public.user_subscriptions'::regclass
  ) THEN
    ALTER TABLE public.user_subscriptions
      ADD CONSTRAINT user_subscriptions_user_id_key UNIQUE (user_id);
    RAISE NOTICE 'Constraint UNIQUE(user_id) creado en user_subscriptions.';
  ELSE
    RAISE NOTICE 'Constraint UNIQUE(user_id) ya existe.';
  END IF;
END $$;
