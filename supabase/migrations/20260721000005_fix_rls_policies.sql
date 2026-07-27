-- ==========================================================
-- VERIFICAR/GARANTIZAR RLS POLICIES PARA ONBOARDING
-- ==========================================================

-- Asegurar que usuarios autenticados pueden insertar en user_language_profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_language_profiles' AND policyname = 'Users can insert their own language profile'
  ) THEN
    CREATE POLICY "Users can insert their own language profile"
      ON public.user_language_profiles FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_settings' AND policyname = 'Users can insert their own settings'
  ) THEN
    CREATE POLICY "Users can insert their own settings"
      ON public.user_settings FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_language_profiles' AND policyname = 'Users can read their own language profile'
  ) THEN
    CREATE POLICY "Users can read their own language profile"
      ON public.user_language_profiles FOR SELECT
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_settings' AND policyname = 'Users can read their own settings'
  ) THEN
    CREATE POLICY "Users can read their own settings"
      ON public.user_settings FOR SELECT
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;
END $$;

-- Also enable RLS on these tables if not already enabled
ALTER TABLE public.user_language_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
