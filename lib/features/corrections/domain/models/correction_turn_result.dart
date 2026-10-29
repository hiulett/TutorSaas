// P-29-b (#193) — Resultado de la evaluación de correcciones en chat libre.

import 'turn_correction.dart';

/// Desenlace de una petición `correction_turn`.
enum CorrectionTurnOutcome {
  /// El modelo respondió y su JSON se pudo interpretar (aunque no trajera
  /// correcciones: el turno estaba bien).
  ok,

  /// El proxy devolvió `402 no_mana`: no se insiste en el resto de la sesión.
  noMana,

  /// Red, HTTP no-200 o respuesta ilegible. No rompe el turno.
  failed,
}

class CorrectionTurnResult {
  const CorrectionTurnResult({
    required this.outcome,
    this.corrections = const [],
  });

  final CorrectionTurnOutcome outcome;

  /// Correcciones ya validadas por [parseCorrections] (tipos acotados,
  /// recortadas a 3 y sin duplicados).
  final List<TurnCorrection> corrections;

  bool get succeeded => outcome == CorrectionTurnOutcome.ok;

  bool get isOutOfMana => outcome == CorrectionTurnOutcome.noMana;

  static const CorrectionTurnResult noMana = CorrectionTurnResult(
    outcome: CorrectionTurnOutcome.noMana,
  );

  static const CorrectionTurnResult failed = CorrectionTurnResult(
    outcome: CorrectionTurnOutcome.failed,
  );
}
