-- ==========================================
-- MÓDULO DE USUARIOS Y AUTENTICACIÓN
-- ==========================================

CREATE TABLE IF NOT EXISTS public.users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE NOT NULL,
    display_name    VARCHAR(100),
    avatar_url      TEXT,
    native_language VARCHAR(10) NOT NULL DEFAULT 'es',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    last_active_at  TIMESTAMPTZ,
    is_active       BOOLEAN DEFAULT TRUE,
    timezone        VARCHAR(50) DEFAULT 'UTC'
);

CREATE TABLE IF NOT EXISTS public.user_settings (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    correction_style    VARCHAR(20) DEFAULT 'balanced',
    tutor_personality   VARCHAR(50) DEFAULT 'friendly',
    tutor_voice_id      VARCHAR(100),
    daily_goal_minutes  INTEGER DEFAULT 15,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    notification_time   TIME DEFAULT '09:00',
    UNIQUE(user_id)
);

-- ==========================================
-- MÓDULO DE IDIOMAS Y NIVELES
-- ==========================================

CREATE TABLE IF NOT EXISTS public.languages (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(10) UNIQUE NOT NULL,  -- 'en', 'es', 'fr'
    name        VARCHAR(100) NOT NULL,
    native_name VARCHAR(100) NOT NULL,
    flag_emoji  VARCHAR(10),
    is_active   BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.cefr_levels (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(5) UNIQUE NOT NULL,   -- 'A1', 'A2', 'B1'
    name        VARCHAR(50) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS public.user_language_profiles (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id         INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    cefr_level_id       INTEGER NOT NULL REFERENCES public.cefr_levels(id) ON DELETE RESTRICT,
    xp_points           INTEGER DEFAULT 0,
    current_streak      INTEGER DEFAULT 0,
    longest_streak      INTEGER DEFAULT 0,
    last_practice_date  DATE,
    total_minutes       INTEGER DEFAULT 0,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, language_id)
);

-- ==========================================
-- MÓDULO DE ESCENARIOS Y LECCIONES
-- ==========================================

CREATE TABLE IF NOT EXISTS public.scenarios (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_id     INTEGER REFERENCES public.languages(id) ON DELETE CASCADE,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    context         TEXT NOT NULL,      -- System prompt context
    difficulty_level VARCHAR(5),        -- A1-C2
    category        VARCHAR(100),       -- 'business', 'travel', 'daily'
    estimated_minutes INTEGER DEFAULT 10,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.scenario_objectives (
    id              SERIAL PRIMARY KEY,
    scenario_id     UUID REFERENCES public.scenarios(id) ON DELETE CASCADE,
    objective       TEXT NOT NULL,
    vocabulary_focus TEXT[]
);

-- ==========================================
-- MÓDULO DE CONVERSACIONES
-- ==========================================

CREATE TABLE IF NOT EXISTS public.conversations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id     INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    scenario_id     UUID REFERENCES public.scenarios(id) ON DELETE SET NULL,
    started_at      TIMESTAMPTZ DEFAULT NOW(),
    ended_at        TIMESTAMPTZ,
    duration_seconds INTEGER,
    fluency_score   DECIMAL(5,2),       -- 0-100
    pronunciation_score DECIMAL(5,2),
    grammar_score   DECIMAL(5,2),
    vocabulary_score DECIMAL(5,2),
    overall_score   DECIMAL(5,2),
    xp_earned       INTEGER DEFAULT 0,
    status          VARCHAR(20) DEFAULT 'active'  -- active, completed, abandoned
);

CREATE TABLE IF NOT EXISTS public.messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    role            VARCHAR(20) NOT NULL,  -- 'user', 'assistant'
    content_text    TEXT NOT NULL,
    audio_url       TEXT,               -- S3/Blob URL del audio
    audio_duration_ms INTEGER,
    tokens_used     INTEGER,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    sequence_number INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS public.corrections (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id      UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    original_text   TEXT NOT NULL,
    corrected_text  TEXT NOT NULL,
    explanation     TEXT,
    error_type      VARCHAR(50),  -- 'grammar', 'vocabulary', 'pronunciation'
    severity        VARCHAR(20)   -- 'minor', 'major', 'critical'
);

-- ==========================================
-- MÓDULO DE PRONUNCIACIÓN
-- ==========================================

CREATE TABLE IF NOT EXISTS public.pronunciation_assessments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id          UUID REFERENCES public.messages(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    target_text         TEXT NOT NULL,
    overall_score       DECIMAL(5,2),
    accuracy_score      DECIMAL(5,2),
    fluency_score       DECIMAL(5,2),
    completeness_score  DECIMAL(5,2),
    prosody_score       DECIMAL(5,2),
    phoneme_details     JSONB,          -- Detalles por fonema
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- MÓDULO DE VOCABULARIO
-- ==========================================

CREATE TABLE IF NOT EXISTS public.vocabulary_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_id     INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE CASCADE,
    word            VARCHAR(200) NOT NULL,
    translation     VARCHAR(200),
    native_language VARCHAR(10) DEFAULT 'es',
    pronunciation_ipa VARCHAR(200),
    audio_url       TEXT,
    part_of_speech  VARCHAR(50),
    difficulty_level VARCHAR(5),
    example_sentence TEXT,
    UNIQUE(language_id, word)
);

CREATE TABLE IF NOT EXISTS public.user_vocabulary (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    vocabulary_id   UUID NOT NULL REFERENCES public.vocabulary_items(id) ON DELETE CASCADE,
    times_seen      INTEGER DEFAULT 1,
    times_correct   INTEGER DEFAULT 0,
    ease_factor     DECIMAL(4,2) DEFAULT 2.5,  -- SM-2 algorithm
    interval_days   INTEGER DEFAULT 1,
    next_review_at  TIMESTAMPTZ,
    last_seen_at    TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, vocabulary_id)
);

