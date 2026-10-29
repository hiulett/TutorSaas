import '../../../dashboard/domain/models/daily_goal_progress.dart';

/// Textos ya localizados que el widget nativo solo tiene que colocar.
///
/// El widget vive fuera de Flutter (RemoteViews), así que los textos se
/// resuelven en Dart con el idioma de la app y se guardan junto a los números.
class HomeWidgetLabels {
  const HomeWidgetLabels({
    required this.streakLabel,
    required this.minutesLabel,
    required this.minutesUnit,
    required this.practice,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final String streakLabel;
  final String minutesLabel;
  final String minutesUnit;
  final String practice;
  final String emptyTitle;
  final String emptyBody;

  /// `8 / 20 min`. Sin meta válida se muestra solo `8 min`.
  String minutesValue(int minutes, int goalMinutes) {
    final done = minutes < 0 ? 0 : minutes;
    final goal = goalMinutes < 0 ? 0 : goalMinutes;
    final unit = minutesUnit.trim();
    final numbers = goal > 0 ? '$done / $goal' : '$done';
    return unit.isEmpty ? numbers : '$numbers $unit';
  }
}

/// Estado que pinta el widget de pantalla de inicio (P-36 / #121).
///
/// Modelo puro: no toca el plugin `home_widget` ni Android. Los minutos, la
/// meta y la racha vienen del servidor (`get_daily_goal_progress`); el widget
/// nunca inventa ceros. Si no hay datos (sesión cerrada, consulta fallida o el
/// día ya cambió) se publica [HomeWidgetSnapshot.empty].
class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({
    required this.hasData,
    required this.dateKey,
    required this.streakDays,
    required this.minutesToday,
    required this.goalMinutes,
    required this.goalDone,
    required this.streakLabel,
    required this.minutesLabel,
    required this.minutesValue,
    required this.practiceLabel,
    required this.emptyTitle,
    required this.emptyBody,
  });

  /// Claves de `SharedPreferences` que lee `DungeonWidgetProvider.kt`.
  static const String keyHasData = 'widget_has_data';
  static const String keyDateKey = 'widget_date_key';
  static const String keyStreakDays = 'widget_streak_days';
  static const String keyStreakLabel = 'widget_streak_label';
  static const String keyMinutesLabel = 'widget_minutes_label';
  static const String keyMinutesValue = 'widget_minutes_value';
  static const String keyMinutesToday = 'widget_minutes_today';
  static const String keyGoalMinutes = 'widget_goal_minutes';
  static const String keyGoalDone = 'widget_goal_done';
  static const String keyPracticeLabel = 'widget_practice_label';
  static const String keyEmptyTitle = 'widget_empty_title';
  static const String keyEmptyBody = 'widget_empty_body';

  factory HomeWidgetSnapshot.fromProgress({
    required DailyGoalProgress progress,
    required HomeWidgetLabels labels,
    required DateTime now,
  }) {
    final minutes = progress.minutesToday < 0 ? 0 : progress.minutesToday;
    final goal = progress.goalMinutes < 0 ? 0 : progress.goalMinutes;
    return HomeWidgetSnapshot(
      hasData: true,
      dateKey: dateKeyFor(now),
      streakDays: progress.streak < 0 ? 0 : progress.streak,
      minutesToday: minutes,
      goalMinutes: goal,
      goalDone: goal > 0 && minutes >= goal,
      streakLabel: labels.streakLabel,
      minutesLabel: labels.minutesLabel,
      minutesValue: labels.minutesValue(minutes, goal),
      practiceLabel: labels.practice,
      emptyTitle: labels.emptyTitle,
      emptyBody: labels.emptyBody,
    );
  }

  /// Estado vacío honesto: sin sesión, sin consulta o con datos de otro día.
  factory HomeWidgetSnapshot.empty({
    required HomeWidgetLabels labels,
    required DateTime now,
  }) {
    return HomeWidgetSnapshot(
      hasData: false,
      dateKey: dateKeyFor(now),
      streakDays: 0,
      minutesToday: 0,
      goalMinutes: 0,
      goalDone: false,
      streakLabel: labels.streakLabel,
      minutesLabel: labels.minutesLabel,
      minutesValue: '',
      practiceLabel: labels.practice,
      emptyTitle: labels.emptyTitle,
      emptyBody: labels.emptyBody,
    );
  }

  final bool hasData;
  final String dateKey;
  final int streakDays;
  final int minutesToday;
  final int goalMinutes;
  final bool goalDone;
  final String streakLabel;
  final String minutesLabel;
  final String minutesValue;
  final String practiceLabel;
  final String emptyTitle;
  final String emptyBody;

  /// Fracción de meta cumplida (0..1) para la barra de progreso.
  double get progressFraction {
    if (goalMinutes <= 0) return 0;
    return (minutesToday / goalMinutes).clamp(0, 1).toDouble();
  }

  /// `true` si la foto sigue siendo de "hoy"; si no, el widget muestra el
  /// estado vacío en vez de números de ayer.
  bool isFreshOn(DateTime now) => hasData && dateKey == dateKeyFor(now);

  Map<String, Object> toWidgetData() => <String, Object>{
    keyHasData: hasData,
    keyDateKey: dateKey,
    keyStreakDays: streakDays,
    keyStreakLabel: streakLabel,
    keyMinutesLabel: minutesLabel,
    keyMinutesValue: minutesValue,
    keyMinutesToday: minutesToday,
    keyGoalMinutes: goalMinutes,
    keyGoalDone: goalDone,
    keyPracticeLabel: practiceLabel,
    keyEmptyTitle: emptyTitle,
    keyEmptyBody: emptyBody,
  };

  /// Clave de día local `yyyy-mm-dd` (misma regla que el provider Kotlin).
  static String dateKeyFor(DateTime when) {
    final month = when.month.toString().padLeft(2, '0');
    final day = when.day.toString().padLeft(2, '0');
    return '${when.year}-$month-$day';
  }
}
