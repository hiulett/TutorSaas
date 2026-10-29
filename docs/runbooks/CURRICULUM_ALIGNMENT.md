# Alineación del currículo (P-38 · issue #123)

_Medido en producción el 29-oct-2026. Consultas de solo lectura al proyecto
`sipiumfdpvnszthykyog`._

## 1. Diagnóstico

### Filas

| Objeto | Filas |
|---|---:|
| `scenarios` | 500 (500 activas) |
| `scenario_goals` | **0** |
| `scenario_phrases` | **0** |
| `scenario_objectives` | 30 |
| `lesson_progress` | 30 (7 `lesson_id` distintos) |
| `user_scenario_goals` | 37 (8 `scenario_id` distintos) |

El contenido de metas y frases vive en `scenarios.goals` y
`scenarios.useful_phrases` (JSONB); las tablas normalizadas están vacías.

### Catálogo Dart vs. `scenarios`

`LessonCatalog.catalog` tiene **140 lecciones** (20 por nivel PRE-A1…C2) y solo
inglés. `scenarios` tiene 500 filas = 125 títulos × 4 idiomas
(`en`, `fr`, `de`, `it`); solo `language_id = 1` tiene PRE-A1.

Comparación del conjunto de títulos por nivel (`language_id = 1`, hash MD5 del
`string_agg(lower(title))` ordenado):

| Nivel | Filas BD | Hash BD | Hash Dart | ¿Igual? |
|---|---:|---|---|---|
| PRE-A1 | 20 | `78a4723c…` | `78a4723c…` | sí |
| A1 | 20 | `ddc0c58c…` | `ddc0c58c…` | sí |
| A2 | 20 | `e9e7a8d3…` | `e9e7a8d3…` | sí |
| B1 | 20 | `1a23f4d2…` | `1a23f4d2…` | sí |
| B2 | 20 | `f021a136…` | `d1f39ab3…` | **no** |
| C1 | 20 | `5a8fb894…` | `0de376eb…` | **no** |
| C2 | 20 | `c263853e…` | `c6ef89fb…` | **no** |

La BD es una semilla del catálogo Dart: 80 de 140 lecciones siguen idénticas y
60 (B2–C2) ya divergieron.

### Claves: el dato que decide la fuente

- `scenarios.id`: **uuid**.
- `scenario_goals.scenario_id`: uuid (tabla vacía).
- `lesson_progress.lesson_id`: **texto**.
- `user_scenario_goals.scenario_id`: **texto**.
- `scenario_progress.scenario_id`: **texto**.

**El 100 % de las claves de progreso reales son ids del catálogo Dart**
(`prea1_hello_hello`, `a1_ordering_coffee_at_a_cafe`, …); no hay ni una fila de
progreso con un uuid de `scenarios`, y ninguna columna de `scenarios` guarda el
slug Dart. Consecuencia: hoy el servidor **no puede** calcular el total de metas
de una lección sin que el cliente se lo envíe.

## 2. Decisión

**El catálogo Dart es la fuente canónica de identidad y metas del currículo de
inglés; `scenarios` pasa a ser el almacén de contenido referenciado por
`lesson_key`.**

Motivos, con los datos de arriba:

1. Todo el progreso histórico (67 filas entre las tres tablas) usa ids Dart; un
   cambio de clave rompería el progreso existente.
2. La BD no tiene hoy ninguna relación con esos ids: ni columna ni tabla de
   mapeo; los títulos coinciden solo en 4 de 7 niveles.
3. Migrar el catálogo a uuid exige reescribir progreso, conversaciones y
   sub-misiones a la vez, con riesgo alto y sin beneficio de producto inmediato.

Camino escrito:

| Fase | Contenido | Estado |
|---|---|---|
| **1** | Una sola regla de "completada" (app + servidor) y vistas de diagnóstico | **este PR** |
| 2 | `scenarios.lesson_key text` (nullable), índice único `(language_id, lesson_key)`, backfill de las 80 coincidencias exactas y mapeo manual de B2–C2; el runtime lee por `lesson_key` | pendiente |
| 3 | `scenarios` como fuente de lectura del currículo en inglés, caché del último currículo (modo sin conexión) y filtro por intereses en la Ruta | pendiente |
| 4 | `LessonCatalog` queda solo como semilla de migración y se retira del runtime | pendiente |

No se borra ni se reescribe ningún dato de progreso en la fase 1.

## 3. Consultas de diagnóstico (solo lectura)

```sql
-- Resumen: filas de scenarios frente a claves de progreso y cuántas empatan.
select * from public.curriculum_alignment_summary;

-- Clave por clave: matched_by_uuid = false ⇒ la BD no referencia el catálogo.
select source, lesson_key, matched_by_uuid, matched_by_title
  from public.curriculum_progress_keys
 order by source, lesson_key;

-- ¿Siguen discrepando el criterio del cliente y el del servidor?
select count(*) filter (where criteria_disagree) as discrepancias,
       count(*) as lecciones_con_progreso
  from public.lesson_completion_state
 where client_passed is not null or server_passed is not null;

-- Detalle de las discrepancias históricas (anteriores a la regla única).
select user_id, lesson_key, goals_done, client_status, server_outcome,
       best_ratio, server_unlocked
  from public.lesson_completion_state
 where criteria_disagree
 order by lesson_key;
```

Antes del cambio, `lesson_completion_state` daba **10 discrepancias en 16
lecciones con progreso**: el cliente marcaba `passed` al 75 % y el servidor
`partial` hasta el 100 %.

## 4. Regla única

`LessonCompletion.isPassed(done, total)` en Dart y
`public.lesson_completion_passed(done, total)` en SQL implementan lo mismo:

- sin metas → superada;
- todas las metas → superada;
- 4 metas o menos y como máximo una fallada → superada;
- en el resto, 75 % del total.

Estrellas (`LessonCompletion.stars` / `lesson_completion_stars`) y halo
(`LessonHalo.*ForCounts`) se derivan de esa misma función; un test recorre todo
el espacio 0–12 metas y falla si el halo, las estrellas o el desbloqueo
discrepan.
