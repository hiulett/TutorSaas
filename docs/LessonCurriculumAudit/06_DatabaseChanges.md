# 06 — Cambios de base de datos (Database Changes)

## Migración creada

`supabase/migrations/20260805_apply_official_120_curriculum.sql`

### Comportamiento
1. `TRUNCATE TABLE public.scenarios RESTART IDENTITY CASCADE;` — elimina las 3240 filas contaminadas (y las FK dependientes: `conversations`, `messages`, `scenario_goals`, `scenario_phrases` relacionadas se limpian por CASCADE).
2. `DO $$ ... END $$;` — inserta **120 lecciones** (20 por nivel A1–C2) × **4 idiomas** (`en`, `fr`, `de`, `it`) = **480 filas**.

### Columnas pobladas
`language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals (jsonb), useful_phrases (jsonb), is_active`.

### Campos que permanecen sin poblar (compatibilidad)
- `is_custom = false` (por defecto), `created_by_user_id = NULL` (son oficiales), `deleted_at = NULL`.
- `id` = UUID autogenerado (no se fuerza id externo).

## Compatibilidad con el esquema actual

| Dependencia | Impacto |
|---|---|
| `updateCatalogFromMap` (`lesson_catalog.dart`) | Lee `title, description, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, language_id` — todos presentes ✅ |
| `getRecommendedLessons` (dashboard repo) | Query a `scenarios` + `scenario_goals` — OK ✅ |
| `conversations` / `messages` | Se vacían por TRUNCATE CASCADE (los chats históricos de lecciones quedan huérfanos; el progreso de metas `user_scenario_goals` referencia `scenario_id` y `goal_id` por string, no FK — no se rompe) |
| `scenario_goals` / `scenario_phrases` (catálogo normalizado) | Se vacían vía CASCADE si tienen FK a scenarios; la app usa `goals`/`useful_phrases` embebidos como fallback ✅ |

## Relaciones (normalización)
La BD normaliza objetivos en `scenario_goals` y frases en `scenario_phrases` (migración `07_normalize_scenario_jsonb`). El seed inserta `goals`/`useful_phrases` embebidos en `scenarios`. **La app usa ambos caminos**:
- `updateCatalogFromMap` lee los embebidos (fallback completo).
- `recommendedLessons` lee los normalizados.

> ⚠️ Si los `scenario_goals`/`scenario_phrases` normalizados quedan vacíos tras el TRUNCATE CASCADE, el `skillsRadarProvider` y las recomendaciones que dependen de ellos se degradarán a valores por defecto. **Recomendación**: tras aplicar la migración, re-normalizar objetivos/frases ejecutando la lógica de `07_normalize_scenario_jsonb.sql` para las 480 filas, o confiar en los embebidos (la app tiene fallback).

## Scripts de auditoría usados

```sql
-- Conteo por nivel
SELECT difficulty_level AS level, COUNT(*) FROM scenarios GROUP BY difficulty_level;
-- Duplicados
SELECT title, COUNT(*) FROM scenarios GROUP BY title HAVING COUNT(*) > 1;
-- Placeholders
SELECT COUNT(*) FILTER (WHERE useful_phrases::text LIKE '%_vocab_%') ...
-- Ausencias
SELECT COUNT(*) FILTER (WHERE goals IS NULL OR jsonb_array_length(goals)=0) ...
```
