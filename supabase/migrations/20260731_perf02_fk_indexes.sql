-- ============================================================================
-- TutorSaas — PERF-02: Índices de claves foráneas faltantes
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
-- Pegar en el SQL Editor y ejecutar (idempotente).
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_api_request_logs_user_id_fk ON public.api_request_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_room_messages_user_id_fk ON public.chat_room_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_room_participants_user_id_fk ON public.chat_room_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_assigned_moderator_id_fk ON public.chat_rooms(assigned_moderator_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_moderator_id_fk ON public.chat_rooms(moderator_id);
CREATE INDEX IF NOT EXISTS idx_conversations_language_id_fk ON public.conversations(language_id);
CREATE INDEX IF NOT EXISTS idx_daily_challenges_language_id_fk ON public.daily_challenges(language_id);
CREATE INDEX IF NOT EXISTS idx_daily_stats_language_id_fk ON public.daily_stats(language_id);
CREATE INDEX IF NOT EXISTS idx_mission_instances_template_id_fk ON public.mission_instances(template_id);
CREATE INDEX IF NOT EXISTS idx_player_event_progress_event_id_fk ON public.player_event_progress(event_id);
CREATE INDEX IF NOT EXISTS idx_player_pergaminos_user_id_fk ON public.player_pergaminos(user_id);
CREATE INDEX IF NOT EXISTS idx_pronunciation_assessments_user_id_fk ON public.pronunciation_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_created_by_user_id_fk ON public.scenarios(created_by_user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id_fk ON public.user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_language_profiles_cefr_level_id_fk ON public.user_language_profiles(cefr_level_id);
CREATE INDEX IF NOT EXISTS idx_user_language_profiles_language_id_fk ON public.user_language_profiles(language_id);
CREATE INDEX IF NOT EXISTS idx_user_scenario_goals_conversation_id_fk ON public.user_scenario_goals(conversation_id);
CREATE INDEX IF NOT EXISTS idx_user_scenario_phrases_conversation_id_fk ON public.user_scenario_phrases(conversation_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_plan_id_fk ON public.user_subscriptions(plan_id);
CREATE INDEX IF NOT EXISTS idx_user_vocabulary_vocabulary_id_fk ON public.user_vocabulary(vocabulary_id);
CREATE INDEX IF NOT EXISTS idx_weekly_stats_language_id_fk ON public.weekly_stats(language_id);

-- ============================================================================
-- Verificación: listar los índices creados (deben aparecer 21 filas).
-- ============================================================================
-- SELECT
--   schemaname,
--   tablename,
--   indexname
-- FROM pg_indexes
-- WHERE schemaname = 'public'
--   AND indexname IN (
--     'idx_api_request_logs_user_id_fk',
--     'idx_chat_room_messages_user_id_fk',
--     'idx_chat_room_participants_user_id_fk',
--     'idx_chat_rooms_assigned_moderator_id_fk',
--     'idx_chat_rooms_moderator_id_fk',
--     'idx_conversations_language_id_fk',
--     'idx_daily_challenges_language_id_fk',
--     'idx_daily_stats_language_id_fk',
--     'idx_mission_instances_template_id_fk',
--     'idx_player_event_progress_event_id_fk',
--     'idx_player_pergaminos_user_id_fk',
--     'idx_pronunciation_assessments_user_id_fk',
--     'idx_scenarios_created_by_user_id_fk',
--     'idx_user_achievements_achievement_id_fk',
--     'idx_user_language_profiles_cefr_level_id_fk',
--     'idx_user_language_profiles_language_id_fk',
--     'idx_user_scenario_goals_conversation_id_fk',
--     'idx_user_scenario_phrases_conversation_id_fk',
--     'idx_user_subscriptions_plan_id_fk',
--     'idx_user_vocabulary_vocabulary_id_fk',
--     'idx_weekly_stats_language_id_fk'
--   )
-- ORDER BY tablename, indexname;

-- SELECT
--   relname                              AS tabla,
--   indexrelname                         AS indice,
--   idx_scan                             AS escaneos,
--   idx_tup_read                         AS filas_leidas
-- FROM pg_stat_user_indexes
-- WHERE schemaname = 'public'
--   AND indexrelname LIKE 'idx_%_fk'
-- ORDER BY relname, indexrelname;
