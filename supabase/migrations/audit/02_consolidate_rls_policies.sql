-- =============================================================
-- MIGRACIÓN 2: Limpiar policies duplicadas y sobre-permisivas
-- =============================================================
-- Elimina policies redundantes y reemplaza con una por operación.
-- =============================================================

-- 2a. user_settings
DROP POLICY IF EXISTS "Public user settings access" ON public.user_settings;
DROP POLICY IF EXISTS "Allow public select user_settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users manage own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Usuario gestiona sus propios ajustes" ON public.user_settings;
CREATE POLICY "user_settings_self" ON public.user_settings
  FOR ALL USING (auth.uid() = user_id);

-- 2b. user_language_profiles
DROP POLICY IF EXISTS "Allow public select user_language_profiles" ON public.user_language_profiles;
DROP POLICY IF EXISTS "Usuarios pueden gestionar su propio perfil" ON public.user_language_profiles;
DROP POLICY IF EXISTS "Public language profiles access" ON public.user_language_profiles;
DROP POLICY IF EXISTS "Usuario gestiona su perfil de idioma" ON public.user_language_profiles;
DROP POLICY IF EXISTS "Allow public select" ON public.user_language_profiles;
CREATE POLICY "profiles_self" ON public.user_language_profiles
  FOR ALL USING (auth.uid() = user_id);

-- 2c. daily_fluency_stats
DROP POLICY IF EXISTS "Permitir todo a usuarios en daily_fluency_stats" ON public.daily_fluency_stats;
CREATE POLICY "fluency_self" ON public.daily_fluency_stats
  FOR ALL USING (auth.uid() = user_id);

-- 2d. speech_dna_metrics
DROP POLICY IF EXISTS "All speech_dna_metrics write" ON public.speech_dna_metrics;
DROP POLICY IF EXISTS "Public select speech_dna_metrics" ON public.speech_dna_metrics;
DROP POLICY IF EXISTS "Allow public select speech_dna_metrics" ON public.speech_dna_metrics;
CREATE POLICY "dna_self" ON public.speech_dna_metrics
  FOR ALL USING (auth.uid() = user_id::uuid);

-- 2e. user_subscriptions
DROP POLICY IF EXISTS "Public select user_subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Public all user_subscriptions" ON public.user_subscriptions;
CREATE POLICY "subscriptions_self" ON public.user_subscriptions
  FOR ALL USING (auth.uid() = user_id::uuid);

-- 2f. users
DROP POLICY IF EXISTS "Allow update on users" ON public.users;
DROP POLICY IF EXISTS "Allow select on users" ON public.users;
DROP POLICY IF EXISTS "Public users full access" ON public.users;
CREATE POLICY "users_read" ON public.users FOR SELECT USING (true);
CREATE POLICY "users_self" ON public.users
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 2g. scenarios
DROP POLICY IF EXISTS "Lectura pública de escenarios activos" ON public.scenarios;
CREATE POLICY "scenarios_read" ON public.scenarios
  FOR SELECT USING (is_active = true);

-- 2h. cefr_levels (solo lectura pública, sin escritura pública)
DROP POLICY IF EXISTS "Lectura pública de niveles CEFR" ON public.cefr_levels;
DROP POLICY IF EXISTS "Permitir inserción de niveles en desarrollo" ON public.cefr_levels;
DROP POLICY IF EXISTS "Permitir lectura pública de niveles" ON public.cefr_levels;
DROP POLICY IF EXISTS "Public select cefr_levels" ON public.cefr_levels;
DROP POLICY IF EXISTS "All cefr_levels write" ON public.cefr_levels;
CREATE POLICY "cefr_read" ON public.cefr_levels FOR SELECT USING (true);

-- 2i. subscription_plans (solo lectura)
DROP POLICY IF EXISTS "Public all subscription_plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Lectura pública de planes" ON public.subscription_plans;
DROP POLICY IF EXISTS "Public select subscription_plans" ON public.subscription_plans;
CREATE POLICY "plans_read" ON public.subscription_plans FOR SELECT USING (true);

-- 2j. user_vocabulary
DROP POLICY IF EXISTS "Users can insert their own user_vocabulary" ON public.user_vocabulary;
DROP POLICY IF EXISTS "Users can read their own user_vocabulary" ON public.user_vocabulary;
DROP POLICY IF EXISTS "Usuario gestiona su vocabulario" ON public.user_vocabulary;
DROP POLICY IF EXISTS "Users can update their own user_vocabulary" ON public.user_vocabulary;
CREATE POLICY "vocab_self" ON public.user_vocabulary
  FOR ALL USING (auth.uid() = user_id);

-- 2k. conversaciones
DROP POLICY IF EXISTS "Users can update their own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can read their own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can insert their own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Usuario gestiona sus conversaciones" ON public.conversations;
CREATE POLICY "conversations_self" ON public.conversations
  FOR ALL USING (auth.uid() = user_id);

-- 2l. messages
DROP POLICY IF EXISTS "Users can read messages from their conversations" ON public.messages;
DROP POLICY IF EXISTS "Users can insert messages in their conversations" ON public.messages;
DROP POLICY IF EXISTS "Permitir todo a usuarios en messages" ON public.messages;
CREATE POLICY "messages_self" ON public.messages
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.conversations WHERE id = messages.conversation_id AND user_id = auth.uid())
  );

-- 2m. user_ai_profiles
DROP POLICY IF EXISTS "Usuario gestiona su perfil de IA" ON public.user_ai_profiles;
CREATE POLICY "ai_profiles_self" ON public.user_ai_profiles
  FOR ALL USING (auth.uid() = user_id);

-- 2n. user_scenario_*
DROP POLICY IF EXISTS "Permitir todo a usuarios en user_scenario_fluency" ON public.user_scenario_fluency;
CREATE POLICY "scenario_fluency_self" ON public.user_scenario_fluency
  FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Permitir todo a usuarios en user_scenario_goals" ON public.user_scenario_goals;
CREATE POLICY "scenario_goals_self" ON public.user_scenario_goals
  FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Permitir todo a usuarios en user_scenario_phrases" ON public.user_scenario_phrases;
CREATE POLICY "scenario_phrases_self" ON public.user_scenario_phrases
  FOR ALL USING (auth.uid() = user_id);

-- 2o. system_ai_settings (solo lectura)
DROP POLICY IF EXISTS "All system_ai_settings write" ON public.system_ai_settings;
DROP POLICY IF EXISTS "Public select system_ai_settings" ON public.system_ai_settings;
CREATE POLICY "ai_settings_read" ON public.system_ai_settings FOR SELECT USING (true);

-- 2p. api_request_logs
DROP POLICY IF EXISTS "Users can insert their own request logs" ON public.api_request_logs;
DROP POLICY IF EXISTS "Users can view their own request logs" ON public.api_request_logs;
CREATE POLICY "logs_self" ON public.api_request_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

SELECT 'Migración 2 completada' AS result;
