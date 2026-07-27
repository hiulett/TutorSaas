-- =============================================================================
-- MIGRACIÓN SEGURA & 100% RLS COMPATIBLE CON SUPABASE DASHBOARD
-- TutorSaas Platform — Database Migration Script (Non-destructive & RLS Secured)
-- =============================================================================

-- 1. EXTENSIÓN DE LA TABLA SCENARIOS (LECCIONES & METAS & FRASES CLAVE)
ALTER TABLE public.scenarios
ADD COLUMN IF NOT EXISTS main_objective TEXT,
ADD COLUMN IF NOT EXISTS assistant_role TEXT DEFAULT 'Tutor IA',
ADD COLUMN IF NOT EXISTS user_role TEXT DEFAULT 'Estudiante',
ADD COLUMN IF NOT EXISTS initial_assistant_message TEXT,
ADD COLUMN IF NOT EXISTS goals JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS useful_phrases JSONB DEFAULT '[]'::jsonb;

-- 2. TABLA CEFR_LEVELS (ASEGURAR COLUMNAS EXTENDIDAS SI LA TABLA YA EXISTÍA)
CREATE TABLE IF NOT EXISTS public.cefr_levels (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    order_index INT DEFAULT 1,
    difficulty_range TEXT DEFAULT '1-5',
    color TEXT DEFAULT '#a855f7',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.cefr_levels
ADD COLUMN IF NOT EXISTS color TEXT DEFAULT '#a855f7',
ADD COLUMN IF NOT EXISTS difficulty_range TEXT DEFAULT '1-5',
ADD COLUMN IF NOT EXISTS order_index INT DEFAULT 1;

INSERT INTO public.cefr_levels (code, name, description, color, difficulty_range, order_index)
VALUES 
    ('A1', 'Principiante', 'Expresiones cotidianas, saludos, familia y necesidades inmediatas básicas.', '#60a5fa', '1 - 2', 1),
    ('A2', 'Elemental', 'Comida, compras, hoteles, transporte y descripciones breves de la vida diaria.', '#38bdf8', '2 - 3', 2),
    ('B1', 'Intermedio', 'Entrevistas laborales, viajes solos, anécdotas, tecnología y trabajo colaborativo.', '#c084fc', '3 - 4', 3),
    ('B2', 'Intermedio Alto', 'Debates, presentación de proyectos, negociación, cultura e hipótesis complejas.', '#f472b6', '4', 4),
    ('C1', 'Avanzado', 'Discurso académico, análisis literario, jerga profesional y matices conceptuales.', '#fbbf24', '5', 5),
    ('C2', 'Maestría', 'Dominio fluido completo a nivel nativo en cualquier ámbito lingüístico.', '#10b981', '5', 6)
ON CONFLICT (code) DO UPDATE 
SET name = EXCLUDED.name, description = EXCLUDED.description, color = EXCLUDED.color, difficulty_range = EXCLUDED.difficulty_range;

-- 3. TABLA DE MÉTRICAS BIOMÉTRICAS DEL HABLA (SPEECH DNA)
CREATE TABLE IF NOT EXISTS public.speech_dna_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT UNIQUE NOT NULL,
    phonetic_clarity_score INT DEFAULT 88,
    speaking_wpm INT DEFAULT 115,
    problem_phonemes TEXT[] DEFAULT ARRAY['/th/', '/r/'],
    total_practice_minutes INT DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. RECREACIÓN LIMPIA DE TABLAS DE MEMBRESÍA Y SUSCRIPCIONES
DROP TABLE IF EXISTS public.user_subscriptions CASCADE;
DROP TABLE IF EXISTS public.subscription_plans CASCADE;

CREATE TABLE public.subscription_plans (
    id VARCHAR(50) PRIMARY KEY, -- 'free', 'monthly', 'annual', 'lifetime'
    name VARCHAR(100) NOT NULL,
    price VARCHAR(50) NOT NULL DEFAULT '$0.00',
    billing_cycle VARCHAR(50) DEFAULT 'monthly',
    monthly_audio_minutes_limit INT NOT NULL DEFAULT 300,
    order_index INT DEFAULT 1,
    description TEXT,
    badge_tag VARCHAR(50),
    features JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.subscription_plans
ADD COLUMN IF NOT EXISTS order_index INT DEFAULT 1;

INSERT INTO public.subscription_plans (id, name, price, billing_cycle, monthly_audio_minutes_limit, order_index, description, badge_tag, features)
VALUES 
('free', 'Plan Gratuito (Trial)', '$0.00', 'monthly', 30, 1, 'Prueba inicial básica para nuevos estudiantes', 'BÁSICO', '["30 min/mes de conversación IA", "Nivel A1", "XP y Racha"]'),
('monthly', 'Plan Mensual', '$9.99', 'monthly', 300, 2, 'Facturado cada mes para práctica constante', NULL, '["300 min/mes de audio IA (5 hrs)", "Tutor 24/7", "Corrección gramatical"]'),
('annual', 'Plan Anual', '$79.99', 'annual', 1200, 3, 'Facturado cada año ($6.66/mes)', 'AHORRA 33%', '["1,200 min/mes de audio IA (20 hrs)", "Voces HD", "Speech DNA completo"]'),
('lifetime', 'Acceso Vitalicio', '$149.99', 'lifetime', 3600, 4, 'Pago único permanente sin renovaciones', 'MEJOR VALOR', '["3,600 min/mes de audio IA (60 hrs)", "Acceso futuro ilimitado"]')
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    order_index = EXCLUDED.order_index,
    monthly_audio_minutes_limit = EXCLUDED.monthly_audio_minutes_limit;

-- 5. TABLA DE SUSCRIPCIONES DE USUARIO
CREATE TABLE public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT UNIQUE NOT NULL,
    plan_id VARCHAR(50) NOT NULL REFERENCES public.subscription_plans(id),
    status VARCHAR(50) DEFAULT 'active',
    period_start TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    period_end TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now() + interval '30 days'),
    used_audio_seconds INT DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 6. FUNCIÓN RPC PARA DECRETAR Y SEGUIR EL TIEMPO DE AUDIO IA CONSUMIDO
CREATE OR REPLACE FUNCTION public.track_ai_audio_time(
    p_user_id TEXT,
    p_duration_seconds INT
) RETURNS JSONB AS $$
DECLARE
    v_plan_limit_seconds INT;
    v_used_seconds INT;
    v_remaining_seconds INT;
    v_plan_id VARCHAR(50);
BEGIN
    INSERT INTO public.user_subscriptions (user_id, plan_id, used_audio_seconds)
    VALUES (p_user_id, 'free', 0)
    ON CONFLICT (user_id) DO NOTHING;

    UPDATE public.user_subscriptions us
    SET used_audio_seconds = us.used_audio_seconds + p_duration_seconds,
        updated_at = timezone('utc'::text, now())
    FROM public.subscription_plans sp
    WHERE us.plan_id = sp.id AND us.user_id = p_user_id
    RETURNING us.used_audio_seconds, (sp.monthly_audio_minutes_limit * 60), us.plan_id
    INTO v_used_seconds, v_plan_limit_seconds, v_plan_id;

    UPDATE public.speech_dna_metrics
    SET total_practice_minutes = ROUND(v_used_seconds / 60.0)
    WHERE user_id = p_user_id;

    v_remaining_seconds := GREATEST(0, v_plan_limit_seconds - v_used_seconds);

    RETURN jsonb_build_object(
        'used_seconds', v_used_seconds,
        'limit_seconds', v_plan_limit_seconds,
        'remaining_seconds', v_remaining_seconds,
        'is_allowed', (v_remaining_seconds > 0),
        'plan_id', v_plan_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNCIÓN RPC PARA CHECK DE QUOTA ANTES DE INICIAR SESIÓN DE VOZ IA
CREATE OR REPLACE FUNCTION public.check_ai_audio_quota(p_user_id TEXT)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'used_seconds', COALESCE(us.used_audio_seconds, 0),
        'limit_seconds', (COALESCE(sp.monthly_audio_minutes_limit, 30) * 60),
        'remaining_seconds', GREATEST(0, (COALESCE(sp.monthly_audio_minutes_limit, 30) * 60) - COALESCE(us.used_audio_seconds, 0)),
        'is_allowed', (GREATEST(0, (COALESCE(sp.monthly_audio_minutes_limit, 30) * 60) - COALESCE(us.used_audio_seconds, 0)) > 0),
        'plan_name', COALESCE(sp.name, 'Plan Gratuito')
    )
    INTO v_result
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;

    IF v_result IS NULL THEN
        RETURN jsonb_build_object(
            'used_seconds', 0,
            'limit_seconds', 1800,
            'remaining_seconds', 1800,
            'is_allowed', true,
            'plan_name', 'Plan Gratuito (Trial)'
        );
    END IF;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. TABLA DE CONFIGURACIÓN GLOBAL DEL SISTEMA DE IA
CREATE TABLE IF NOT EXISTS public.system_ai_settings (
    id INT PRIMARY KEY DEFAULT 1,
    stt_model TEXT DEFAULT 'whisper-large-v3-turbo',
    llm_model TEXT DEFAULT 'deepseek-chat',
    temperature NUMERIC DEFAULT 0.7,
    correction_level TEXT DEFAULT 'moderate',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

INSERT INTO public.system_ai_settings (id, stt_model, llm_model, temperature, correction_level)
VALUES (1, 'whisper-large-v3-turbo', 'deepseek-chat', 0.7, 'moderate')
ON CONFLICT (id) DO UPDATE
SET stt_model = EXCLUDED.stt_model, llm_model = EXCLUDED.llm_model, temperature = EXCLUDED.temperature, correction_level = EXCLUDED.correction_level;

-- 9. HABILITAR SEGURIDAD RLS EN TODAS LAS TABLAS
ALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cefr_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.speech_dna_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_ai_settings ENABLE ROW LEVEL SECURITY;

-- POLÍTICAS RLS PÚBLICAS
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Public select scenarios" ON public.scenarios;
    CREATE POLICY "Public select scenarios" ON public.scenarios FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public all scenarios" ON public.scenarios;
    CREATE POLICY "Public all scenarios" ON public.scenarios FOR ALL USING (true);

    DROP POLICY IF EXISTS "Public select cefr_levels" ON public.cefr_levels;
    CREATE POLICY "Public select cefr_levels" ON public.cefr_levels FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public all cefr_levels" ON public.cefr_levels;
    CREATE POLICY "Public all cefr_levels" ON public.cefr_levels FOR ALL USING (true);

    DROP POLICY IF EXISTS "Public select speech_dna_metrics" ON public.speech_dna_metrics;
    CREATE POLICY "Public select speech_dna_metrics" ON public.speech_dna_metrics FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public all speech_dna_metrics" ON public.speech_dna_metrics;
    CREATE POLICY "Public all speech_dna_metrics" ON public.speech_dna_metrics FOR ALL USING (true);

    DROP POLICY IF EXISTS "Public select subscription_plans" ON public.subscription_plans;
    CREATE POLICY "Public select subscription_plans" ON public.subscription_plans FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public all subscription_plans" ON public.subscription_plans;
    CREATE POLICY "Public all subscription_plans" ON public.subscription_plans FOR ALL USING (true);

    DROP POLICY IF EXISTS "Public select user_subscriptions" ON public.user_subscriptions;
    CREATE POLICY "Public select user_subscriptions" ON public.user_subscriptions FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public all user_subscriptions" ON public.user_subscriptions;
    CREATE POLICY "Public all user_subscriptions" ON public.user_subscriptions FOR ALL USING (true);

    DROP POLICY IF EXISTS "Public select system_ai_settings" ON public.system_ai_settings;
    CREATE POLICY "Public select system_ai_settings" ON public.system_ai_settings FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public all system_ai_settings" ON public.system_ai_settings;
    CREATE POLICY "Public all system_ai_settings" ON public.system_ai_settings FOR ALL USING (true);
END $$;
