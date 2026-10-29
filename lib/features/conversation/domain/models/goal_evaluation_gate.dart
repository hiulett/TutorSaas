/// Decide si merece la pena lanzar la evaluación de metas con IA (P-41 / #126).
///
/// Cada evaluación es una llamada extra al modelo; lanzarla con "ok", "yes" o
/// un monosílabo solo gasta tokens. Se evalúa cuando:
/// - la respuesta del alumno tiene ≥ [minWords] palabras, o
/// - contiene una palabra significativa de alguna meta pendiente.
///
/// El cierre de sesión fuerza una última evaluación para no perder metas.
class GoalEvaluationGate {
  const GoalEvaluationGate._();

  static const int minWords = 5;

  static bool shouldEvaluate({
    required String lastUserMessage,
    required List<String> goalTexts,
  }) {
    final text = lastUserMessage.toLowerCase().trim();
    if (text.isEmpty) return false;

    final words = text
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length >= minWords) return true;

    for (final goal in goalTexts) {
      for (final keyword in keywordsOf(goal)) {
        if (text.contains(keyword)) return true;
      }
    }
    return false;
  }

  /// Palabras significativas de una meta (≥4 letras, sin duplicados).
  static Set<String> keywordsOf(String goal) {
    final words = goal
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((word) => word.length >= 4);
    return words.toSet();
  }
}
