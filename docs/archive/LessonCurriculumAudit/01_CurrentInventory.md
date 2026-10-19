# 01 — Inventario actual (Current Inventory)

## Fecha de auditoría
2026-08-05 · Proyecto: TutorSaas / Dungeon of English · BD: `sipiumfdpvnszthykyog`

## Resumen

| Fuente | Lecciones | Estado |
|---|---|---|
| BD `public.scenarios` | **3 240 filas** (540/nivel × 6) | ❌ 100% auto-generadas con placeholders |
| Títulos únicos en BD | 135/nivel (×4 idiomas = 540 filas/nivel) | ❌ No pedagógicas, re-aplicadas |
| Seed oficial `20260723000000_seed_20_lessons_per_level.sql` | **120 curadas (20/nivel)** | ✅ Curado, NO aplicado a BD |
| Catálogo estático Flutter `lesson_catalog.dart` | 17 lecciones | ⚠️ Curado pero incompleto |

## Detalle BD (`scenarios`)

### Conteo por nivel (filas y títulos únicos)
| Nivel | Filas | Títulos únicos | Placeholder phrases | Metas genéricas |
|---|---|---|---|---|
| A1 | 540 | 135 | 540 | 540 |
| A2 | 540 | 135 | 540 | 540 |
| B1 | 540 | 135 | 540 | 540 |
| B2 | 540 | 135 | 540 | 540 |
| C1 | 540 | 135 | 540 | 540 |
| C2 | 540 | 135 | 540 | 540 |

### Distribución por idioma
`language_id` 1..4 (en, fr, de, it) → 810 filas cada uno. Cada título se replica en los 4 idiomas.

### Problemas detectados en BD
1. **Placeholders**: `useful_phrases` tipo `travel_vocab_1`, `travel_expresion_6`, `A1_termino_11`, `clave_16_travel` (100% de filas).
2. **Metas genéricas idénticas**: las 10 metas se repiten textualmente en todas las lecciones ("1. Iniciar conversación sobre X", "2. Expresar la necesidad principal", ...).
3. **Nivel incorrecto**: títulos de nivel avanzado etiquetados como A1 (ej. *"A1 Business: Defending Annual Budget Strategy to Board"*, *"A1 Art: Deconstructing Existential Motifs in Novel"*, *"A1 History: Debating Central Bank Macroeconomic Interest Rates"*).
4. **Duplicados**: cada título único aparece 4× (idiomas). Además los seeds masivos `seed_lessons_*.sql` (135/nivel, TRUNCATE) sobreescribieron al seed curado de 120.
5. **Descripción placeholder**: "Escenario real (n/15) nivel A1 travel." — sin contenido pedagógico.

### Origen de la contaminación
Los archivos `seed_lessons_A1.sql` … `seed_lessons_C2.sql` (783 KB cada uno, con `TRUNCATE TABLE public.scenarios`) y `seed_A1_en.sql`… (196 KB, por idioma) se aplicaron **después** del seed curado de 120 lecciones, borrándolo. Verificación en BD: `COUNT(*) FILTER (WHERE title IN (...20 títulos A1 oficiales...)) = 0`.

## Detalle catálogo estático Flutter (pre-cambio)

`lib/features/dashboard/data/models/lesson_catalog.dart` — `LessonCatalog.catalog`:

| Nivel | Lecciones | IDs |
|---|---|---|
| A1 | 5 | a1_greetings, a1_family, a1_numbers_time, a1_food_order, a1_airport_checkin |
| A2 | 3 | l1, a2_hotel, a2_past_experiences |
| B1 | 2 | b1_tech, b1_job_interview |
| B2 | 2 | l2, b2_business_meeting |
| C1 | 1 | l4 |
| C2 | 4 | c2_academic_debate, c2_literary_critique, c2_corporate_crisis, c2_philosophical_discourse |
| **Total** | **17** | |

Cada lección estática tenía exactamente 5 `goals` y 10 `usefulPhrases`.

## Resumen de decisión

- **BD**: limpiar (TRUNCATE) y aplicar las **120 lecciones oficiales** (20/nivel × 4 idiomas).
- **Flutter**: sincronizar `LessonCatalog.catalog` a las **120 lecciones** para que el roadmap, el desbloqueo y las recomendaciones funcionen de forma autónoma.
