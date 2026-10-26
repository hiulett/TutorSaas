import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/streak_rules.dart';

void main() {
  group('StreakRules.countsAsPractice', () {
    test('1 objetivo cuenta aunque sean 0 minutos', () {
      expect(StreakRules.countsAsPractice(minutes: 0, objectives: 1), isTrue);
    });

    test('3 minutos cuentan aunque no haya objetivos', () {
      expect(StreakRules.countsAsPractice(minutes: 3, objectives: 0), isTrue);
    });

    test('2 minutos sin objetivos no cuentan', () {
      expect(StreakRules.countsAsPractice(minutes: 2, objectives: 0), isFalse);
    });
  });

  group('StreakRules.nextStreak', () {
    final today = DateTime(2026, 10, 26);

    test('primer dia arranca en 1', () {
      expect(
        StreakRules.nextStreak(current: 0, lastPractice: null, today: today),
        1,
      );
    });

    test('ayer incrementa', () {
      expect(
        StreakRules.nextStreak(
          current: 4,
          lastPractice: DateTime(2026, 10, 25),
          today: today,
        ),
        5,
      );
    });

    test('mismo dia no incrementa', () {
      expect(
        StreakRules.nextStreak(
          current: 4,
          lastPractice: today,
          today: today,
        ),
        4,
      );
    });

    test('salto de dos dias reinicia', () {
      expect(
        StreakRules.nextStreak(
          current: 9,
          lastPractice: DateTime(2026, 10, 23),
          today: today,
        ),
        1,
      );
    });

    test('cambio de mes y de anio se calcula por fecha', () {
      expect(
        StreakRules.nextStreak(
          current: 2,
          lastPractice: DateTime(2025, 12, 31),
          today: DateTime(2026, 1, 1),
        ),
        3,
      );
    });
  });

  group('StreakRules.shouldRemind', () {
    test('no avisa si ya practico hoy', () {
      expect(
        StreakRules.shouldRemind(
          streak: 5,
          lastPractice: DateTime(2026, 10, 26, 9),
          now: DateTime(2026, 10, 26, 22),
        ),
        isFalse,
      );
    });

    test('avisa si practico ayer y queda poco para medianoche', () {
      expect(
        StreakRules.shouldRemind(
          streak: 5,
          lastPractice: DateTime(2026, 10, 25, 20),
          now: DateTime(2026, 10, 26, 22),
        ),
        isTrue,
      );
    });

    test('no avisa si practico ayer pero es por la manana', () {
      expect(
        StreakRules.shouldRemind(
          streak: 5,
          lastPractice: DateTime(2026, 10, 25, 20),
          now: DateTime(2026, 10, 26, 10),
        ),
        isFalse,
      );
    });

    test('no avisa sin racha o sin fecha', () {
      expect(
        StreakRules.shouldRemind(
          streak: 0,
          lastPractice: DateTime(2026, 10, 25),
          now: DateTime(2026, 10, 26, 23),
        ),
        isFalse,
      );
      expect(
        StreakRules.shouldRemind(
          streak: 3,
          lastPractice: null,
          now: DateTime(2026, 10, 26, 23),
        ),
        isFalse,
      );
    });
  });
}
