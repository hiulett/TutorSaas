# Rediseño del Flujo de Evaluación del Oráculo — Conversación Oral con IA

> **Ruta:** `Docs/Oracle-Redesign/ORACLE_REDESIGN_PROPOSAL.md`
> **Estado:** PROPUESTA — pendiente de aprobación
> **Tema:** TutorSaas / Dungeon of English

---

## 1. Análisis del estado actual

### 1.1 Qué ya existe (reutilizable)
El flujo del Oráculo ya usa un **chat de voz conversacional** implementado como
"modo Oracle" dentro del pipeline de misiones:

| Componente | Ubicación | Estado |
|---|---|---|
| `initOracleSession` | `conversation_providers.dart:147` | ✅ arranca el chat con el Oráculo |
| `_runOracleTurn` | `:373` | ✅ turno de voz (record→Groq→DeepSeek SSE→TTS) |
| `_buildOracleHistory` | `:458` | ✅ system prompt del examinador adaptativo |
| `_finalizeOracleEvaluation` | `:492` | ✅ clasifica con `PlacementAiEvaluator` |
| `_persistOracleAssessment` | `:558` | ✅ guarda en `user_language_profiles` + `oracle_assessments` |
| `ConversationScreen(oracleMode)` | pantalla del chat | ✅ misma UI que las misiones |

### 1.2 Lo que el prompt pide mejorar
1. **Progresión por niveles CEFR explícita** (5 preguntas/nivel A1→C2) — el prompt actual
   pide "2-3 preguntas por banda" genéricas.
2. **Saludo inicial natural** obligatorio ("Are you ready?").
3. **Detección de "no puede continuar"** — detener en el nivel donde el usuario falla
   (no solo forzar 10-16 turnos).
4. **Persistencia granular**: sesión, **cada pregunta** (orden, CEFR, texto), **cada
   respuesta** (transcripción, tiempo, duración, métricas, score parcial).
5. **Mensaje final inmersivo** del Oráculo con el nivel + rango.

### 1.3 Brechas técnicas detectadas
- El prompt no estructura la progresión por bloques de 5 preguntas/nivel ni define
  cuándo "saltar de nivel" vs "detener".
- La persistencia guarda `answers` como lista plana en `oracle_assessments.answers`
  (jsonb), sin separar pregunta/respuesta ni métricas por turno.
- No se guarda duración de sesión ni modelo de IA en la fila de evaluación.

---

## 2. Modelo de datos propuesto (extensión)

Se extiende la tabla `oracle_assessments` existente (ya creada) con granularidad.

### 2.1 `oracle_assessments` (sesión) — extender columnas
```sql
ALTER TABLE public.oracle_assessments
  ADD COLUMN IF NOT EXISTS duration_seconds int DEFAULT 0,      -- ya existe
  ADD COLUMN IF NOT EXISTS ai_model text DEFAULT 'deepseek-v4-flash',
  ADD COLUMN IF NOT EXISTS prompt_version text DEFAULT 'v2',
  ADD COLUMN IF NOT EXISTS stopped_at_cefr text,                 -- nivel donde se detuvo
  ADD COLUMN IF NOT EXISTS scores_pronunciation int,
  ADD COLUMN IF NOT EXISTS scores_fluency int,
  ADD COLUMN IF NOT EXISTS scores_grammar int,
  ADD COLUMN IF NOT EXISTS scores_vocabulary int,
  ADD COLUMN IF NOT EXISTS scores_comprehension int;
```

### 2.2 `oracle_turns` (nueva — cada pregunta+respuesta)
```sql
CREATE TABLE public.oracle_turns (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid references public.oracle_assessments(id) on delete cascade,
  turn_order int not null,
  cefr_level varchar(5) not null,
  question_text text,
  question_audio_url text,
  answer_transcript text,
  answer_audio_url text,
  response_time_sec numeric,
  answer_duration_sec numeric,
  pronunciation_score int,
  fluency_score int,
  grammar_score int,
  vocabulary_score int,
  comprehension_score int,
  naturalness_score int,
  partial_score int,
  created_at timestamptz default now()
);
-- RLS: lectura/escritura solo del owner (vía assessment_id → user_id)
```

---

## 3. Algoritmo de evaluación propuesto

### 3.1 Estructura del system prompt (v2)
Se reescribe `_buildOracleHistory` con:

