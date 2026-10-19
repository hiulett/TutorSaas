# 05 — Sincronización de UI (Dashboard ↔ Chat)

## Estado objetivo: una sola fuente, dos vistas

```
                      user_scenario_goals  (BD, fuente única)
                                  │
        ┌─────────────────────────┴──────────────────────────┐
        │  completedGoalsProvider (nuevo, autoDispose)        │  goalEvaluationResults (estado en memoria)
        ▼                                                      ▼
   Dashboard roadmap                                     Chat (ConversationScreen)
   • barra de etapa  = Σcompletadas/Σtotales              • barra amarilla = MissionProgressService.lessonProgress
   • QuestCard       = lessonProgress(...)                  • LiveGoalsTrackerBar = mismo servicio
        │                                                      │
        └──────────── dashboardRefreshProvider ◄────────────────┘   (endSession → invalidate)
                             │
                             └── recarga completedGoalsProvider → dashboard refleja % persistido
```

## Componente base compartido

Las barras **ya comparten** el widget base `SegmentedBar` (`lib/core/widgets/segmented_bar.dart`):

- `QuestCard` → `SegmentedBar(value: progress, segments: progressSegments, ...)` (`quest_card.dart:154`)
- `LiveGoalsTrackerBar` → `SegmentedBar(value: completedCount / totalCount, ...)` (`live_goals_tracker_bar.dart:63-68`)
- Barra de etapa del roadmap → `LinearProgressIndicator` (barra continua de etapa, correcto para un agregado)

Con la fuente única, **`QuestCard` y `LiveGoalsTrackerBar` reciben el mismo valor**, de modo que un mismo objetivo completado pinta el mismo segmento en el dashboard y en el chat.

## Sincronización en tiempo real durante la conversación

1. La IA evalúa metas en `_evaluateGoalsWithAi` (`conversation_providers.dart:1049-1097`).
2. `goalEvaluationResults` se actualiza → **re-build inmediato** del chat (barra amarilla + LiveGoalsTrackerBar) gracias a Riverpod.
3. `saveCompletedGoal` persiste en `user_scenario_goals` en el **mismo turno** (fire-and-forget, pero inmediato).
4. Al salir del chat, `endSession` incrementa `dashboardRefreshProvider` → `completedGoalsProvider` (que lo observa) se invalida → al volver al dashboard, la QuestCard muestra el % real persistido.

## Casos especiales garantizados

| Caso | Valor mostrado (todas las pantallas) |
|---|---|
| Misión iniciada, 0 objetivos | `0/5` → `0%` |
| 1 objetivo completado | `1/5` → `20%` |
| 2 completados | `2/5` → `40%` |
| 3 completados | `3/5` → `60%` |
| 4 completados | `4/5` → `80%` |
| 5 completados | `5/5` → `100%` |
| Salir del chat con 100% | Dashboard sigue mostrando `100%` (persistido, no recalculado) |

## Invariantes

- `totalGoals` siempre proviene del catálogo (`LessonData.goals.length`), nunca hardcodeado en la UI.
- `completedGoals` siempre proviene de `user_scenario_goals` (vía provider) o de `goalEvaluationResults` (que se siembra y persiste desde esa misma tabla).
- No hay segundos cálculos: cualquier % nuevo pasa por `MissionProgressService`.
