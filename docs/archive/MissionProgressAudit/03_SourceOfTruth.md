# 03 — Fuente única de verdad (Single Source of Truth)

## La tabla oficial

`user_scenario_goals` es la **única fuente de verdad** del progreso de una misión:

```
user_id      → jugador
scenario_id  → la misión/lección (id del catálogo, p.ej. 'a1_greetings')
goal_id      → identificador del objetivo dentro de la lección (p.ej. 'g1')
is_completed → true cuando el objetivo está completado
```

- Los objetivos completados se escriben **inmediatamente** con `saveCompletedGoal` (UPSERT) durante el chat.
- El total de objetivos de una misión se define en el **catálogo estático** `LessonCatalog.getLessonById(id).goals.length`.

## Definición del progreso

```
Progress(mission) = completedGoals / totalGoals
```

donde:
- `completedGoals` = nº de filas en `user_scenario_goals` con `user_id`, `scenario_id` e `is_completed = true`
- `totalGoals` = nº de `ScenarioGoalItem` de esa lección en el catálogo (`LessonData.goals.length`)

Reglas:
- `totalGoals == 0` → `0.0` (evita división por cero).
- `completedGoals` nunca supera `totalGoals` (clamp 0.0–1.0).
- Una misión recién iniciada → `0/5 = 0%`.
- Una misión con 3/4 objetivos → `75%`, idéntico en todas las pantallas.

## Quién consume qué

| Pantalla | Antes | Después (fuente única) |
|---|---|---|
| Dashboard — barra de etapa | `conversations` binario | `user_scenario_goals` (objetivos completados de la etapa / objetivos totales de la etapa) |
| Dashboard — QuestCard | hardcodeado por estado | `MissionProgressService.lessonProgress(completedGoals, totalGoals)` leyendo `user_scenario_goals` |
| Chat — barra amarilla | `max(score, mensajes/10)` | `MissionProgressService.lessonProgress` con `goalEvaluationResults` (que **se persiste** en `user_scenario_goals` en el mismo turno) |
| Chat — `LiveGoalsTrackerBar` | cálculo inline (correcto) | el mismo `MissionProgressService` |

## Cómo se sincroniza (eventos)

```
Usuario completa un objetivo
        │  _evaluateGoalsWithAi() [conversation_providers.dart:1049]
        ▼
goalEvaluationResults[key] = true   (estado en memoria, inmediato)
        │  saveCompletedGoal()       (UPSERT user_scenario_goals, fire-and-forget)
        ▼
user_scenario_goals (BD)  ← persistido en el MISMO turno, nunca solo en memoria
        │
        ├── completedGoalsProvider (FutureProvider.autoDispose) [nuevo]
        │         └── Dashboard roadmap → % por objetivos
        │
        └── re-entrada al chat → loadCompletedGoals() siembra goalEvaluationResults
                  └── LiveGoalsTrackerBar + barra amarilla → mismo %
```

Al salir del chat, `endSession` invalida `dashboardRefreshProvider`, que dispara la recarga de `completedGoalsProvider` → el dashboard refleja el 100% (o el % real) al volver.

## Invariancia (propiedad clave)

Para cualquier misión M, en cualquier instante t, todas las pantallas deben resolver:

```
f(completedGoals(M,t), totalGoals(M))  — misma función pura, mismos datos
```

Si dos pantallas muestran % distintos, es un bug en la sincronización de datos (cache/invalidación), nunca una diferencia de fórmula, porque la fórmula es única y compartida.
