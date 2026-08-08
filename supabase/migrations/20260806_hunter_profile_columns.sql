-- ============================================================================
-- TutorSaas — Hunter Profile: columnas de stats/bio en users
-- Fecha: 2026-08-06
--
-- Añade las columnas que el HunterStatusScreen lee/escribe via
-- userProfileProvider / updateUserProfile. Sin estas columnas, el guardado
-- fallaba silenciosamente (PostgREST 400) y los stats siempre volvían a base 5.
-- equipped_title_code se mantiene en user_language_profiles (fuente canónica).
-- Idempotente.
-- ============================================================================

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS bio TEXT,
  ADD COLUMN IF NOT EXISTS str_stat INTEGER NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS int_stat INTEGER NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS dex_stat INTEGER NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS luk_stat INTEGER NOT NULL DEFAULT 5;
