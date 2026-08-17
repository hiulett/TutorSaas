-- 20260815_multilingual_scenarios.sql
-- T7 · Localización del contenido de lecciones (lesson_catalog) a través de la BD.
--
-- Esquema real de `scenarios`: id, language_id, title, description, context,
-- difficulty_level, category, estimated_minutes, is_active, created_at.
-- Los objetivos viven en `scenario_objectives` (objective, vocabulary_focus).
--
-- Esta migración: (1) limpia las columnas mal añadidas por una versión previa,
-- (2) añade columnas por idioma (title/description/context), (3) backfill seguro.
-- Es idempotente (guarda con EXCEPTION). Aplicar por SQL Editor o `supabase db push`.

DO $$
BEGIN
  -- Limpia columnas de la versión previa (no corresponden al esquema real).
  BEGIN ALTER TABLE scenarios DROP COLUMN IF EXISTS main_objective_es; EXCEPTION WHEN undefined_column THEN NULL; END;
  BEGIN ALTER TABLE scenarios DROP COLUMN IF EXISTS main_objective_pt; EXCEPTION WHEN undefined_column THEN NULL; END;
  BEGIN ALTER TABLE scenarios DROP COLUMN IF EXISTS scenario_context_es; EXCEPTION WHEN undefined_column THEN NULL; END;
  BEGIN ALTER TABLE scenarios DROP COLUMN IF EXISTS scenario_context_pt; EXCEPTION WHEN undefined_column THEN NULL; END;

  -- Columnas de título.
  BEGIN ALTER TABLE scenarios ADD COLUMN title_es text; EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE scenarios ADD COLUMN title_pt text; EXCEPTION WHEN duplicate_column THEN NULL; END;

  -- Columnas de descripción.
  BEGIN ALTER TABLE scenarios ADD COLUMN description_es text; EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE scenarios ADD COLUMN description_pt text; EXCEPTION WHEN duplicate_column THEN NULL; END;

  -- Columnas de contexto del escenario (System prompt / scenarioContext).
  BEGIN ALTER TABLE scenarios ADD COLUMN context_es text; EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE scenarios ADD COLUMN context_pt text; EXCEPTION WHEN duplicate_column THEN NULL; END;
END $$;

-- Backfill: los campos localizados vacíos se rellenan con el valor base inglés
-- para no romper la UI mientras se traduce el contenido.
UPDATE scenarios
SET title_es       = COALESCE(NULLIF(title_es, ''), title),
    title_pt       = COALESCE(NULLIF(title_pt, ''), title),
    description_es = COALESCE(NULLIF(description_es, ''), description),
    description_pt = COALESCE(NULLIF(description_pt, ''), description),
    context_es     = COALESCE(NULLIF(context_es, ''), context),
    context_pt     = COALESCE(NULLIF(context_pt, ''), context)
WHERE title_es IS NULL OR title_pt IS NULL OR context_es IS NULL OR context_pt IS NULL;

-- Cambio en la app (código Dart, NO SQL):
--   LessonCatalog.updateCatalogFromMap() debe leer las columnas según locale:
--     title:       locale == 'es' ? data['title_es'] : (locale == 'pt' ? data['title_pt'] : data['title'])
--     description: idem con description_es / description_pt
--     context:     idem con context_es / context_pt
--   Los objetivos (scenario_objectives.objective) y useful_phrases se pueden
--   localizar después añadiendo columnas objective_es/objective_pt a esa tabla.
