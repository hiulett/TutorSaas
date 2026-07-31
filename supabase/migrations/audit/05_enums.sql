-- =============================================================
-- MIGRACIÓN 5: ENUMs para estados
-- =============================================================

CREATE TYPE public.conversation_status AS ENUM ('active', 'completed', 'abandoned');
ALTER TABLE public.conversations
  ALTER COLUMN status TYPE public.conversation_status
  USING COALESCE(NULLIF(status, ''), 'active')::public.conversation_status;
ALTER TABLE public.conversations
  ALTER COLUMN status SET DEFAULT 'active';

CREATE TYPE public.payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded', 'cancelled');
ALTER TABLE public.payments
  ALTER COLUMN status TYPE public.payment_status
  USING COALESCE(NULLIF(status, ''), 'pending')::public.payment_status;

CREATE TYPE public.subscription_status AS ENUM ('active', 'cancelled', 'expired', 'trial');
ALTER TABLE public.user_subscriptions
  ALTER COLUMN status TYPE public.subscription_status
  USING COALESCE(NULLIF(status, ''), 'active')::public.subscription_status;
ALTER TABLE public.user_subscriptions
  ALTER COLUMN status SET DEFAULT 'active';

CREATE TYPE public.achievement_condition AS ENUM ('conversations', 'messages', 'streak_days', 'xp_total', 'vocabulary_count', 'minutes_total', 'scenarios_completed', 'perfect_sessions');
ALTER TABLE public.achievements
  ALTER COLUMN condition_type TYPE public.achievement_condition
  USING condition_type::public.achievement_condition;

SELECT 'Migración 5 completada' AS result;
