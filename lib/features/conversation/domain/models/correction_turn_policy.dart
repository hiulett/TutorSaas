// P-29-b (#193) / P-40-c (#222) — Correcciones en conversación libre.
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
//
// P-40-c: `correction_turn` es una acción **gratuita** (`FREE_ACTIONS` en el
// proxy). El maná ya lo paga el turno de conversación; las correcciones son su
// salida pedagógica y no dependen del saldo. Por eso la política no tiene
// ninguna condición de maná: un alumno con 0 de maná que conversa con el turno
// de gracia sigue generando historial de errores.

import '../../../corrections/domain/models/turn_correction.dart';
import 'goal_evaluation_gate.dart';

class CorrectionTurnPolicy {
  const CorrectionTurnPolicy._();

  /// Tope duro de evaluaciones de corrección por sesión de chat libre.
  ///
  /// Ya no se traduce en maná (la acción es gratuita), pero acota el gasto real
  /// de tokens: máximo 6 llamadas cortas por sesión frente a un turno de
  /// conversación por cada mensaje del alumno.
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
  static bool shouldRequest({
    required String correctionLevel,
    required String lastUserMessage,
    required int evaluationsThisSession,
    bool goalsEvaluatedThisTurn = false,
  }) {
    if (goalsEvaluatedThisTurn) return false;
    if (!levelUsesTurnEvaluation(correctionLevel)) return false;
    if (evaluationsThisSession >= maxEvaluationsPerSession) return false;
    return GoalEvaluationGate.shouldEvaluate(
      lastUserMessage: lastUserMessage,
      goalTexts: const [],
    );
  }

  /// ¿Se puede persistir esta tanda en `public.corrections`?
  ///
  /// P-40-c: sin datos reales no hay fila. Un invitado, un turno sin `turn_ref`
  /// o una lista vacía no escriben nada; nunca se inventan correcciones para
  /// «tener historial». Con datos válidos, la escritura es idempotente por el
  /// índice `(user_id, turn_ref, error_type, original_text)`.
  static bool shouldPersist({
    required String? userId,
    required String? turnRef,
    required List<TurnCorrection> corrections,
  }) {
    if (corrections.isEmpty) return false;
    if (userId == null || userId.isEmpty || userId.startsWith('guest_')) {
      return false;
    }
    return turnRef != null && turnRef.isNotEmpty;
  }
}
