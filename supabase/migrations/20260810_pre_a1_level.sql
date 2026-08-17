-- ==========================================================
-- NIVEL PRE-A1 (Fundamentos) — rango F del gremio
-- ==========================================================
-- Nivel por debajo de A1 para hablantes super-básicos. order_index 0 lo
-- coloca antes de A1 (1) en cualquier orden por escala.

INSERT INTO public.cefr_levels (code, name, description, order_index)
VALUES (
  'PRE-A1',
  'Fundamentos (Pre-A1)',
  'Nivel CEFR Pre-A1: palabras sueltas, saludos, números y vocabulario mínimo.',
  0
)
ON CONFLICT (code) DO NOTHING;
