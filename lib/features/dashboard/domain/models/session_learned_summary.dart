import 'dart:math' as math;

/// P-28 — modelos y lógica de presentación del resumen «Qué aprendiste».
///
/// Los datos llegan de la RPC `get_session_learned_summary` (palabras,
/// correcciones, metas y foco reales) y de la recompensa confirmada en
/// servidor al cerrar la sesión. Todo el parseo es tolerante: un campo ausente
/// degrada a vacío en lugar de romper el resumen. Este archivo es puro Dart
/// (sin Flutter ni l10n) para poder testearlo directamente.

/// Palabra nueva o repasada durante la sesión.
class LearnedWord {
  final String? vocabularyId;
  final String word;
  final String translation;
  final bool isNew;
  final bool mastered;
  final int intervalDays;

  const LearnedWord({
    required this.word,
    required this.translation,
    this.vocabularyId,
    this.isNew = false,
    this.mastered = false,
    this.intervalDays = 1,
  });

  static LearnedWord? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final word = _str(raw['word']);
    if (word.isEmpty) return null;
    final translation = _str(raw['translation']);
    final id = _str(raw['vocabulary_id']);
    return LearnedWord(
      word: word,
      translation: translation.isEmpty ? word : translation,
      vocabularyId: id.isEmpty ? null : id,
      isNew: raw['is_new'] == true,
      mastered: raw['mastered'] == true,
      intervalDays: _int(raw['interval_days']) ?? 1,
    );
  }

  /// Item con el formato que consume `SrsFlashcardModal`.
  Map<String, dynamic> toSrsItem() => {
    'word': word,
    'translation': translation,
    if (vocabularyId != null) 'vocabulary_id': vocabularyId,
    'interval_days': intervalDays,
  };
}

/// Corrección registrada en la sesión (original → corregido → por qué).
class SessionCorrection {
  final String original;
  final String corrected;
  final String? explanation;
  final String? errorType;

  const SessionCorrection({
    required this.original,
    required this.corrected,
    this.explanation,
    this.errorType,
  });

  static SessionCorrection? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final original = _str(raw['original']);
    final corrected = _str(raw['corrected']);
    if (original.isEmpty || corrected.isEmpty) return null;
    final explanation = _str(raw['explanation']);
    final errorType = _str(raw['error_type']);
    return SessionCorrection(
      original: original,
      corrected: corrected,
      explanation: explanation.isEmpty ? null : explanation,
      errorType: errorType.isEmpty ? null : errorType,
    );
  }
}

/// Respuesta cruda de `get_session_learned_summary` ya normalizada.
class LearnedSummaryData {
  final List<LearnedWord> words;
  final List<SessionCorrection> corrections;
  final List<String> completedGoals;
  final int goalsCompletedInDb;
  final int? goalsTotalInDb;
  final int newWords;
  final int reviewedWords;
  final String? focus;
  final String? focusSource;
  final int? phoneticClarity;
  final int? wpm;

  const LearnedSummaryData({
    this.words = const [],
    this.corrections = const [],
    this.completedGoals = const [],
    this.goalsCompletedInDb = 0,
    this.goalsTotalInDb,
    this.newWords = 0,
    this.reviewedWords = 0,
    this.focus,
    this.focusSource,
    this.phoneticClarity,
    this.wpm,
  });

  /// Sin datos: la UI debe decirlo explícitamente, nunca inventar cifras.
  static const LearnedSummaryData empty = LearnedSummaryData();

  bool get hasWords => words.isNotEmpty;
  bool get hasCorrections => corrections.isNotEmpty;
  bool get hasFocus => (focus ?? '').isNotEmpty;

  factory LearnedSummaryData.fromRpc(Object? json) {
    if (json is! Map) return empty;

    final words = <LearnedWord>[];
    final rawWords = json['words'];
    if (rawWords is List) {
      for (final raw in rawWords) {
        final parsed = LearnedWord.tryParse(raw);
        if (parsed != null) words.add(parsed);
      }
    }

    final corrections = <SessionCorrection>[];
    final rawCorrections = json['corrections'];
    if (rawCorrections is List) {
      for (final raw in rawCorrections) {
        final parsed = SessionCorrection.tryParse(raw);
        if (parsed != null) corrections.add(parsed);
      }
    }

    final goals = <String>[];
    final rawGoals = json['goals'];
    if (rawGoals is List) {
      for (final raw in rawGoals) {
        final text = _str(raw);
        if (text.isNotEmpty) goals.add(text);
      }
    }

    final focusRaw = json['focus'];
    String? focus;
    String? focusSource;
    if (focusRaw is Map) {
      final text = _str(focusRaw['text']);
      if (text.isNotEmpty) {
        focus = text;
        final source = _str(focusRaw['source']);
        focusSource = source.isEmpty ? null : source;
      }
    } else {
      final text = _str(focusRaw);
      if (text.isNotEmpty) focus = text;
    }

    int? clarity;
    int? wpm;
    final metrics = json['metrics'];
    if (metrics is Map) {
      clarity = _int(metrics['phonetic_clarity']);
      wpm = _int(metrics['wpm']);
    }

    final goalsInDb = _int(json['goals_completed']) ?? goals.length;

    return LearnedSummaryData(
      words: words,
      corrections: corrections,
      completedGoals: goals,
      goalsCompletedInDb: goalsInDb,
      goalsTotalInDb: _int(json['goals_total']),
      newWords: _int(json['new_words']) ?? 0,
      reviewedWords: _int(json['reviewed_words']) ?? 0,
      focus: focus,
      focusSource: focusSource,
      phoneticClarity: clarity,
      wpm: wpm,
    );
  }
}

