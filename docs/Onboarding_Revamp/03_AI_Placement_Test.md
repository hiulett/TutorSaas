# 03 · Integración de IA para la clasificación de nivel (AI Placement Test)

> **Estado:** Propuesta técnica · **Área:** Onboarding → Oráculo · **Lenguaje:** Documento de integración
>
> Cómo convertir la evaluación del Oráculo de una heurística de longitud de palabras (escrita)
> a una clasificación automática **por IA** basada en la conversación **por voz** con el pipeline real
> de la app (Groq Whisper STT → DeepSeek LLM → flutter_tts).

---

## 1. Contexto actual (verificado en código)

### 1.1 Pipeline de voz ya existente (NO tocar)

La app ya dispone de un pipeline de voz completo en `lib/features/conversation/data/repositories/conversation_repository_impl.dart`:

| Paso | Servicio | Implementación real |
|------|----------|---------------------|
| 1. Grabación | `record` (AAC/m4a), hold-to-talk | `conversation_providers.dart` (`AudioRecorder`) |
| 2. STT | Groq Whisper `whisper-large-v3-turbo`, `language: 'en'` forzado | `transcribeAudio(audioPath)` → multipart `recording.m4a` |
| 3. LLM | DeepSeek `chat/completions`, SSE streaming | `getTutorResponseStream(history)` → modelo **`deepseek-v4-flash`** |
| 4. TTS | `flutter_tts` on-device, rate 0.48 | widgets de `conversation/` |

> **Nota de fidelidad:** AGENTS.md menciona `deepseek-chat`, pero el código real de
> `conversation_repository_impl.dart:119` y `:259` usa el modelo **`deepseek-v4-flash`**.
> El nuevo método de evaluación debe usar **el mismo modelo que el código real**
> (`deepseek-v4-flash`), con `stream: false`, tal como ya hace `evaluateGoals()`.

### 1.2 Evaluación ACTUAL del Oráculo

`lib/features/onboarding/presentation/screens/oracle_conversation_screen.dart`:

- Las preguntas vienen de `oracleQuestionsProvider` (tabla `oracle_questions`, límite 7, fallback local de 5).
- El usuario responde **por escrito** en un `TextField` (pese a que el UI diga "RESPONDE CON TU VOZ").
- `_computeLevel()` (línea 78) es una heurística de **promedio de palabras por respuesta**:

| Promedio de palabras | CEFR |
|----------------------|------|
| < 6 | A1 |
| 6 – 11 | A2 |
| 12 – 19 | B1 |
| 20 – 31 | B2 |
| >= 32 | C1 |

- Al terminar llama a `savePlacementResult(userId, cefrLevel, learningGoal, mainDifficulty, quizScore)`.

### 1.3 Persistencia actual

`lib/features/onboarding/presentation/providers/placement_providers.dart`:

```dart
abstract class PlacementRepository {
  Future<void> savePlacementResult({
    required String userId,
    required String cefrLevel,
    required String learningGoal,
    required String mainDifficulty,
    required int quizScore,
  });
}
```

`PlacementRepositoryImpl` hace 3 cosas:
1. Resuelve `cefr_levels.code → id` (fallback `id = 1`).
2. `upsert` en `user_language_profiles` (conflicto `user_id, language_id`).
3. Escribe en `users.bio` una cadena `[Stats|...] Goal: ... | Obstacle: ... | Quiz: ...`.

**NO guarda:** rango del juego (`game_rank`), `scores`, `strengths`, `weaknesses`, `explanation`.

### 1.4 Esquemas DB involucrados

- `oracle_questions` (`supabase/migrations/20260730_oracle_questions.sql`): preguntas activas config en DB.
- `cefr_levels` (`20260717000000_init.sql`): `id SERIAL PK, code VARCHAR(5) UNIQUE, name, description, order_index`.
- `user_language_profiles` (`20260717000000_init.sql`):
  ```sql
  user_id UUID PK FK, language_id INT FK, cefr_level_id INT FK,
  xp_points, current_streak, longest_streak, last_practice_date,
  total_minutes, created_at, UNIQUE(user_id, language_id)
  ```

---

## 2. Propuesta

### 2.1 Conversación por voz con el Oráculo

Reutilizar el **mismo** mecanismo de grabación/STT/TTS de `conversation/` (no duplicar código):

1. El Oráculo hace una pregunta abierta (¿Cómo te llamas? ¿Qué haces? ¿Cuéntame sobre tu ciudad?).
   - Fuente preferida: tablas `oracle_questions` (preguntas ya existentes y configurables).
   - Las preguntas deben migrar de "cerradas" a **abiertas de producción de habla espontánea**.
