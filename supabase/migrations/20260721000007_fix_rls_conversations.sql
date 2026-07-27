-- ==========================================================
-- AGREGAR RLS POLICIES PARA CONVERSATIONS Y MESSAGES
-- ==========================================================

-- Enable RLS on conversations
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

-- Policy: users can SELECT their own conversations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'conversations' AND policyname = 'Users can read their own conversations'
  ) THEN
    CREATE POLICY "Users can read their own conversations"
      ON public.conversations FOR SELECT
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;
END $$;

-- Policy: users can INSERT their own conversations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'conversations' AND policyname = 'Users can insert their own conversations'
  ) THEN
    CREATE POLICY "Users can insert their own conversations"
      ON public.conversations FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- Policy: users can UPDATE their own conversations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'conversations' AND policyname = 'Users can update their own conversations'
  ) THEN
    CREATE POLICY "Users can update their own conversations"
      ON public.conversations FOR UPDATE
      TO authenticated
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- Enable RLS on messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policy: users can SELECT messages from their own conversations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'Users can read messages from their conversations'
  ) THEN
    CREATE POLICY "Users can read messages from their conversations"
      ON public.messages FOR SELECT
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM public.conversations
          WHERE conversations.id = messages.conversation_id
          AND conversations.user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Policy: users can INSERT messages in their own conversations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'Users can insert messages in their conversations'
  ) THEN
    CREATE POLICY "Users can insert messages in their conversations"
      ON public.messages FOR INSERT
      TO authenticated
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.conversations
          WHERE conversations.id = messages.conversation_id
          AND conversations.user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- ==========================================================
-- vocabulary_items es un diccionario global (sin user_id)
-- Se permite SELECT/INSERT a todos los autenticados
-- ==========================================================

ALTER TABLE public.vocabulary_items ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'vocabulary_items' AND policyname = 'All authenticated users can read vocabulary_items'
  ) THEN
    CREATE POLICY "All authenticated users can read vocabulary_items"
      ON public.vocabulary_items FOR SELECT
      TO authenticated
      USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'vocabulary_items' AND policyname = 'All authenticated users can insert into vocabulary_items'
  ) THEN
    CREATE POLICY "All authenticated users can insert into vocabulary_items"
      ON public.vocabulary_items FOR INSERT
      TO authenticated
      WITH CHECK (true);
  END IF;
END $$;

-- ==========================================================
-- AGREGAR RLS POLICIES PARA USER_VOCABULARY
-- ==========================================================

ALTER TABLE public.user_vocabulary ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_vocabulary' AND policyname = 'Users can read their own user_vocabulary'
  ) THEN
    CREATE POLICY "Users can read their own user_vocabulary"
      ON public.user_vocabulary FOR SELECT
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_vocabulary' AND policyname = 'Users can insert their own user_vocabulary'
  ) THEN
    CREATE POLICY "Users can insert their own user_vocabulary"
      ON public.user_vocabulary FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_vocabulary' AND policyname = 'Users can update their own user_vocabulary'
  ) THEN
    CREATE POLICY "Users can update their own user_vocabulary"
      ON public.user_vocabulary FOR UPDATE
      TO authenticated
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;
