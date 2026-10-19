# Auditoría 01 — Estado Actual del Onboarding (Resumen Verificado)

**Fecha:** 2026-08-01
**Ámbito:** Estado real y verificado del onboarding completo: flujo de 5 pasos, Oráculo, modo desarrollador, tarjeta del héroe, progreso y pipeline de IA
**Estado:** Hallazgos verificados contra código (sin cambios realizados)

---

## 1. Resumen ejecutivo

El onboarding de TutorSaas es funcional y está compuesto por **5 pasos en `PageView`** que persisten un perfil completo del cazador, una **evaluación del Oráculo en modo chat ESCRITO** (no por voz), un **modo desarrollador ya implementado**, una **tarjeta del héroe que solo aparece en el hub (no al terminar el onboarding)**, un **progreso calculado con 3 fórmulas distintas** y un **pipeline de IA real (Groq STT + DeepSeek + TTS)** cuya conexión aún tiene un error pendiente de capturar.

Ninguno de los hallazgos es bloqueante para el arranque, pero **todos impactan la percepción del usuario**: el Oráculo no usa el pipeline de voz que la app ya posee, y la tarjeta del héroe "que se promete al cazar" nunca se muestra al finalizar el wizard.

## 2. Flujo del onboarding (5 pasos)

| Paso | Índice | Contenido | Evidencia |
|---|---|---|---|
| Idioma nativo | 0 | Chips + selección de idioma nativo (obligatorio) | `onboarding_screen.dart:338`, validación `:92-97` |
| País | 1 | Chips + dropdown de país | `onboarding_screen.dart:339` |
| Idioma objetivo | 2 | Selección de idioma a aprender (obligatorio) | `onboarding_screen.dart:340`, validación `:99-104` |
| Clasificación del Oráculo | 3 | Explicación narrativa + botón **"INICIAR EVALUACIÓN"** → `/oracle-test` | `onboarding_screen.dart:341`, `:369`, `:787`, push `:142` |
| Creación de personaje | 4 | `character_creation_wizard.dart` (avatar, nombre, clase) — botón propio | `onboarding_screen.dart:342`, botón oculto en paso 4 `:349` |

Puntos clave del flujo:

- **Progreso visual**: barra segmentada de 5 bloques + etiqueta `1/5` (`onboarding_screen.dart:304-323`).
- **Navegación**: `PageView` con `NeverScrollableScrollPhysics`; avance controlado por `_nextPage()` (`onboarding_screen.dart:334-336`, `:90-123`).
- **El paso 3 no exige niveles manuales**: el usuario elige "INICIAR EVALUACIÓN" o puede omitir; si omite (resultado nulo), el guardado parte de **A1 por defecto** (`onboarding_screen.dart:166`).
- **Al regresar del Oráculo** con resultado, se avanza directamente al paso 4 y se fijan `cefrLevel` / `gameRank` (`onboarding_screen.dart:141-155`).

### Guardado final

`_completeOnboardingAndPurchase()` (`onboarding_screen.dart:158-233`) persiste:

1. `onboardingRepository.saveOnboardingData(...)` — idiomas, CEFR, metas, intereses, motivación, estilo, etc. (`:168-180`).
2. `userLanguageProvider` — idioma de aprendizaje / explicaciones en nativo / idioma UI (`:182-188`).
3. `users.country_code` (`:191-193`) y `user_language_profiles.game_rank` (`:198-200`).
4. `dashboardRepository.updateUserProfile(...)` con nombre y avatar (`:205-211`).
5. `isPremiumProvider.setPremium(false)` — el paywall queda post-sesión, el onboarding arranca en free (`:216`).
6. Finaliza con **`context.go('/home')`** (`:225`), también en el bloque de error (`:230`).

## 3. Oráculo (evaluación por voz vs. chat escrito)

