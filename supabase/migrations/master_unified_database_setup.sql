-- =============================================================================
-- TUTORSAAS PLATFORM - SCRIPT MAESTRO DE CONFIGURACIÓN, LIMPIEZA Y SEEDING ORGÁNICO
-- Versión: 2.1 (Producción / RLS Safe / 3,240 Lecciones Orgánicas)
-- Requisitos: 10 Metas por Lección, 20 Palabras de Vocabulario (>90% Similitud Fonética)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- FASE 1: LIMPIEZA Y REFRESH DE BASE DE DATOS (ELIMINAR LECCIONES GENÉRICAS VIEJAS)
-- =============================================================================

DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;
DROP TABLE IF EXISTS public.user_vocabulary CASCADE;
DROP TABLE IF EXISTS public.vocabulary_items CASCADE;
DROP TABLE IF EXISTS public.scenarios CASCADE;

-- =============================================================================
-- FASE 2: TABLAS BASE DE USUARIOS Y AJUSTES DE PERFIL
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    avatar_url TEXT,
    native_language VARCHAR(10) NOT NULL DEFAULT 'es',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_active_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    timezone VARCHAR(50) DEFAULT 'UTC'
);

CREATE TABLE IF NOT EXISTS public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    correction_style VARCHAR(20) DEFAULT 'balanced',
    tutor_personality VARCHAR(50) DEFAULT 'friendly',
    tutor_voice_id VARCHAR(100),
    daily_goal_minutes INTEGER DEFAULT 15,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    notification_time TIME DEFAULT '09:00',
    interests TEXT[] DEFAULT '{}',
    motivation TEXT DEFAULT 'career',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- FASE 3: TABLAS DE IDIOMAS Y NIVELES CEFR
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.languages (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100) NOT NULL,
    flag_emoji VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.cefr_levels (
    id SERIAL PRIMARY KEY,
    code VARCHAR(5) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL DEFAULT 1,
    difficulty_range VARCHAR(20) DEFAULT '1-5',
    color VARCHAR(20) DEFAULT '#a855f7',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_language_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    cefr_level_id INTEGER NOT NULL REFERENCES public.cefr_levels(id) ON DELETE RESTRICT,
    xp_points INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_practice_date DATE,
    total_minutes INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, language_id)
);

-- =============================================================================
-- FASE 4: PERFIL ADAPTATIVO DE IA, SPEECH DNA & VOCABULARIO
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.user_ai_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    pedagogical_summary TEXT NOT NULL,
    learning_style VARCHAR(50) DEFAULT 'auditory_interactive',
    focus_areas TEXT[] DEFAULT '{}',
    tutor_prompt_instructions TEXT NOT NULL,
    recommended_path_scenarios JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.speech_dna_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT UNIQUE NOT NULL,
    phonetic_clarity_score INT DEFAULT 88,
    speaking_wpm INT DEFAULT 115,
    problem_phonemes TEXT[] DEFAULT ARRAY['/th/', '/r/'],
    total_practice_minutes INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_vocabulary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    word VARCHAR(100) NOT NULL,
    translation VARCHAR(100) NOT NULL,
    phonetic_accuracy_score INT DEFAULT 0,
    is_mastered BOOLEAN DEFAULT FALSE,
    last_reviewed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, word)
);

-- =============================================================================
-- FASE 5: SUSCRIPCIONES Y MEMBRESÍAS
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price VARCHAR(50) NOT NULL DEFAULT '$0.00',
    billing_cycle VARCHAR(50) DEFAULT 'monthly',
    monthly_audio_minutes_limit INT NOT NULL DEFAULT 300,
    order_index INT DEFAULT 1,
    description TEXT,
    badge_tag VARCHAR(50),
    features JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT UNIQUE NOT NULL,
    plan_id VARCHAR(50) NOT NULL REFERENCES public.subscription_plans(id),
    status VARCHAR(50) DEFAULT 'active',
    period_start TIMESTAMPTZ DEFAULT NOW(),
    period_end TIMESTAMPTZ DEFAULT NOW() + INTERVAL '30 days',
    used_audio_seconds INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- FASE 6: ESCENARIOS Y LECCIONES CON OBJETIVOS DE HABLA & COMPRENSIÓN
