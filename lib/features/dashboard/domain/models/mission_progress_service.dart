/// Única fuente de verdad del progreso de una misión.
///
/// Progress = completedGoals / totalGoals
///
/// - `completedGoals` proviene de `user_scenario_goals` (filas con
///   `is_completed = true`) o, durante el chat, de `goalEvaluationResults`
///   (que se siembra y persiste desde esa misma tabla).
/// - `totalGoals` siempre proviene del catálogo (`LessonData.goals.length`),
///   nunca hardcodeado en la UI.
///
/// Helper puro — sin widgets ni dependencias de Flutter.
class MissionProgressService {
  const MissionProgressService._();

  /// Progreso de una misión a partir de objetivos completados y totales.
  ///
  /// - `totalGoals <= 0` → `0.0` (evita división por cero).
  /// - Resultado clampado a `0.0–1.0`.
  static double lessonProgress({
    required int completedGoals,
    required int totalGoals,
  }) {
    if (totalGoals <= 0) return 0.0;
    return (completedGoals / totalGoals).clamp(0.0, 1.0).toDouble();
  }

  /// Cuenta cuántos objetivos de [results] están en `true`.
  ///
  /// [results] es el estado en memoria del chat (`goalEvaluationResults`):
  /// clave = `goal.id`, valor = alcanzado.
  static int countCompletedGoals(Map<String, bool> results) {
    return results.values.where((v) => v).length;
  }

  /// Nº de objetivos completados para [scenarioId] a partir de filas de
  /// `user_scenario_goals` (cada fila: `scenario_id`, `goal_id`, `is_completed`).
  static int completedGoalsForScenario(
    List<Map<String, dynamic>> rows,
    String scenarioId,
  ) {
    return rows
        .where((r) => r['scenario_id'] == scenarioId && r['is_completed'] == true)
        .length;
  }
}
