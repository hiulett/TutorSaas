-- ============================================================================
-- Oracle Assessments — Registro persistente de cada examen conversacional
-- del Oráculo (onboarding Paso 4). Complementa las columnas placement_* de
-- user_language_profiles con el transcript completo y el detalle de métricas.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.oracle_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    cefr_level VARCHAR(5) NOT NULL DEFAULT 'A1',
    game_rank VARCHAR(5) DEFAULT 'E',
    target_language VARCHAR(10) NOT NULL DEFAULT 'en',
    native_language VARCHAR(10) DEFAULT 'es',
    scores JSONB,
    strengths JSONB,
    weaknesses JSONB,
    explanation TEXT,
    recommended_focus TEXT,
    answers JSONB,
    duration_seconds INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.oracle_assessments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "oracle_assessments_select_own" ON public.oracle_assessments;
CREATE POLICY "oracle_assessments_select_own" ON public.oracle_assessments
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "oracle_assessments_insert_own" ON public.oracle_assessments;
CREATE POLICY "oracle_assessments_insert_own" ON public.oracle_assessments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_oracle_assessments_user
    ON public.oracle_assessments (user_id, created_at DESC);
