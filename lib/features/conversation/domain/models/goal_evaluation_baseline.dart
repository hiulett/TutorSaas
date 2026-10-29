/// Evaluador heurístico determinista para el golden set de metas (P-39).
///
/// **No persiste nada y no llama a ningún modelo.** Es la línea base contra la
/// que se comparan las conversaciones de referencia
/// (`test/fixtures/goal_evaluation_golden_set.json`) en CI. En producción la
/// única fuente de verdad es la respuesta de `goal_eval` filtrada por
/// [GoalEvaluationResult.goalsForCatalog]; las keywords del catálogo solo
/// pueden usarse como respaldo visual (P-41).
///
/// Reglas (documentadas y cubiertas por tests):
/// 1. Solo cuentan los turnos del alumno (`user`/`student`); el tutor nunca
///    aporta evidencia.
/// 2. La frase debe tener una longitud mínima según el nivel: 1 palabra en
///    PRE-A1, 3 en A1/A2, 5 en B1+.
/// 3. Debe contener al menos una palabra de contenido de la meta (texto,
///    keywords o frase de ejemplo). Se comparan prefijos de 4 letras para
///    tolerar plurales y derivados (`improve`/`improvement`).
/// 4. Si la meta une dos requisitos con `and`/`with`, exige dos palabras de
///    contenido distintas: "debilidad **y** paso de mejora" no se cumple solo
///    mencionando la debilidad.
/// 5. Si la meta pide preguntar (`ask`/`question`), la frase debe ser una
///    pregunta (`?` o pronombre/auxiliar inicial).
library;

class GoalBaselineRule {
  const GoalBaselineRule({
    required this.id,
    required this.text,
    this.keywords = const [],
    this.examplePhrase = '',
  });

  final String id;
  final String text;
  final List<String> keywords;
  final String examplePhrase;
}

class GoalBaselineTurn {
  const GoalBaselineTurn({required this.speaker, required this.text});

  final String speaker;
  final String text;

  bool get isStudent => speaker == 'user' || speaker == 'student';
}

class GoalEvaluationBaseline {
  const GoalEvaluationBaseline._();

  static const Set<String> _stopwords = {
    'about',
    'after',
    'again',
    'also',
    'and',
    'any',
    'are',
    'ask',
    'been',
    'before',
    'being',
    'both',
    'but',
    'can',
    'could',
    'did',
    'does',
    'doing',
    'each',
    'explain',
    'express',
    'for',
    'from',
    'give',
    'had',
    'has',
    'have',
    'her',
    'here',
    'highlight',
    'him',
    'his',
    'how',
    'into',
    'its',
    'just',
    'make',
    'more',
    'most',
    'must',
    'not',
    'now',
    'order',
    'other',
    'our',
    'out',
    'over',
    'own',
    'provide',
    'say',
    'she',
    'should',
    'some',
    'specify',
    'such',
    'tell',
    'than',
    'that',
    'the',
    'their',
    'them',
    'then',
    'there',
    'these',
    'they',
    'this',
    'those',
    'through',
    'use',
    'very',
    'was',
    'were',
    'what',
    'when',
    'where',
    'which',
    'while',
    'who',
    'why',
    'will',
    'with',
    'would',
    'you',
    'your',
  };

  static const Set<String> _questionOpeners = {
    'am',
    'are',
    'can',
    'could',
    'do',
    'does',
    'how',
    'is',
    'may',
    'should',
    'was',
    'were',
    'what',
    'when',
    'where',
    'which',
    'who',
    'why',
    'will',
    'would',
  };

  /// Evalúa [goals] contra [turns] con reglas puramente locales.
  static Map<String, bool> evaluate({
    required List<GoalBaselineRule> goals,
    required List<GoalBaselineTurn> turns,
    String level = 'A1',
  }) {
    final studentTexts = turns
        .where((turn) => turn.isStudent)
        .map((turn) => turn.text)
        .where((text) => text.trim().isNotEmpty)
        .toList();

    return {
      for (final goal in goals) goal.id: _satisfies(goal, studentTexts, level),
    };
  }

  static bool _satisfies(
    GoalBaselineRule goal,
    List<String> studentTexts,
    String level,
  ) {
    final minWords = _minWordsFor(level);
    final contentWords = _contentWords(goal);
    if (contentWords.isEmpty) return false;

    // "weakness with improvement" exige ambos conceptos; "milk or sugar" no.
    final requiresBoth = RegExp(
      r'\b(and|with)\b',
      caseSensitive: false,
    ).hasMatch(goal.text);
    final requiredMatches = requiresBoth ? 2 : 1;
    final asksQuestion = RegExp(
      r'\b(ask|question)\b',
      caseSensitive: false,
    ).hasMatch(goal.text);

    for (final text in studentTexts) {
      final words = _words(text);
      if (words.length < minWords) continue;
      if (asksQuestion && !_looksLikeQuestion(text, words)) continue;

      final matched = <String>{};
      for (final content in contentWords) {
        if (words.any((word) => _sameStem(word, content))) {
          matched.add(content);
        }
      }
      if (matched.length >= requiredMatches) return true;
    }
    return false;
  }

  static int _minWordsFor(String level) {
    final normalized = level.toUpperCase();
    if (normalized.startsWith('PRE')) return 1;
    if (normalized.startsWith('B') || normalized.startsWith('C')) return 5;
    return 3;
  }

  static Set<String> _contentWords(GoalBaselineRule goal) {
    final source =
        '${goal.text} ${goal.keywords.join(' ')} '
        '${goal.examplePhrase}';
    return _words(
      source,
    ).where((word) => word.length >= 2 && !_stopwords.contains(word)).toSet();
  }

  static List<String> _words(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static bool _looksLikeQuestion(String text, List<String> words) {
    if (text.contains('?')) return true;
    return words.isNotEmpty && _questionOpeners.contains(words.first);
  }

  /// Compara prefijos de hasta 4 letras: `coffee`/`coffees`,
  /// `improve`/`improvement`. Exige al menos 4 letras en la palabra corta.
  static bool _sameStem(String a, String b) {
    if (a == b) return true;
    final shortest = a.length < b.length ? a.length : b.length;
    if (shortest < 4) return false;
    final compare = shortest < 5 ? shortest : 5;
    return a.substring(0, compare) == b.substring(0, compare);
  }
}
