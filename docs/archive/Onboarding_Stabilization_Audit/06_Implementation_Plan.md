# Plan de Implementación 06 — Estabilización del Onboarding

**Fecha:** 2026-08-01
**Ámbito:** Ejecución priorizada de las correcciones del onboarding (voz del Oráculo, tarjeta del héroe, progreso, avatar, diagnóstico IA)
**Estado:** Plan propuesto — sin cambios de código aplicados

---

## 0. Resumen de fases

| Fase | Prioridad | Entregable | Esfuerzo estimado |
|---|---|---|---|
| Fase 1 | P0 | Oráculo por voz (STT + TTS) | Alto |
| Fase 2 | P0 | Tarjeta del héroe al finalizar el onboarding | Medio |
| Fase 3 | P1 | Progreso centralizado (helper único) | Medio |
| Fase 4 | P1 | Panel de avatar responsive en el wizard | Bajo |
| Fase 5 | P2 | Diagnóstico de IA (preparación, esperar captura) | Bajo |

Orden sugerido: **Fase 1 → Fase 2 → Fase 3 → Fase 4 → Fase 5**. Las Fases 1 y 2 son P0 porque atacan directamente lo que el usuario percibe como defectos ("el Oráculo no habla" y "no aparece la tarjeta del héroe").

---

## Fase 1 (P0) — Oráculo por voz

### Objetivo
Reemplazar el `TextField` del Oráculo por **entrada por voz (hold-to-talk)** y **respuesta oral (TTS)**, alineando el test con el pipeline de voz real de la app. La evaluación IA (`PlacementAiEvaluator`) ya consume transcripciones, así que **su contrato no cambia**.

### Archivos
| Archivo | Cambio |
|---|---|
| `lib/features/onboarding/presentation/screens/oracle_conversation_screen.dart` | Reemplazar input escrito por hold-to-talk + reproducción TTS |
| `lib/features/conversation/data/repositories/conversation_repository_impl.dart` | **No modificar** `transcribeAudio` (ya sirve); solo reutilizar. Ver aviso TTS abajo. |
| `lib/core/ai/placement_ai.dart` | Sin cambios (contrato por transcripciones). |

### Widgets / navegación
- Eliminar (o justificar) `TextField` + `TextEditingController` (`oracle_conversation_screen.dart:64`, `:400-401`).
- Añadir botón **hold-to-talk** con el paquete `record` (mismo patrón que `conversation_screen`).
- Al soltar: grabar AAC/m4a → `ConversationRepository.transcribeAudio(audioPath)` (Groq) → anexar la transcripción al hilo (`_answers`).
- **Respuesta oral**: ⚠️ `generateTtsAudio` es un stub que devuelve `''` (`conversation_repository_impl.dart:219`). Para el TTS del Oráculo integrar **`flutter_tts` directamente** (rate 0.48), igual que hace `conversation_screen`. No depender del stub.
- Mantener el flujo: al completar las preguntas → `_finish()` evalúa y devuelve el resultado como hoy (`oracle_conversation_screen.dart:107-195`).
- Navegación sin cambios: sigue siendo `/oracle-test` lanzado desde `onboarding_screen.dart:142`.

### Dependencias
- `record` (ya en pubspec, usado en conversación), `groq` vía `transcribeAudio`, `flutter_tts`.
- Mismo contrato de repositorio (`conversation_repository.dart:4`, `:6`).

### Verificación
- `flutter analyze` con 0 errores.
- Test manual con modo dev activado (`devAlwaysShowOnboardingProvider`): pasar los 5 pasos hablando, validar que el nivel resultante refleje la transcripción real.
- Test manual de latencia: ciclo voz → transcripción → evaluación ≤ objetivo <1.5s con instrumentación del pipeline.

---

## Fase 2 (P0) — Tarjeta del héroe al finalizar el onboarding

### Objetivo
Que el usuario vea **su héroe/cazador elegido al terminar el onboarding**, ya que hoy aterriza en `/home` sin ninguna presentación (`onboarding_screen.dart:225`).

### Archivos
| Archivo | Cambio |
|---|---|
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Tras `_completeOnboardingAndPurchase()` exitoso, mostrar la tarjeta del héroe o un resumen del cazador antes de `context.go('/home')` |
| `lib/features/dashboard/presentation/widgets/ai_pick_hero_card.dart` | Reutilizar tal cual; o crear un "resumen de cazador" que muestre `_characterName`, `_characterClass`, `_selectedCefrCode`, `_gameRank` |
| `lib/features/dashboard/presentation/widgets/recommended_lessons_hub.dart` | Sin cambios (ya renderiza `AIPickHeroCard:309`) |

