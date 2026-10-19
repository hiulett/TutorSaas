# 05 — Plan de nuevas lecciones (New Lessons Plan)

## Estrategia

No se crean lecciones desde cero: se **aplica el currículo oficial ya curado** de 120 lecciones (20/nivel) que existía en el repositorio pero fue sobreescrito por seeds masivos. Esta decisión evita contenido duplicado y mantiene el diseño pedagógico validado.

## Plan de ejecución

### Paso 1 — BD (migración de limpieza + seed)
Archivo creado: `supabase/migrations/20260805_apply_official_120_curriculum.sql`

```
1. TRUNCATE TABLE public.scenarios RESTART IDENTITY CASCADE;
2. DO $$ ... FOR lang_rec IN (en, fr, de, it) ... INSERT 120 lecciones ... END $$;
```

- **120 lecciones × 4 idiomas = 480 filas** en `scenarios`.
- Sin `ON CONFLICT` (la tabla se vacía primero → idempotente por construcción).
- ⚠️ **Pendiente de aplicar** vía SQL Editor (MCP en read-only).

### Paso 2 — Catálogo Flutter
`lib/features/dashboard/data/models/lesson_catalog.dart` — `LessonCatalog.catalog` regenerado a **120 lecciones**.

- Generado programáticamente desde el seed SQL (script Node en temp).
- Cada `LessonData` incluye: `id`, `title`, `description`, `level`, `category`, `interest`, `difficulty`, `iconKey`, `mainObjective`, `scenarioContext`, `assistantRole`, `userRole`, `initialAssistantMessage`, `goals` (3–5), `usefulPhrases` (3–5).
- IDs estables tipo `a1_ordering_coffee_at_a_cafe`, `c2_supreme_court_constitutional_argument`.
- Se eliminó el bloque manual de 17 lecciones (reemplazado por el generado).

### Paso 3 — Tests
`test/lesson_catalog_test.dart` actualizado:
- 20 lecciones por nivel y 120 total.
- IDs únicos, títulos únicos por nivel.
- Toda lección con goals/mainObjective/initialAssistantMessage.
- Resolución por ID y por título.

## Diseño pedagógico de cada lección

Cada `LessonData` (equivalente a la fase 5 del prompt) contiene:

| Dato | Fuente |
|---|---|
| ID, Nivel CEFR, Orden (posición en lista) | generado |
| Nombre / Descripción / Objetivo | seed (`title`, `description`, `main_objective`) |
| Competencia principal (Speaking/Conversation) | implícita: todas son conversacionales |
| Escenario | `scenarioContext` (rol del NPC, contexto real) |
| Objetivos (5–10) | `goals` (texto + keywords para evaluación) |
| Vocabulario | `keywords` por objetivo |
| Expresiones útiles | `usefulPhrases` |
| Duración | seed `estimated_minutes` (en BD) |
| XP / Gemas | asignado por UI/recompensa (fuera del modelo) |
| Pronunciación / Gramática | inyectadas en el prompt del LLM por nivel (`levelAppropriateOpening`, system prompt por CEFR) |

## Metadatos que quedan fuera del modelo `LessonData`
`LessonData` no tiene campos de XP/gemas/pronunciación/gramática explícitos. El sistema los deriva:
- XP/gemas: `learning_path_roadmap.dart` (recompensa de tarjeta).
- Gramática/pronunciación: system prompt del LLM en `conversation_providers.dart` (usa `lesson.level`).
- Desbloqueos: `LessonUnlockService` (secuencial por orden del catálogo).
