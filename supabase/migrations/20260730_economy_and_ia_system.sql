-- ============================================================================
-- MIGRACIÓN UNIFICADA: Economía, IA como recurso, Gremio, Retención
-- Ejecutar en orden en el SQL Editor de Supabase
-- ============================================================================

-- 1. TABLAS DE ECONOMÍA
-- ============================================================================

-- Inventario de objetos cosméticos del jugador
CREATE TABLE IF NOT EXISTS public.player_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    item_code VARCHAR(100) NOT NULL,
    item_type VARCHAR(50) NOT NULL CHECK (item_type IN (
        'title','skin','frame','aura','pet','emote','theme',
        'table_theme','guild_decoration','relic','consumable'
    )),
    is_equipped BOOLEAN DEFAULT false,
    acquired_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, item_code)
);

-- Catálogo de cosméticos (tienda)
CREATE TABLE IF NOT EXISTS public.cosmetic_catalog (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    price_gems INTEGER NOT NULL DEFAULT 0,
    rarity VARCHAR(20) DEFAULT 'common' CHECK (rarity IN ('common','rare','epic','legendary','limited')),
    is_limited BOOLEAN DEFAULT false,
    season VARCHAR(50),
    image_url TEXT,
    available_from TIMESTAMPTZ DEFAULT NOW(),
    available_to TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Estado diario del jugador (rachas, invocaciones, pergaminos)
CREATE TABLE IF NOT EXISTS public.player_daily_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    invocations_used INTEGER DEFAULT 0,
    invocations_max INTEGER DEFAULT 20,
    pergaminos_used INTEGER DEFAULT 0,
    pergaminos_max INTEGER DEFAULT 5,
    guild_quests_completed INTEGER DEFAULT 0,
    daily_reward_claimed BOOLEAN DEFAULT false,
    bonus_invocations INTEGER DEFAULT 0,
    UNIQUE(user_id, date)
);

-- Rachas del jugador
CREATE TABLE IF NOT EXISTS public.player_streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_active_date DATE,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Pool de misiones del gremio (contenido predefinido, sin IA)
CREATE TABLE IF NOT EXISTS public.guild_quest_pool (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quest_type VARCHAR(20) NOT NULL CHECK (quest_type IN ('daily','weekly','collaborative','emergency')),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    objective_type VARCHAR(50) NOT NULL DEFAULT 'speak_minutes' CHECK (objective_type IN (
        'speak_minutes','vocab_words','sessions','xp_earned','grammar_score',
        'fluency_score','consecutive_days','guild_messages','perfect_session'
    )),
    target_value INTEGER NOT NULL DEFAULT 10,
    xp_reward INTEGER DEFAULT 50,
    gem_reward INTEGER DEFAULT 0,
    item_reward VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    min_cefr_level VARCHAR(5),
    max_cefr_level VARCHAR(5),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Misiones completadas por el jugador
CREATE TABLE IF NOT EXISTS public.player_completed_quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    quest_id VARCHAR(200) NOT NULL,
    quest_type VARCHAR(20) NOT NULL,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, quest_id)
);

-- Battle Pass del gremio
CREATE TABLE IF NOT EXISTS public.guild_battle_pass (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    season VARCHAR(50) NOT NULL,
    level INTEGER DEFAULT 1,
    xp_progress INTEGER DEFAULT 0,
    is_premium BOOLEAN DEFAULT false,
    claimed_rewards TEXT[] DEFAULT '{}',
    UNIQUE(user_id, season)
);

-- Pergaminos de Sabiduría (contenido batch offline)
CREATE TABLE IF NOT EXISTS public.player_pergaminos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content JSONB NOT NULL,
    is_used BOOLEAN DEFAULT false,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. MIGRACIONES A TABLAS EXISTENTES
-- ============================================================================

-- Agregar columna de clase de personaje al perfil
ALTER TABLE public.user_language_profiles 
ADD COLUMN IF NOT EXISTS player_class VARCHAR(50) DEFAULT 'warrior';

ALTER TABLE public.user_language_profiles 
ADD COLUMN IF NOT EXISTS guild_role VARCHAR(50) DEFAULT 'member';

ALTER TABLE public.user_language_profiles 
ADD COLUMN IF NOT EXISTS total_gems INTEGER DEFAULT 0;

