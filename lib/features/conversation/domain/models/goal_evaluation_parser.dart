import 'dart:convert';

import '../../../corrections/domain/models/turn_correction.dart';
import 'goal_evaluation_result.dart';

/// Parser tolerante de la respuesta de `goal_eval` (lógica pura, testeable).
///
/// Acepta:
/// - el formato nuevo `{"goals": {...}, "corrections": [...]}`,
/// - el formato antiguo plano `{"g1": true, "g2": false}`,
/// - la clave `errors` como alias de `corrections`,
/// - bloques ```json ... ``` alrededor del JSON.
///
/// Cualquier cosa que no cumpla el esquema se descarta: el turno nunca se
/// bloquea por una respuesta inválida del modelo.
GoalEvaluationResult parseGoalEvaluation(String raw) {
  final cleaned = _stripCodeFence(raw).trim();
  if (cleaned.isEmpty) return GoalEvaluationResult.empty;

  Object? decoded;
  try {
    decoded = jsonDecode(cleaned);
  } catch (_) {
    return GoalEvaluationResult.empty;
  }
  if (decoded is! Map) return GoalEvaluationResult.empty;

  final hasEnvelope =
      decoded.containsKey('goals') || decoded.containsKey('corrections');
  final goalsRaw = hasEnvelope ? decoded['goals'] : decoded;

  final goals = <String, bool>{};
  if (goalsRaw is Map) {
    for (final entry in goalsRaw.entries) {
      final value = entry.value;
      // Solo booleanos explícitos: `"true"` o `1` no son evidencia.
      if (value is bool) goals[entry.key.toString()] = value;
    }
  }

  final correctionsRaw = decoded['corrections'] ?? decoded['errors'];
  final parsedCorrections = parseCorrections(correctionsRaw);

  return GoalEvaluationResult(
    goals: goals,
    corrections: parsedCorrections.corrections,
    discardedCorrections: parsedCorrections.discarded,
  );
}

String _stripCodeFence(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith('```')) return trimmed;
  final firstLineBreak = trimmed.indexOf('\n');
  if (firstLineBreak < 0) return trimmed;
  var body = trimmed.substring(firstLineBreak + 1);
  final closing = body.lastIndexOf('```');
  if (closing >= 0) body = body.substring(0, closing);
  return body.trim();
}
