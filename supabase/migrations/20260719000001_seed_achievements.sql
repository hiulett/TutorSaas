-- ==========================================================
-- SEED DE LOGROS Y METAS DE GAMIFICACIÓN
-- ==========================================================

INSERT INTO public.achievements (code, title, description, icon_url, xp_reward, condition_type, condition_value)
VALUES 
  ('first_steps', 'Primeros Pasos', 'Completa tu primer escenario de conversación.', 'bronze', 10, 'conversations', 1),
  ('chatterbox', 'Charlatán', 'Envía 10 mensajes en una sola conversación.', 'bronze', 20, 'messages', 10),
  ('consistency', 'Constancia Diaria', 'Alcanza una racha de 3 días de práctica.', 'silver', 50, 'streak', 3),
  ('polyglot', 'Políglota', 'Completa conversaciones en 2 idiomas diferentes.', 'silver', 80, 'languages', 2),
  ('vocab_master', 'Maestro del Vocabulario', 'Aprende 50 palabras nuevas en el vocabulario.', 'gold', 150, 'vocabulary', 50),
  ('golden_voice', 'Elocuencia Dorada', 'Obtén una puntuación de pronunciación de más del 90%.', 'gold', 200, 'pronunciation', 90)
ON CONFLICT (code) DO UPDATE 
SET 
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  icon_url = EXCLUDED.icon_url,
  xp_reward = EXCLUDED.xp_reward,
  condition_type = EXCLUDED.condition_type,
  condition_value = EXCLUDED.condition_value;
