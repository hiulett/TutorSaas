-- ============================================================================
-- TutorSaas — PERF-04: Eliminación de índices duplicados/sobrelapados
-- detectados por los Advisors de performance de Supabase.
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
-- Pegar en el SQL Editor y ejecutar (idempotente).
-- Criterio: conservar el índice de mayor cobertura (_hot / compuesto con
-- fecha) y dropear el simple. Cada DROP vive dentro de un bloque DO guardado
-- por to_regclass y, además, se verifica en pg_indexes que el índice de
-- cobertura exista realmente; si no existe, NO se dropea el simple.
-- ============================================================================

-- 1. ai_usage_logs: idx_ai_usage_logs_user (simple) es prefijo del compuesto
--    idx_ai_usage_user_date → DROP del simple, conservar el compuesto.
DO $$
BEGIN
  IF to_regclass('public.ai_usage_logs') IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM pg_indexes
       WHERE schemaname = 'public'
         AND tablename  = 'ai_usage_logs'
         AND indexname  = 'idx_ai_usage_user_date'
     )
  THEN
    EXECUTE 'DROP INDEX IF EXISTS public.idx_ai_usage_logs_user';
  END IF;
END $$;

-- 2. chat_room_messages: idx_chat_room_messages_room (simple) está cubierto
--    por idx_chat_room_messages_room_id_hot (room_id, created_at) → DROP del
--    simple.
DO $$
BEGIN
  IF to_regclass('public.chat_room_messages') IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM pg_indexes
       WHERE schemaname = 'public'
         AND tablename  = 'chat_room_messages'
         AND indexname  = 'idx_chat_room_messages_room_id_hot'
     )
  THEN
    EXECUTE 'DROP INDEX IF EXISTS public.idx_chat_room_messages_room';
  END IF;
END $$;

-- 3. chat_room_participants: idx_chat_room_participants_room (simple) está
--    cubierto por idx_chat_room_participants_room_id_hot (room_id) → DROP del
--    simple.
DO $$
BEGIN
  IF to_regclass('public.chat_room_participants') IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM pg_indexes
       WHERE schemaname = 'public'
         AND tablename  = 'chat_room_participants'
         AND indexname  = 'idx_chat_room_participants_room_id_hot'
     )
  THEN
    EXECUTE 'DROP INDEX IF EXISTS public.idx_chat_room_participants_room';
  END IF;
END $$;

-- 4. user_language_profiles: idx_user_language_profiles_user (simple,
--    pre-existente) duplica a idx_user_language_profiles_user_id_hot → DROP
--    del simple, conservar el _hot (el que usa la app).
DO $$
BEGIN
  IF to_regclass('public.user_language_profiles') IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM pg_indexes
       WHERE schemaname = 'public'
         AND tablename  = 'user_language_profiles'
         AND indexname  = 'idx_user_language_profiles_user_id_hot'
     )
  THEN
    EXECUTE 'DROP INDEX IF EXISTS public.idx_user_language_profiles_user';
  END IF;
END $$;

-- 5. user_vocabulary: idx_user_vocabulary_user_id (simple) duplica a
--    idx_user_vocabulary_user_id_hot → DROP del simple, conservar el _hot.
DO $$
BEGIN
  IF to_regclass('public.user_vocabulary') IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM pg_indexes
       WHERE schemaname = 'public'
         AND tablename  = 'user_vocabulary'
         AND indexname  = 'idx_user_vocabulary_user_id_hot'
     )
  THEN
    EXECUTE 'DROP INDEX IF EXISTS public.idx_user_vocabulary_user_id';
  END IF;
END $$;

-- ============================================================================
-- Verificación: los índices simples deben haber desaparecido y los de
-- cobertura deben seguir presentes (debe devolver 5 filas).
-- ============================================================================
-- SELECT
--   schemaname,
--   tablename,
--   indexname
-- FROM pg_indexes
-- WHERE schemaname = 'public'
--   AND indexname IN (
--     'idx_ai_usage_user_date',
--     'idx_chat_room_messages_room_id_hot',
--     'idx_chat_room_participants_room_id_hot',
--     'idx_user_language_profiles_user_id_hot',
--     'idx_user_vocabulary_user_id_hot'
--   )
-- ORDER BY tablename, indexname;
