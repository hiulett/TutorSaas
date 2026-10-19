# 02 — Inconsistencias detectadas

## 1. Dashboard QuestCard usa valores hardcodeados por estado

`learning_path_roadmap.dart:386-388`:

```dart
progress: isCompleted
    ? 1.0
    : (isNextLesson ? 0.25 : (isUnlockedByOracle ? 0.0 : 0.0)),
```

- Una misión que el usuario **nunca abrió** pero que es "siguiente" muestra **25%**.
- Una misión completada al 100% de objetivos muestra **100%** solo si `completedByPlayer` (existe fila en `conversations`), ignorando los objetivos reales.
- No consulta `user_scenario_goals` en absoluto.

**Ejemplo del bug reportado**: Dashboard "40%" = misión marcada como "siguiente" (0.25 no es 40%, pero si la lógica combinaba `stageProgress` o el score de otra fila, el resultado era arbitrario); el chat mostraba "0%" porque `score` no está escrito y `messages.length` arranca en 1 → `(1-1)/10 = 0`.

## 2. Chat: barra superior no mide objetivos

`conversation_screen.dart:583-592`:

```dart
savedProgress    = ProgressUtils.lessonProgress(...)  // lee score, nunca escrito → 0
currentProgress  = (messages.length - 1) / 10.0        // divide mensajes entre 10
realProgressRatio = max(savedProgress, currentProgress)
```

- El umbral `10` es **arbitrario y hardcodeado**.
- No usa `goalEvaluationResults`.
- Resultado: la barra amarilla puede mostrar 0% (recién entrado), 20%, 40%… según cuántos mensajes escriba, sin relación con los objetivos de la misión.

## 3. Cálculos duplicados

| Método | Archivo | Lógica |
|---|---|---|
| `ProgressUtils.lessonProgress` | `progress_utils.dart:14-28` | score/100 |
| `_getLessonScore` (muerto) | `learning_path_roadmap.dart:57-69` | score, fallback 88 |
| `_isLessonCompleted` | `learning_path_roadmap.dart:51-55` | duplica `ProgressUtils.isLessonCompleted` |
| `completedCount` inline | `live_goals_tracker_bar.dart:25` | cuenta objetivos true |
| `savedProgress/currentProgress` | `conversation_screen.dart:583-592` | score + mensajes/10 |

Hay **5 implementaciones** distintas del mismo concepto "progreso de misión".

## 4. Valores hardcodeados

| Valor | Ubicación | Problema |
|---|---|---|
| `0.25` (siguiente) | `learning_path_roadmap.dart:387` | % inventado |
| `1.0` (completada) | `learning_path_roadmap.dart:386` | no refleja objetivos reales |
| `88` (score por defecto) | `learning_path_roadmap.dart:68` | código muerto |
| `0.5` (neutro) | `progress_utils.dart:27` | fallback sin datos |
| `10` (umbral mensajes) | `conversation_screen.dart:591` | % de mensajes, no de objetivos |

## 5. Estado en memoria no sincronizado con BD

- `goalEvaluationResults` (memoria) es la única fuente del `LiveGoalsTrackerBar`. Se siembra desde BD al entrar, pero **el dashboard nunca lo lee**.
- El dashboard usa `conversations` (que solo indica presencia de conversación) y estados de desbloqueo calculados en memoria por `LessonUnlockService.classify`.

## 6. "Completada" sin filtro real

`completedLessonsProvider` (`dashboard_providers.dart:234-237`) selecciona **todas** las filas de `conversations` sin `.eq('is_completed', true)` ni status. Una conversación abandonada marca la lección como superada.

## 7. Score muerto

`_getLessonScore` y `score` en `_RoadmapNodeTile` se calculan pero **nunca se renderizan** (grep confirmado). Es código muerto que da falsa impresión de que el score alimenta la UI.

## Resumen de impacto

- El Dashboard no refleja el progreso real de objetivos de ninguna misión.
- El Chat muestra un % basado en mensajes, no en objetivos.
- Ninguna pantalla comparte la misma fuente: la inconsistencia "Dashboard 40% vs Chat 0%" es estructural.
