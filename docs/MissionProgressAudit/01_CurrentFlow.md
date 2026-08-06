# 01 — Flujo actual del cálculo de progreso

## Resumen ejecutivo

Existen **tres cálculos de progreso independientes y divergentes** para el avance de una misión/lección:

| Pantalla | Dónde se calcula | Fuente de datos | Fórmula |
|---|---|---|---|
| Dashboard — barra de etapa (Ruta por Etapas) | `learning_path_roadmap.dart:105-107` | `conversations` (filas con `scenario_id`) | lecciones con fila / total lecciones de la etapa |
| Dashboard — QuestCard de cada lección | `learning_path_roadmap.dart:386-388` | estado de desbloqueo (`completedByPlayer/nextAvailable/...`) | **hardcodeado**: `1.0` / `0.25` / `0.0` |
| Chat — barra amarilla superior | `conversation_screen.dart:583-592` | `conversations.score` (nunca se escribe) + nº de mensajes en memoria | `max(score/100, mensajes/10)` |
| Chat — barra verde de objetivos (`LiveGoalsTrackerBar`) | `live_goals_tracker_bar.dart:25,63-68` | `goalEvaluationResults` (estado en memoria) | `completadas / total` |

El único cálculo **semánticamente correcto** (objetivos completados / objetivos totales) es el de `LiveGoalsTrackerBar`, pero solo existe en memoria durante el chat y no se comparte con el dashboard.

## Diagrama de flujo actual

```
BD user_scenario_goals (is_completed=true)
        │  saveCompletedGoal() [persiste durante el chat]
        ▼
goalEvaluationResults  (memoria, ConversationState)
        │  LiveGoalsTrackerBar → barra verde (x/y)  ✓ correcto pero efímero
        │
        └── conversacion 99% en memoria, 0% persistido si no se vuelve a abrir

BD conversations (scenario_id, score, fluency_score)
        │  completedLessonsProvider
        ▼
completedLessonsHistory  (dashboard)
        │  ProgressUtils.lessonProgress → usa score (que NUNCA se escribe) → 0
        │  learning_path_roadmap → QuestCard hardcodeado 1.0/0.25/0.0
        ▼
Dashboard: % ficticio por estado, NO por objetivos reales
```

## Detalle Dashboard

1. **`completedLessonsProvider`** (`dashboard_providers.dart:228-242`): `FutureProvider.autoDispose` que consulta:
   ```sql
   SELECT scenario_id, score, fluency_score, created_at FROM conversations WHERE user_id = ?
   ```
   Sin filtro de "finalizada/aprobada": cualquier conversación (incluso abandonada) marca la lección como superada.

2. **`ProgressUtils.lessonProgress`** (`progress_utils.dart:14-28`): `score/100` o `fluency_score/100`, con `0.5` de fallback. **`score` y `fluency_score` nunca se escriben en `conversations`** (verificado: los writes de fluency van a `daily_fluency_stats`/`user_scenario_fluency`), por lo que esto devuelve 0 en la práctica.

3. **`learning_path_roadmap.dart`**:
   - Barra de etapa (L105-107): `completedCount / totalCount` donde `completedCount` = lecciones con *cualquier* fila en `conversations`.
   - QuestCard por lección (L386-388): `progress` hardcodeado por estado → `1.0` si `completedByPlayer`, `0.25` si `nextAvailable`, `0.0` si `unlockedByOracle` o `locked`.
   - `_getLessonScore` (L57-69) y el parámetro `score` de `_RoadmapNodeTile` (L264, L283, L295) son **código muerto**: nunca se renderizan.

## Detalle Chat

1. **Barra amarilla** (`conversation_screen.dart:583-592`):
   ```dart
   savedProgress    = ProgressUtils.lessonProgress(completedLessons, scenarioId)  // = 0 (score no se escribe)
   progressMessages = messages.length - 1                                        // nº de mensajes en memoria
   currentProgress  = progressMessages / 10.0                                    // divide entre 10 (¡fijo!)
   realProgressRatio = max(savedProgress, currentProgress)                        // = mensajes/10
   ```
   Esta barra **no mide objetivos**: mide cuántos mensajes escribió el usuario sobre un umbral fijo de 10. Por eso puede mostrar 0%, 20%, 40% arbitrarios sin relación con la misión.

2. **`LiveGoalsTrackerBar`** (`live_goals_tracker_bar.dart:25,63-68`): usa `goalEvaluationResults` (estado en memoria, sembrado desde BD en `initSession` vía `loadCompletedGoals`) y muestra `completadas/total` + `SegmentedBar`. Es el cálculo correcto, pero solo visible dentro del chat.

## Persistencia

- `saveCompletedGoal` (`conversation_repository_impl.dart:506-530`) hace `UPSERT` en **`user_scenario_goals`** con `is_completed=true` **en el momento** en que la IA evalúa cada objetivo (fire-and-forget por turno). La persistencia inmediata ya funciona.
- Al salir, `endSession` invalida `dashboardRefreshProvider` e `userProgressProvider`, forzando recarga del dashboard.
- **Problema**: el dashboard no lee `user_scenario_goals` para el % de cada misión → ignora todo el progreso de objetivos persistido.

## Tablas reales

| Tabla | Rol | Estado |
|---|---|---|
| `user_scenario_goals` | **Única fuente de verdad del progreso de objetivos** (`user_id, scenario_id, goal_id, is_completed`) | Sí, usada y escrita |
| `conversations` | Historial de conversaciones (sin score persistido) | Solo presencia de fila |
| `user_scenario_phrases` | Frases útiles usadas | Auxiliar |
| `user_vocabulary` | Vocabulario SM-2 | Auxiliar |
| `scenario_progress` / `user_progress` / `mission_progress` | **No existen** | — |

## Conclusión

El porcentaje real de una misión debe ser `objetivos_completados_en_user_scenario_goals / objetivos_totales_del_catálogo`. Ese dato ya se persiste correctamente; lo que falta es que **Dashboard y Chat lo consuman de la misma forma**.
