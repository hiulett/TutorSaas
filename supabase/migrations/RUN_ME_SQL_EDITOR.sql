-- ============================================================
-- TutorSaas — Phase 1: RLS Policies Faltantes
-- ============================================================
-- Instrucciones para AI Agent:
--
-- 1. Ir a https://supabase.com/dashboard/project/sipiumfdpvnszthykyog
-- 2. Abrir SQL Editor
-- 3. Pegar TODO este archivo y ejecutar
-- 4. Confirmar que no hay errores (las 10 políticas deben crearse)
--
-- O via Supabase CLI:
--   supabase db push --linked
--
-- ============================================================

-- 1. Catálogos públicos (lectura para todos)
CREATE POLICY "achievements_read" ON public.achievements FOR SELECT USING (true);
CREATE POLICY "objectives_read" ON public.scenario_objectives FOR SELECT USING (true);

-- 2. Datos propios del usuario (solo ver/editar lo suyo)
CREATE POLICY "pronunciation_self" ON public.pronunciation_assessments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "payments_self" ON public.payments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "usage_logs_self" ON public.ai_usage_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "challenges_self" ON public.daily_challenges FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "daily_stats_self" ON public.daily_stats FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "weekly_stats_self" ON public.weekly_stats FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "user_achievements_self" ON public.user_achievements FOR ALL USING (auth.uid() = user_id);

-- 3. Corrections (join a través de messages → conversations)
CREATE POLICY "corrections_self" ON public.corrections FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.messages
    JOIN public.conversations ON conversations.id = messages.conversation_id
    WHERE messages.id = corrections.message_id
      AND conversations.user_id = auth.uid()
  )
);
