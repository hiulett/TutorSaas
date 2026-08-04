import 'package:flutter_test/flutter_test.dart';

/// QA-03: helpers de lógica pura del módulo de economía.
///
/// La lógica real vive en `EconomyRepositoryImpl`
/// (`lib/features/economy/data/repositories/economy_repository_impl.dart`),
/// que depende de Supabase (red). Este test NO instancia el repositorio:
/// replica el cálculo exacto y verifica los umbrales del código real.
///
/// - `claimDailyReward` (líneas 157-162): gemas escalonadas por racha
///   5 / 50 / 100 / 300 según días >= 0 / 7 / 14 / 30 (pergaminos 2/5/8/15).
/// - `invocations_max` (líneas 24-25 y 31): 20 + (streak ~/ 7) * 5.
({int gems, int pergaminos}) dailyReward(int days) {
  int gems = 5;
  int pergaminos = 2;
  if (days >= 7) {
    gems = 50;
    pergaminos = 5;
  }
  if (days >= 14) {
    gems = 100;
    pergaminos = 8;
  }
  if (days >= 30) {
    gems = 300;
    pergaminos = 15;
  }
  return (gems: gems, pergaminos: pergaminos);
}

int invocationsMax(int streakDays) => 20 + (streakDays ~/ 7) * 5;

void main() {
  group('claimDailyReward escalonado por racha', () {
    test('racha 0 días → 5 gemas (recompensa base)', () {
      final reward = dailyReward(0);
      expect(reward.gems, 5);
      expect(reward.pergaminos, 2);
    });

    test('racha 6 días → 5 gemas (aún por debajo del primer umbral)', () {
      expect(dailyReward(6).gems, 5);
    });

    test('racha 7 días → 50 gemas (primer umbral)', () {
      final reward = dailyReward(7);
      expect(reward.gems, 50);
      expect(reward.pergaminos, 5);
    });

    test('racha 13 días → 50 gemas (por debajo de 14)', () {
      expect(dailyReward(13).gems, 50);
    });

    test('racha 14 días → 100 gemas (segundo umbral)', () {
      final reward = dailyReward(14);
      expect(reward.gems, 100);
      expect(reward.pergaminos, 8);
    });

    test('racha 29 días → 100 gemas (por debajo de 30)', () {
      expect(dailyReward(29).gems, 100);
    });

    test('racha 30 días → 300 gemas (tercer umbral)', () {
      final reward = dailyReward(30);
      expect(reward.gems, 300);
      expect(reward.pergaminos, 15);
    });

    test('racha 45 días → 300 gemas (se mantiene el máximo)', () {
      expect(dailyReward(45).gems, 300);
    });
  });

  group('invocations_max con bonus de racha', () {
    test('racha 0 → máximo base de 20', () {
      expect(invocationsMax(0), 20);
    });

    test('racha 6 → 20 (sin bonus, no llega a 7)', () {
      expect(invocationsMax(6), 20);
    });

    test('racha 7 → 25 (primer bonus de +5)', () {
      expect(invocationsMax(7), 25);
    });

    test('racha 13 → 25 (mismo tramo que 7)', () {
      expect(invocationsMax(13), 25);
    });

    test('racha 14 → 30 (+10 acumulado)', () {
      expect(invocationsMax(14), 30);
    });

    test('racha 30 → 40 (20 + 4*5)', () {
      expect(invocationsMax(30), 40);
    });

    test('racha 49 → 55 (20 + 7*5)', () {
      expect(invocationsMax(49), 55);
    });
  });
}
