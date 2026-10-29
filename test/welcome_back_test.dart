import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/welcome_back.dart';

/// P-27 (#112): la tarjeta de retorno solo aparece tras 3 días y con lección.
void main() {
  WelcomeBack build({
    int daysAway = 4,
    String lessonId = 'a1_ordering_coffee_at_a_cafe',
    int goalsRemaining = 1,
    int totalGoals = 3,
    int streak = 0,
  }) => WelcomeBack(
    daysAway: daysAway,
    lessonId: lessonId,
    lessonTitle: 'Ordering coffee',
    goalsRemaining: goalsRemaining,
    totalGoals: totalGoals,
    streak: streak,
  );

  test('aparece a partir de 3 dias', () {
    expect(build(daysAway: 2).shouldShow, isFalse);
    expect(build(daysAway: 3).shouldShow, isTrue);
    expect(build(daysAway: 30).shouldShow, isTrue);
  });

  test('sin leccion identificable no se muestra', () {
    expect(build(lessonId: '').shouldShow, isFalse);
  });

  test('marca la leccion completada cuando no quedan metas', () {
    expect(build(goalsRemaining: 0).lessonCompleted, isTrue);
    expect(build(goalsRemaining: 1).lessonCompleted, isFalse);
    expect(build(goalsRemaining: 0, totalGoals: 0).lessonCompleted, isFalse);
  });

  test('sin racha ofrece empezar una nueva', () {
    expect(build(streak: 0).streakReset, isTrue);
    expect(build(streak: 5).streakReset, isFalse);
  });
}
