-- ============================================================================
-- TutorSaas — Carisma (línea de título evaluada por IA)
-- Fecha: 2026-08-11
-- Añade a user_language_profiles el score de carisma conversacional (0-100),
-- evaluado por la IA al final de cada conversación y persistido para el
-- progreso del título de Carisma.
-- ============================================================================

ALTER TABLE public.user_language_profiles
ADD COLUMN IF NOT EXISTS carisma_score NUMERIC DEFAULT 0;
