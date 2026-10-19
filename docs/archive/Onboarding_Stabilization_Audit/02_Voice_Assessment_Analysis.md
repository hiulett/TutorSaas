# Auditoría 02 — Análisis de la Evaluación por Voz (Oracle Test)

**Fecha:** 2026-08-01
**Ámbito:** Flujo de evaluación de nivel (`/oracle-test`) vs. pipeline de voz existente
**Estado:** Hallazgo verificado — propuesta de rediseño (sin cambios de código)

---

## 1. Hallazgo

El test del Oráculo (`oracle_conversation_screen.dart`) se implementó como **chat ESCRITO**, no como una entrevista oral con el Oráculo.

Evidencia:

- Usa `TextField` con `TextEditingController` (`oracle_conversation_screen.dart:64`, `oracle_conversation_screen.dart:400-401`).
- `_submit()` (`oracle_conversation_screen.dart:89-101`) agrega el texto escrito al hilo de respuestas.
- `_finish()` (`oracle_conversation_screen.dart:103-125`) llama a `PlacementAiEvaluator.evaluatePlacement(_answers)` (de `lib/core/ai/placement_ai.dart`, motor DeepSeek), persiste vía `_persistAiDetails` (upsert a `user_language_profiles`: `game_rank`, `placement_scores`/`strengths`/`weaknesses`, `placement_explanation`, `recommended_focus`, `assessed_at`) y devuelve el resultado al flujo con `Navigator.pop(placementResult)` (fallback a `/home`).

La evaluación IA valora pronunciación / vocabulario / gramática / comprensión / fluidez / naturalidad, pero hoy se ejecuta sobre **transcripciones simuladas por texto escrito**, no sobre audio real.

## 2. Causa raíz

Durante el revamp del onboarding el test se construyó como un chat de texto, **sin integrar el pipeline de voz que la app ya posee**. La app sí cuenta con un pipeline real y funcionando:

1. Record (AAC/m4a) → 2. Groq Whisper STT (`whisper-large-v3-turbo`, idioma `en` forzado) → 3. DeepSeek SSE streaming → 4. flutter_tts (rate 0.48).

`ConversationRepository.transcribeAudio(audioPath)` (Groq) y `generateTtsAudio(text)` existen y se reutilizan en `conversation_screen` (patrón hold-to-talk con el paquete `record`). El Oráculo quedó desconectado de esta infraestructura.

## 3. Evidencia

| Elemento | Referencia |
|---|---|
| Input escrito | `oracle_conversation_screen.dart:64`, `:400-401` |
| Envío de texto | `oracle_conversation_screen.dart:89-101` |
| Cierre / evaluación | `oracle_conversation_screen.dart:103-125` |
| Evaluador IA (DeepSeek) | `lib/core/ai/placement_ai.dart` (`PlacementAiEvaluator.evaluatePlacement`) |
| Persistencia del perfil | `_persistAiDetails` → upsert `user_language_profiles` |
| STT existente | `ConversationRepository.transcribeAudio(audioPath)` (Groq) |
| TTS existente | `ConversationRepository.generateTtsAudio(text)` / flutter_tts |
| Pipeline de voz (AGENTS.md) | record → Whisper → DeepSeek → flutter_tts |

## 4. Archivos afectados

- `lib/features/onboarding/presentation/oracle_conversation_screen.dart` (reemplazo del input).
- `lib/core/.../conversation_repository_impl.dart` (reutilizar `transcribeAudio` / `generateTtsAudio`).
- `lib/core/ai/placement_ai.dart` (la evaluación ya consume transcripciones; sin cambios de contrato).

## 5. Solución propuesta — conversación oral completa

1. **Sustituir `TextField` por botón hold-to-talk** siguiendo el patrón `record` ya usado en `conversation_screen`.
2. **STT:** al soltar el botón, invocar `ConversationRepository.transcribeAudio(audioPath)` (Groq Whisper) y anexar la transcripción al hilo de respuestas.
3. **TTS / respuestas orales:** el Oráculo responde mediante `generateTtsAudio` / flutter_tts con **preguntas abiertas** que fuerzan habla espontánea (mejor señal que respuestas leídas).
4. **Evaluación:** la IA (DeepSeek vía `PlacementAiEvaluator`) evalúa las transcripciones de habla real, lo que da sentido real a las dimensiones pronunciación / fluidez / naturalidad.
5. **Sin cajas de texto:** justificar o eliminar el botón de escritura manual para no reintroducir el modo chat.

## 6. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| **Latencia** del ciclo STT + LLM + TTS sobre el presupuesto <1.5s | Streaming SSE ya implementado; precalentar TTS; medir con instrumentación del pipeline existente. |
| **Fallos de micrófono** en el dispositivo | Estados de error visibles con `debugPrint` + UI de reintento; nunca bloquear el flujo. |
| **Permisos** de grabación denegados | Solicitud y guía de permisos antes de iniciar; degradación elegante. |
| Transcripciones ruidosas | Mantener el fallback de **texto opcional** (con justificación visible) como red de seguridad. |

## 7. Notas de cierre

- No se modifica código en esta auditoría; es una propuesta de rediseño pendiente de aprobación.
- El contrato de persistencia y evaluación (`user_language_profiles`, `PlacementAiEvaluator`) permanece intacto.
