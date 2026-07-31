-- =============================================================
-- MIGRACIÓN 1: Trigger handle_new_user + RLS Chat Rooms
-- =============================================================
-- Ejecutar en: https://supabase.com/dashboard/project/sipiumfdpvnszthykyog/sql/new
-- Fecha: 2026-07-28
-- =============================================================

-- 1a. Función para sincronizar auth.users → public.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', split_part(NEW.email, '@', 1))
  );
  INSERT INTO public.user_settings (user_id) VALUES (NEW.id);
  INSERT INTO public.user_language_profiles (user_id, language_id, cefr_level_id)
  VALUES (NEW.id, 1, 1);
  RETURN NEW;
END;
$$;

-- 1b. Trigger sobre auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 1c. RLS en tablas de chat
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_messages ENABLE ROW LEVEL SECURITY;

-- 1d. Policies para chat_rooms
DROP POLICY IF EXISTS "Anyone can read rooms" ON public.chat_rooms;
CREATE POLICY "Anyone can read rooms" ON public.chat_rooms
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated can create rooms" ON public.chat_rooms;
CREATE POLICY "Authenticated can create rooms" ON public.chat_rooms
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 1e. Policies para chat_room_participants
DROP POLICY IF EXISTS "Participants can read their rooms" ON public.chat_room_participants;
CREATE POLICY "Participants can read their rooms" ON public.chat_room_participants
  FOR SELECT USING (auth.uid() = user_id OR auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can join rooms" ON public.chat_room_participants;
CREATE POLICY "Users can join rooms" ON public.chat_room_participants
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 1f. Policies para chat_room_messages
DROP POLICY IF EXISTS "Participants can read messages" ON public.chat_room_messages;
CREATE POLICY "Participants can read messages" ON public.chat_room_messages
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.chat_room_participants
    WHERE room_id = chat_room_messages.room_id AND user_id = auth.uid()
  ));

DROP POLICY IF EXISTS "Participants can send messages" ON public.chat_room_messages;
CREATE POLICY "Participants can send messages" ON public.chat_room_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Verificación
SELECT 'Migración 1 completada' AS result;
