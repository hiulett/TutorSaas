-- Fix conversations.scenario_id to accept catalog string IDs (e.g. 'a1_greetings')
-- instead of requiring a UUID FK to scenarios table.
ALTER TABLE public.conversations
  DROP CONSTRAINT IF EXISTS conversations_scenario_id_fkey;

ALTER TABLE public.conversations
  ALTER COLUMN scenario_id TYPE VARCHAR(50),
  ALTER COLUMN scenario_id DROP NOT NULL;

-- Add progress tracking column (0.0 – 1.0)
ALTER TABLE public.conversations
  ADD COLUMN IF NOT EXISTS progress DOUBLE PRECISION DEFAULT 0;

-- Make sequence_number optional so existing code doesn't break
ALTER TABLE public.messages
  ALTER COLUMN sequence_number DROP NOT NULL,
  ALTER COLUMN sequence_number SET DEFAULT 0;
