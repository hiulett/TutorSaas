import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/economy/domain/models/mana_budget.dart';

/// P-26 (#111): el medidor de maná avisa cuando quedan pocos turnos y sabe
/// cuándo se recarga. Todo se calcula desde el JSON de `get_mana_state`.
void main() {
  Map<String, dynamic> freeState({
    int dailyRemaining = 200,
    int dailyLimit = 200,
  }) => {
    'is_free': true,
    'remaining': 3000,
    'daily_remaining': dailyRemaining,
    'daily_limit': dailyLimit,
    'allowance': 3000,
    'purchased': 0,
    'expires_at': null,
  };

  test('turnos restantes con el coste de mazmorra (12)', () {
    final budget = ManaBudget.fromState(freeState(dailyRemaining: 50));

    expect(budget.turnsLeft, 4);
    expect(budget.isLow, isFalse);
    expect(budget.isEmpty, isFalse);
  });

  test('avisa a 3 turnos o menos', () {
    expect(ManaBudget.fromState(freeState(dailyRemaining: 37)).turnsLeft, 3);
    expect(ManaBudget.fromState(freeState(dailyRemaining: 37)).isLow, isTrue);
    expect(ManaBudget.fromState(freeState(dailyRemaining: 36)).isLow, isTrue);
    expect(ManaBudget.fromState(freeState(dailyRemaining: 48)).isLow, isFalse);
  });

  test('sin llegar al coste de un turno esta vacio, no bajo', () {
    final budget = ManaBudget.fromState(freeState(dailyRemaining: 11));

    expect(budget.isEmpty, isTrue);
    expect(budget.isLow, isFalse);
    expect(budget.turnsLeft, 0);
  });

  test('plan gratuito: recarga en la proxima medianoche UTC', () {
    final budget = ManaBudget.fromState(freeState(dailyRemaining: 5));
    final now = DateTime.utc(2026, 10, 29, 22, 30);

    expect(budget.refillAt(now), DateTime.utc(2026, 10, 30));
    expect(budget.refillIn(now), const Duration(hours: 1, minutes: 30));
  });

  test('plan de pago: recarga en expires_at', () {
    final budget = ManaBudget.fromState({
      'is_free': false,
      'remaining': 900,
      'allowance': 3000,
      'purchased': 0,
      'daily_remaining': 200,
      'daily_limit': 200,
      'expires_at': '2026-11-15T00:00:00Z',
    });
    final now = DateTime.utc(2026, 11, 14, 20);

    expect(budget.available, 900);
    expect(budget.capacity, 3000);
    expect(budget.refillIn(now), const Duration(hours: 4));
  });

  test('el coste por turno configurable cambia los turnos', () {
    final budget = ManaBudget.fromState(
      freeState(dailyRemaining: 40),
      costPerTurn: 8,
    );

    expect(budget.turnsLeft, 5);
    expect(budget.isLow, isFalse);
  });

  test('un coste invalido usa el valor por defecto', () {
    final budget = ManaBudget.fromState(
      freeState(dailyRemaining: 24),
      costPerTurn: 0,
    );

    expect(budget.costPerTurn, ManaBudget.defaultCostPerTurn);
    expect(budget.turnsLeft, 2);
  });

  test('la barra nunca pasa del 100%', () {
    final budget = ManaBudget.fromState(
      freeState(dailyRemaining: 260, dailyLimit: 200),
    );

    expect(budget.ratio, 1.0);
  });
}
