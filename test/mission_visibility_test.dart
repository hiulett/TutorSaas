import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_models.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_visibility.dart';

/// Issue #109 · P-24: reglas puras de visibilidad y alcanzabilidad.
void main() {
  MissionInstance mission({
    String id = 'm1',
    String type = 'daily',
    String objective = 'speak_minutes',
    int target = 3,
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

  group('MissionVisibility.isTypeVisible', () {
    test('solo daily y weekly son visibles', () {
      expect(MissionVisibility.isTypeVisible('daily'), isTrue);
      expect(MissionVisibility.isTypeVisible('weekly'), isTrue);
    });

    test('secretas, eventos, gremio y secondary quedan ocultas', () {
      for (final type in MissionVisibility.hiddenTypes) {
        expect(
          MissionVisibility.isTypeVisible(type),
          isFalse,
          reason: '$type debe quedar oculto hasta que exista flujo',
        );
      }
    });
  });

  group('MissionVisibility.isAutoTracked', () {
    test('los cinco objetivos con trigger de servidor están soportados', () {
      for (final objective in MissionVisibility.autoTrackedObjectives) {
        expect(MissionVisibility.isAutoTracked(objective), isTrue);
      }
    });

    test('un objetivo sin trigger no está soportado', () {
      expect(MissionVisibility.isAutoTracked('pronunciation_score'), isFalse);
    });
  });

  group('MissionVisibility.capFor', () {
    test('techos diarios y semanales de speak_minutes', () {
      expect(
        MissionVisibility.capFor(
          objectiveType: 'speak_minutes',
          missionType: 'daily',
        ),
        10,
      );
      expect(
        MissionVisibility.capFor(
          objectiveType: 'speak_minutes',
          missionType: 'weekly',
        ),
        15,
      );
    });

    test('devuelve null para objetivos no rastreados', () {
      expect(
        MissionVisibility.capFor(
          objectiveType: 'unknown',
          missionType: 'daily',
        ),
        isNull,
      );
    });
  });

  group('MissionVisibility.isReachable', () {
    test('habla 3 minutos diarios es alcanzable', () {
      expect(
        MissionVisibility.isReachable(
          missionType: 'daily',
          objectiveType: 'speak_minutes',
          targetValue: 3,
        ),
        isTrue,
      );
    });

    test(
      'habla 10 minutos diarios sigue siendo alcanzable (1/59 completada)',
      () {
        expect(
          MissionVisibility.isReachable(
            missionType: 'daily',
            objectiveType: 'speak_minutes',
            targetValue: 10,
          ),
          isTrue,
        );
      },
    );

    test('habla 11 minutos diarios supera el techo medido', () {
      expect(
        MissionVisibility.isReachable(
          missionType: 'daily',
          objectiveType: 'speak_minutes',
          targetValue: 11,
        ),
        isFalse,
      );
    });

    test('habla 25 minutos semanales no es alcanzable', () {
      expect(
        MissionVisibility.isReachable(
          missionType: 'weekly',
          objectiveType: 'speak_minutes',
          targetValue: 25,
        ),
        isFalse,
      );
    });

    test('aprender 20 palabras semanales no es alcanzable', () {
      expect(
        MissionVisibility.isReachable(
          missionType: 'weekly',
          objectiveType: 'vocab_words',
          targetValue: 20,
        ),
        isFalse,
      );
    });

    test('aprender 10 palabras semanales sí es alcanzable', () {
      expect(
        MissionVisibility.isReachable(
          missionType: 'weekly',
          objectiveType: 'vocab_words',
          targetValue: 10,
        ),
        isTrue,
      );
    });

    test(
      'tipo oculto nunca es alcanzable aunque el objetivo tenga trigger',
      () {
        expect(
          MissionVisibility.isReachable(
            missionType: 'secondary',
            objectiveType: 'speak_minutes',
            targetValue: 1,
          ),
          isFalse,
        );
      },
    );

    test('target 0 o negativo no es alcanzable', () {
      expect(
        MissionVisibility.isReachable(
          missionType: 'daily',
          objectiveType: 'sessions',
          targetValue: 0,
        ),
        isFalse,
      );
      expect(
        MissionVisibility.isReachable(
          missionType: 'daily',
          objectiveType: 'sessions',
          targetValue: -1,
        ),
        isFalse,
      );
    });

    test('objetivo sin trigger no es alcanzable', () {
      expect(
        MissionVisibility.isReachable(
          missionType: 'daily',
          objectiveType: 'pronunciation_score',
          targetValue: 1,
        ),
        isFalse,
      );
    });
  });

  group('MissionVisibility.unavailableReason', () {
    test('null cuando la misión es alcanzable', () {
      expect(MissionVisibility.unavailableReason(mission()), isNull);
    });

    test('hidden_type para tipos fuera de la UI', () {
      expect(
        MissionVisibility.unavailableReason(mission(type: 'secret')),
        'hidden_type',
      );
    });

    test('untracked_objective cuando no hay trigger', () {
      expect(
        MissionVisibility.unavailableReason(
          mission(objective: 'pronunciation_score'),
        ),
        'untracked_objective',
      );
    });

    test('target_too_high cuando supera el techo', () {
      expect(
        MissionVisibility.unavailableReason(mission(target: 11)),
        'target_too_high',
      );
    });

    test('una misión completada nunca es no disponible', () {
      expect(
        MissionVisibility.unavailableReason(
          mission(target: 11, current: 11, status: 'completed'),
        ),
        isNull,
      );
    });

    test('invalid_target cuando el target no es positivo', () {
      expect(
        MissionVisibility.unavailableReason(mission(target: 0)),
        'invalid_target',
      );
    });
  });

  group('MissionVisibility.byType', () {
    test('filtra por tipo y descarta expiradas', () {
      final rows = [
        mission(id: 'a', type: 'daily'),
        mission(id: 'b', type: 'weekly'),
        mission(
          id: 'c',
          type: 'daily',
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        mission(id: 'd', type: 'secondary'),
      ];
      final daily = MissionVisibility.byType(rows, type: 'daily');
      expect(daily.map((m) => m.id), ['a']);
    });

    test('devuelve vacío para tipos ocultos', () {
      final rows = [mission(type: 'secret')];
      expect(MissionVisibility.byType(rows, type: 'secret'), isEmpty);
    });

    test('ordena reclamables primero y luego por progreso', () {
      final rows = [
        mission(id: 'low', current: 1, target: 5),
        mission(id: 'done', current: 5, target: 5, status: 'completed'),
        mission(id: 'mid', current: 3, target: 5),
      ];
      final ordered = MissionVisibility.byType(rows, type: 'daily');
      expect(ordered.map((m) => m.id), ['done', 'mid', 'low']);
    });
  });
}
