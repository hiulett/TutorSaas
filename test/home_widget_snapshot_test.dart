import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/daily_goal_progress.dart';
import 'package:tutorsaas/features/home_widget/domain/models/home_widget_snapshot.dart';

/// P-36 (#121): el widget nativo solo pinta lo que este modelo produce.
/// Se prueba el formateo y la honestidad del estado (sin ceros falsos ni
/// datos de ayer).
void main() {
  const labels = HomeWidgetLabels(
    streakLabel: 'RACHA',
    minutesLabel: 'HOY',
    minutesUnit: 'min',
    practice: 'PRACTICAR',
    emptyTitle: 'Abre la app para empezar',
    emptyBody: 'Tu racha y los minutos de hoy aparecen al abrir la app.',
  );

  final today = DateTime(2026, 10, 29, 9, 30);

  HomeWidgetSnapshot snapshotFor({
    int minutes = 0,
    int goal = 20,
    int streak = 0,
    DateTime? now,
  }) {
    return HomeWidgetSnapshot.fromProgress(
      progress: DailyGoalProgress.fromMap({
        'minutes_today': minutes,
        'goal_minutes': goal,
        'streak': streak,
      }),
      labels: labels,
      now: now ?? today,
    );
  }

  test('formatea minutos de hoy contra la meta y la racha', () {
    final snapshot = snapshotFor(minutes: 8, goal: 20, streak: 12);

    expect(snapshot.hasData, isTrue);
    expect(snapshot.minutesValue, '8 / 20 min');
    expect(snapshot.minutesToday, 8);
    expect(snapshot.goalMinutes, 20);
    expect(snapshot.streakDays, 12);
    expect(snapshot.streakLabel, 'RACHA');
    expect(snapshot.minutesLabel, 'HOY');
    expect(snapshot.goalDone, isFalse);
    expect(snapshot.progressFraction, closeTo(0.4, 0.001));
  });

  test('meta superada: barra al 100% y estado de meta cumplida', () {
    final snapshot = snapshotFor(minutes: 45, goal: 30);

    expect(snapshot.goalDone, isTrue);
    expect(snapshot.progressFraction, 1.0);
    expect(snapshot.minutesValue, '45 / 30 min');
  });

  test('meta inválida no divide por cero y no marca la meta', () {
    final snapshot = snapshotFor(minutes: 5, goal: 0);

    expect(snapshot.progressFraction, 0);
    expect(snapshot.goalDone, isFalse);
    expect(snapshot.minutesValue, '5 min');
  });

  test('valores negativos del servidor se sanean a cero', () {
    final snapshot = HomeWidgetSnapshot.fromProgress(
      progress: const DailyGoalProgress(
        minutesToday: -3,
        goalMinutes: -10,
        streak: -1,
        longestStreak: 0,
        goalCompleted: false,
        practicedToday: false,
        celebrated: false,
      ),
      labels: labels,
      now: today,
    );

    expect(snapshot.minutesToday, 0);
    expect(snapshot.goalMinutes, 0);
    expect(snapshot.streakDays, 0);
    expect(snapshot.hasData, isTrue);
  });

  test('estado vacío: sin datos no hay números ni ceros falsos', () {
    final snapshot = HomeWidgetSnapshot.empty(labels: labels, now: today);

    expect(snapshot.hasData, isFalse);
    expect(snapshot.minutesValue, isEmpty);
    expect(snapshot.progressFraction, 0);
    expect(snapshot.emptyTitle, 'Abre la app para empezar');
    expect(snapshot.isFreshOn(today), isFalse);
  });

  test('cambia el día: la foto de ayer deja de ser fresca', () {
    final yesterday = snapshotFor(
      minutes: 20,
      goal: 20,
      streak: 4,
      now: DateTime(2026, 10, 28, 23, 55),
    );

    expect(yesterday.isFreshOn(DateTime(2026, 10, 28, 23, 59)), isTrue);
    expect(yesterday.isFreshOn(DateTime(2026, 10, 29, 0, 5)), isFalse);
  });

  test('dateKeyFor rellena mes y día con dos dígitos', () {
    expect(HomeWidgetSnapshot.dateKeyFor(DateTime(2026, 1, 5)), '2026-01-05');
    expect(HomeWidgetSnapshot.dateKeyFor(DateTime(2026, 11, 30)), '2026-11-30');
  });

  test('toWidgetData expone exactamente las claves que lee Kotlin', () {
    final data = snapshotFor(minutes: 8, goal: 20, streak: 3).toWidgetData();

    expect(data[HomeWidgetSnapshot.keyHasData], isTrue);
    expect(data[HomeWidgetSnapshot.keyDateKey], '2026-10-29');
    expect(data[HomeWidgetSnapshot.keyStreakDays], 3);
    expect(data[HomeWidgetSnapshot.keyStreakLabel], 'RACHA');
    expect(data[HomeWidgetSnapshot.keyMinutesLabel], 'HOY');
    expect(data[HomeWidgetSnapshot.keyMinutesValue], '8 / 20 min');
    expect(data[HomeWidgetSnapshot.keyMinutesToday], 8);
    expect(data[HomeWidgetSnapshot.keyGoalMinutes], 20);
    expect(data[HomeWidgetSnapshot.keyGoalDone], isFalse);
    expect(data[HomeWidgetSnapshot.keyPracticeLabel], 'PRACTICAR');
    expect(data[HomeWidgetSnapshot.keyEmptyTitle], 'Abre la app para empezar');
    expect(data[HomeWidgetSnapshot.keyEmptyBody], isNotEmpty);
    expect(data.length, 12);
  });

  test('sin unidad localizada no queda un espacio suelto', () {
    const sinUnidad = HomeWidgetLabels(
      streakLabel: 'STREAK',
      minutesLabel: 'TODAY',
      minutesUnit: '  ',
      practice: 'PRACTICE',
      emptyTitle: 'Open the app to start',
      emptyBody: 'Body',
    );

    expect(sinUnidad.minutesValue(8, 20), '8 / 20');
    expect(sinUnidad.minutesValue(8, 0), '8');
  });
}
