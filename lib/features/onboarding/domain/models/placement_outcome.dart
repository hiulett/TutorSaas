/// Resultado del examen oral del Oráculo.
///
/// Desde #73 el nivel lo calcula y lo persiste el servidor
/// (`evaluate-placement`); el cliente solo lee este resultado. Por eso el
/// modelo no deduce nada: si un campo falta, se muestra lo que mandó el
/// servidor o un valor neutro, nunca un nivel inventado en Dart.
class PlacementOutcome {
  const PlacementOutcome({
    required this.cefrLevel,
    required this.gameRank,
    this.scores = const {},
    this.strengths = const [],
    this.weaknesses = const [],
    this.explanation = '',
    this.recommendedFocus = '',
    this.previousCefrLevel = '',
    this.promoted = false,
    this.fromHeuristic = false,
    this.decision = '',
    this.reasonCode = '',
    this.rubric = const {},
    this.nextAttemptAt,
    this.forced = false,
    this.turns = 0,
    this.mode = '',
  });

  factory PlacementOutcome.fromMap(Map<String, dynamic> map) {
    return PlacementOutcome(
      cefrLevel: _text(map['cefr_level']).toUpperCase(),
      gameRank: _text(map['game_rank']).toUpperCase(),
      scores: map['scores'] is Map
          ? Map<String, dynamic>.from(map['scores'] as Map)
          : const {},
      strengths: _textList(map['strengths']),
      weaknesses: _textList(map['weaknesses']),
      explanation: _text(map['explanation']),
      recommendedFocus: _text(map['recommended_focus']),
      previousCefrLevel: _text(map['previous_cefr_level']).toUpperCase(),
      promoted: map['promoted'] == true,
      fromHeuristic: _text(map['source']) == 'heuristic',
      decision: _text(map['decision']),
      reasonCode: _text(map['reason_code']),
      rubric: map['rubric'] is Map
          ? Map<String, dynamic>.from(map['rubric'] as Map)
          : const {},
      nextAttemptAt: _date(map['next_attempt_at']),
      forced: map['forced'] == true,
      turns: map['turns'] is num ? (map['turns'] as num).toInt() : 0,
      mode: _text(map['mode']),
    );
  }

  /// Nivel CEFR validado por el servidor (PRE-A1…C2).
  final String cefrLevel;

  /// Rango del juego validado por el servidor (F…SSS).
  final String gameRank;

  final Map<String, dynamic> scores;
  final List<String> strengths;
  final List<String> weaknesses;
  final String explanation;
  final String recommendedFocus;

  /// Nivel antes de esta evaluación (vacío en el placement inicial).
  final String previousCefrLevel;

  /// `true` si esta evaluación subió de nivel.
  final bool promoted;

  /// `true` si el modelo no devolvió JSON válido y el servidor usó la
  /// heurística de longitud de respuesta.
  final bool fromHeuristic;

  /// P-31 (#116): veredicto del servidor (`promoted` | `maintained` |
  /// `initial`). Vacío en respuestas antiguas.
  final String decision;

  /// Motivo cuando no asciende: `rubric_below_threshold`, `no_improvement`,
  /// `rubric_unavailable`.
  final String reasonCode;

  /// Rúbrica de 6 dimensiones devuelta por el servidor (media, umbrales y
  /// puntuación por dimensión).
  final Map<String, dynamic> rubric;

  /// Reintento disponible tras un intento que no ascendió.
  final DateTime? nextAttemptAt;

  /// `true` si el examen se cerró por tope de turnos o por tiempo.
  final bool forced;

  /// Respuestas evaluadas (contadas por el servidor).
  final int turns;

  /// `boss` | `placement`.
  final String mode;

  static DateTime? _date(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  static String _text(Object? value) =>
      value is String ? value.trim() : (value == null ? '' : '$value'.trim());

  static List<String> _textList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
