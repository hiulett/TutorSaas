/// Decide si merece la pena lanzar la evaluación de metas con IA (P-41 / #126).
///
/// Cada evaluación es una llamada extra al modelo; lanzarla con "ok", "yes" o
/// un monosílabo solo gasta tokens. Se evalúa cuando:
/// - la respuesta del alumno tiene ≥ [minWords] palabras, o
/// - contiene una palabra significativa de una meta pendiente (texto de la
///   meta o keywords del catálogo).
///
/// El cierre de sesión fuerza una última evaluación para no perder metas.
/// Este gate solo decide **cuándo** llamar; nunca marca metas: la evidencia
/// que persiste es la respuesta del modelo filtrada por catálogo (P-39).
class GoalEvaluationGate {
  const GoalEvaluationGate._();

  static const int minWords = 5;

  static bool shouldEvaluate({
    required String lastUserMessage,
    required List<String> goalTexts,
    List<String> goalKeywords = const [],
  }) {
    final text = lastUserMessage.toLowerCase().trim();
    if (text.isEmpty) return false;

    final words = _words(text);
    if (words.length >= minWords) return true;

    for (final goal in goalTexts) {
      for (final keyword in keywordsOf(goal)) {
        if (_containsKeyword(words, text, keyword)) return true;
      }
    }
    // Las keywords del catálogo pueden ser más cortas que 4 letras ("hi",
    // "tea"), así que se comparan por palabra completa para no activar con
    // "this" por contener "hi".
    for (final keyword in goalKeywords) {
      if (_containsKeyword(words, text, keyword.toLowerCase().trim())) {
        return true;
      }
    }
    return false;
  }

  /// Palabras significativas de una meta (≥4 letras, sin duplicados).
  static Set<String> keywordsOf(String goal) {
    final words = _words(goal.toLowerCase()).where((word) => word.length >= 4);
    return words.toSet();
  }

  static List<String> _words(String text) {
    return text
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static bool _containsKeyword(
    List<String> words,
    String text,
    String keyword,
  ) {
    if (keyword.isEmpty) return false;
    if (keyword.contains(' ')) return text.contains(keyword);
    for (final word in words) {
      if (word == keyword) return true;
      // Plurales/derivados cortos: "coffee"/"coffees".
      if (word.length >= 4 &&
          keyword.length >= 4 &&
          word.startsWith(keyword.substring(0, 4)) &&
          word.length <= keyword.length + 2) {
        return true;
      }
    }
    return false;
  }
}
