/// P-34b (#119): frase de ayuda tocable ("Necesito ayuda").
///
/// El origen se conserva para la analítica (`lesson` = catálogo Dart,
/// `scenario` = tabla `scenario_phrases`). Nunca se inventan frases: si no
/// hay datos, la lista llega vacía y la UI lo dice.
class HelpPhrase {
  const HelpPhrase({
    required this.id,
    required this.text,
    this.translation,
    this.origin = HelpPhraseOrigin.lesson,
  });

  final String id;
  final String text;
  final String? translation;
  final HelpPhraseOrigin origin;
}

enum HelpPhraseOrigin { lesson, scenario }
