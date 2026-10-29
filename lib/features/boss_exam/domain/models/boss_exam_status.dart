import '../services/level_checkpoint.dart';

/// P-31 (#116) — Requisitos de entrada al "Jefe de mazmorra" (examen de
/// promoción del Oráculo).
///
/// El estado lo calcula el servidor (`boss_exam_status`): nivel actual,
/// práctica acumulada y cooldown. Este modelo solo lee y normaliza la
/// respuesta; no deduce nada que el servidor no haya dicho.
enum BossExamState {
  /// Falta algún requisito (nivel o práctica).
  locked,

  /// Se puede retar al jefe ahora mismo.
  ready,

  /// Hubo un intento fallido reciente; hay que esperar al reintento.
  cooldown,
}

/// Un requisito concreto del jefe, con su progreso real.
class BossExamRequirement {
  const BossExamRequirement({
    required this.id,
    required this.met,
    required this.current,
    required this.target,
  });

  /// `level` | `practice` | `cooldown`.
  final String id;
  final bool met;
  final num current;
  final num target;

  factory BossExamRequirement.fromMap(Map<String, dynamic> map) {
    return BossExamRequirement(
      id: _text(map['id']),
      met: map['met'] == true,
      current: _number(map['current']),
      target: _number(map['target']),
    );
  }

  /// Progreso 0..1 para pintar la barra del requisito.
  double get progress {
    if (met) return 1;
    if (target <= 0) return 0;
    return (current / target).clamp(0.0, 1.0).toDouble();
  }

  static num _number(Object? value) =>
      value is num ? value : num.tryParse('${value ?? ''}') ?? 0;

  static String _text(Object? value) =>
      value is String ? value.trim() : (value == null ? '' : '$value'.trim());
}

/// Foto del estado del jefe devuelta por el servidor.
class BossExamStatus {
  const BossExamStatus({
    required this.currentLevel,
    required this.currentRank,
    required this.state,
    this.requirements = const [],
    this.objectivesCompleted = 0,
    this.objectivesTarget = 6,
    this.minutesPracticed = 0,
    this.minutesTarget = 30,
    this.currentStreak = 0,
    this.streakTarget = 2,
    this.lessonsPassed = 0,
    this.lessonsSinceLastCheck = 0,
    this.checkInterval = 10,
    this.checkDue = false,
    this.cooldownUntil,
    this.serverTime,
  });

  final String currentLevel;
  final String currentRank;
  final BossExamState state;
  final List<BossExamRequirement> requirements;

  final int objectivesCompleted;
  final int objectivesTarget;
  final int minutesPracticed;
  final int minutesTarget;
  final int currentStreak;
  final int streakTarget;

  /// Lecciones superadas del nivel actual (dato informativo del servidor).
  final int lessonsPassed;

  /// P-43 (#128): lecciones superadas desde el último reto del jefe (o desde el
  /// placement inicial si nunca se retó).
  final int lessonsSinceLastCheck;

  /// Cada cuántas lecciones el servidor propone revisar el nivel.
  final int checkInterval;

  /// `true` cuando toca proponer el examen del jefe. El servidor solo avisa:
  /// el nivel lo decide `evaluate-placement`.
  final bool checkDue;

  final DateTime? cooldownUntil;

  /// Hora del servidor: base para calcular el tiempo de espera restante sin
  /// depender del reloj del dispositivo.
  final DateTime? serverTime;

  bool get isReady => state == BossExamState.ready;
  bool get isLocked => state == BossExamState.locked;
  bool get isOnCooldown => state == BossExamState.cooldown;

  /// Requisitos que aún no se cumplen, para explicar el bloqueo.
  List<BossExamRequirement> get blocking =>
      requirements.where((requirement) => !requirement.met).toList();

  /// Tiempo restante de cooldown respecto a [now]. `null` si no aplica.
  Duration? cooldownRemaining(DateTime now) {
    final until = cooldownUntil;
    if (until == null) return null;
    final remaining = until.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory BossExamStatus.fromMap(Map<String, dynamic> map) {
    final rawRequirements = map['requirements'];
    final requirements = rawRequirements is List
        ? rawRequirements
              .whereType<Map>()
              .map(
                (item) => BossExamRequirement.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <BossExamRequirement>[];

    return BossExamStatus(
      currentLevel: _text(map['current_level']).toUpperCase(),
      currentRank: _text(map['current_rank']).toUpperCase(),
      state: _state(map['state']),
      requirements: requirements,
      objectivesCompleted: _int(map['objectives_completed']),
      objectivesTarget: _int(map['objectives_target'], fallback: 6),
      minutesPracticed: _int(map['minutes_practiced']),
      minutesTarget: _int(map['minutes_target'], fallback: 30),
      currentStreak: _int(map['current_streak']),
      streakTarget: _int(map['streak_target'], fallback: 2),
      lessonsPassed: _int(map['lessons_passed']),
      // Sin las claves de P-43 se cae al dato anterior: el servidor viejo no
      // rompe la pantalla y el aviso simplemente no aparece.
      lessonsSinceLastCheck: _int(
        map['lessons_since_last_check'],
        fallback: _int(map['lessons_passed']),
      ),
      checkInterval: _int(
        map['check_interval'],
        fallback: LevelCheckpoint.interval,
      ),
      checkDue: map['check_due'] == true,
      cooldownUntil: _date(map['cooldown_until']),
      serverTime: _date(map['server_time']),
    );
  }

  static BossExamState _state(Object? raw) {
    switch (_text(raw).toLowerCase()) {
      case 'ready':
        return BossExamState.ready;
      case 'cooldown':
        return BossExamState.cooldown;
      default:
        return BossExamState.locked;
    }
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? fallback;
  }

  static DateTime? _date(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  static String _text(Object? value) =>
      value is String ? value.trim() : (value == null ? '' : '$value'.trim());
}
