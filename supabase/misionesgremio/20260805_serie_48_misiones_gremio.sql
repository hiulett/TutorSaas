-- =============================================================================
-- SERIE DE MISIONES DEL GREMIO - 48 misiones (6 por rango E..SSS) × 4 idiomas
-- Total: 192 filas en guild_quest_pool
-- =============================================================================

-- 1. Añadir columna language_id a guild_quest_pool
ALTER TABLE public.guild_quest_pool ADD COLUMN IF NOT EXISTS language_id INTEGER;
UPDATE public.guild_quest_pool SET language_id = 1 WHERE language_id IS NULL;

-- 1b. Rastrear el quest_id del pool en mission_instances (para registrar cumplidas)
ALTER TABLE public.mission_instances ADD COLUMN IF NOT EXISTS quest_id VARCHAR(200);

-- 2. Limpiar el pool anterior (las misiones viejas se reemplazan por la serie)
DELETE FROM public.guild_quest_pool;

INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'daily', 'Voice of the Guild E', 'Speak out loud and train your fluency (Speak 5).', 'speak_minutes', 5, 60, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'daily', 'La Voix du Gild E', 'Parlez à voix haute et entraînez votre aisance (Parler 5).', 'speak_minutes', 5, 60, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'daily', 'Stimme der Gilde E', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 5).', 'speak_minutes', 5, 60, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'daily', 'La Voce della Gilda E', 'Parla ad alta voce e allena la tua fluidità (Parlare 5).', 'speak_minutes', 5, 60, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'daily', 'Lexicon Hunter E', 'Master new words and expand your arsenal (New words 10).', 'new_words', 10, 55, 8, 'E', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'daily', 'Chasseur de Lexique E', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 10).', 'new_words', 10, 55, 8, 'E', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'daily', 'Lexikonjäger E', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 10).', 'new_words', 10, 55, 8, 'E', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'daily', 'Cacciatore di Lessico E', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 10).', 'new_words', 10, 55, 8, 'E', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild E', 'Speak out loud and train your fluency (Conversations 3).', 'conversations', 3, 120, 20, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild E', 'Parlez à voix haute et entraînez votre aisance (Conversations 3).', 'conversations', 3, 120, 20, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde E', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 3).', 'conversations', 3, 120, 20, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda E', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 3).', 'conversations', 3, 120, 20, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally E', 'Contribute to the guild and help allies (Contributions 2).', 'guild_contributions', 2, 90, 15, 'E', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild E', 'Contribuez au gild et aidez vos alliés (Contributions 2).', 'guild_contributions', 2, 90, 15, 'E', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter E', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 2).', 'guild_contributions', 2, 90, 15, 'E', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda E', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 2).', 'guild_contributions', 2, 90, 15, 'E', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'daily', 'Scribe of the Realm E', 'Write sentences and strengthen your grammar (Sentences 8).', 'sentences_written', 8, 50, 6, 'E', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'daily', 'Scribe du Royaume E', 'Écrivez des phrases et renforcez votre grammaire (Phrases 8).', 'sentences_written', 8, 50, 6, 'E', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'daily', 'Schreiber des Reiches E', 'Schreibe Sätze und stärke deine Grammatik (Sätze 8).', 'sentences_written', 8, 50, 6, 'E', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'daily', 'Scrivano del Regno E', 'Scrivi frasi e rafforza la tua grammatica (Frasi 8).', 'sentences_written', 8, 50, 6, 'E', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'daily', 'Voice of the Guild E', 'Speak out loud and train your fluency (Pronunciation 4).', 'pronunciation_scores', 4, 65, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'daily', 'La Voix du Gild E', 'Parlez à voix haute et entraînez votre aisance (Prononciation 4).', 'pronunciation_scores', 4, 65, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'daily', 'Stimme der Gilde E', 'Sprich laut und trainiere deine Flüssigkeit (Aussprache 4).', 'pronunciation_scores', 4, 65, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'daily', 'La Voce della Gilda E', 'Parla ad alta voce e allena la tua fluidità (Pronuncia 4).', 'pronunciation_scores', 4, 65, 10, 'E', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'daily', 'Voice of the Guild D', 'Speak out loud and train your fluency (Speak 10).', 'speak_minutes', 10, 80, 12, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'daily', 'La Voix du Gild D', 'Parlez à voix haute et entraînez votre aisance (Parler 10).', 'speak_minutes', 10, 80, 12, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'daily', 'Stimme der Gilde D', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 10).', 'speak_minutes', 10, 80, 12, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'daily', 'La Voce della Gilda D', 'Parla ad alta voce e allena la tua fluidità (Parlare 10).', 'speak_minutes', 10, 80, 12, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Lexicon Hunter D', 'Master new words and expand your arsenal (New words 25).', 'new_words', 25, 150, 25, 'D', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Chasseur de Lexique D', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 25).', 'new_words', 25, 150, 25, 'D', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Lexikonjäger D', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 25).', 'new_words', 25, 150, 25, 'D', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Cacciatore di Lessico D', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 25).', 'new_words', 25, 150, 25, 'D', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Master Debater D', 'Express and defend your opinions (Opinions 5).', 'opinions_expressed', 5, 140, 22, 'D', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Maître Débatteur D', 'Exprimez et défendez vos opinions (Opinions 5).', 'opinions_expressed', 5, 140, 22, 'D', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Meisterdebatteur D', 'Äußere und verteidige deine Meinungen (Meinungen 5).', 'opinions_expressed', 5, 140, 22, 'D', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Maestro del Dibattito D', 'Esprimi e difendi le tue opinioni (Opinioni 5).', 'opinions_expressed', 5, 140, 22, 'D', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally D', 'Contribute to the guild and help allies (Contributions 4).', 'guild_contributions', 4, 130, 20, 'D', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild D', 'Contribuez au gild et aidez vos alliés (Contributions 4).', 'guild_contributions', 4, 130, 20, 'D', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter D', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 4).', 'guild_contributions', 4, 130, 20, 'D', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda D', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 4).', 'guild_contributions', 4, 130, 20, 'D', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Scribe of the Realm D', 'Write sentences and strengthen your grammar (Sentences 20).', 'sentences_written', 20, 120, 18, 'D', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Scribe du Royaume D', 'Écrivez des phrases et renforcez votre grammaire (Phrases 20).', 'sentences_written', 20, 120, 18, 'D', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Schreiber des Reiches D', 'Schreibe Sätze und stärke deine Grammatik (Sätze 20).', 'sentences_written', 20, 120, 18, 'D', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Scrivano del Regno D', 'Scrivi frasi e rafforza la tua grammatica (Frasi 20).', 'sentences_written', 20, 120, 18, 'D', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'daily', 'Voice of the Guild D', 'Speak out loud and train your fluency (Conversations 2).', 'conversations', 2, 100, 16, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'daily', 'La Voix du Gild D', 'Parlez à voix haute et entraînez votre aisance (Conversations 2).', 'conversations', 2, 100, 16, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'daily', 'Stimme der Gilde D', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 2).', 'conversations', 2, 100, 16, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'daily', 'La Voce della Gilda D', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 2).', 'conversations', 2, 100, 16, 'D', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild C', 'Speak out loud and train your fluency (Speak 30).', 'speak_minutes', 30, 200, 35, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild C', 'Parlez à voix haute et entraînez votre aisance (Parler 30).', 'speak_minutes', 30, 200, 35, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde C', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 30).', 'speak_minutes', 30, 200, 35, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda C', 'Parla ad alta voce e allena la tua fluidità (Parlare 30).', 'speak_minutes', 30, 200, 35, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Lexicon Hunter C', 'Master new words and expand your arsenal (New words 40).', 'new_words', 40, 220, 40, 'C', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Chasseur de Lexique C', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 40).', 'new_words', 40, 220, 40, 'C', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Lexikonjäger C', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 40).', 'new_words', 40, 220, 40, 'C', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Cacciatore di Lessico C', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 40).', 'new_words', 40, 220, 40, 'C', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Master Debater C', 'Express and defend your opinions (Opinions 8).', 'opinions_expressed', 8, 210, 35, 'C', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Maître Débatteur C', 'Exprimez et défendez vos opinions (Opinions 8).', 'opinions_expressed', 8, 210, 35, 'C', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Meisterdebatteur C', 'Äußere und verteidige deine Meinungen (Meinungen 8).', 'opinions_expressed', 8, 210, 35, 'C', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Maestro del Dibattito C', 'Esprimi e difendi le tue opinioni (Opinioni 8).', 'opinions_expressed', 8, 210, 35, 'C', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally C', 'Contribute to the guild and help allies (Contributions 6).', 'guild_contributions', 6, 190, 30, 'C', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild C', 'Contribuez au gild et aidez vos alliés (Contributions 6).', 'guild_contributions', 6, 190, 30, 'C', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter C', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 6).', 'guild_contributions', 6, 190, 30, 'C', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda C', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 6).', 'guild_contributions', 6, 190, 30, 'C', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Scribe of the Realm C', 'Write sentences and strengthen your grammar (Sentences 35).', 'sentences_written', 35, 180, 28, 'C', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Scribe du Royaume C', 'Écrivez des phrases et renforcez votre grammaire (Phrases 35).', 'sentences_written', 35, 180, 28, 'C', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Schreiber des Reiches C', 'Schreibe Sätze und stärke deine Grammatik (Sätze 35).', 'sentences_written', 35, 180, 28, 'C', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Scrivano del Regno C', 'Scrivi frasi e rafforza la tua grammatica (Frasi 35).', 'sentences_written', 35, 180, 28, 'C', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild C', 'Speak out loud and train your fluency (Conversations 4).', 'conversations', 4, 230, 40, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild C', 'Parlez à voix haute et entraînez votre aisance (Conversations 4).', 'conversations', 4, 230, 40, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde C', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 4).', 'conversations', 4, 230, 40, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda C', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 4).', 'conversations', 4, 230, 40, 'C', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild B', 'Speak out loud and train your fluency (Speak 60).', 'speak_minutes', 60, 320, 55, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild B', 'Parlez à voix haute et entraînez votre aisance (Parler 60).', 'speak_minutes', 60, 320, 55, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde B', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 60).', 'speak_minutes', 60, 320, 55, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda B', 'Parla ad alta voce e allena la tua fluidità (Parlare 60).', 'speak_minutes', 60, 320, 55, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Lexicon Hunter B', 'Master new words and expand your arsenal (New words 60).', 'new_words', 60, 340, 60, 'B', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Chasseur de Lexique B', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 60).', 'new_words', 60, 340, 60, 'B', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Lexikonjäger B', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 60).', 'new_words', 60, 340, 60, 'B', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Cacciatore di Lessico B', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 60).', 'new_words', 60, 340, 60, 'B', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Master Debater B', 'Express and defend your opinions (Opinions 12).', 'opinions_expressed', 12, 330, 55, 'B', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Maître Débatteur B', 'Exprimez et défendez vos opinions (Opinions 12).', 'opinions_expressed', 12, 330, 55, 'B', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Meisterdebatteur B', 'Äußere und verteidige deine Meinungen (Meinungen 12).', 'opinions_expressed', 12, 330, 55, 'B', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Maestro del Dibattito B', 'Esprimi e difendi le tue opinioni (Opinioni 12).', 'opinions_expressed', 12, 330, 55, 'B', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally B', 'Contribute to the guild and help allies (Contributions 8).', 'guild_contributions', 8, 300, 50, 'B', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild B', 'Contribuez au gild et aidez vos alliés (Contributions 8).', 'guild_contributions', 8, 300, 50, 'B', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter B', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 8).', 'guild_contributions', 8, 300, 50, 'B', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda B', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 8).', 'guild_contributions', 8, 300, 50, 'B', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Scribe of the Realm B', 'Write sentences and strengthen your grammar (Sentences 50).', 'sentences_written', 50, 290, 45, 'B', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Scribe du Royaume B', 'Écrivez des phrases et renforcez votre grammaire (Phrases 50).', 'sentences_written', 50, 290, 45, 'B', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Schreiber des Reiches B', 'Schreibe Sätze und stärke deine Grammatik (Sätze 50).', 'sentences_written', 50, 290, 45, 'B', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Scrivano del Regno B', 'Scrivi frasi e rafforza la tua grammatica (Frasi 50).', 'sentences_written', 50, 290, 45, 'B', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild B', 'Speak out loud and train your fluency (Conversations 6).', 'conversations', 6, 350, 60, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild B', 'Parlez à voix haute et entraînez votre aisance (Conversations 6).', 'conversations', 6, 350, 60, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde B', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 6).', 'conversations', 6, 350, 60, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda B', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 6).', 'conversations', 6, 350, 60, 'B', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild A', 'Speak out loud and train your fluency (Speak 90).', 'speak_minutes', 90, 480, 80, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild A', 'Parlez à voix haute et entraînez votre aisance (Parler 90).', 'speak_minutes', 90, 480, 80, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde A', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 90).', 'speak_minutes', 90, 480, 80, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda A', 'Parla ad alta voce e allena la tua fluidità (Parlare 90).', 'speak_minutes', 90, 480, 80, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Lexicon Hunter A', 'Master new words and expand your arsenal (New words 80).', 'new_words', 80, 500, 90, 'A', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Chasseur de Lexique A', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 80).', 'new_words', 80, 500, 90, 'A', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Lexikonjäger A', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 80).', 'new_words', 80, 500, 90, 'A', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Cacciatore di Lessico A', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 80).', 'new_words', 80, 500, 90, 'A', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Master Debater A', 'Express and defend your opinions (Opinions 16).', 'opinions_expressed', 16, 490, 80, 'A', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Maître Débatteur A', 'Exprimez et défendez vos opinions (Opinions 16).', 'opinions_expressed', 16, 490, 80, 'A', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Meisterdebatteur A', 'Äußere und verteidige deine Meinungen (Meinungen 16).', 'opinions_expressed', 16, 490, 80, 'A', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Maestro del Dibattito A', 'Esprimi e difendi le tue opinioni (Opinioni 16).', 'opinions_expressed', 16, 490, 80, 'A', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally A', 'Contribute to the guild and help allies (Contributions 10).', 'guild_contributions', 10, 460, 75, 'A', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild A', 'Contribuez au gild et aidez vos alliés (Contributions 10).', 'guild_contributions', 10, 460, 75, 'A', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter A', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 10).', 'guild_contributions', 10, 460, 75, 'A', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda A', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 10).', 'guild_contributions', 10, 460, 75, 'A', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Scribe of the Realm A', 'Write sentences and strengthen your grammar (Sentences 70).', 'sentences_written', 70, 450, 70, 'A', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Scribe du Royaume A', 'Écrivez des phrases et renforcez votre grammaire (Phrases 70).', 'sentences_written', 70, 450, 70, 'A', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Schreiber des Reiches A', 'Schreibe Sätze und stärke deine Grammatik (Sätze 70).', 'sentences_written', 70, 450, 70, 'A', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Scrivano del Regno A', 'Scrivi frasi e rafforza la tua grammatica (Frasi 70).', 'sentences_written', 70, 450, 70, 'A', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild A', 'Speak out loud and train your fluency (Conversations 8).', 'conversations', 8, 510, 90, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild A', 'Parlez à voix haute et entraînez votre aisance (Conversations 8).', 'conversations', 8, 510, 90, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde A', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 8).', 'conversations', 8, 510, 90, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda A', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 8).', 'conversations', 8, 510, 90, 'A', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild S', 'Speak out loud and train your fluency (Speak 120).', 'speak_minutes', 120, 700, 120, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild S', 'Parlez à voix haute et entraînez votre aisance (Parler 120).', 'speak_minutes', 120, 700, 120, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde S', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 120).', 'speak_minutes', 120, 700, 120, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda S', 'Parla ad alta voce e allena la tua fluidità (Parlare 120).', 'speak_minutes', 120, 700, 120, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Lexicon Hunter S', 'Master new words and expand your arsenal (New words 100).', 'new_words', 100, 720, 130, 'S', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Chasseur de Lexique S', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 100).', 'new_words', 100, 720, 130, 'S', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Lexikonjäger S', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 100).', 'new_words', 100, 720, 130, 'S', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Cacciatore di Lessico S', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 100).', 'new_words', 100, 720, 130, 'S', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Master Debater S', 'Express and defend your opinions (Opinions 20).', 'opinions_expressed', 20, 710, 120, 'S', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Maître Débatteur S', 'Exprimez et défendez vos opinions (Opinions 20).', 'opinions_expressed', 20, 710, 120, 'S', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Meisterdebatteur S', 'Äußere und verteidige deine Meinungen (Meinungen 20).', 'opinions_expressed', 20, 710, 120, 'S', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Maestro del Dibattito S', 'Esprimi e difendi le tue opinioni (Opinioni 20).', 'opinions_expressed', 20, 710, 120, 'S', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally S', 'Contribute to the guild and help allies (Contributions 12).', 'guild_contributions', 12, 680, 110, 'S', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild S', 'Contribuez au gild et aidez vos alliés (Contributions 12).', 'guild_contributions', 12, 680, 110, 'S', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter S', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 12).', 'guild_contributions', 12, 680, 110, 'S', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda S', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 12).', 'guild_contributions', 12, 680, 110, 'S', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Scribe of the Realm S', 'Write sentences and strengthen your grammar (Sentences 90).', 'sentences_written', 90, 660, 100, 'S', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Scribe du Royaume S', 'Écrivez des phrases et renforcez votre grammaire (Phrases 90).', 'sentences_written', 90, 660, 100, 'S', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Schreiber des Reiches S', 'Schreibe Sätze und stärke deine Grammatik (Sätze 90).', 'sentences_written', 90, 660, 100, 'S', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Scrivano del Regno S', 'Scrivi frasi e rafforza la tua grammatica (Frasi 90).', 'sentences_written', 90, 660, 100, 'S', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild S', 'Speak out loud and train your fluency (Conversations 10).', 'conversations', 10, 740, 130, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild S', 'Parlez à voix haute et entraînez votre aisance (Conversations 10).', 'conversations', 10, 740, 130, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde S', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 10).', 'conversations', 10, 740, 130, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda S', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 10).', 'conversations', 10, 740, 130, 'S', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild SS', 'Speak out loud and train your fluency (Speak 150).', 'speak_minutes', 150, 950, 170, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild SS', 'Parlez à voix haute et entraînez votre aisance (Parler 150).', 'speak_minutes', 150, 950, 170, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde SS', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 150).', 'speak_minutes', 150, 950, 170, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda SS', 'Parla ad alta voce e allena la tua fluidità (Parlare 150).', 'speak_minutes', 150, 950, 170, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Lexicon Hunter SS', 'Master new words and expand your arsenal (New words 130).', 'new_words', 130, 980, 180, 'SS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Chasseur de Lexique SS', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 130).', 'new_words', 130, 980, 180, 'SS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Lexikonjäger SS', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 130).', 'new_words', 130, 980, 180, 'SS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Cacciatore di Lessico SS', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 130).', 'new_words', 130, 980, 180, 'SS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Master Debater SS', 'Express and defend your opinions (Opinions 25).', 'opinions_expressed', 25, 960, 170, 'SS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Maître Débatteur SS', 'Exprimez et défendez vos opinions (Opinions 25).', 'opinions_expressed', 25, 960, 170, 'SS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Meisterdebatteur SS', 'Äußere und verteidige deine Meinungen (Meinungen 25).', 'opinions_expressed', 25, 960, 170, 'SS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Maestro del Dibattito SS', 'Esprimi e difendi le tue opinioni (Opinioni 25).', 'opinions_expressed', 25, 960, 170, 'SS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally SS', 'Contribute to the guild and help allies (Contributions 15).', 'guild_contributions', 15, 920, 160, 'SS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild SS', 'Contribuez au gild et aidez vos alliés (Contributions 15).', 'guild_contributions', 15, 920, 160, 'SS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter SS', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 15).', 'guild_contributions', 15, 920, 160, 'SS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda SS', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 15).', 'guild_contributions', 15, 920, 160, 'SS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Scribe of the Realm SS', 'Write sentences and strengthen your grammar (Sentences 120).', 'sentences_written', 120, 900, 150, 'SS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Scribe du Royaume SS', 'Écrivez des phrases et renforcez votre grammaire (Phrases 120).', 'sentences_written', 120, 900, 150, 'SS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Schreiber des Reiches SS', 'Schreibe Sätze und stärke deine Grammatik (Sätze 120).', 'sentences_written', 120, 900, 150, 'SS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Scrivano del Regno SS', 'Scrivi frasi e rafforza la tua grammatica (Frasi 120).', 'sentences_written', 120, 900, 150, 'SS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild SS', 'Speak out loud and train your fluency (Conversations 12).', 'conversations', 12, 1000, 180, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild SS', 'Parlez à voix haute et entraînez votre aisance (Conversations 12).', 'conversations', 12, 1000, 180, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde SS', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 12).', 'conversations', 12, 1000, 180, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda SS', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 12).', 'conversations', 12, 1000, 180, 'SS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild SSS', 'Speak out loud and train your fluency (Speak 200).', 'speak_minutes', 200, 1300, 240, 'SSS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild SSS', 'Parlez à voix haute et entraînez votre aisance (Parler 200).', 'speak_minutes', 200, 1300, 240, 'SSS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde SSS', 'Sprich laut und trainiere deine Flüssigkeit (Sprechen 200).', 'speak_minutes', 200, 1300, 240, 'SSS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda SSS', 'Parla ad alta voce e allena la tua fluidità (Parlare 200).', 'speak_minutes', 200, 1300, 240, 'SSS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Lexicon Hunter SSS', 'Master new words and expand your arsenal (New words 160).', 'new_words', 160, 1350, 250, 'SSS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Chasseur de Lexique SSS', 'Maîtrisez de nouveaux mots et élargissez votre arsenal (Nouveaux mots 160).', 'new_words', 160, 1350, 250, 'SSS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Lexikonjäger SSS', 'Meistere neue Wörter und erweitere dein Arsenal (Neue Wörter 160).', 'new_words', 160, 1350, 250, 'SSS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Cacciatore di Lessico SSS', 'Padroneggia nuove parole ed espandi il tuo arsenale (Nuove parole 160).', 'new_words', 160, 1350, 250, 'SSS', 'vocabulary', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Master Debater SSS', 'Express and defend your opinions (Opinions 30).', 'opinions_expressed', 30, 1320, 240, 'SSS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Maître Débatteur SSS', 'Exprimez et défendez vos opinions (Opinions 30).', 'opinions_expressed', 30, 1320, 240, 'SSS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Meisterdebatteur SSS', 'Äußere und verteidige deine Meinungen (Meinungen 30).', 'opinions_expressed', 30, 1320, 240, 'SSS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Maestro del Dibattito SSS', 'Esprimi e difendi le tue opinioni (Opinioni 30).', 'opinions_expressed', 30, 1320, 240, 'SSS', 'argumentation', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'collaborative', 'Guild Ally SSS', 'Contribute to the guild and help allies (Contributions 18).', 'guild_contributions', 18, 1280, 230, 'SSS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'collaborative', 'Allié du Gild SSS', 'Contribuez au gild et aidez vos alliés (Contributions 18).', 'guild_contributions', 18, 1280, 230, 'SSS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'collaborative', 'Gildenverbündeter SSS', 'Trage zur Gilde bei und hilf Verbündeten (Beiträge 18).', 'guild_contributions', 18, 1280, 230, 'SSS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'collaborative', 'Alleato della Gilda SSS', 'Contribuisci alla gilda e aiuta gli alleati (Contributi 18).', 'guild_contributions', 18, 1280, 230, 'SSS', 'collaborative', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Scribe of the Realm SSS', 'Write sentences and strengthen your grammar (Sentences 150).', 'sentences_written', 150, 1250, 220, 'SSS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'Scribe du Royaume SSS', 'Écrivez des phrases et renforcez votre grammaire (Phrases 150).', 'sentences_written', 150, 1250, 220, 'SSS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Schreiber des Reiches SSS', 'Schreibe Sätze und stärke deine Grammatik (Sätze 150).', 'sentences_written', 150, 1250, 220, 'SSS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'Scrivano del Regno SSS', 'Scrivi frasi e rafforza la tua grammatica (Frasi 150).', 'sentences_written', 150, 1250, 220, 'SSS', 'writing', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (1, 'weekly', 'Voice of the Guild SSS', 'Speak out loud and train your fluency (Conversations 15).', 'conversations', 15, 1380, 250, 'SSS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (2, 'weekly', 'La Voix du Gild SSS', 'Parlez à voix haute et entraînez votre aisance (Conversations 15).', 'conversations', 15, 1380, 250, 'SSS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (3, 'weekly', 'Stimme der Gilde SSS', 'Sprich laut und trainiere deine Flüssigkeit (Gespräche 15).', 'conversations', 15, 1380, 250, 'SSS', 'speaking', TRUE, NULL, NULL);
INSERT INTO public.guild_quest_pool
  (language_id, quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, game_rank, category, is_active, min_cefr_level, max_cefr_level)
  VALUES (4, 'weekly', 'La Voce della Gilda SSS', 'Parla ad alta voce e allena la tua fluidità (Conversazioni 15).', 'conversations', 15, 1380, 250, 'SSS', 'speaking', TRUE, NULL, NULL);

-- Índice para filtrar por idioma y rango
CREATE INDEX IF NOT EXISTS idx_guild_pool_lang_rank ON public.guild_quest_pool (language_id, game_rank);

-- Verificación
-- SELECT game_rank, COUNT(*) FROM public.guild_quest_pool GROUP BY game_rank;  -- 6 por rango × 4 idiomas = 24
-- SELECT language_id, COUNT(*) FROM public.guild_quest_pool GROUP BY language_id; -- 48 por idioma