ALTER TABLE public.user_language_profiles 
ADD COLUMN IF NOT EXISTS total_gold INTEGER DEFAULT 100;

-- Agregar soporte para racha diaria a user_language_profiles
ALTER TABLE public.user_language_profiles 
ADD COLUMN IF NOT EXISTS last_active_date DATE;

-- Agregar columna de tipo de moderación a chat_rooms (si no existe)
ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS moderator_type TEXT NOT NULL DEFAULT 'ai' 
CHECK (moderator_type IN ('ai', 'creator', 'assigned'));

ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS assigned_moderator_id UUID REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS description TEXT;

ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3. SEED DATA: Pool inicial de misiones del gremio
-- ============================================================================
INSERT INTO public.guild_quest_pool (quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, min_cefr_level) VALUES
    ('daily', 'El Eco del Guerrero', 'Habla 5 minutos en una sala de voz del gremio', 'speak_minutes', 5, 50, 5, NULL),
    ('daily', 'El Librero Curioso', 'Aprende 3 palabras nuevas en conversaciones', 'vocab_words', 3, 40, 5, NULL),
    ('daily', 'El Mensajero Veloz', 'Completa 2 sesiones de conversación', 'sessions', 2, 60, 10, NULL),
    ('daily', 'El Escriba Diligente', 'Gana 100 XP en el día', 'xp_earned', 100, 30, 3, NULL),
    ('daily', 'El Afinador de Vocales', 'Logra un score de fluidez >80%', 'fluency_score', 80, 50, 5, 'B1'),
    ('daily', 'El Gramático', 'Completa una conversación sin errores graves', 'grammar_score', 90, 50, 5, 'A2'),
    ('daily', 'El Viajero Frecuente', 'Usa el gremio por 3 días consecutivos', 'consecutive_days', 3, 100, 15, NULL),
    ('weekly', 'El Campeón del Gremio', 'Acumula 500 XP durante la semana', 'xp_earned', 500, 200, 30, NULL),
    ('weekly', 'El Orador Incansable', 'Habla 60 minutos total en la semana', 'speak_minutes', 60, 300, 50, NULL),
    ('weekly', 'El Políglota', 'Acumula 20 palabras nuevas en la semana', 'vocab_words', 20, 250, 40, NULL),
    ('collaborative', 'El Banquete del Gremio', 'Entre todos los miembros: hablen 500 minutos', 'speak_minutes', 500, 200, 50, NULL),
    ('collaborative', 'La Cacería Colectiva', 'Entre todos los miembros: completen 50 sesiones', 'sessions', 50, 300, 75, NULL),
    ('collaborative', 'La Lluvia de Maná', 'Entre todos los miembros: ganen 5000 XP', 'xp_earned', 5000, 400, 100, NULL)
ON CONFLICT DO NOTHING;

