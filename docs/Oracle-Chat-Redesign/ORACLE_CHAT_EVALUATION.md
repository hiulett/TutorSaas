# Rediseño del Paso 4 — Evaluación del Oráculo por Chat de Voz

> **Ruta:** `docs/Oracle-Chat-Redesign/ORACLE_CHAT_EVALUATION.md`
> **Alcance:** Reemplazar el flujo de preguntas secuenciales del Oráculo por una
> conversación oral inmersiva que reutiliza la arquitectura del chat de voz de
> misiones.
> **Tema:** TutorSaas / Dungeon of English

---

## 1. Análisis realizado

Se auditaron las siguientes áreas (previo a cualquier cambio):

| Área | Hallazgo |
|---|---|
| `ConversationScreen` | Chat de voz libre de misiones: burbujas, waveform, micrófono central, animación `_AnimatedMessage`, modos teclado/tópicos, overlay de monstruo. **Reutilizable al 100%.** |
| `ConversationNotifier` | Orquesta record (AAC) → Groq STT → DeepSeek SSE → flutter_tts, con persistencia en `conversations`/`messages`. Contiene el pipeline real del sistema. |
| `OracleConversationScreen` (viejo) | Ya usaba voz (hold-to-talk + TTS), pero con **preguntas secuenciales** (`_currentIndex++`), contador X/Y y botón "saltar/completar". No es un chat libre. |
| `PlacementAiEvaluator` | Clasificador IA (DeepSeek, no-stream) que devuelve `cefr_level`, `game_rank`, `scores`, `strengths`, `weaknesses`, `explanation`, `recommended_focus`. Con fallback heurístico (A1<6, A2 6-11, B1 12-19, B2 20-31, C1≥32). |
| `CefrRank` | Mapeo canónico CEFR↔rango (A1→E … C2→S) + descripciones. Reutilizado sin cambios. |
| Persistencia | Columnas `game_rank`, `placement_scores`, `placement_strengths`, `placement_weaknesses`, `placement_explanation`, `placement_recommended_focus`, `placement_assessed_at` ya existen en `user_language_profiles`. |
| `PlacementTestScreen` | Quiz por páginas de opción múltiple, **código muerto** (no registrado en router ni importado). Eliminado. |

**Conclusión clave:** el Paso 4 *ya* era una pantalla de voz, pero no un chat.
La máxima reutilización consiste en **añadir un "modo Oracle" al pipeline de
conversación existente**, no crear un sistema de chat nuevo.

---

## 2. Decisiones de arquitectura

1. **Modo Oracle en `ConversationNotifier` en lugar de una pantalla nueva.**
   Se añadió `initOracleSession()` que configura el estado con
   `isOracleEvaluation: true` y conduce la entrevista con el mismo
   `getTutorResponseStream`. Esto elimina duplicación de lógica de voz,
   TTS, STT y persistencia.

2. **`ConversationScreen` se reutiliza tal cual**, con un parámetro
   `oracleMode`. En modo Oracle se ocultan los elementos de misión que no
   aplican a un examen (barra de progreso de lección, `LiveGoalsTrackerBar`,
   mana, overlay de monstruo, brújula de misión, 20 tópicos) y se mantiene el
   micrófono, teclado, waveform y burbujas. **El diseño del chat es idéntico.**

3. **La IA decide el fin del examen**, no la UI. El system prompt instruye al
   Oráculo a cerrar con el token `[EVALUATION_COMPLETE]`. El notifier detecta
   el token, lo limpia del mensaje mostrado y dispara la clasificación.

4. **Ruta `/oracle-test` sin nueva ruta**: el router ahora construye
   `ConversationScreen(oracleMode: true)`. El onboarding pasa los idiomas por
   query params (`?target=…&native=…`). El contrato de retorno se mantiene:
   `Navigator.pop(Map)` con `cefrLevel`/`gameRank`.

5. **Evaluación y persistencia reutilizadas**: `PlacementAiEvaluator` +
   columnas `placement_*` ya existentes + nueva tabla `oracle_assessments`
   para el transcript y duración.

---

## 3. Componentes reutilizados

| Componente | Uso en el nuevo flujo |
|---|---|
| `ConversationScreen` | Pantalla del examen (UI completa del chat). |
| `ConversationNotifier` | Orquestación de voz, STT, SSE, TTS, persistencia. |
| `ConversationRepositoryImpl` | `transcribeAudio` (Groq), `getTutorResponseStream` (DeepSeek), `getOrCreateConversation`/`saveMessage`. |
| `VoiceWaveformVisualizer` | Visualizador de audio. |
| `_AnimatedMessage` / burbujas | Mensajes del Oráculo y del jugador. |
| `PlacementAiEvaluator` | Clasificación CEFR + rango + métricas. |
| `CefrRank` | Equivalencia CEFR ↔ rango del juego. |
| `user_language_profiles` | Columnas `placement_*` + `game_rank`. |
| `RpgAvatar` / flujo de onboarding | Sin cambios en el paso de personaje (paso 5). |