2. El usuario mantiene pulsado (hold-to-talk) y su respuesta se transcribe con `transcribeAudio()`.
3. La transcripción se muestra en el chat como burbuja del "Cazador" y se acumula en `_answers`.
4. El Oráculo puede responder con TTS (flutter_tts) + texto en pantalla para dar sensación de diálogo.

### 2.2 Clasificación por IA

Al terminar la conversación:

- Enviar a DeepSeek (`deepseek-v4-flash`, `stream: false`) un prompt de evaluación que recibe **las transcripciones del usuario** (solo las del estudiante, nunca las del Oráculo).
- La IA devuelve **JSON estricto** con nivel CEFR, rango del juego, puntuaciones, fortalezas, debilidades y explicación.

### 2.3 Equivalencia CEFR ↔ Rango del juego

La IA entrega CEFR y la capa Dart convierte a rango del juego (o la IA lo devuelve directamente, validado en Dart):

| Rango del juego | CEFR |
|-----------------|------|
| E | A1 bajo |
| D | A1 / A2 |
| C | A2 / B1 |
| B | B1 / B2 |
| A | B2 |
| S | C1 |
| SS | C1+ |
| SSS | C2 |

> **Recomendación:** que la IA devuelva el CEFR (estándar educativo) y el rango del juego se derive
> con una función pura en Dart (`gameRankFromCefr(String cefr)`) para no depender del modelo. Ver §5.

### 2.4 Persistencia

Ampliar el modelo de persistencia (nueva tabla `ai_placement_results` + columnas ligeras en
`user_language_profiles`). Ver §6.

### 2.5 Fallback

Si DeepSeek falla o no hay conexión → degradar a la heurística `_computeLevel()` actual, sin romper el flujo.
La clasificación por IA es una **mejora progresiva**, no un bloqueante. Ver §8.

---

## 3. Prompt de evaluación de DeepSeek

### 3.1 Mensaje `system`

```
You are a strict and objective language level evaluator (CEFR).
You analyze a student's SPOKEN English transcriptions collected during a placement interview.

Rules:
1. ONLY evaluate the STUDENT's answers. Ignore the Oracle's questions and prompts.
2. Assess these dimensions and score each 0-100:
   - pronunciation (based on written transcription clues; be conservative)
   - vocabulary
   - grammar
   - comprehension (how well the student addresses the question)
   - fluency (length, coherence, hesitation markers, filler words)
3. Determine a single CEFR level (A1, A2, B1, B2, C1, C2) based on the CAN-DO descriptors.
4. List 2-3 strengths and 2-3 weaknesses as short Spanish noun phrases.
5. Write a 1-2 sentence explanation in Spanish, narrated in the RPG tone of the Oracle
   ("El cazador...").
6. Choose one recommended_focus from this enum:
   basic_phrases, everyday_vocabulary, past_tenses, present_tenses, future_tenses,
   conditionals, grammar_past_tenses, grammar_articles, listening_comprehension,
   speaking_fluency, pronunciation_clarity, complex_topics.
7. If the answers are too short or empty, the level must be A1 and scores must be low.
8. Be strict. Do not inflate levels because the student is motivated.

Return ONLY a valid JSON object. No markdown, no code fences, no explanations.
```

### 3.2 Mensaje `user`

```
Evaluate the following student transcriptions. Each block is one answer to an Oracle question.

Answers:
1. "My name is Carlos. I from Mexico. I work in a office."
2. "I like play soccer and watch movies. My favorite movie is ..."
3. "Every day I wake up at seven, eat breakfast, and go to work."

Return the JSON result now.
```

### 3.3 Esquema de salida JSON

```json
{
  "cefr_level": "B1",
  "game_rank": "C",
  "scores": {
    "pronunciation": 72,
    "vocabulary": 65,
    "grammar": 58,
    "comprehension": 80,
    "fluency": 70
  },
  "strengths": ["comprensión oral", "vocabulario cotidiano"],
  "weaknesses": ["tiempos verbales", "fluidez en temas complejos"],
  "explanation": "El cazador mantiene conversaciones fluidas sobre su vida cotidiana, pero aún duda en el uso de tiempos pasados.",
  "recommended_focus": "grammar_past_tenses"
}
```

### 3.4 Endpoint / request real

Mismo patrón que `evaluateGoals()` (`conversation_repository_impl.dart:256`), pero **sin streaming**:

