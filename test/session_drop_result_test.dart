import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/economy/domain/models/session_drop_result.dart';

/// Contrato normalizado del drop de fin de sesión.
void main() {
  test('drop nuevo con importes del servidor', () {
    final drop = SessionDropResult.fromMap(const {
      'success': true,
      'ok': true,
      'already_claimed': false,
      'rarity': 'epico',
      'xp': 30,
      'gold': 20,
      'reason': null,
    });

    expect(drop.success, isTrue);
    expect(drop.hasDrop, isTrue);
    expect(drop.rarity, 'epico');
    expect(drop.xp, 30);
    expect(drop.gold, 20);
  });

  test('drop ya reclamado no es error', () {
    final drop = SessionDropResult.fromMap(const {
      'success': true,
      'already_claimed': true,
      'rarity': 'comun',
      'xp': 15,
      'gold': 10,
    });

    expect(drop.isNoop, isTrue);
    expect(drop.hasDrop, isFalse);
  });

  test('sin metas no hay drop', () {
    final drop = SessionDropResult.fromMap(const {
      'success': false,
      'already_claimed': false,
      'reason': 'no_goals',
    });

    expect(drop.success, isFalse);
    expect(drop.reason, 'no_goals');
    expect(drop.hasDrop, isFalse);
  });

  test('acepta la forma antigua con ok', () {
    final drop = SessionDropResult.fromMap(const {
      'ok': true,
      'already_claimed': false,
      'rarity': 'legendario',
      'xp': 45,
      'gold': 30,
    });

    expect(drop.success, isTrue);
    expect(drop.rarity, 'legendario');
  });

  test('respuesta vacia no inventa drop', () {
    final drop = SessionDropResult.fromMap(const {});

    expect(drop.success, isFalse);
    expect(drop.xp, 0);
    expect(drop.gold, 0);
    expect(drop.hasDrop, isFalse);
  });
}
