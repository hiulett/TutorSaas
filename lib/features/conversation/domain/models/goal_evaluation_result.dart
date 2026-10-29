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
    this.succeeded = false,
  });

  /// `goalId` → cumplida.
  ///
  /// Puede contener ids que no pertenecen a la lección: usa
  /// [goalsForCatalog] antes de persistir o de pintar la barra de metas.
  final Map<String, bool> goals;

  /// Correcciones válidas del turno (ya filtradas por tipo y tamaño).
  final List<TurnCorrection> corrections;

  /// Bloques de corrección descartados por no cumplir el esquema.
  final int discardedCorrections;

  /// `true` solo si el proxy respondió y su contenido se pudo interpretar.
  ///
  /// Un fallo de red, un HTTP no-200 o una respuesta ilegible dejan esto en
  /// `false` para que la siguiente evaluación pueda reintentarse.
  final bool succeeded;

  static const GoalEvaluationResult empty = GoalEvaluationResult();

  bool get isEmpty => goals.isEmpty && corrections.isEmpty;

  /// Regla P-39: una meta solo puede marcarse si el modelo la devolvió con
  /// `true` **y** su id pertenece al catálogo de la lección.
  ///
  /// Devuelve una entrada por id del catálogo (las no devueltas quedan en
  /// `false`) y descarta cualquier id inventado o desconocido.
  Map<String, bool> goalsForCatalog(Iterable<String> catalogGoalIds) {
    final allowed = <String>{};
    for (final id in catalogGoalIds) {
      final normalized = id.trim();
      if (normalized.isNotEmpty) allowed.add(normalized);
    }
    return {for (final id in allowed) id: goals[id] == true};
  }
}
