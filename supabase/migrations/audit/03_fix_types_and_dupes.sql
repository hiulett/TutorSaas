-- =============================================================
-- MIGRACIÓN 3: Corrección de tipos y columnas duplicadas
-- =============================================================

-- 3a. speech_dna_metrics.user_id: TEXT → UUID con FK
ALTER TABLE public.speech_dna_metrics
  ALTER COLUMN user_id TYPE uuid USING user_id::uuid;

ALTER TABLE public.speech_dna_metrics
  ADD CONSTRAINT speech_dna_metrics_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

-- 3b. messages: eliminar columnas duplicadas (role = sender_role, content_text = text)
ALTER TABLE public.messages DROP COLUMN IF EXISTS role;
ALTER TABLE public.messages DROP COLUMN IF EXISTS content_text;

-- 3c. user_subscriptions.user_id: TEXT → UUID
ALTER TABLE public.user_subscriptions
  ALTER COLUMN user_id TYPE uuid USING user_id::uuid;

-- 3d. Agregar updated_at faltante
ALTER TABLE public.user_vocabulary ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.vocabulary_items ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.chat_room_participants ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.chat_room_messages ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.user_achievements ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.daily_challenges ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.achievements ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.scenario_objectives ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.corrections ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
ALTER TABLE public.pronunciation_assessments ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- 3e. Trigger automático para updated_at
CREATE OR REPLACE FUNCTION public.trigger_set_timestamps()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT table_name FROM information_schema.columns
    WHERE column_name = 'updated_at' AND table_schema = 'public'
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS set_updated_at ON public.%I;
       CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.%I
       FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamps()',
      tbl, tbl
    );
  END LOOP;
END;
$$;

SELECT 'Migración 3 completada' AS result;