/// Métricas que el resumen pinta como celdas.
enum SummaryMetricKind { duration, words, goals, turns }

class SummaryMetric {
  final SummaryMetricKind kind;
  final String value;

  const SummaryMetric(this.kind, this.value);
}

/// Vista de presentación del cierre de sesión. Pura: recibe lo que devolvieron
/// el servidor (recompensa) y la RPC (aprendizaje) y expone valores ya listos
/// para pintar, sin inventar cifras cuando falta el dato.
class SessionSummaryView {
  final int xp;
  final int gold;
  final int fragments;
  final bool rewardApplied;
  final bool rewardDuplicated;
  final int goalsCompleted;
  final int goalsTotal;
  final int minutes;
  final int turns;
  final int words;
  final LearnedSummaryData learned;

  const SessionSummaryView({
    this.xp = 0,
    this.gold = 0,
    this.fragments = 0,
    this.rewardApplied = false,
    this.rewardDuplicated = false,
    this.goalsCompleted = 0,
    this.goalsTotal = 0,
    this.minutes = 0,
    this.turns = 0,
    this.words = 0,
    this.learned = LearnedSummaryData.empty,
  });

  static const SessionSummaryView empty = SessionSummaryView();

  /// Construye la vista combinando fuentes reales:
  /// - [sessionResult]: recompensa confirmada por `apply_session_rewards`.
  /// - [learned]: agregados de la BD para esta sesión.
  /// - [inMemoryGoalsCompleted] / [inMemoryTurns] / [inMemoryWords]: lo que el
  ///   alumno acaba de ver en la conversación (las escrituras de metas son
  ///   `fire-and-forget`, así que la BD puede ir un paso por detrás; nunca
  ///   mostramos menos de lo que el alumno logró).
  /// - [catalogGoalsTotal]: metas del catálogo curricular de la lección.
  factory SessionSummaryView.from({
    Map<String, dynamic>? sessionResult,
    LearnedSummaryData learned = LearnedSummaryData.empty,
    int inMemoryGoalsCompleted = 0,
    int inMemoryTurns = 0,
    int inMemoryWords = 0,
    int? catalogGoalsTotal,
  }) {
    final minutes = _int(sessionResult?['minutes']) ?? 0;
    final dbGoals = _int(sessionResult?['objectives']) ?? 0;
    final goalsCompleted = math.max(
      math.max(dbGoals, inMemoryGoalsCompleted),
      learned.goalsCompletedInDb,
    );
    var goalsTotal = math.max(
      catalogGoalsTotal ?? 0,
      math.max(
        _int(sessionResult?['goals_total']) ?? 0,
        learned.goalsTotalInDb ?? 0,
      ),
    );
    if (goalsTotal < goalsCompleted) goalsTotal = goalsCompleted;

    return SessionSummaryView(
      xp: _int(sessionResult?['xp']) ?? 0,
      gold: _int(sessionResult?['gold']) ?? 0,
      fragments: _int(sessionResult?['fragments']) ?? 0,
      rewardApplied: sessionResult?['reward_applied'] == true,
      rewardDuplicated: sessionResult?['duplicated'] == true,
      goalsCompleted: goalsCompleted,
      goalsTotal: goalsTotal,
      minutes: minutes,
      turns: math.max(_int(sessionResult?['turns']) ?? 0, inMemoryTurns),
      words: inMemoryWords,
      learned: learned,
    );
  }

  /// Hubo conversación real (no un resumen abierto desde cero).
  bool get hasSessionData =>
      turns > 0 || words > 0 || minutes > 0 || goalsCompleted > 0;

  double get goalsRatio =>
      goalsTotal <= 0 ? 0 : (goalsCompleted / goalsTotal).clamp(0.0, 1.0);

  /// `3/4` cuando se conoce el total; `3` cuando la lección no declara metas.
  String get goalsLabel =>
      goalsTotal <= 0 ? '$goalsCompleted' : '$goalsCompleted/$goalsTotal';

  String get xpLabel => rewardApplied ? '+$xp' : '—';
  String get goldLabel => rewardApplied ? '+$gold' : '—';
  String get fragmentsLabel => rewardApplied ? '+$fragments' : '—';

  /// Celdas de métricas con datos reales; `—` cuando el dato no existe.
  List<SummaryMetric> get metricRows => [
    SummaryMetric(SummaryMetricKind.duration, minutes > 0 ? '$minutes' : '—'),
    SummaryMetric(SummaryMetricKind.words, words > 0 ? '$words' : '—'),
    SummaryMetric(
      SummaryMetricKind.goals,
      goalsTotal <= 0 && goalsCompleted <= 0 ? '—' : goalsLabel,
    ),
    SummaryMetric(SummaryMetricKind.turns, turns > 0 ? '$turns' : '—'),
  ];

  /// Palabras listas para abrir el repaso SRS.
  List<Map<String, dynamic>> get srsItems =>
      learned.words.map((w) => w.toSrsItem()).toList(growable: false);
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String _str(Object? value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString();
  return '';
}