```jsonc
POST https://api.deepseek.com/v1/chat/completions
Authorization: Bearer <DEEPSEEK_API_KEY>
{
  "model": "deepseek-v4-flash",
  "stream": false,
  "temperature": 0.2,
  "messages": [
    { "role": "system", "content": "<§3.1>" },
    { "role": "user",   "content": "<§3.2 con las transcripciones>" }
  ]
}
```

Respuesta esperada: `choices[0].message.content` = string JSON a parsear.

---

## 4. Cómo parsearlo en Dart (modelo freezed)

Crear un modelo freezed + json_serializable, siguiendo el patrón de
`lib/features/conversation/domain/models/conversation_message.dart`.

### 4.1 `lib/features/onboarding/domain/models/ai_placement_result.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_placement_result.freezed.dart';
part 'ai_placement_result.g.dart';

@freezed
class AiPlacementScores with _$AiPlacementScores {
  const factory AiPlacementScores({
    @Default(0) int pronunciation,
    @Default(0) int vocabulary,
    @Default(0) int grammar,
    @Default(0) int comprehension,
    @Default(0) int fluency,
  }) = _AiPlacementScores;

  factory AiPlacementScores.fromJson(Map<String, dynamic> json) =>
      _$AiPlacementScoresFromJson(json);
}

@freezed
class AiPlacementResult with _$AiPlacementResult {
  const factory AiPlacementResult({
    @Default('A1') String cefrLevel,
    String? gameRank,
    @Default(AiPlacementScores()) AiPlacementScores scores,
    @Default([]) List<String> strengths,
    @Default([]) List<String> weaknesses,
    @Default('') String explanation,
    String? recommendedFocus,
  }) = _AiPlacementResult;

  factory AiPlacementResult.fromJson(Map<String, dynamic> json) =>
      _$AiPlacementResultFromJson(json);
}
```

> Los `@Default(...)` garantizan que un JSON parcial (común en LLMs) **nunca** rompa el parseo:
> la clasificación degrada a valores seguros en lugar de lanzar `FormatException`.

### 4.2 Parsing defensivo

El LLM a veces envuelve el JSON en markdown (```json ... ```) o añade ruido. Extraer el objeto robustamente:

```dart
AiPlacementResult parseAiPlacement(String raw) {
  var text = raw.trim();
  text = text.replaceFirst(RegExp(r'^```(json)?'), '').replaceFirst(RegExp(r'```$'), '');
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  final jsonStr = (start >= 0 && end >= start) ? text.substring(start, end + 1) : '{}';
  return AiPlacementResult.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
```

### 4.3 Validación y normalización

```dart
const validCefr = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};
const validRanks = {'E', 'D', 'C', 'B', 'A', 'S', 'SS', 'SSS'};

String sanitizeCefr(String raw) => validCefr.contains(raw) ? raw : 'A1';
String sanitizeRank(String? raw) =>
    (raw != null && validRanks.contains(raw)) ? raw : gameRankFromCefr(sanitizeCefr(raw));
```

---

## 5. Dónde viviría el método

### 5.1 Repositorio (preferido)

Ampliar la abstracción existente en `lib/features/onboarding/presentation/providers/placement_providers.dart`
(interface `PlacementRepository`) y su implementación, más un repositorio/método para la llamada IA.

```dart
abstract class PlacementRepository {
  // Firmas actuales
  Future<void> savePlacementResult({ ... });

  // Nuevas firmas propuestas
  Future<AiPlacementResult> evaluateWithAi(List<String> userAnswers);
  Future<void> saveAiPlacementResult({
    required String userId,
    required AiPlacementResult result,
    required int quizScore,
  });
}
```

**Alternativa recomendada:** reutilizar `ConversationRepositoryImpl` añadiendo un método
`evaluatePlacement(List<String> userAnswers)` que siga exactamente el patrón de `evaluateGoals()`
(sistema + user + `stream: false` + parseo), ya que contiene el `Dio` cliente configurado con
`ApiConstants` y los timeouts. Evita duplicar cliente HTTP.

### 5.2 ¿Cliente directo o Edge Function?

| Opción | Ventajas | Desventajas |
|--------|----------|-------------|
| **Cliente directo (recomendado ahora)** | Consistente con el código actual; la API key viaja vía `--dart-define` (IA-01); cero infraestructura | La key `DEEPSEEK_API_KEY` queda en el cliente (riesgo de exposición) |
| Edge Function (Supabase) | La key queda en el servidor; se puede auditar/cachear | Trabajo extra; rompe la latencia objetivo si no se cuida el cold start |

> Decisión sugerida: mantener **cliente directo** en una primera iteración (paridad con el pipeline
> existente), y migrar a Edge Function en una fase posterior si se valida el riesgo de la API key.
> El prompt de §3 y el contrato JSON son los mismos en ambos casos.

### 5.3 Flujo de integración en `oracle_conversation_screen.dart`

```
_finish()
 ├─ ¿hay conexión y transcripciones no vacías? ── no ─▶ _computeLevel()  (fallback)
 └─ sí
    ├─ result = await evaluateWithAi(_answers)      // DeepSeek, stream:false, ~1-3s
    ├─ on OK:  gameRank = result.gameRank ?? gameRankFromCefr(result.cefrLevel)
    ├─ on error: result = null → _computeLevel()
    └─ saveAiPlacementResult(userId, result, quizScore: _answers.length)
       └─ context.go('/home')
