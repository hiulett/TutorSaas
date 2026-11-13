import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/economy/domain/models/wallet_origin.dart';

void main() {
  group('WalletOrigin.fromRows (#374)', () {
    test('separa lo ganado de la canasta del plan y suma lo gastado', () {
      final origin = WalletOrigin.fromRows([
        {'currency': 'gold', 'delta': 100, 'reason': 'session_reward'},
        {'currency': 'gold', 'delta': 300, 'reason': 'plan_allowance'},
        {'currency': 'gold', 'delta': -60, 'reason': 'purchase_cosmetic'},
        {'currency': 'gems', 'delta': 50, 'reason': 'plan_allowance'},
      ], 'gold');

      expect(origin.earned, 100);
      expect(origin.fromPlan, 300);
      expect(origin.spent, 60);
      expect(origin.totalEarned, 400);
    });

    test('ignora otras monedas', () {
      final origin = WalletOrigin.fromRows([
        {'currency': 'gems', 'delta': 999, 'reason': 'plan_allowance'},
      ], 'fragments');

      expect(origin.earned, 0);
      expect(origin.fromPlan, 0);
      expect(origin.spent, 0);
    });

    test('tolera filas sin delta o sin razón', () {
      final origin = WalletOrigin.fromRows([
        {'currency': 'gold'},
        {'currency': 'gold', 'delta': 25},
      ], 'gold');

      expect(origin.earned, 25);
      expect(origin.fromPlan, 0);
    });
  });
}
