// P-29-b (#193) — Correcciones en conversación libre.
//
// Lógica pura (sin Flutter ni Supabase) para decidir **cuándo** se pide una
// evaluación de correcciones cuando la sesión no tiene metas de lección
// pendientes. El coste se acota con tres reglas:
//
// 1. Nada de una llamada por turno: se reutiliza `GoalEvaluationGate`
//    (respuesta de ≥5 palabras). En chat libre no hay metas, así que el gate
//    solo aplica su umbral de longitud.
// 2. Tope duro por sesión: [CorrectionTurnPolicy.maxEvaluationsPerSession].
// 3. `correction_level = important_only` no llama al modelo (el alumno pide
//    «solo lo importante» y el chip ya filtra a gramática; ahorramos la
//    llamada). Ese nivel sigue recibiendo correcciones en lecciones con metas,
//    donde la evaluación ya se paga para marcar objetivos.
//
// Si el turno ya lanzó `goal_eval` (lección con metas), las correcciones llegan
// en esa misma respuesta: nunca se pide una segunda llamada.

import '../../../corrections/domain/models/turn_correction.dart';
import 'goal_evaluation_gate.dart';

class CorrectionTurnPolicy {
  const CorrectionTurnPolicy._();

  /// Tope duro de evaluaciones de corrección por sesión de chat libre.
  ///
  /// Con `action_code = correction_turn` (3 de maná) el coste máximo extra por
  /// sesión es 18 de maná, muy por debajo del turno de conversación (8/turno).
  static const int maxEvaluationsPerSession = 6;

  /// Niveles que sí justifican una llamada al modelo en chat libre.
  ///
  /// `important_only` queda fuera a propósito: el nivel pide el mínimo ruido y
  /// el valor de detectar «solo lo grave» no compensa una petición extra.
  static bool levelUsesTurnEvaluation(String level) {
    return normalizeCorrectionLevel(level) != 'important_only';
  }

  /// Decide si este turno debe pedir `correction_turn`.
  ///
  /// [evaluationsThisSession] cuenta las peticiones ya lanzadas en la sesión
  /// (incluidas las fallidas: el tope acota el gasto, no los aciertos).
  /// [goalsEvaluatedThisTurn] evita la llamada duplicada cuando `goal_eval` ya
  /// devolvió las correcciones.
  /// [skippedForMana] se activa tras un 402: el resto de la sesión no vuelve a
  /// pedir correcciones (degradación limpia, sin error visible).
  static bool shouldRequest({
    required String correctionLevel,
    required String lastUserMessage,
    required int evaluationsThisSession,
    bool goalsEvaluatedThisTurn = false,
    bool skippedForMana = false,
  }) {
    if (goalsEvaluatedThisTurn) return false;
    if (skippedForMana) return false;
    if (!levelUsesTurnEvaluation(correctionLevel)) return false;
    if (evaluationsThisSession >= maxEvaluationsPerSession) return false;
    return GoalEvaluationGate.shouldEvaluate(
      lastUserMessage: lastUserMessage,
      goalTexts: const [],
    );
  }
}