### Opciones de diseño (elegir una)
1. **Pantalla intermedia post-guardado** (recomendada): tras guardar, mostrar una vista corta "Tu héroe ha sido elegido" con `AIPickHeroCard` o un resumen con datos del personaje, botón "EMPEZAR AVENTURA" → `context.go('/home')`.
2. **Anclar en `/home`**: si `userProfile` está recién creado (primera sesión), mostrar el héroe como banner en la pestaña Dungeons.
3. **Hoja/diálogo**: `showModalBottomSheet` con la tarjeta y CTA.

### Widgets / navegación
- Si se elige pantalla intermedia, se agrega una ruta simple o un `Navigator.push` con resultado que luego hace `context.go('/home')`.
- Mantener `context.go('/home')` como destino final obligatorio (no romper el arranque en free).

### Verificación
- Test manual: terminar onboarding → ver tarjeta del héroe → "EMPEZAR AVENTURA" → `/home`.
- Test manual con modo dev: repetir el flujo varias veces sin datos corruptos.
- `flutter analyze` con 0 errores.

---

## Fase 3 (P1) — Progreso centralizado

### Objetivo
Eliminar la triple definición de progreso (dungeon header = posición de nivel; roadmap = completadas/etapa; chat = max(save, mensajes/10)) creando **un único helper** alimentado por `completedLessonsProvider`.

### Archivos
| Archivo | Cambio |
|---|---|
| `lib/features/dashboard/.../progress_utils.dart` (**nuevo**) | Helper único: `computeLessonProgress(completedLessons, scenarioId)` y `computeStageProgress(completedLessons, stageLevel)`. Fuente de verdad = `completedLessonsProvider` (`dashboard_providers.dart:228`) |
| `lib/features/dashboard/presentation/screens/dungeon_map_screen.dart` | Corregir header: usar progreso real por etapa/lecciones completadas en vez de `(effectiveIndex + 1) / levelOrder.length` (`:23-26`, `:114-118`) |
| `lib/features/dashboard/presentation/widgets/learning_path_roadmap.dart` | Delegar en el helper (`:105-107`) |
| `lib/features/conversation/presentation/screens/conversation_screen.dart` | Usar el mismo origen para `savedProgress` en vez de `match['progress']` de `recommendedLessonsProvider` (`:558-574`) |
| `lib/features/dashboard/presentation/providers/dashboard_providers.dart` | Verificar/alinear el campo `progress` de `recommendedLessonsProvider` con el helper |

### Verificación
- Unidad: tests del helper con datos de ejemplo (lección completada/parcial/no iniciada, etapas A1..C2).
- Manual: misma lección debe mostrar el mismo % en dungeon, roadmap y chat.
- `flutter analyze` con 0 errores.

---

## Fase 4 (P1) — Panel de avatar responsive

### Objetivo
Evitar overflow del panel de avatares en pantallas estrechas (6 orbes × 48 px en `Row spaceEvenly` ≈ 288 px mínimo).

### Archivos
| Archivo | Cambio |
|---|---|
| `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart` | Hacer el panel de avatares responsive: `Wrap` en vez de `Row`, orbes con `LayoutBuilder`/`FractionallySizedBox`, o tamaño fluido en función del ancho disponible |

### Verificación
- Manual: rotar el dispositivo y probar en pantallas pequeñas (≤ 320 dp) sin `RenderFlex overflow`.
- `flutter analyze` con 0 errores.

---

## Fase 5 (P2) — Diagnóstico de IA (preparar, esperar captura)

### Objetivo
Completar el diagnóstico del error de conexión IA **cuando el usuario aporte la captura** (log / error exacto). Ver `05_AI_Service_Diagnostics.md` para el checklist completo.

### Archivos
- Revisar `lib/core/constants/api_constants.dart` (claves vía `--dart-define`).
- Revisar `conversation_repository_impl.dart` (retries/timeouts DeepSeek y Groq).
- Revisar `lib/core/ai/placement_ai.dart` (timeouts 30s/60s del evaluador del Oráculo).

### Verificación
- Reproducir el error con el modo dev y capturar el log real (mensaje + status code) antes de tocar código.

---

## Riesgos transversales

| Riesgo | Fase | Mitigación |
|---|---|---|
| TTS del Oráculo depende de un stub (`generateTtsAudio` = `''`) | 1 | Integrar `flutter_tts` directo; no usar el stub |
| Cambios de voz rompen la evaluación heurística (`_computeLevel`) | 1 | Mantener el fallback; las transcripciones son texto, el contrato no cambia |
| Nueva pantalla intermedia alarga el onboarding percibido | 2 | CTA claro "EMPEZAR AVENTURA"; reutilizar `AIPickHeroCard` |
| Centralizar progreso altera % mostrados en pantallas existentes | 3 | Tests de unidad + comparar antes/después por pantalla |
| Respuesta del usuario pendiente (captura IA) | 5 | No tocar código hasta tener la captura |
