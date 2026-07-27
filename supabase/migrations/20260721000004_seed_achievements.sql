-- ==========================================================
-- SEED DE ACHIEVEMENTS (re-ejecución de 20260719000001)
-- ==========================================================

INSERT INTO public.achievements (code, title, description, icon_url, xp_reward, condition_type, condition_value)
VALUES
  ('first_conversation', 'Primera Conversación', 'Completa tu primera conversación.', 'bronze', 50, 'conversations', 1),
  ('streak_7', 'Racha de 7 Días', 'Practica 7 días consecutivos.', 'silver', 200, 'streak', 7),
  ('streak_30', 'Racha de 30 Días', 'Practica 30 días consecutivos.', 'gold', 1000, 'streak', 30),
  ('vocab_50', 'Vocabulario: 50 Palabras', 'Aprende 50 palabras nuevas.', 'bronze', 100, 'vocabulary', 50),
  ('vocab_200', 'Vocabulario: 200 Palabras', 'Aprende 200 palabras nuevas.', 'silver', 400, 'vocabulary', 200),
  ('vocab_500', 'Vocabulario: 500 Palabras', 'Aprende 500 palabras nuevas.', 'gold', 1000, 'vocabulary', 500),
  ('messages_100', '100 Mensajes', 'Envía 100 mensajes en conversaciones.', 'bronze', 150, 'messages', 100),
  ('messages_500', '500 Mensajes', 'Envía 500 mensajes en conversaciones.', 'silver', 500, 'messages', 500),
  ('polyglot', 'Políglota', 'Estudia 2 idiomas diferentes.', 'gold', 300, 'languages', 2),
  ('dedication', 'Dedicación', 'Acumula 10 horas de práctica.', 'silver', 300, 'minutes', 600)
ON CONFLICT (code) DO NOTHING;
