# 04 — Nuevo algoritmo de progreso

## `MissionProgressService`

Nuevo servicio puro (sin Flutter widgets ni IO) en
`lib/features/dashboard/domain/models/mission_progress_service.dart`.

```dart
/// Única fuente de verdad del progreso de una misión.
///
/// Progress = completedGoals / totalGoals
class MissionProgressService {
  const MissionProgressService._();

  /// Progreso de una misión a partir de objetivos.
  /// totalGoals <= 0 → 0.0. Resultado clamp 0.0–1.0.
  static double lessonProgress({
    required int completedGoals,
    required int totalGoals,
  }) {
    if (totalGoals <= 0) return 0.0;
    return (completedGoals / totalGoals).clamp(0.0, 1.0).toDouble();
  }

  /// Cuenta cuántos objetivos de [results] están en true.
  static int countCompletedGoals(Map<String, bool> results) {
    return results.values.where((v) => v).length;
  }

  /// Conteo de objetivos completados para un escenario desde filas de
  /// `user_scenario_goals` (cada fila: scenario_id, goal_id, is_completed).
  static int completedGoalsForScenario(
    List<Map<String, dynamic>> rows,
    String scenarioId,
  ) {
    return rows
        .where((r) => r['scenario_id'] == scenarioId && r['is_completed'] == true)
        .length;
  }
}
```

## Fórmula de etapa (Ruta por Etapas)

La barra superior del roadmap pasa de "conteo binario de conversaciones" a:

```
stageProgress = Σ completedGoals(etapa) / Σ totalGoals(etapa)
```

Se calcula sumando `completedGoalsForScenario` por cada lección de la etapa y dividiendo entre la suma de `lesson.goals.length` de las mismas. Mantiene la protección de división por cero.

## Fórmula del Chat

La barra amarilla pasa de `max(score, mensajes/10)` a:

```dart
final ratio = MissionProgressService.lessonProgress(
  completedGoals: MissionProgressService.countCompletedGoals(
    conversationState.goalEvaluationResults,
  ),
  totalGoals: currentLesson?.goals.length ?? 0,
);
```

`goalEvaluationResults` es el estado en memoria sembrado desde BD y persistido en el mismo turno, así que **durante** la sesión y **después** (al volver a entrar) coincide exactamente con `user_scenario_goals`.

## Cuándo se recalcula

- **Dashboard**: al cambiar `dashboardRefreshProvider` (invalidate tras `endSession`), al cambiar nivel de etapa, y al cambiar de lección. `completedGoalsProvider` es `autoDispose` → se libera y recarga al volver a la pantalla.
- **Chat**: cada vez que el estado `goalEvaluationResults` cambia (re-build de `ConsumerWidget`), lo que ocurre justo después de que la IA evalúa y persiste cada objetivo. Sin timers, sin polling.

## Rendimiento

- Sin consultas nuevas en el hot path del chat: la barra usa estado en memoria ya presente.
- El dashboard agrega **una** consulta ligera (`user_scenario_goals`, columnas `scenario_id, goal_id, is_completed`), reemplazando lecturas de `conversations.score` que no aportaban.
- Caché segura: `completedGoalsProvider` se invalida con `dashboardRefreshProvider`; nunca se cachea un valor de progreso más allá de la sesión.