-- 4. SEED DATA: Catálogo de cosméticos inicial
-- ============================================================================
INSERT INTO public.cosmetic_catalog (id, name, description, category, price_gems, rarity) VALUES
    ('title_novato', 'Novato del Abismo', 'Título inicial de todo aventurero', 'title', 0, 'common'),
    ('title_eloquente', 'Elocuente del Gremio', 'Reconocimiento por hablar con claridad', 'title', 500, 'rare'),
    ('title_imparable', 'Imparable', 'Otorgado por racha de 30 días', 'title', 0, 'epic'),
    ('title_cazador_sombras', 'Cazador de Sombras', 'Título de elite del gremio', 'title', 800, 'epic'),
    ('title_leyenda_viva', 'Leyenda Viva', 'Solo los más dedicados', 'title', 2000, 'legendary'),
    ('frame_escudo', 'Escudo del Gremio', 'Marco con escudo protector', 'frame', 600, 'rare'),
    ('frame_dragón', 'Alas de Dragón', 'Marco con alas desplegadas', 'frame', 1200, 'epic'),
    ('frame_abismo', 'Mirada del Abismo', 'Marco con efecto de oscuridad', 'frame', 2000, 'legendary'),
    ('aura_mana', 'Llama de Maná', 'Aura brillante color cian', 'aura', 800, 'rare'),
    ('aura_fuego', 'Espíritu de Fuego', 'Partículas de fuego alrededor', 'aura', 1500, 'epic'),
    ('aura_sombras', 'Alma de las Sombras', 'Niebla oscura con destellos', 'aura', 2500, 'legendary'),
    ('pet_lunático', 'Lunático', 'Mascota flotante que te acompaña', 'pet', 1500, 'epic'),
    ('pet_fénix', 'Fénix Carbonizado', 'Ave de fuego renacida', 'pet', 2500, 'legendary'),
    ('emote_paquete1', 'Reacciones Arcanas Vol.1', '10 emotes para el chat del gremio', 'emote', 400, 'common'),
    ('theme_mesa_bosque', 'Tema: Bosque Nocturno', 'Tema visual para tu mesa de gremio', 'table_theme', 2000, 'epic'),
    ('theme_mesa_abismo', 'Tema: Abismo Arcano', 'Tema visual de alto rango', 'table_theme', 3000, 'legendary'),
    ('relic_oraculo', 'Fragmento del Oráculo', 'Obtenido al completar la prueba inicial', 'relic', 0, 'rare'),
    ('relic_dragón', 'Corazón del Dragón', 'Completar un nivel CEFR completo', 'relic', 0, 'epic'),
    ('relic_tiempo', 'Llave del Tiempo', 'Racha de 30 días consecutivos', 'relic', 0, 'epic'),
    ('consumible_invocacion5', '+5 Invocaciones al Oráculo', 'Recarga 5 invocaciones de IA', 'consumable', 50, 'common'),
    ('consumible_invocacion20', '+20 Invocaciones al Oráculo', 'Recarga 20 invocaciones de IA', 'consumable', 180, 'rare'),
    ('consumible_pergamino10', '10 Pergaminos de Sabiduría', 'Contenido offline para practicar sin IA', 'consumable', 100, 'common'),
    ('consumible_pergamino50', '50 Pergaminos de Sabiduría', 'Lote grande de práctica offline', 'consumable', 400, 'rare')
ON CONFLICT (id) DO NOTHING;

-- 5. ENABLE REALTIME
-- ============================================================================
alter publication supabase_realtime add table public.player_daily_state;
alter publication supabase_realtime add table public.player_streaks;
alter publication supabase_realtime add table public.guild_battle_pass;

-- 6. RLS POLICIES
-- ============================================================================
ALTER TABLE public.player_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_daily_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guild_quest_pool ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_completed_quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guild_battle_pass ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_pergaminos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cosmetic_catalog ENABLE ROW LEVEL SECURITY;

-- Leer: todos los autenticados
DROP POLICY IF EXISTS "select_own_inventory" ON public.player_inventory;
CREATE POLICY "select_own_inventory" ON public.player_inventory FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "select_own_daily" ON public.player_daily_state;
CREATE POLICY "select_own_daily" ON public.player_daily_state FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_daily" ON public.player_daily_state;
CREATE POLICY "insert_own_daily" ON public.player_daily_state FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "update_own_daily" ON public.player_daily_state;
CREATE POLICY "update_own_daily" ON public.player_daily_state FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "select_own_streaks" ON public.player_streaks;
CREATE POLICY "select_own_streaks" ON public.player_streaks FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "upsert_own_streaks" ON public.player_streaks;
CREATE POLICY "upsert_own_streaks" ON public.player_streaks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "update_own_streaks" ON public.player_streaks FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "select_guild_quests" ON public.guild_quest_pool;
CREATE POLICY "select_guild_quests" ON public.guild_quest_pool FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "select_own_completed_quests" ON public.player_completed_quests;
CREATE POLICY "select_own_completed_quests" ON public.player_completed_quests FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_completed_quests" ON public.player_completed_quests;
CREATE POLICY "insert_own_completed_quests" ON public.player_completed_quests FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "select_own_bp" ON public.guild_battle_pass;
CREATE POLICY "select_own_bp" ON public.guild_battle_pass FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "upsert_own_bp" ON public.guild_battle_pass;
CREATE POLICY "upsert_own_bp" ON public.guild_battle_pass FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "select_own_pergaminos" ON public.player_pergaminos;
CREATE POLICY "select_own_pergaminos" ON public.player_pergaminos FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "select_cosmetics" ON public.cosmetic_catalog;
CREATE POLICY "select_cosmetics" ON public.cosmetic_catalog FOR SELECT USING (auth.role() = 'authenticated');
