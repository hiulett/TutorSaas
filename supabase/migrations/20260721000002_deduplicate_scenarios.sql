-- ==========================================================
-- ELIMINAR ESCENARIOS DUPLICADOS (seeded 2 veces)
-- ==========================================================

-- 1. Eliminar objectives de los duplicados
DELETE FROM public.scenario_objectives
WHERE scenario_id IN (
  SELECT id FROM (
    SELECT id, title, language_id, ROW_NUMBER() OVER (
      PARTITION BY title, language_id ORDER BY created_at ASC
    ) AS rn
    FROM public.scenarios
  ) dup
  WHERE dup.rn > 1
);

-- 2. Eliminar escenarios duplicados (conservar los más antiguos)
DELETE FROM public.scenarios
WHERE id IN (
  SELECT id FROM (
    SELECT id, title, language_id, ROW_NUMBER() OVER (
      PARTITION BY title, language_id ORDER BY created_at ASC
    ) AS rn
    FROM public.scenarios
  ) dup
  WHERE dup.rn > 1
);