| Elemento | Estado verificado | Evidencia |
|---|---|---|
| Interfaz de respuesta | **`TextField` de chat escrito** (`TextEditingController`) | `oracle_conversation_screen.dart:64`, `:400-401` |
| Envío de respuesta | `_submit()` agrega texto al hilo y avanza | `oracle_conversation_screen.dart:93-105` |
| Evaluación IA | `PlacementAiEvaluator.evaluatePlacement(answers)` (DeepSeek) con fallback heurístico local | `oracle_conversation_screen.dart:117-122`; `lib/core/ai/placement_ai.dart:15`, modelo `deepseek-v4-flash` `:18` |
| Nivel local sin IA | Heurística por palabras promedio (`_computeLevel`) | `oracle_conversation_screen.dart:82-91` |
| Persistencia | `placementRepository.savePlacementResult(...)` + `_persistAiDetails(...)` (upsert a `user_language_profiles`) | `oracle_conversation_screen.dart:146-152`, `:155-164`, `:199+` |
| Devolución al flujo | `Navigator.pop(placementResult)`; fallback a `/home` si no hay pila | `oracle_conversation_screen.dart:187-195` |

**Conclusión**: la evaluación IA valora pronunciación / fluidez / naturalidad, pero hoy se ejecuta sobre **transcripciones simuladas por texto escrito**, no sobre audio real. La app ya tiene un pipeline de voz funcional (ver §6).

## 4. Modo desarrollador (YA implementado)

- **Provider**: `devAlwaysShowOnboardingProvider` (`StateNotifierProvider<bool>`) con persistencia en `SharedPreferences` clave `'dev_always_show_onboarding'` — `onboarding_providers.dart:13`, `:24`, `:29`.
- **Switch** en Settings → Config: `"Forzar Onboarding Continuo"` — `settings_screen.dart:1196` (watch), `:1231-1240` (switch, toggle en `:1238`).
- **Lectura en el arranque**: `welcome_screen.dart:29` — si está activo, redirige a `/onboarding` en vez de `/home`.

**Impacto**: el modo dev está completo y no requiere trabajo. Es la herramienta de QA para probar los cambios de este plan sin tocar perfiles reales.

## 5. Tarjeta del héroe (`AIPickHeroCard`)

| Punto | Estado verificado | Evidencia |
|---|---|---|
| Widget | `AIPickHeroCard` (StatelessWidget) | `ai_pick_hero_card.dart:8`, `:14` |
| Dónde se muestra | SOLO en el hub de lecciones recomendadas, cuando **no hay búsqueda/categoría/nivel activos** | `recommended_lessons_hub.dart:308-316` (`if (_searchQuery.isEmpty && _selectedCategory == 'all' && _selectedCefr == 'all')`, render `:309`) |
| Dónde NO se muestra | **Al finalizar el onboarding** (`context.go('/home')` va directo al dashboard) ni en el flujo post-onboarding | `onboarding_screen.dart:225`, `:230` |

**Conclusión**: el usuario reporta "no aparece la tarjeta del héroe" porque, al terminar el onboarding, se aterriza en la pestaña Dungeons del dashboard; la tarjeta solo existe dentro de la pestaña de recomendaciones y condicionada a filtros vacíos. No hay ningún momento que la presente como "tu héroe ha sido elegido".

## 6. Progreso — 3 cálculos distintos

La fuente real de lecciones completadas es `completedLessonsProvider` (consulta `conversations` por `user_id`) — `dashboard_providers.dart:228`.

| Pantalla | Cálculo | Evidencia |
|---|---|---|
| **Dungeon header** | `SegmentedBar(value: (effectiveIndex + 1) / levelOrder.length)` → **posición del nivel actual** (`A1..C2`), NO progreso real | `dungeon_map_screen.dart:23-26` (derivado de `userProgressProvider.level_code`), `:114-118` |
| **LearningPathRoadmap** | `stageProgress = completedCount / totalCount` por etapa, desde `completedLessonsHistory` (= `completedLessonsProvider`) | `learning_path_roadmap.dart:105-107` |
| **Chat** | `realProgressRatio = max(savedProgress, (mensajes-1)/10)`; `savedProgress` viene de `match['progress']` de `recommendedLessonsProvider` | `conversation_screen.dart:558-574` |

**Conclusión**: para una misma lección, el roadmap puede mostrar avance y el chat 0% (y el dungeon header muestra posición de nivel, no avance). La fuente de verdad no está centralizada.

