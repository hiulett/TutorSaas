import '../../../onboarding/domain/models/cefr_rank.dart';
import '../models/boss_exam_rubric.dart';

/// P-31 (#116) — Reglas puras del examen de promoción.
///
/// El examen no puede quedarse abierto para siempre: hay un tope duro de
/// turnos y un tiempo máximo. Al alcanzarlos se cierra con la evidencia
/// disponible y el servidor decide con lo que haya (incluida la rúbrica).
class BossExamRules {
  BossExamRules._();

  /// Tope duro de respuestas del jugador antes de forzar el cierre.
  static const int maxTurns = 8;

  /// Evidencia mínima para que el servidor acepte evaluar el intento.
  static const int minAnswers = 5;

  /// Tiempo máximo del examen desde la apertura del Oráculo.
  static const Duration timeLimit = Duration(minutes: 12);

  /// ¿Hay que cerrar ya (por turnos o por tiempo)?
  static bool shouldForceClose({
    required int turns,
    required Duration elapsed,
  }) {
    if (turns >= maxTurns) return true;
    return elapsed >= timeLimit;
  }

  /// ¿Hay evidencia suficiente para pedir la evaluación al servidor?
  ///
  /// Si el examen se cierra con menos respuestas, no se llama a la función:
  /// el intento no cuenta ni consume cooldown.
  static bool hasEnoughEvidence(int turns) => turns >= minAnswers;

  /// Veredicto que puede deducir el cliente cuando el servidor no lo manda.
  ///
  /// Ascender exige nivel superior **y** rúbrica aprobada; si falta algo, se
  /// mantiene el nivel (nunca baja).
  static BossExamLocalVerdict decide({
    required String previousLevel,
    required String evaluatedLevel,
    required Map<String, dynamic> scores,
  }) {
    if (previousLevel.isEmpty) {
      return const BossExamLocalVerdict(
        promoted: false,
        reasonCode: '',
        initial: true,
      );
    }
    final rubric = BossExamRubric.fromScores(scores);
    final previousIndex = CefrRank.cefrOrder.indexOf(previousLevel);
    final evaluatedIndex = CefrRank.cefrOrder.indexOf(evaluatedLevel);
    final higher = previousIndex >= 0 && evaluatedIndex > previousIndex;
    if (!higher) {
      return const BossExamLocalVerdict(
        promoted: false,
        reasonCode: 'no_improvement',
      );
    }
    if (!rubric.passed) {
      return const BossExamLocalVerdict(
        promoted: false,
        reasonCode: 'rubric_below_threshold',
      );
    }
    return const BossExamLocalVerdict(promoted: true, reasonCode: '');
  }

  /// Salud visual del jefe (100 → 0) según los turnos consumidos.
  ///
  /// Capa cosmética: no altera la evaluación, que es del servidor.
  static int bossHealthPercent(int turns) {
    if (turns <= 0) return 100;
    final consumed = (turns / maxTurns).clamp(0.0, 1.0);
    return (100 - consumed * 100).round().clamp(0, 100);
  }
}

/// Resultado local (espejo de la regla del servidor) para tests y fallback.
class BossExamLocalVerdict {
  const BossExamLocalVerdict({
    required this.promoted,
    required this.reasonCode,
    this.initial = false,
  });

  final bool promoted;
  final String reasonCode;

  /// `true` si no había nivel previo (placement inicial).
  final bool initial;
}
