import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_claim_result.dart';

/// Issue #109 · P-24: lectura de la respuesta de `claim_mission_reward`.
void main() {
  test('mapea una recompensa nueva con los importes del servidor', () {
    final result = MissionClaimResult.fromRpc({
      'ok': true,
      'already_claimed': false,
      'xp': 50,
      'gems': 5,
    });
    expect(result.ok, isTrue);
    expect(result.alreadyClaimed, isFalse);
    expect(result.xp, 50);
    expect(result.gems, 5);
    expect(result.hasReward, isTrue);
    expect(result.nothingToClaim, isFalse);
  });

  test('un reclamado previo es ok pero sin recompensa nueva', () {
    final result = MissionClaimResult.fromRpc({
      'ok': true,
      'already_claimed': true,
      'xp': 0,
      'gems': 0,
    });
    expect(result.ok, isTrue);
    expect(result.nothingToClaim, isTrue);
    expect(result.hasReward, isFalse);
  });

  test('not_completed devuelve ok=false con motivo del servidor', () {
    final result = MissionClaimResult.fromRpc({
      'ok': false,
      'reason': 'not_completed',
    });
    expect(result.ok, isFalse);
    expect(result.reason, 'not_completed');
  });

  test('not_found devuelve ok=false con motivo del servidor', () {
    final result = MissionClaimResult.fromRpc({
      'ok': false,
      'reason': 'not_found',
    });
    expect(result.ok, isFalse);
    expect(result.reason, 'not_found');
  });

  test('respuesta no-map se trata como fallo de protocolo', () {
    final result = MissionClaimResult.fromRpc('no-json');
    expect(result.ok, isFalse);
    expect(result.reason, 'invalid_response');
  });

  test('motivo ausente o vacío se normaliza a unknown', () {
    expect(MissionClaimResult.fromRpc({'ok': false}).reason, 'unknown');
    expect(
      MissionClaimResult.fromRpc({'ok': false, 'reason': ''}).reason,
      'unknown',
    );
  });

  test('failure nombra el motivo', () {
    const result = MissionClaimResult.failure('exception');
    expect(result.ok, isFalse);
    expect(result.reason, 'exception');
    expect(result.hasReward, isFalse);
  });
}
