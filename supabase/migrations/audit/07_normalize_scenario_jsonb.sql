-- =============================================================
-- MIGRACIÓN 7: Normalizar JSONB de scenarios en tablas separadas
-- =============================================================
-- NOTA: Esta migración conserva los campos JSONB originales.
-- Las nuevas tablas sirven como fuente normalizada para consultas.

-- 7a. Tabla de objetivos por escenario
CREATE TABLE IF NOT EXISTS public.scenario_goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id uuid NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,
  goal_key text NOT NULL,
  goal_text text NOT NULL,
  keywords text[] DEFAULT '{}',
  order_index int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- 7b. Tabla de frases útiles por escenario
CREATE TABLE IF NOT EXISTS public.scenario_phrases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id uuid NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,
  phrase text NOT NULL,
  translation text NOT NULL,
  order_index int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- 7c. Migrar datos existentes desde JSONB (solo si hay datos)
INSERT INTO public.scenario_goals (scenario_id, goal_key, goal_text, order_index)
SELECT s.id, g->>'id', g->>'text', row_number() OVER (PARTITION BY s.id) - 1
FROM public.scenarios s, jsonb_array_elements(s.goals) AS g
WHERE jsonb_array_length(s.goals) > 0
ON CONFLICT DO NOTHING;

INSERT INTO public.scenario_phrases (scenario_id, phrase, translation, order_index)
SELECT s.id, p->>'phrase', p->>'translation', row_number() OVER (PARTITION BY s.id) - 1
FROM public.scenarios s, jsonb_array_elements(s.useful_phrases) AS p
WHERE jsonb_array_length(s.useful_phrases) > 0
ON CONFLICT DO NOTHING;

-- 7d. Índices para las nuevas tablas
CREATE INDEX IF NOT EXISTS idx_scenario_goals_scenario ON public.scenario_goals(scenario_id);
CREATE INDEX IF NOT EXISTS idx_scenario_phrases_scenario ON public.scenario_phrases(scenario_id);

SELECT 'Migración 7 completada' AS result;
