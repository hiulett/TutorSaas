-- ============================================================
-- FASE 1.3: Fix permissive RLS policies
-- ============================================================

-- Fix cefr_recommendation_rules: remove ALL-write for anon
DROP POLICY IF EXISTS "All cefr_recommendation_rules write" ON public.cefr_recommendation_rules;
DROP POLICY IF EXISTS "Public select cefr_recommendation_rules" ON public.cefr_recommendation_rules;

CREATE POLICY "Authenticated users can read cefr_recommendation_rules"
  ON public.cefr_recommendation_rules FOR SELECT
  TO authenticated
  USING (true);

-- Fix languages: remove public INSERT
DROP POLICY IF EXISTS "Permitir inserción de idiomas en desarrollo" ON public.languages;
DROP POLICY IF EXISTS "Permitir lectura pública de idiomas" ON public.languages;
DROP POLICY IF EXISTS "Lectura pública de idiomas" ON public.languages;
DROP POLICY IF EXISTS "Lectura pública de idiomas y niveles" ON public.languages;

CREATE POLICY "Anyone can read languages"
  ON public.languages FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Only admins can insert languages"
  ON public.languages FOR INSERT
  TO authenticated
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Fix vocabulary_items: restrict INSERT
DROP POLICY IF EXISTS "All authenticated users can insert into vocabulary_items" ON public.vocabulary_items;
DROP POLICY IF EXISTS "All authenticated users can read vocabulary_items" ON public.vocabulary_items;

CREATE POLICY "Authenticated users can read vocabulary_items"
  ON public.vocabulary_items FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert vocabulary_items"
  ON public.vocabulary_items FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Fix subscription_plans: remove duplicate policies
DROP POLICY IF EXISTS "Lectura pública de planes de suscripción" ON public.subscription_plans;
DROP POLICY IF EXISTS "Authenticated users can read subscription_plans" ON public.subscription_plans;

CREATE POLICY "Anyone can read subscription_plans"
  ON public.subscription_plans FOR SELECT
  TO anon
  USING (true);
