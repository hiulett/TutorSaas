-- ==========================================================
-- CREACIÓN DE TABLAS PARA SALAS DE CHAT DE VOZ Y TEXTO
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(200) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    moderator_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
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
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Supabase Realtime replication on these tables
alter publication supabase_realtime add table public.chat_rooms;
alter publication supabase_realtime add table public.chat_room_participants;
alter publication supabase_realtime add table public.chat_room_messages;
