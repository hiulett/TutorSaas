-- ============================================================================
-- TutorSaas — Onboarding Redesign (F5): persistencia de creación de personaje
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
-- Pegar en el SQL Editor y ejecutar (idempotente).
-- ============================================================================

-- Clase del aventurero (warrior, mage, assassin, knight, archer, summoner,
-- paladin, necromancer)
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS character_class TEXT;

-- Índice del avatar seleccionado (referencia al catálogo de avatares)
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS avatar_index INTEGER DEFAULT 0;

-- ============================================================================
-- Verificación:
--   SELECT column_name FROM information_schema.columns
--   WHERE table_schema='public' AND table_name='user_language_profiles'
--   AND column_name IN ('character_class','avatar_index');
-- ============================================================================
