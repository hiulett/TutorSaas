-- ============================================================================
-- SCRIPT COMPLETO: Sistema de Chat, Moderación y Guild Hall
-- Ejecutar en orden en el SQL Editor de Supabase
-- ============================================================================

-- 1. CREACIÓN DE TABLAS (si no existen)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(200) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    moderator_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    moderator_type  TEXT NOT NULL DEFAULT 'ai' CHECK (moderator_type IN ('ai', 'creator', 'assigned')),
    assigned_moderator_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.chat_room_participants (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id         UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    is_speaker      BOOLEAN DEFAULT FALSE,
    speaker_slot    INTEGER NULL CHECK (speaker_slot BETWEEN 1 AND 10),
    joined_at       TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_id, speaker_slot),
    UNIQUE(room_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.chat_room_messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id         UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    message_text    TEXT NOT NULL,
    message_type    TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'system', 'moderation')),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 2. MIGRACIONES PARA TABLAS EXISTENTES
-- ============================================================================

-- Agregar columnas si no existen (para tablas ya creadas)
ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS moderator_type TEXT NOT NULL DEFAULT 'ai';

ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS assigned_moderator_id UUID REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS description TEXT;

ALTER TABLE public.chat_rooms 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.chat_room_messages 
ADD COLUMN IF NOT EXISTS message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'system', 'moderation'));

-- Drop and recreate constraint to avoid duplicate
ALTER TABLE public.chat_rooms DROP CONSTRAINT IF EXISTS chat_rooms_moderator_type_check;
ALTER TABLE public.chat_rooms 
ADD CONSTRAINT chat_rooms_moderator_type_check 
CHECK (moderator_type IN ('ai', 'creator', 'assigned'));

-- 3. CREAR FOREIGN KEYS (si no existen)
-- ============================================================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chat_rooms_assigned_moderator_id_fkey'
    ) THEN
        ALTER TABLE public.chat_rooms
        ADD CONSTRAINT chat_rooms_assigned_moderator_id_fkey
        FOREIGN KEY (assigned_moderator_id) REFERENCES public.users(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 4. REALTIME (habilitar suscripciones en tiempo real)
-- ============================================================================
alter publication supabase_realtime add table public.chat_rooms;
alter publication supabase_realtime add table public.chat_room_participants;
alter publication supabase_realtime add table public.chat_room_messages;

-- 5. RLS (Row Level Security) - Permitir acceso autenticado
-- ============================================================================
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuarios autenticados pueden leer salas" ON public.chat_rooms;
CREATE POLICY "Usuarios autenticados pueden leer salas" ON public.chat_rooms
    FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Usuarios autenticados pueden crear salas" ON public.chat_rooms;
CREATE POLICY "Usuarios autenticados pueden crear salas" ON public.chat_rooms
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Creador o moderador pueden actualizar sala" ON public.chat_rooms;
CREATE POLICY "Creador o moderador pueden actualizar sala" ON public.chat_rooms
    FOR UPDATE USING (auth.uid() = moderator_id OR auth.uid() = assigned_moderator_id);

DROP POLICY IF EXISTS "Usuarios autenticados pueden leer participantes" ON public.chat_room_participants;
CREATE POLICY "Usuarios autenticados pueden leer participantes" ON public.chat_room_participants
    FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Usuarios autenticados pueden unirse" ON public.chat_room_participants;
CREATE POLICY "Usuarios autenticados pueden unirse" ON public.chat_room_participants
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Usuarios pueden abandonar" ON public.chat_room_participants;
CREATE POLICY "Usuarios pueden abandonar" ON public.chat_room_participants
    FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Moderador puede remover participantes" ON public.chat_room_participants;
CREATE POLICY "Moderador puede remover participantes" ON public.chat_room_participants
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.chat_rooms 
            WHERE id = chat_room_participants.room_id 
            AND (moderator_id = auth.uid() OR assigned_moderator_id = auth.uid())
        )
    );

DROP POLICY IF EXISTS "Usuarios autenticados pueden leer mensajes" ON public.chat_room_messages;
CREATE POLICY "Usuarios autenticados pueden leer mensajes" ON public.chat_room_messages
    FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Usuarios autenticados pueden enviar mensajes" ON public.chat_room_messages;
CREATE POLICY "Usuarios autenticados pueden enviar mensajes" ON public.chat_room_messages
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 6. PRECIOS AGRESIVOS (Subscription Plans)
-- ============================================================================
INSERT INTO subscription_plans (id, name, price, billing_cycle, monthly_audio_minutes_limit, order_index, description, badge_tag, features, is_active)
VALUES
    ('free', 'Plan Gratuito', '$0.00', 'monthly', 30, 1, 'Practica gratis con límites diarios', 'BÁSICO', '["5 conversaciones con IA/día","Corrección gramatical básica","Acceso al mapa de mazmorras","1 examen boss/semana","Historial de 7 días"]'::jsonb, true),
    ('monthly', 'Plan Mensual', '$1.99', 'monthly', 300, 2, 'Acceso completo por el precio de un café', 'MÁS ECONÓMICO', '["Conversaciones IA ilimitadas","Corrección gramatical avanzada","Speech DNA completo","Blind Listening ilimitado","Modo Boss ilimitado","Historial ilimitado"]'::jsonb, true),
    ('annual', 'Plan Anual', '$14.99', 'annual', 1200, 3, 'Menos de $1.25/mes — el mejor valor', 'AHORRA 37%', '["Todo lo del plan mensual","1.200 min/mes de audio IA","Títulos y cosméticos exclusivos","Battle Pass incluido","Soporte prioritario"]'::jsonb, true),
    ('lifetime', 'Acceso Vitalicio', '$29.99', 'lifetime', 600, 4, 'Pago único, beneficios de por vida', 'ACCESO TOTAL', '["Todo lo del plan anual","600 min/mes de por vida","Todos los cosméticos futuros","Acceso a expansiones premium","Prioridad máxima en servidores"]'::jsonb, true)
ON CONFLICT (id) DO UPDATE SET
    price = EXCLUDED.price,
    monthly_audio_minutes_limit = EXCLUDED.monthly_audio_minutes_limit,
    badge_tag = EXCLUDED.badge_tag,
    features = EXCLUDED.features,
    description = EXCLUDED.description,
    is_active = true;

-- 7. COLUMNA equipped_title_code (para status window)
-- ============================================================================
ALTER TABLE user_language_profiles 
ADD COLUMN IF NOT EXISTS equipped_title_code text DEFAULT 'oido_halcon_abismo_c';
