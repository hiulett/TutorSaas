import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/daily_goal_progress.dart';

/// P-23 (#108): la meta diaria la calcula el servidor. Estos tests cubren el
/// anillo (fracción), los minutos restantes y la celebración única del día.
void main() {
  DailyGoalProgress parse(Map<String, dynamic> map) =>
      DailyGoalProgress.fromMap(map);

  test('anillo a medias: 8 de 20 minutos', () {
    final progress = parse({
      'minutes_today': 8,
      'goal_minutes': 20,
      'goal_completed': false,
    });

    expect(progress.ratio, closeTo(0.4, 0.001));
    expect(progress.remainingMinutes, 12);
    expect(progress.goalCompleted, isFalse);
    expect(progress.canCelebrate, isFalse);
  });

  test('meta cumplida: el anillo se limita a 1 aunque se pase', () {
    final progress = parse({
      'minutes_today': 45,
      'goal_minutes': 30,
      'goal_completed': true,
      'celebrated': false,
    });

    expect(progress.ratio, 1.0);
    expect(progress.remainingMinutes, 0);
    expect(progress.goalCompleted, isTrue);
    expect(progress.canCelebrate, isTrue);
  });

  test('celebrada hoy no vuelve a celebrarse', () {
    final progress = parse({
      'minutes_today': 30,
      'goal_minutes': 30,
      'goal_completed': true,
      'celebrated': true,
    });

    expect(progress.canCelebrate, isFalse);
  });

  test('meta invalida no divide por cero', () {
    final progress = parse({'minutes_today': 5, 'goal_minutes': 0});

    expect(progress.ratio, 0);
    expect(progress.goalCompleted, isFalse);
  });

  test('sin datos se asume 0 minutos y racha 0', () {
    final progress = parse(const {});

    expect(progress.minutesToday, 0);
    expect(progress.streak, 0);
    expect(progress.practicedToday, isFalse);
    expect(progress.canCelebrate, isFalse);
  });

  test('num en lugar de int (json) no rompe el modelo', () {
    final progress = parse({
      'minutes_today': 12.4,
      'goal_minutes': 15.0,
      'streak': 3.6,
    });

    expect(progress.minutesToday, 12);
    expect(progress.goalMinutes, 15);
    expect(progress.streak, 4);
  });
}