1. **Saludo inmersivo fijo** (texto del prompt) + primera pregunta "Are you ready?".
2. **Bloques CEFR**: A1 (5) → A2 (5) → B1 (5) → B2 (5) → C1 (5) → C2 (5),
   con ejemplos de cada nivel (del prompt del usuario).
3. **Regla de salto**: subir de nivel si el usuario responde con ≥3 de 5 preguntas
   correctas y con fluidez suficiente; **detener** si falla 2 consecutivas del mismo
   nivel → nivel actual = el último dominado.
4. **Adaptación dinámica**: follow-up, aclaración, profundización según la respuesta
   anterior. Nunca lista fija.
5. **Registro silencioso** de métricas por turno.
6. **Token de fin** `[EVALUATION_COMPLETE]` + instrucción de felicitación inmersiva
   (nivel + rango) antes del token.

### 3.2 Turnos
- El Oráculo pregunta → usuario responde por voz → STT → el turno se envía con historial.
- Tras cada respuesta, el turno se guarda en `oracle_turns` (métricas best-effort).
- Al recibir `[EVALUATION_COMPLETE]`, `_finalizeOracleEvaluation`:
  1. `PlacementAiEvaluator.evaluatePlacement(answers)` → CEFR + rango + scores.
  2. Persistir sesión completa (`oracle_assessments`) + turns (`oracle_turns`).
  3. Devolver resultado al onboarding.

### 3.3 Clasificación
- CEFR directo de la IA (A1-C2).
- Rango por `CefrRank.gameRankFromCefr` (A1→E … C2→S). Si la IA devuelve SS/SSS,
  se conserva (el mapeo inverso ya lo soporta).

---

## 4. Persistencia granular (mejora)

- **Sesión**: `oracle_assessments` con duración, modelo IA, fecha, idiomas.
- **Por turno**: `oracle_turns` con pregunta (texto/audio), respuesta (transcripción/
  audio/tiempo/duración), métricas de pronunciación/fluidez/gramática/vocabulario/
  comprensión/naturalidad y score parcial.
- **Evaluación final**: columnas `scores_*` + `cefr_level` + `game_rank` +
  strengths/weaknesses/recommended_focus en `oracle_assessments`.

---

## 5. Mejoras adicionales propuestas (compatibles)

1. **Detección de estancamiento**: si el usuario responde <3 palabras o solo "yes/no"
   en 2 preguntas seguidas, el Oráculo baja de nivel o cierra (evita evaluaciones eternas).
2. **Tiempo de respuesta** por turno (se mide desde fin de pregunta → inicio de
   transcripción) y se persiste.
3. **Prompt versionado** (`prompt_version`) para trazabilidad de cambios futuros.
4. **Fallback**: si la IA no emite el token, se cierra a los ~20 turnos máximos.

---

## 6. Reutilización (sin duplicación)

| Necesidad | Se reutiliza |
|---|---|
| Chat de voz | `ConversationScreen(oracleMode)` + `ConversationNotifier` |
| STT | `conversationRepository.transcribeAudio` (Groq) |
| TTS | flutter_tts en `ConversationNotifier` |
| LLM | `getTutorResponseStream` (DeepSeek SSE) |
| Clasificación | `PlacementAiEvaluator` + `CefrRank` |
| Persistencia | `oracle_assessments` (existente) + nueva `oracle_turns` |

---

## 7. Implementación planificada (tras aprobación)
1. Reescribir `_buildOracleHistory` con la progresión CEFR + saludo + reglas de detención.
2. Migración `20260804_oracle_turns.sql` (tabla + columnas en assessments).
3. `_runOracleTurn`: registrar turno (pregunta/respuesta/tiempo/métricas) en `oracle_turns`.
4. `_finalizeOracleEvaluation`: persistir scores finales + duración + modelo.
5. QA: analyze (0 errores), test (73/73), build APK.

---

## 8. Criterios de aceptación
- La conversación es 100% oral, natural y progresiva (A1→C2).
- La dificultad sube/baja según el desempeño; se detiene donde el usuario no puede seguir.
- Cada pregunta/respuesta y sus métricas se persisten.
- El resultado final incluye CEFR + rango + felicitación inmersiva.
- Sin duplicación de lógica; 0 errores analyze; 73/73 tests; build OK.
