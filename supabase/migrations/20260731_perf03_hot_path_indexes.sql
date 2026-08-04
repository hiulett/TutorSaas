-- ============================================================================
-- TutorSaas — PERF-03: Índices de rendimiento en tablas de alta escritura
-- y consultas frecuentes (hot paths).
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
-- Pegar en el SQL Editor y ejecutar (idempotente).
-- Cada índice vive dentro de un bloque DO guardado por to_regclass, de modo
-- que no falle aunque alguna tabla base no exista todavía.
-- Nomenclatura: idx_<tabla>_<columna>_hot
-- ============================================================================

-- 1. Perfil de idioma por usuario
DO $$
BEGIN
  IF to_regclass('public.user_language_profiles') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_user_language_profiles_user_id_hot ON public.user_language_profiles(user_id)';
  END IF;
END $$;

-- 2. Estado diario del jugador por usuario
DO $$
BEGIN
  IF to_regclass('public.player_daily_state') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_player_daily_state_user_id_hot ON public.player_daily_state(user_id)';
  END IF;
END $$;

-- 3. Progreso del usuario
DO $$
BEGIN
  IF to_regclass('public.user_progress') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_user_progress_user_id_hot ON public.user_progress(user_id)';
  END IF;
END $$;

-- 4. Vocabulario del usuario
DO $$
BEGIN
  IF to_regclass('public.user_vocabulary') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_user_vocabulary_user_id_hot ON public.user_vocabulary(user_id)';
  END IF;
END $$;

-- 5. Logs recientes de API
DO $$
BEGIN
  IF to_regclass('public.api_request_logs') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_api_request_logs_created_at_hot ON public.api_request_logs(created_at DESC)';
  END IF;
END $$;

-- 6. Historial ordenado por conversación
DO $$
BEGIN
  IF to_regclass('public.conversation_messages') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_conversation_messages_conversation_id_hot ON public.conversation_messages(conversation_id, created_at)';
  END IF;
END $$;

-- 7. Últimos mensajes del usuario
DO $$
BEGIN
  IF to_regclass('public.conversation_messages') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_conversation_messages_user_id_hot ON public.conversation_messages(user_id, created_at)';
  END IF;
END $$;

-- 8. Misiones por usuario
DO $$
BEGIN
  IF to_regclass('public.mission_instances') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_mission_instances_user_id_hot ON public.mission_instances(user_id)';
  END IF;
END $$;

-- 9. Misiones por estado
DO $$
BEGIN
  IF to_regclass('public.mission_instances') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_mission_instances_status_hot ON public.mission_instances(status)';
  END IF;
END $$;

-- 10. Logros por usuario
DO $$
BEGIN
  IF to_regclass('public.user_achievements') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id_hot ON public.user_achievements(user_id)';
  END IF;
END $$;

-- 11. Metas del usuario
DO $$
BEGIN
  IF to_regclass('public.user_scenario_goals') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_user_scenario_goals_user_id_hot ON public.user_scenario_goals(user_id)';
  END IF;
END $$;

-- 12. Frases del usuario (si la tabla existe)
DO $$
BEGIN
  IF to_regclass('public.user_phrase_progress') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_user_phrase_progress_user_id_hot ON public.user_phrase_progress(user_id)';
  END IF;
END $$;

-- 13. Historial de la sala de chat
DO $$
BEGIN
  IF to_regclass('public.chat_room_messages') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_chat_room_messages_room_id_hot ON public.chat_room_messages(room_id, created_at)';
  END IF;
END $$;

-- 14. Participantes por sala
DO $$
BEGIN
  IF to_regclass('public.chat_room_participants') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_chat_room_participants_room_id_hot ON public.chat_room_participants(room_id)';
  END IF;
END $$;

-- 15. Suscripciones por usuario
DO $$
BEGIN
  IF to_regclass('public.user_subscriptions') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id_hot ON public.user_subscriptions(user_id)';
  END IF;
END $$;

-- 16. Progreso de eventos por usuario
DO $$
BEGIN
  IF to_regclass('public.player_event_progress') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_player_event_progress_user_id_hot ON public.player_event_progress(user_id)';
  END IF;
END $$;

-- ============================================================================
-- Verificación: listar los índices creados (deben aparecer 16 filas).
-- ============================================================================
-- SELECT
--   schemaname,
--   tablename,
--   indexname
-- FROM pg_indexes
-- WHERE schemaname = 'public'
--   AND indexname IN (
--     'idx_user_language_profiles_user_id_hot',
--     'idx_player_daily_state_user_id_hot',
--     'idx_user_progress_user_id_hot',
--     'idx_user_vocabulary_user_id_hot',
--     'idx_api_request_logs_created_at_hot',
--     'idx_conversation_messages_conversation_id_hot',
--     'idx_conversation_messages_user_id_hot',
--     'idx_mission_instances_user_id_hot',
--     'idx_mission_instances_status_hot',
--     'idx_user_achievements_user_id_hot',
--     'idx_user_scenario_goals_user_id_hot',
--     'idx_user_phrase_progress_user_id_hot',
--     'idx_chat_room_messages_room_id_hot',
--     'idx_chat_room_participants_room_id_hot',
--     'idx_user_subscriptions_user_id_hot',
--     'idx_player_event_progress_user_id_hot'
--   )
-- ORDER BY tablename, indexname;
