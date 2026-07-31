-- =============================================================
-- MIGRACIÓN 4: Índices de performance
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_status ON public.conversations(status);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sequence ON public.messages(conversation_id, sequence_number);
CREATE INDEX IF NOT EXISTS idx_daily_stats_user_date ON public.daily_stats(user_id, date);
CREATE INDEX IF NOT EXISTS idx_weekly_stats_user_week ON public.weekly_stats(user_id, week_start);
CREATE INDEX IF NOT EXISTS idx_daily_fluency_user_date ON public.daily_fluency_stats(user_id, date);
CREATE INDEX IF NOT EXISTS idx_user_vocabulary_user_id ON public.user_vocabulary(user_id);
CREATE INDEX IF NOT EXISTS idx_user_vocabulary_review ON public.user_vocabulary(user_id, next_review_at);
CREATE INDEX IF NOT EXISTS idx_user_scenario_goals_scenario ON public.user_scenario_goals(user_id, scenario_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_language_level ON public.scenarios(language_id, difficulty_level);
CREATE INDEX IF NOT EXISTS idx_user_language_profiles_user ON public.user_language_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_room_participants_room ON public.chat_room_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_room_messages_room ON public.chat_room_messages(room_id, created_at);
CREATE INDEX IF NOT EXISTS idx_ai_usage_logs_user ON public.ai_usage_logs(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_payments_user ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_challenges_user ON public.daily_challenges(user_id, date);

SELECT 'Migración 4 completada — ' || count(*)::text || ' índices creados' AS result FROM pg_indexes WHERE tablename IN ('conversations','messages','daily_stats','weekly_stats','daily_fluency_stats','user_vocabulary','user_scenario_goals','scenarios','user_language_profiles','chat_room_participants','chat_room_messages','ai_usage_logs','payments','daily_challenges') AND indexname LIKE 'idx_%';
