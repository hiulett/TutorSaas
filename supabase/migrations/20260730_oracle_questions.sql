-- ============================================================================
-- Oracle Questions — Evaluación silenciosa del onboarding
-- Configurable desde web_admin o SQL Editor
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.oracle_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_text TEXT NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    emotion VARCHAR(50) DEFAULT 'calm',
    language_code VARCHAR(10) DEFAULT 'en',
    is_active BOOLEAN DEFAULT true,
    min_cefr_level VARCHAR(5),
    max_cefr_level VARCHAR(5),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed data: 7 preguntas progresivas (se muestran 5 aleatorias por evaluación)
INSERT INTO public.oracle_questions (question_text, order_index, emotion, language_code) VALUES
    ('Welcome, young adventurer. I am the Oracle of the Guild. I have been expecting you. Tell me about yourself — where are you from and what brings you here?', 1, 'calm', 'en'),
    ('Interesting. And what do you do when you are not practicing languages? What are your hobbies or passions?', 2, 'curious', 'en'),
    ('Tell me about your daily routine. What does a normal day look like for you?', 3, 'warm', 'en'),
    ('Now, imagine you find a dragon in your backyard. What would you say to it and how would you react?', 4, 'playful', 'en'),
    ('Think about a challenge you have faced recently. How did you handle it and what did you learn?', 5, 'wise', 'en'),
    ('What is your greatest dream for the future? Describe it in detail — where are you, what are you doing, who is with you?', 6, 'warm', 'en'),
    ('If you could give advice to your younger self about learning English, what would you say?', 7, 'wise', 'en')
ON CONFLICT DO NOTHING;

ALTER TABLE public.oracle_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_oracle_questions" ON public.oracle_questions;
CREATE POLICY "select_oracle_questions" ON public.oracle_questions
    FOR SELECT USING (auth.role() = 'authenticated');
