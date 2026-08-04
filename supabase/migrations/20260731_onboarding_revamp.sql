-- ============================================================================
-- TutorSaas — Onboarding Revamp (T10): persistencia de clasificación IA
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
-- Pegar en el SQL Editor y ejecutar (idempotente).
-- ============================================================================

-- Rango del juego (E,D,C,B,A,S,SS,SSS) derivado del CEFR por la IA
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS game_rank TEXT;

-- Puntuaciones por dimensión (pronunciación, vocabulario, gramática, comprensión, fluidez)
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS placement_scores JSONB;

-- Fortalezas detectadas por la IA
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS placement_strengths JSONB;

-- Debilidades detectadas por la IA
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS placement_weaknesses JSONB;

-- Explicación del resultado (texto)
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS placement_explanation TEXT;

-- Foco recomendado (ej. 'grammar_past_tenses')
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS placement_recommended_focus TEXT;

-- Fecha de la clasificación
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS placement_assessed_at TIMESTAMPTZ;

-- ============================================================================
-- Verificación: las 7 columnas deben existir tras ejecutar lo anterior.
-- ============================================================================
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_language_profiles'
  AND column_name IN (
        'game_rank',
        'placement_scores',
        'placement_strengths',
        'placement_weaknesses',
        'placement_explanation',
        'placement_recommended_focus',
        'placement_assessed_at'
      )
ORDER BY column_name;

-- Índices: no aplican (1 fila por usuario y lenguaje; se accede por PK user_id/language_id).
-- RLS: no se modifica — las nuevas columnas se heredan de la policy profiles_self existente.
