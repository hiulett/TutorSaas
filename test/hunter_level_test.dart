import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/hunter_level.dart';

/// Issue #28: curva de nivel del cazador.
void main() {
  test('nivel 1 desde 0 XP', () {
    expect(HunterLevel.levelFor(0), 1);
    expect(HunterLevel.levelFor(-10), 1);
  });

  test('sube cada 1000 XP', () {
    expect(HunterLevel.levelFor(999), 1);
    expect(HunterLevel.levelFor(1000), 2);
    expect(HunterLevel.levelFor(1999), 2);
    expect(HunterLevel.levelFor(2000), 3);
    expect(HunterLevel.levelFor(9500), 10);
  });

  test('progreso dentro del nivel', () {
    expect(HunterLevel.xpIntoLevel(0), 0);
    expect(HunterLevel.xpIntoLevel(450), 450);
    expect(HunterLevel.xpIntoLevel(1450), 450);
    expect(HunterLevel.progressFor(500), closeTo(0.5, 0.0001));
    expect(HunterLevel.progressFor(1000), 0.0);
  });

  test('nunca devuelve progreso fuera de rango', () {
    for (var xp = 0; xp <= 5000; xp += 137) {
      final p = HunterLevel.progressFor(xp);
      expect(p, greaterThanOrEqualTo(0.0));
      expect(p, lessThan(1.0));
      expect(HunterLevel.levelFor(xp), greaterThanOrEqualTo(1));
    }
  });
}
