-- ============================================================================
-- TutorSaas — SEC-01: Restringir políticas RLS de datos de usuario a authenticated
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
--
-- PROBLEMA: las políticas RLS creadas sin `TO <rol>` aplican a PUBLIC (rol 0),
-- por lo que usuarios ANÓNIMOS pueden intentar acceder a datos de usuario.
-- PostgreSQL permite cambiar el rol destino con ALTER POLICY (sin reconstruir
-- la expresión).
--
-- Este script restringe a `authenticated` TODAS las políticas de tablas con
-- datos de usuario. Los catálogos públicos (cefr_levels, scenarios,
-- cosmetic_catalog, etc.) se DEJAN como están (lectura anónima correcta).
--
-- ⚠️ IMPORTANTE: los nombres de política con espacios deben ir entre comillas
-- dobles. Ejecutar TODO el script.
-- ============================================================================

-- ── Datos de progreso / perfil ─────────────────────────────────────────────
ALTER POLICY conversations_self ON public.conversations TO authenticated;
ALTER POLICY messages_self ON public.messages TO authenticated;
ALTER POLICY corrections_self ON public.corrections TO authenticated;
ALTER POLICY profiles_self ON public.user_language_profiles TO authenticated;
ALTER POLICY user_settings_self ON public.user_settings TO authenticated;
ALTER POLICY ai_profiles_self ON public.user_ai_profiles TO authenticated;
ALTER POLICY users_read ON public.users TO authenticated;
ALTER POLICY users_self ON public.users TO authenticated;
ALTER POLICY subscriptions_self ON public.user_subscriptions TO authenticated;
ALTER POLICY vocab_self ON public.user_vocabulary TO authenticated;
ALTER POLICY scenario_goals_self ON public.user_scenario_goals TO authenticated;
ALTER POLICY scenario_phrases_self ON public.user_scenario_phrases TO authenticated;
ALTER POLICY scenario_fluency_self ON public.user_scenario_fluency TO authenticated;
ALTER POLICY user_achievements_self ON public.user_achievements TO authenticated;
ALTER POLICY dna_self ON public.speech_dna_metrics TO authenticated;
ALTER POLICY pronunciation_self ON public.pronunciation_assessments TO authenticated;
ALTER POLICY fluency_self ON public.daily_fluency_stats TO authenticated;
ALTER POLICY daily_stats_self ON public.daily_stats TO authenticated;
ALTER POLICY weekly_stats_self ON public.weekly_stats TO authenticated;
ALTER POLICY challenges_self ON public.daily_challenges TO authenticated;
ALTER POLICY usage_logs_self ON public.ai_usage_logs TO authenticated;
ALTER POLICY logs_self ON public.api_request_logs TO authenticated;

-- ── Misiones ───────────────────────────────────────────────────────────────
ALTER POLICY select_own_instances ON public.mission_instances TO authenticated;
ALTER POLICY insert_own_instances ON public.mission_instances TO authenticated;
ALTER POLICY update_own_instances ON public.mission_instances TO authenticated;
ALTER POLICY select_own_secret ON public.secret_missions TO authenticated;
ALTER POLICY select_own_rewards ON public.reward_history TO authenticated;
ALTER POLICY insert_own_rewards ON public.reward_history TO authenticated;
ALTER POLICY select_guild_collab ON public.guild_collaborative_missions TO authenticated;

-- ── Economía / inventario ──────────────────────────────────────────────────
ALTER POLICY select_own_inventory ON public.player_inventory TO authenticated;
ALTER POLICY select_own_daily ON public.player_daily_state TO authenticated;
ALTER POLICY insert_own_daily ON public.player_daily_state TO authenticated;
ALTER POLICY update_own_daily ON public.player_daily_state TO authenticated;
ALTER POLICY select_own_streaks ON public.player_streaks TO authenticated;
ALTER POLICY update_own_streaks ON public.player_streaks TO authenticated;
ALTER POLICY upsert_own_streaks ON public.player_streaks TO authenticated;
ALTER POLICY select_own_pergaminos ON public.player_pergaminos TO authenticated;
ALTER POLICY select_own_bp ON public.guild_battle_pass TO authenticated;
ALTER POLICY upsert_own_bp ON public.guild_battle_pass TO authenticated;
ALTER POLICY select_own_completed_quests ON public.player_completed_quests TO authenticated;
ALTER POLICY insert_own_completed_quests ON public.player_completed_quests TO authenticated;
ALTER POLICY select_own_events ON public.player_event_progress TO authenticated;
ALTER POLICY insert_own_events ON public.player_event_progress TO authenticated;

-- ── Pagos ──────────────────────────────────────────────────────────────────
ALTER POLICY payments_self ON public.payments TO authenticated;

-- ── Gremio (salas) ─────────────────────────────────────────────────────────
-- "Anyone can read rooms": lectura de salas compartida entre autenticados.
ALTER POLICY "Anyone can read rooms" ON public.chat_rooms TO authenticated;
ALTER POLICY "Authenticated can create rooms" ON public.chat_rooms TO authenticated;
ALTER POLICY "Participants can read their rooms" ON public.chat_room_participants TO authenticated;
ALTER POLICY "Users can join rooms" ON public.chat_room_participants TO authenticated;
ALTER POLICY "Participants can read messages" ON public.chat_room_messages TO authenticated;
ALTER POLICY "Participants can send messages" ON public.chat_room_messages TO authenticated;

-- ═══ Verificación (debe devolver 0 para anon en tablas de usuario) ═════════
-- SELECT c.relname, p.polname FROM pg_policy p
--   JOIN pg_class c ON c.oid=p.polrelid
--   WHERE c.relnamespace='public'::regnamespace
--     AND p.polroles::text='{0}'
--     AND c.relname IN ('payments','conversations','messages','user_settings',
--       'mission_instances','player_inventory','user_subscriptions');