## 7. Pipeline de IA (AGENTS.md + código)

Pipeline oficial: record (AAC/m4a) → Groq Whisper STT (`en` forzado) → DeepSeek SSE streaming → flutter_tts (rate 0.48).

| Etapa | Estado verificado | Evidencia |
|---|---|---|
| STT (Groq) | `ConversationRepository.transcribeAudio(audioPath)` real: `FormData` multipart → `whisper-large-v3-turbo`, `language: en` | `conversation_repository_impl.dart:36-59`; contrato `conversation_repository.dart:4` |
| LLM (DeepSeek) | `streamConversation` SSE con reintentos; modelo `deepseek-v4-flash` | `conversation_repository_impl.dart:102+`, `:119` |
| TTS | **`generateTtsAudio` es un STUB que devuelve `''`** (`conversation_repository_impl.dart:219`) — el TTS real usa `flutter_tts` en la pantalla de conversación, no este método | `conversation_repository.dart:6`, `conversation_repository_impl.dart:219` |
| Evaluación de metas | `evaluateGoals(...)` (DeepSeek) | `conversation_repository_impl.dart:221+` |

**Pendiente**: error de conexión IA reportado por el usuario sin captura aún → ver `05_AI_Service_Diagnostics.md`.

> ⚠️ **Aviso para Fase 1**: `generateTtsAudio` no es un servicio TTS funcional (devuelve `''`). Si el Oráculo por voz requiere respuesta oral, debe integrarse `flutter_tts` directamente (como ya hace `conversation_screen`), NO depender de `generateTtsAudio`.

## 8. Tabla resumen de hallazgos

| ID | Hallazgo | Prioridad | Evidencia |
|---|---|---|---|
| H1 | Onboarding 5 pasos completo y persistente, arranca en free | — | `onboarding_screen.dart:158-233`, `:225` |
| H2 | Oráculo es **chat escrito**, no voz | P0 | `oracle_conversation_screen.dart:64`, `:400-401` |
| H3 | Modo desarrollador ya implementado | — | `onboarding_providers.dart:13`, `settings_screen.dart:1238`, `welcome_screen.dart:29` |
| H4 | Tarjeta del héroe solo en hub con filtros vacíos; **no al terminar el onboarding** | P0 | `recommended_lessons_hub.dart:308-316`; `onboarding_screen.dart:225` |
| H5 | Progreso con 3 fórmulas distintas; dungeon header mide posición de nivel | P1 | `dungeon_map_screen.dart:23-26`; `learning_path_roadmap.dart:105-107`; `conversation_screen.dart:558-574` |
| H6 | Pipeline de voz real (STT/LLM) pero `generateTtsAudio` es stub `''` | P1 | `conversation_repository_impl.dart:36`, `:219` |
| H7 | Error de conexión IA sin captura | P2 | ver `05_AI_Service_Diagnostics.md` |

## 9. Archivos clave del onboarding

| Ruta | Rol |
|---|---|
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Wizard de 5 pasos + guardado final |
| `lib/features/onboarding/presentation/screens/oracle_conversation_screen.dart` | Evaluación del Oráculo (chat escrito) |
| `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart` | Paso 4: personaje / avatar |
| `lib/features/onboarding/presentation/providers/onboarding_providers.dart` | `onboardingRepositoryProvider` + `devAlwaysShowOnboardingProvider` |
| `lib/core/ai/placement_ai.dart` | `PlacementAiEvaluator` (DeepSeek) |
| `lib/features/dashboard/presentation/widgets/ai_pick_hero_card.dart` | Tarjeta del héroe |
| `lib/features/dashboard/presentation/widgets/recommended_lessons_hub.dart` | Único lugar donde se renderiza la tarjeta del héroe |
| `lib/features/dashboard/presentation/providers/dashboard_providers.dart` | `completedLessonsProvider`, `recommendedLessonsProvider` |
| `lib/features/conversation/data/repositories/conversation_repository_impl.dart` | `transcribeAudio` (Groq), `streamConversation` (DeepSeek), `generateTtsAudio` (stub) |
