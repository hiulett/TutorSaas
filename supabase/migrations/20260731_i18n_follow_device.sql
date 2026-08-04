-- ============================================================================
-- TutorSaas — i18n: follow_device_language en user_settings
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
-- Pegar en el SQL Editor y ejecutar (idempotente).
-- ============================================================================

-- Si la interfaz debe seguir el idioma del dispositivo (default TRUE)
ALTER TABLE public.user_settings
    ADD COLUMN IF NOT EXISTS follow_device_language BOOLEAN NOT NULL DEFAULT TRUE;

-- Garantizar native_language en users (la IA lo usa para explicaciones)
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS native_language VARCHAR(10);

-- ============================================================================
-- Verificación:
--   SELECT column_name FROM information_schema.columns
--   WHERE table_schema='public' AND table_name='user_settings'
--   AND column_name IN ('ui_language','learning_language',
--                       'ai_explanations_native','follow_device_language');
-- ============================================================================
