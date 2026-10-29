/// Progreso de la meta diaria (P-23 / #108).
///
/// Lo calcula el servidor (`get_daily_goal_progress`) con los minutos reales
/// del día (`practice_sessions`) y la meta de `user_settings`. El cliente no
/// suma minutos por su cuenta.
class DailyGoalProgress {
  const DailyGoalProgress({
    required this.minutesToday,
    required this.goalMinutes,
    required this.streak,
    required this.longestStreak,
    required this.goalCompleted,
    required this.practicedToday,
    required this.celebrated,
  });

  factory DailyGoalProgress.fromMap(Map<String, dynamic> map) {
    final minutes = _int(map['minutes_today']);
    final goal = _int(map['goal_minutes']);
    return DailyGoalProgress(
      minutesToday: minutes,
      goalMinutes: goal,
      streak: _int(map['streak']),
      longestStreak: _int(map['longest_streak']),
      goalCompleted:
          map['goal_completed'] == true || (goal > 0 && minutes >= goal),
      practicedToday: map['practiced_today'] == true || minutes > 0,
      celebrated: map['celebrated'] == true,
    );
  }

  final int minutesToday;
  final int goalMinutes;
  final int streak;
  final int longestStreak;
  final bool goalCompleted;
  final bool practicedToday;
  final bool celebrated;

  /// Fracción de la meta cumplida, entre 0 y 1 (para el anillo).
  double get ratio {
    if (goalMinutes <= 0) return 0;
    final value = minutesToday / goalMinutes;
    return value.clamp(0, 1).toDouble();
  }

  int get remainingMinutes {
    final remaining = goalMinutes - minutesToday;
    return remaining > 0 ? remaining : 0;
  }

  /// Hay celebración pendiente: meta cumplida y aún no celebrada hoy.
  bool get canCelebrate => goalCompleted && !celebrated;

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? 0;
  }
}
