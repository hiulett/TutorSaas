/// P-40b (#221) — Banda CEFR del escenario adaptada al alumno.
///
/// El ajuste de P-40 (#125) era **léxico**: cambiaba el prompt pero el
/// escenario seguía en su banda fija. Aquí la banda se resuelve con el nivel
/// real del alumno y se ajusta con las rachas de acierto/fallo, sin generar
/// contenido ni llamar a ningún modelo:
///
/// * si el escenario está por encima del nivel real, se recorta a ese nivel;
/// * dos fallos seguidos bajan una banda (suelo PRE-A1);
/// * tres turnos limpios y con sustancia suben una banda (techo C2);
/// * el número de objetivos que el tutor persigue se reduce cuando el hueco
///   entre escenario y alumno es grande.
///
/// La banda resultante es la que viaja al system prompt y la que decide el
/// mensaje de apertura, no solo el vocabulario.
library;

import 'dart:math' as math;

import 'tutor_adaptation.dart';

/// Resultado de adaptar un escenario a un alumno concreto.
class ScenarioBandPlan {
  const ScenarioBandPlan({
    required this.learnerLevel,
    required this.scenarioLevel,
    required this.effectiveLevel,
    required this.goalBudget,
    required this.scenarioAboveLearner,
    required this.simplified,
    required this.stretched,
  });

  /// Nivel real del alumno (`user_language_profiles → cefr_levels`).
  final String learnerLevel;

  /// `scenarios.difficulty_level` / `LessonData.level`.
  final String scenarioLevel;

  /// Banda que debe usar el tutor. Vacía si no hay datos suficientes.
  final String effectiveLevel;

  /// Cuántos objetivos debe perseguir el tutor (0 = todos).
  final int goalBudget;

  /// El escenario está por encima del nivel real y se recortó.
  final bool scenarioAboveLearner;

  /// La racha de fallos bajó la banda.
  final bool simplified;

  /// La racha de aciertos subió la banda.
  final bool stretched;

  /// `true` si la banda efectiva no coincide con la del escenario.
  bool get changesBand =>
      effectiveLevel.isNotEmpty &&
      effectiveLevel != scenarioLevel.trim().toUpperCase();

  /// `true` si el tutor debe perseguir menos objetivos que el escenario.
  bool get limitsGoals => goalBudget > 0;
}

class ScenarioBand {
  const ScenarioBand._();

  /// Escala CEFR de la app (misma que `CefrRank.cefrOrder` y `cefr_levels`).
  static const List<String> levels = [
    'PRE-A1',
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  /// Mínimo de objetivos que se conservan cuando el escenario queda grande.
  static const int minGoalBudget = 2;

  static String normalize(String level) => level.trim().toUpperCase();

  /// Índice canónico; -1 si el nivel no se reconoce.
  static int indexOf(String level) => levels.indexOf(normalize(level));

  static String? adjacentDown(String level) {
    final index = indexOf(level);
    if (index <= 0) return null;
    return levels[index - 1];
  }

  static String? adjacentUp(String level) {
    final index = indexOf(level);
    if (index < 0 || index >= levels.length - 1) return null;
    return levels[index + 1];
  }

  /// Banda para el refuerzo (P-42): una banda por debajo del nivel real.
  ///
  /// El refuerzo se genera cuando el alumno no superó la lección; mantener la
  /// misma banda repetiría la dificultad que acaba de fallar. Si no hay banda
  /// inferior (PRE-A1), se conserva el nivel real.
  static String remedialLevel(String realLevel) {
    final normalized = normalize(realLevel);
    return adjacentDown(normalized) ?? normalized;
  }

  /// Resuelve la banda efectiva y el presupuesto de objetivos del turno.
  static ScenarioBandPlan plan({
    required String learnerLevel,
    required String scenarioLevel,
    TutorDifficultyAdjustment adaptation = TutorDifficultyAdjustment.steady,
    int totalGoals = 0,
  }) {
    final learner = normalize(learnerLevel);
    final scenario = normalize(scenarioLevel);
    final learnerIdx = indexOf(learner);
    final scenarioIdx = indexOf(scenario);

    if (scenarioIdx < 0) {
      return ScenarioBandPlan(
        learnerLevel: learner,
        scenarioLevel: scenario,
        effectiveLevel: learnerIdx >= 0 ? learner : '',
        goalBudget: 0,
        scenarioAboveLearner: false,
        simplified: false,
        stretched: false,
      );
    }
    if (learnerIdx < 0) {
      return ScenarioBandPlan(
        learnerLevel: learner,
        scenarioLevel: scenario,
        effectiveLevel: scenario,
        goalBudget: 0,
        scenarioAboveLearner: false,
        simplified: false,
        stretched: false,
      );
    }

    final scenarioAboveLearner = scenarioIdx > learnerIdx;
    var effectiveIdx = math.min(scenarioIdx, learnerIdx);
    var simplified = false;
    var stretched = false;

    switch (adaptation) {
      case TutorDifficultyAdjustment.simplify:
        if (effectiveIdx > 0) {
          effectiveIdx -= 1;
          simplified = true;
        }
        break;
      case TutorDifficultyAdjustment.stretch:
        if (effectiveIdx < levels.length - 1) {
          effectiveIdx += 1;
          stretched = true;
        }
        break;
      case TutorDifficultyAdjustment.steady:
        break;
    }

    return ScenarioBandPlan(
      learnerLevel: learner,
      scenarioLevel: scenario,
      effectiveLevel: levels[effectiveIdx],
      goalBudget: _goalBudget(
        totalGoals: totalGoals,
        gap: scenarioIdx - learnerIdx,
        simplified: simplified,
      ),
      scenarioAboveLearner: scenarioAboveLearner,
      simplified: simplified,
      stretched: stretched,
    );
  }

  /// Objetivos a perseguir: todos si el escenario encaja; menos si es grande o
  /// si el alumno viene de fallar. Nunca deja un presupuesto inútil (1).
  static int _goalBudget({
    required int totalGoals,
    required int gap,
    required bool simplified,
  }) {
    if (totalGoals <= 0) return 0;
    var budget = 0;
    if (gap > 0) {
      final ratio = gap >= 2 ? 0.4 : 0.6;
      budget = (totalGoals * ratio).ceil();
    } else if (simplified) {
      budget = (totalGoals * 0.5).ceil();
    }
    if (simplified && gap > 0) budget -= 1;
    if (budget > 0) budget = math.max(minGoalBudget, budget);
    if (budget >= totalGoals) return 0;
    return budget;
  }
}