-- ==========================================
-- MÓDULO DE ESTADÍSTICAS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.daily_stats (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id     INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    date            DATE NOT NULL,
    minutes_practiced INTEGER DEFAULT 0,
    conversations_count INTEGER DEFAULT 0,
    words_learned   INTEGER DEFAULT 0,
    xp_earned       INTEGER DEFAULT 0,
    avg_fluency_score DECIMAL(5,2),
    UNIQUE(user_id, language_id, date)
);

CREATE TABLE IF NOT EXISTS public.weekly_stats (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id     INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    week_start      DATE NOT NULL,
    total_minutes   INTEGER DEFAULT 0,
    total_xp        INTEGER DEFAULT 0,
    conversations   INTEGER DEFAULT 0,
    avg_score       DECIMAL(5,2),
    UNIQUE(user_id, language_id, week_start)
);

-- ==========================================
-- MÓDULO DE GAMIFICACIÓN
-- ==========================================

CREATE TABLE IF NOT EXISTS public.achievements (
    id              SERIAL PRIMARY KEY,
    code            VARCHAR(100) UNIQUE NOT NULL,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    icon_url        TEXT,
    xp_reward       INTEGER DEFAULT 0,
    condition_type  VARCHAR(50),   -- 'streak', 'conversations', 'vocabulary'
    condition_value INTEGER
);

CREATE TABLE IF NOT EXISTS public.user_achievements (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    achievement_id  INTEGER NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
    earned_at       TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

CREATE TABLE IF NOT EXISTS public.daily_challenges (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id     INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    date            DATE NOT NULL,
    challenge_type  VARCHAR(50),
    target_value    INTEGER,
    current_value   INTEGER DEFAULT 0,
    is_completed    BOOLEAN DEFAULT FALSE,
    xp_reward       INTEGER,
    UNIQUE(user_id, language_id, date)
);

-- ==========================================
-- MÓDULO DE SUSCRIPCIONES Y PAGOS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    code            VARCHAR(50) UNIQUE NOT NULL,
    price_usd       DECIMAL(10,2),
    interval        VARCHAR(20),  -- 'monthly', 'yearly', 'lifetime'
    features        JSONB,
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plan_id                 INTEGER NOT NULL REFERENCES public.subscription_plans(id) ON DELETE RESTRICT,
    status                  VARCHAR(20) NOT NULL, -- 'active', 'cancelled', 'expired'
    started_at              TIMESTAMPTZ DEFAULT NOW(),
    expires_at              TIMESTAMPTZ,
    cancelled_at            TIMESTAMPTZ,
    revenuecat_subscriber_id VARCHAR(255),
    store                   VARCHAR(20),  -- 'app_store', 'play_store', 'web'
    UNIQUE(user_id)
);

CREATE TABLE IF NOT EXISTS public.payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES public.user_subscriptions(id) ON DELETE SET NULL,
    amount_usd      DECIMAL(10,2),
    currency        VARCHAR(10) DEFAULT 'USD',
    status          VARCHAR(20),  -- 'succeeded', 'failed', 'refunded'
    payment_method  VARCHAR(50),
    stripe_payment_id VARCHAR(255),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- MÓDULO DE CONFIGURACIÓN DE IA
-- ==========================================

CREATE TABLE IF NOT EXISTS public.ai_usage_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE SET NULL,
    model           VARCHAR(100),
    input_tokens    INTEGER,
    output_tokens   INTEGER,
    cost_usd        DECIMAL(10,6),
    latency_ms      INTEGER,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- ÍNDICES CRÍTICOS
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_started_at ON public.conversations(started_at);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at);
CREATE INDEX IF NOT EXISTS idx_daily_stats_user_date ON public.daily_stats(user_id, date);
CREATE INDEX IF NOT EXISTS idx_user_vocabulary_next_review ON public.user_vocabulary(user_id, next_review_at);
CREATE INDEX IF NOT EXISTS idx_ai_usage_user_date ON public.ai_usage_logs(user_id, created_at);

-- ==========================================
-- TRIGGERS PARA SUPABASE AUTH SYNC
-- ==========================================
-- Sincroniza automáticamente la tabla auth.users de Supabase con public.users

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, avatar_url)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'display_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  
  -- Inicializar settings por defecto
  INSERT INTO public.user_settings (user_id)
  VALUES (new.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
