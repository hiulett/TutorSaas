import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_models.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_spotlight.dart';

/// Issue #109 · P-24: selección 1 principal + 2 secundarias.
void main() {
  MissionInstance mission({
    required String id,
    String type = 'daily',
    String objective = 'speak_minutes',
    int target = 5,
    int current = 0,
    String status = 'active',
    bool claimed = false,
    DateTime? expiresAt,
  }) => MissionInstance(
    id: id,
    userId: 'u1',
    missionType: type,
    title: 'Misión $id',
    objectiveType: objective,
    targetValue: target,
    currentValue: current,
    status: status,
    isRewardClaimed: claimed,
    expiresAt: expiresAt,
    startedAt: DateTime(2026, 1, 1),
  );

  test('sin misiones devuelve un destacado vacío', () {
    final spotlight = MissionSpotlight.from(const []);
    expect(spotlight.isEmpty, isTrue);
    expect(spotlight.primary, isNull);
    expect(spotlight.secondary, isEmpty);
  });

  test('la principal es la más cercana a completarse', () {
    final spotlight = MissionSpotlight.from([
      mission(id: 'a', current: 1),
      mission(id: 'b', current: 4),
      mission(id: 'c', current: 2),
    ]);
    expect(spotlight.primary?.id, 'b');
    expect(spotlight.secondary.map((m) => m.id), ['c', 'a']);
  });

  test('las reclamables tienen prioridad sobre el progreso', () {
    final spotlight = MissionSpotlight.from([
      mission(id: 'progress', current: 4),
      mission(id: 'claimable', current: 5, status: 'completed'),
    ]);
    expect(spotlight.primary?.id, 'claimable');
  });

  test('excluye misiones no alcanzables', () {
    final spotlight = MissionSpotlight.from([
      mission(id: 'too_long', type: 'weekly', target: 25),
      mission(id: 'ok', target: 3),
    ]);
    expect(spotlight.primary?.id, 'ok');
    expect(spotlight.secondary, isEmpty);
  });

  test('excluye tipos ocultos (secretas, gremio, secondary)', () {
    final spotlight = MissionSpotlight.from([
      mission(id: 'secret', type: 'secret', current: 4),
      mission(id: 'guild', type: 'guild', current: 4),
      mission(id: 'secondary', type: 'secondary', current: 4),
      mission(id: 'daily', current: 1),
    ]);
    expect(spotlight.primary?.id, 'daily');
    expect(spotlight.secondary, isEmpty);
  });

  test('excluye misiones expiradas', () {
    final spotlight = MissionSpotlight.from([
      mission(
        id: 'expired',
        current: 5,
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      mission(id: 'live', current: 1),
    ]);
    expect(spotlight.primary?.id, 'live');
  });

  test('devuelve como máximo 2 secundarias por defecto', () {
    final spotlight = MissionSpotlight.from([
      for (var i = 0; i < 6; i++) mission(id: 'm$i', current: i),
    ]);
    expect(spotlight.primary, isNotNull);
    expect(spotlight.secondary.length, MissionSpotlight.defaultSecondaryCount);
  });

  test('incluye semanales en el destacado si son alcanzables', () {
    final spotlight = MissionSpotlight.from([
      mission(id: 'weekly', type: 'weekly', target: 15, current: 14),
      mission(id: 'daily', current: 1),
    ]);
    expect(spotlight.primary?.id, 'weekly');
  });

  test(
    'empate de progreso se resuelve de forma determinista por target e id',
    () {
      final spotlight = MissionSpotlight.from([
        mission(id: 'b', current: 2, target: 5),
        mission(id: 'a', current: 2, target: 5),
        mission(id: 'c', current: 2, target: 4),
      ]);
      // Mismo progreso (0.5): gana el target menor; empate total → id.
      expect(spotlight.primary?.id, 'c');
      expect(spotlight.secondary.map((m) => m.id), ['a', 'b']);
    },
  );
}