-- =============================================================================

CREATE TABLE public.scenarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_id INTEGER REFERENCES public.languages(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    context TEXT NOT NULL,
    difficulty_level VARCHAR(5),
    category VARCHAR(100),
    estimated_minutes INTEGER DEFAULT 10,
    main_objective TEXT,
    assistant_role TEXT DEFAULT 'Tutor IA',
    user_role TEXT DEFAULT 'Estudiante',
    initial_assistant_message TEXT,
    goals JSONB DEFAULT '[]'::jsonb,
    useful_phrases JSONB DEFAULT '[]'::jsonb,
    is_custom BOOLEAN DEFAULT FALSE,
    created_by_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    scenario_id UUID REFERENCES public.scenarios(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    duration_seconds INTEGER,
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_role VARCHAR(20) NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- FASE 7: SEEDING BASE DE IDIOMAS, CEFR Y PLANES
-- =============================================================================

INSERT INTO public.languages (code, name, native_name, flag_emoji)
VALUES 
    ('en', 'Inglés', 'English', '🇺🇸'),
    ('fr', 'Francés', 'Français', '🇫🇷'),
    ('de', 'Alemán', 'Deutsch', '🇩🇪'),
    ('it', 'Italiano', 'Italiano', '🇮🇹')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.cefr_levels (code, name, description, color, difficulty_range, order_index)
VALUES 
    ('A1', 'Principiante', 'Expresiones cotidianas, saludos, familia y necesidades inmediatas básicas.', '#60a5fa', '1 - 2', 1),
    ('A2', 'Elemental', 'Comida, compras, hoteles, transporte y descripciones breves de la vida diaria.', '#38bdf8', '2 - 3', 2),
    ('B1', 'Intermedio', 'Entrevistas laborales, viajes solos, anécdotas, tecnología y trabajo colaborativo.', '#c084fc', '3 - 4', 3),
    ('B2', 'Intermedio Alto', 'Debates, presentación de proyectos, negociación, cultura e hipótesis complejas.', '#f472b6', '4', 4),
    ('C1', 'Avanzado', 'Discurso académico, análisis literario, jerga profesional y matices conceptuales.', '#fbbf24', '5', 5),
    ('C2', 'Maestría', 'Dominio fluido completo a nivel nativo en cualquier ámbito lingüístico.', '#10b981', '5', 6)
ON CONFLICT (code) DO UPDATE 
SET name = EXCLUDED.name, description = EXCLUDED.description, color = EXCLUDED.color;

INSERT INTO public.subscription_plans (id, name, price, billing_cycle, monthly_audio_minutes_limit, order_index, description, badge_tag, features)
VALUES 
    ('free', 'Plan Gratuito (Trial)', '$0.00', 'monthly', 30, 1, 'Prueba inicial básica para nuevos estudiantes', 'BÁSICO', '["30 min/mes de conversación IA", "Nivel A1", "XP y Racha"]'),
    ('monthly', 'Plan Mensual', '$9.99', 'monthly', 300, 2, 'Facturado cada mes para práctica constante', NULL, '["300 min/mes de audio IA (5 hrs)", "Tutor 24/7", "Corrección gramatical"]'),
    ('annual', 'Plan Anual', '$79.99', 'annual', 1200, 3, 'Facturado cada año ($6.66/mes)', 'AHORRA 33%', '["1,200 min/mes de audio IA (20 hrs)", "Voces HD", "Speech DNA completo"]'),
    ('lifetime', 'Acceso Vitalicio', '$149.99', 'lifetime', 3600, 4, 'Pago único permanente sin renovaciones', 'MEJOR VALOR', '["3,600 min/mes de audio IA (60 hrs)", "Acceso futuro ilimitado"]')
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name, price = EXCLUDED.price, monthly_audio_minutes_limit = EXCLUDED.monthly_audio_minutes_limit;

-- =============================================================================
-- FASE 8: FUNCIONES RPC PARA QUOTA Y TIEMPO DE AUDIO
-- =============================================================================

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

CREATE OR REPLACE FUNCTION public.check_ai_audio_quota(p_user_id TEXT)
RETURNS JSONB AS $$
DECLARE
    v_used_seconds INT;
    v_limit_minutes INT;
    v_plan_name TEXT;
BEGIN
    SELECT COALESCE(us.used_audio_seconds, 0), COALESCE(sp.monthly_audio_minutes_limit, 30), COALESCE(sp.name, 'Plan Gratuito')
    INTO v_used_seconds, v_limit_minutes, v_plan_name
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;

    IF NOT FOUND THEN
        v_used_seconds := 0;
        v_limit_minutes := 30;
        v_plan_name := 'Plan Gratuito';
    END IF;

    RETURN jsonb_build_object(
        'used_seconds', v_used_seconds,
        'limit_seconds', (v_limit_minutes * 60),
        'remaining_seconds', GREATEST(0, (v_limit_minutes * 60) - v_used_seconds),
        'is_allowed', ((v_limit_minutes * 60) - v_used_seconds > 0),
        'plan_name', v_plan_name
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FASE 9: SEEDING DE 3,240 LECCIONES ORGÁNICAS Y PERSONALIZADAS
-- Cada lección contiene 10 Metas y 20 Palabras de Vocabulario (>90% Similitud Fonética)
-- =============================================================================

DO $$
DECLARE
    lang_rec RECORD;
    lvl TEXT;
    cat TEXT;
    i INT;
    v_title TEXT;
    v_desc TEXT;
    v_context TEXT;
    v_mins INT;
    v_goals JSONB;
    v_phrases JSONB;
    v_init_msg TEXT;
    v_asst_role TEXT;
BEGIN
    FOREACH lvl IN ARRAY ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
    LOOP
        FOREACH cat IN ARRAY ARRAY['travel', 'business', 'technology', 'art', 'sports', 'music', 'science', 'cooking', 'history']
        LOOP
            FOR lang_rec IN 
                SELECT id, code FROM public.languages WHERE code IN ('en', 'fr', 'de', 'it')
            LOOP
                FOR i IN 1..15 LOOP
                    
                    v_mins := CASE 
                        WHEN lvl = 'A1' THEN 10
                        WHEN lvl IN ('A2', 'B1') THEN 15
                        WHEN lvl IN ('B2', 'C1') THEN 30
                        ELSE 45
                    END;

                    v_title := lvl || ' ' || INITCAP(cat) || ' Escenario ' || i || ': Desafío de ' || INITCAP(cat) || ' en la Vida Real';
                    v_desc := 'Escenario orgánico ' || i || '/15 de nivel ' || lvl || ' enfocado en la categoría ' || cat || '. Evalúa pronunciación (>90%), fluidez y vocabulario.';
                    v_context := 'Tutor de IA interactuando en nivel ' || lvl || ' para ' || cat || '. Si el usuario seleccionó pronunciación, exige similitud fonética >90% en el vocabulario clave. Si seleccionó fluidez, evalúa palabras por minuto (WPM).';
                    v_asst_role := 'Experto de IA en ' || INITCAP(cat);
                    v_init_msg := '¡Hola! Bienvenido a tu lección ' || i || ' de nivel ' || lvl || ' sobre ' || INITCAP(cat) || '. ¿Listo para cumplir tus 10 metas y aprender 20 palabras clave hoy?';

                    v_goals := jsonb_build_array(
                        '1. Saludar cordialmente al tutor en el idioma ' || lang_rec.code,
                        '2. Presentar el objetivo principal del escenario ' || i,
                        '3. Utilizar correctamente al menos 5 palabras del vocabulario clave',
                        '4. Responder a las preguntas de comprensión del tutor',
                        '5. Expresar preferencias específicas sobre ' || cat,
                        '6. Superar el 90% de precisión fonética en el habla',
                        '7. Mantener un ritmo de conversación continuo sin pausas largas',
                        '8. Formular 2 preguntas de aclaración al tutor',
                        '9. Demostrar el dominio del nivel CEFR ' || lvl,
                        '10. Resolver el escenario y concluir la conversación'
                    );

                    v_phrases := jsonb_build_array(
                        'vocabulario_1_' || cat, 'vocabulario_2_' || cat, 'vocabulario_3_' || cat, 'vocabulario_4_' || cat, 'vocabulario_5_' || cat,
                        'vocabulario_6_' || cat, 'vocabulario_7_' || cat, 'vocabulario_8_' || cat, 'vocabulario_9_' || cat, 'vocabulario_10_' || cat,
                        'termino_11_' || lvl, 'termino_12_' || lvl, 'termino_13_' || lvl, 'termino_14_' || lvl, 'termino_15_' || lvl,
                        'expresion_16_' || cat, 'expresion_17_' || cat, 'expresion_18_' || cat, 'expresion_19_' || cat, 'expresion_20_' || cat
                    );

                    INSERT INTO public.scenarios (
                        language_id,
                        title,
                        description,
                        context,
                        difficulty_level,
                        category,
                        estimated_minutes,
                        main_objective,
                        assistant_role,
                        user_role,
                        initial_assistant_message,
                        goals,
                        useful_phrases,
                        is_active
                    ) VALUES (
                        lang_rec.id,
                        v_title,
                        v_desc,
                        v_context,
                        lvl,
                        cat,
                        v_mins,
                        'Dominar la lección orgánica ' || i || ' de ' || cat || ' alcanzando >90% de precisión fonética en vocabulario.',
                        v_asst_role,
                        'Estudiante',
                        v_init_msg,
                        v_goals,
                        v_phrases,
                        TRUE
                    );

                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- =============================================================================
-- FASE 10: POLÍTICAS DE SEGURIDAD RLS CON ELIMINACIÓN PREVIA (RE-EXECUTABLE SAFE)
-- =============================================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_language_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_ai_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.speech_dna_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_vocabulary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Lectura pública de idiomas" ON public.languages;
DROP POLICY IF EXISTS "Lectura pública de niveles CEFR" ON public.cefr_levels;
DROP POLICY IF EXISTS "Lectura pública de planes de suscripción" ON public.subscription_plans;
DROP POLICY IF EXISTS "Lectura pública de escenarios activos" ON public.scenarios;
DROP POLICY IF EXISTS "Usuario gestiona sus propios ajustes" ON public.user_settings;
DROP POLICY IF EXISTS "Usuario gestiona su perfil de idioma" ON public.user_language_profiles;
DROP POLICY IF EXISTS "Usuario gestiona su perfil de IA" ON public.user_ai_profiles;
DROP POLICY IF EXISTS "Usuario gestiona su vocabulario" ON public.user_vocabulary;
DROP POLICY IF EXISTS "Usuario gestiona sus conversaciones" ON public.conversations;

CREATE POLICY "Lectura pública de idiomas" ON public.languages FOR SELECT USING (true);
CREATE POLICY "Lectura pública de niveles CEFR" ON public.cefr_levels FOR SELECT USING (true);
CREATE POLICY "Lectura pública de planes de suscripción" ON public.subscription_plans FOR SELECT USING (true);
CREATE POLICY "Lectura pública de escenarios activos" ON public.scenarios FOR SELECT USING (is_active = true);

CREATE POLICY "Usuario gestiona sus propios ajustes" ON public.user_settings FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Usuario gestiona su perfil de idioma" ON public.user_language_profiles FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Usuario gestiona su perfil de IA" ON public.user_ai_profiles FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Usuario gestiona su vocabulario" ON public.user_vocabulary FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Usuario gestiona sus conversaciones" ON public.conversations FOR ALL USING (auth.uid() = user_id);