```

- `_computeLevel()` **se conserva** como fallback (no se elimina).
- El indicador de nivel en pantalla usa el resultado de IA si existe, sino `_computeLevel()`.

---

## 6. Esquema SQL propuesto

Nueva tabla para los resultados detallados de IA + columnas ligeras en `user_language_profiles`.

```sql
-- ============================================================================
-- AI Placement Results — clasificación por IA del Oráculo
-- 20260801_ai_placement_results.sql
-- ============================================================================

-- 1. Columnas ligeras de acceso rápido en user_language_profiles
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS game_rank        VARCHAR(5),
    ADD COLUMN IF NOT EXISTS last_placement_at TIMESTAMPTZ;

-- 2. Tabla de resultados detallados (histórico por evaluación)
CREATE TABLE IF NOT EXISTS public.ai_placement_results (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    language_id        INTEGER NOT NULL REFERENCES public.languages(id) ON DELETE RESTRICT,
    cefr_level         VARCHAR(5) NOT NULL CHECK (cefr_level IN ('A1','A2','B1','B2','C1','C2')),
    game_rank          VARCHAR(5) CHECK (game_rank IN ('E','D','C','B','A','S','SS','SSS')),
    score_pronunciation SMALLINT DEFAULT 0 CHECK (score_pronunciation BETWEEN 0 AND 100),
    score_vocabulary    SMALLINT DEFAULT 0 CHECK (score_vocabulary BETWEEN 0 AND 100),
    score_grammar       SMALLINT DEFAULT 0 CHECK (score_grammar BETWEEN 0 AND 100),
    score_comprehension SMALLINT DEFAULT 0 CHECK (score_comprehension BETWEEN 0 AND 100),
    score_fluency       SMALLINT DEFAULT 0 CHECK (score_fluency BETWEEN 0 AND 100),
    strengths          TEXT[] DEFAULT '{}',
    weaknesses         TEXT[] DEFAULT '{}',
    explanation        TEXT,
    recommended_focus  VARCHAR(50),
    method             VARCHAR(20) NOT NULL DEFAULT 'ai',   -- 'ai' | 'heuristic'
    created_at         TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_placement_results_user
    ON public.ai_placement_results (user_id, created_at DESC);

-- 3. RLS
ALTER TABLE public.ai_placement_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_ai_placement" ON public.ai_placement_results;
CREATE POLICY "select_own_ai_placement" ON public.ai_placement_results
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_ai_placement" ON public.ai_placement_results;
CREATE POLICY "insert_own_ai_placement" ON public.ai_placement_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### 6.1 Guardado (evolución de `savePlacementResult`)

- Mantener el `upsert` actual en `user_language_profiles` (compatibilidad con el resto de la app).
- Añadir: `game_rank = result.gameRank`, `last_placement_at = now()`.
- Insertar fila en `ai_placement_results` (con `method = 'ai'`; si falló la IA, `method = 'heuristic'` y campos nulos).
- Mantener la escritura de `users.bio` (o migrarla a un campo dedicado en una fase posterior).

> **Ojo con RLS:** la app escribe desde el cliente autenticado; las políticas deben permitir
> `INSERT/SELECT` solo del propio `auth.uid()`. No añadir políticas `FOR UPDATE` innecesarias.
> Algunas escrituras pueden fallar contra el proyecto live ("read-only transaction") —
> aplicar vía SQL Editor o una rama, según AGENTS.md.

---

## 7. Puntuaciones y focus recomendado (semántica)

- `scores` (0–100): base para el "radar de stats" del HUD del jugador. Se muestran en pantalla de
  resumen tras el Oráculo.
- `recommended_focus`: alimenta la selección de lecciones/escenarios iniciales y la misión de
  onboarding. Enum validado en Dart y en `CHECK` de DB.
- `strengths` / `weaknesses`: texto para el "reporte del Oráculo" y para retroalimentación del
  gremio (chat rooms).

---

## 8. Fallback y degradación

| Fallo | Comportamiento |
|-------|----------------|
| Sin red / timeouts DeepSeek | Usar `_computeLevel()` (heurística actual). `method = 'heuristic'`. El flujo sigue a `/home`. |
| JSON inválido / campos faltantes | `parseAiPlacement` devuelve resultado con `@Default`; si ni eso es posible → heurística. |
| STT vacío / respuestas muy cortas | Se descartan; si quedan < 3 respuestas útiles → heurística o reintentar pregunta. |
| RLS/upsert falla | `try-catch` con `debugPrint` (patrón actual); el usuario nunca se bloquea. |
| API key vacía (`--dart-define` no inyectada) | Detectar `ApiConstants.deepseekApiKey.isEmpty` → heurística directa (sin intento de red). |

Regla de oro: **la IA es un plus; el flujo actual es la red de seguridad.** Ningún cambio debe hacer
que el usuario quede atrapado en la pantalla del Oráculo.

---

## 9. Riesgos y mitigación

### 9.1 Latencia

- Riesgo: el target del pipeline es **< 1.5s**; una llamada `stream: false` a DeepSeek con 5 respuestas
  puede tardar **1–3s**.
- Mitigación:
  - Mostrar pantalla de "El Oráculo consulta los archivos del reino…" (spinner con narrativa) durante la evaluación.
  - Enviar **solo las transcripciones del usuario** (no el historial completo) para reducir tokens.
  - `temperature: 0.2` y `max_tokens` acotado (por ejemplo 500) para respuestas más cortas y estables.
  - No bloquear la UI: `evaluateWithAi` corre en un provider/futuro; la pantalla puede mostrarse mientras carga.

### 9.2 Calidad del STT

- Riesgo: Whisper puede introducir errores que engañen al evaluador ("I from Mexico" con mala
  gramática puede ser error de transcripción).
- Mitigación:
  - Prompt del sistema: "si la transcripción parece ruido o está vacía, no penalices y baja el peso".
  - Evaluar con 5+ respuestas (no con 1) para promediar ruido.
  - Conservar la transcripción cruda para auditoría y permitir corrección manual posterior.

### 9.3 Consistencia del JSON del LLM

- Riesgo: markdown, keys en snake_case/camelCase, campos extra.
- Mitigación: parsing defensivo (§4.2), `@Default` (§4.1), `sanitizeCefr/sanitizeRank` (§4.3),
  y validación final en DB (`CHECK` constraints).

### 9.4 Seguridad de la API key

- Riesgo: `DEEPSEEK_API_KEY` en el cliente (estado actual del proyecto).
- Mitigación: sigue siendo inyectada vía `--dart-define` y nunca commiteada (IA-01). Fase 2: mover a Edge Function.

### 9.5 Costos

- Riesgo: cada evaluación = 1 llamada LLM.
- Mitigación: 1 llamada por evaluación (no por pregunta), limitada al onboarding (1 vez por usuario
  típicamente), y registrada en `api_request_logs` como el resto (`invoke_llm`).

### 9.6 Regresión del flujo actual

- Riesgo: tocar `oracle_conversation_screen.dart` puede romper el onboarding.
- Mitigación: cambios aditivos (nueva firma, nueva pantalla de carga), conservar `_computeLevel()`,
  y validar con `flutter analyze` (0 errores) y `flutter test`.

---

## 10. Checklist de implementación

- [ ] Modelo freezed `AiPlacementResult` + `AiPlacementScores` + codegen (`build_runner`).
- [ ] Método `evaluatePlacement(List<String>)` en `ConversationRepositoryImpl` (o `PlacementRepository`).
- [ ] Prompt `system`/`user` de §3 (constante compartida).
- [ ] Migración SQL `20260801_ai_placement_results.sql` (+ RLS + índice).
- [ ] Evolución de `savePlacementResult` → `saveAiPlacementResult` (upsert + insert histórico + bio).
- [ ] Hook en `oracle_conversation_screen.dart` (`_finish`) con fallback a `_computeLevel()`.
- [ ] `flutter gen-l10n` si se añaden claves de UI (pantalla de carga del Oráculo).
- [ ] `flutter analyze` (0 errores) y `flutter test`.
- [ ] Prueba manual: voz → transcripción → IA → rango del juego → pantalla `/home`.
- [ ] Prueba de degradación: apagar red en el punto de evaluación → heurística → flujo continúa.
