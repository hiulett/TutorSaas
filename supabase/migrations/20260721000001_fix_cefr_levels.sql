-- ==========================================================
-- POBLAR NIVELES CEFR FALTANTES (A2, B2, C1, C2)
-- ==========================================================

INSERT INTO public.cefr_levels (code, name, description, order_index)
VALUES
  ('A2', 'Básico (A2)', 'Nivel CEFR A2', 2),
  ('B2', 'Intermedio Alto (B2)', 'Nivel CEFR B2', 4),
  ('C1', 'Avanzado (C1)', 'Nivel CEFR C1', 5),
  ('C2', 'Maestría (C2)', 'Nivel CEFR C2', 6)
ON CONFLICT (code) DO NOTHING;
