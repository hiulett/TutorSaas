-- Phase 1: RLS Policies for 10 tables that had RLS enabled but no policies

-- 1. Catálogos (lectura pública)
CREATE POLICY "achievements_read" ON public.achievements FOR SELECT USING (true);
CREATE POLICY "objectives_read" ON public.scenario_objectives FOR SELECT USING (true);

-- 2. Usuario-propio (ALL)
CREATE POLICY "pronunciation_self" ON public.pronunciation_assessments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "payments_self" ON public.payments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "usage_logs_self" ON public.ai_usage_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "challenges_self" ON public.daily_challenges FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "daily_stats_self" ON public.daily_stats FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "weekly_stats_self" ON public.weekly_stats FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "user_achievements_self" ON public.user_achievements FOR ALL USING (auth.uid() = user_id);

-- 3. Corrections (join-chain: corrections -> messages -> conversations -> user)
CREATE POLICY "corrections_self" ON public.corrections FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.messages
    JOIN public.conversations ON conversations.id = messages.conversation_id
    WHERE messages.id = corrections.message_id
      AND conversations.user_id = auth.uid()
  )
);
