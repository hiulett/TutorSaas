import '../../../corrections/domain/models/turn_correction.dart';

/// Resultado de la llamada existente `goal_eval` (P-29).
///
/// Una sola petición devuelve las metas cumplidas **y** las correcciones del
/// turno: no se añade una llamada nueva por turno.
class GoalEvaluationResult {
  const GoalEvaluationResult({
    this.goals = const {},
    this.corrections = const [],
    this.discardedCorrections = 0,
  });

  /// `goalId` → cumplida.
  final Map<String, bool> goals;

  /// Correcciones válidas del turno (ya filtradas por tipo y tamaño).
  final List<TurnCorrection> corrections;

  /// Bloques de corrección descartados por no cumplir el esquema.
  final int discardedCorrections;

  static const GoalEvaluationResult empty = GoalEvaluationResult();

  bool get isEmpty => goals.isEmpty && corrections.isEmpty;
}
