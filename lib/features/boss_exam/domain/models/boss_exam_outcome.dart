import '../../../onboarding/domain/models/cefr_rank.dart';
import 'boss_exam_rubric.dart';

/// P-31 (#116) — Resultado del examen de promoción.
///
/// `decision` y `reasonCode` los calcula el servidor. Si la respuesta no los
/// trae, el cliente solo puede derivar un veredicto comparando niveles; nunca
/// inventa una promoción.
enum BossExamVerdict {
  /// Subió de nivel.
  promoted,

  /// Se mantiene el nivel actual.
  maintained,

  /// Placement inicial: no había nivel previo.
  initial,
}

class BossExamOutcome {
  const BossExamOutcome({
    required this.level,
    required this.rank,
    required this.verdict,
    this.previousLevel = '',
    this.reasonCode = '',
    this.explanation = '',
    this.recommendedFocus = '',
    this.strengths = const [],
    this.weaknesses = const [],
    this.rubric = BossExamRubric.empty,
    this.nextAttemptAt,
    this.forced = false,
    this.turns = 0,
  });

  final String level;
  final String rank;

  /// 'B1' | '' — nivel antes del intento.
  final String previousLevel;
  final BossExamVerdict verdict;

  /// `rubric_below_threshold` | `no_improvement` | `rubric_unavailable` | ''.
  final String reasonCode;
  final String explanation;
  final String recommendedFocus;
  final List<String> strengths;
  final List<String> weaknesses;
  final BossExamRubric rubric;

  /// Reintento disponible tras un intento que no ascendió.
  final DateTime? nextAttemptAt;

  /// `true` si el examen se cerró por tope de turnos o por tiempo.
  final bool forced;
  final int turns;

  bool get promoted => verdict == BossExamVerdict.promoted;
  bool get maintained => verdict == BossExamVerdict.maintained;
  bool get isInitial => verdict == BossExamVerdict.initial;

  /// Hay motivo que explicar (solo cuando no asciende).
  bool get hasReason => reasonCode.isNotEmpty;

  factory BossExamOutcome.fromMap(Map<String, dynamic> map) {
    final level = _text(map['cefr_level']).toUpperCase();
    final previousLevel = _text(map['previous_cefr_level']).toUpperCase();
    final rubricMap = map['rubric'];
    final scoresMap = map['scores'];

    final rubric = rubricMap is Map && rubricMap['dimensions'] is Map
        ? BossExamRubric.fromScores(
            Map<String, dynamic>.from(rubricMap['dimensions'] as Map),
          )
        : (scoresMap is Map
              ? BossExamRubric.fromScores(Map<String, dynamic>.from(scoresMap))
              : BossExamRubric.empty);

    return BossExamOutcome(
      level: level,
      rank: _text(map['game_rank']).toUpperCase(),
      previousLevel: previousLevel,
      verdict: _verdict(
        map['decision'],
        level: level,
        previous: previousLevel,
        promotedFlag: map['promoted'] == true,
      ),
      reasonCode: _text(map['reason_code']),
      explanation: _text(map['explanation']),
      recommendedFocus: _text(map['recommended_focus']),
      strengths: _textList(map['strengths']),
      weaknesses: _textList(map['weaknesses']),
      rubric: rubric,
      nextAttemptAt: _date(map['next_attempt_at']),
      forced: map['forced'] == true,
      turns: _int(map['turns']),
    );
  }

  static BossExamVerdict _verdict(
    Object? raw, {
    required String level,
    required String previous,
    required bool promotedFlag,
  }) {
    switch (_text(raw).toLowerCase()) {
      case 'promoted':
        return BossExamVerdict.promoted;
      case 'maintained':
        return BossExamVerdict.maintained;
      case 'initial':
        return BossExamVerdict.initial;
    }
    // Sin decisión explícita (servidor antiguo): derivar solo con los datos
    // que mandó el servidor. Sin nivel previo no puede haber ascenso.
    if (previous.isEmpty) return BossExamVerdict.initial;
    if (promotedFlag) return BossExamVerdict.promoted;
    final previousIndex = CefrRank.cefrOrder.indexOf(previous);
    final currentIndex = CefrRank.cefrOrder.indexOf(level);
    if (previousIndex >= 0 && currentIndex > previousIndex) {
      return BossExamVerdict.promoted;
    }
    return BossExamVerdict.maintained;
  }

  static List<String> _textList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => _text(item))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('${value ?? ''}') ?? 0;

  static DateTime? _date(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  static String _text(Object? value) =>
      value is String ? value.trim() : (value == null ? '' : '$value'.trim());
}