---

## 4. Estrategia de evaluación conversacional

La IA recibe un system prompt de **examinador oral** con:

- **Apertura automática en A1**: saludo + presentación (nombre, familia, gustos).
- **2-3 preguntas por banda CEFR** (A1→A2→B1→B2→C1→C2), subiendo de nivel
  cuando el jugador responde bien y bajando si se bloquea.
- **Adaptación dinámica**: follow-ups, aclaraciones, cambio de tema, profundización
  según cada respuesta. Prohibido leer listas fijas.
- **Reglas de registro silencioso** de 12 métricas: pronunciación, fluidez,
  gramática, vocabulario, comprensión oral, capacidad de mantener la
  conversación, naturalidad, corrección, complejidad del lenguaje, confianza,
  tiempo de respuesta y coherencia.
- **Cierre**: tras ~10-16 turnos del jugador, el Oráculo emite una línea de
  cierre mística + el token `[EVALUATION_COMPLETE]`.

---

## 5. Modificaciones realizadas

| Archivo | Cambio |
|---|---|
| `lib/features/conversation/domain/models/conversation_state.dart` | +4 campos: `isOracleEvaluation`, `oracleTargetLanguage`, `oracleNativeLanguage`, `oracleResult`. |
| `lib/features/conversation/presentation/providers/conversation_providers.dart` | +`initOracleSession`, `_runOracleTurn`, `_buildOracleHistory`, `_finalizeOracleEvaluation`, `_persistOracleAssessment`, helpers `_stringField`/`_stringListField`/`_assessmentDurationSeconds`; ramificación en `_processTranscription`; salto de cuota/permisos de Núcleo Arcano en modo Oracle. |
| `lib/features/conversation/presentation/screens/conversation_screen.dart` | +`oracleMode`, `oracleTargetLanguage`, `oracleNativeLanguage`; init condicional; pop con resultado al completar; oculta UI de misión en modo Oracle. |
| `lib/app/router.dart` | `/oracle-test` → `ConversationScreen(oracleMode: true)` con query params; removido import de la pantalla vieja. |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | `_startOracleEvaluation` pasa `?target=…&native=…`. |
| `supabase/migrations/20260731_oracle_assessments.sql` | **Nueva tabla** `oracle_assessments` (transcript, métricas, nivel, rango, idiomas, duración) + RLS own-read/insert. |
| `test/oracle_conversation_test.dart` | Actualizada la referencia de la heurística al nuevo hogar (`PlacementAiEvaluator`). |

**Eliminados (código muerto):**
- `oracle_conversation_screen.dart` (flujo por preguntas).
- `placement_test_screen.dart` (quiz por páginas, no referenciado).
- `oracle_providers.dart` y `oracle_question.dart` (solo usados por la pantalla vieja).

---

## 6. Elementos eliminados (cumplimiento del brief)

- Navegación entre preguntas. ✅
- Pantallas independientes de preguntas. ✅
- Botón "Siguiente pregunta" / "Saltar". ✅
- Preguntas hardcodeadas / tabla `oracle_questions` (queda en BD, sin uso en app). ✅
- Flujo por páginas / estado manual (`_currentIndex`, `_answers`). ✅
- Estado manual de la evaluación → ahora lo decide la IA y lo expone el notifier. ✅

---

## 7. Persistencia

| Dato | Dónde |
|---|---|
| Conversación (mensajes Oráculo/jugador) | `conversations` + `messages` (reutilizado). |
| Nivel CEFR + rango + métricas + strengths/weaknesses/explanation/focus | `user_language_profiles` (columnas `placement_*`, `game_rank`). |
| Transcript completo, idioma objetivo/nativo, duración | `oracle_assessments` (nueva). |
| Fecha | `placement_assessed_at` y `created_at`. |

La escritura es **best-effort** (try/catch silencioso) para no romper el flujo
si la BD live aún no tiene las columnas/tabla (proyecto en modo read-only).

---

## 8. Internacionalización

- Todos los textos visibles del chat reutilizan las claves existentes:
  `oracle_title`, `oracle_listening`, `oracle_processing`, `oracle_no_voice`.
- El Oráculo **habla en el idioma objetivo** (`oracleTargetLanguage`) definido
  en el system prompt. La interfaz usa el idioma de la app (l10n existente).
- No se introdujeron textos hardcodeados nuevos en la UI.

---

## 9. QA

- `flutter analyze`: 0 errores (bar del proyecto).
- `flutter test`: 73/73 (test Oracle actualizado, resto intacto).
- `flutter build apk --debug`: OK.

---

## 10. Extensibilidad futura

- El modo Oracle vive dentro del pipeline de conversación: cualquier mejora de
  STT/TTS/LLM aplica automáticamente al examen.
- La tabla `oracle_assessments` permite historial de exámenes y re-evaluaciones
  (ya soportado desde el dashboard: quick access "ORÁCULO").
- La estrategia de dificultad está en un único system prompt
  (`_buildOracleHistory`), fácil de ajustar o parametrizar por idioma.
