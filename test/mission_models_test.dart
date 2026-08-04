import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_models.dart';

/// QA-01: cobertura de lógica pura de modelos de misiones
/// (sin red ni widgets).
void main() {
  group('MissionInstance.progress', () {
    MissionInstance instance({int target = 10, int current = 5}) => MissionInstance(
          id: 'm1',
          userId: 'u1',
          missionType: 'daily',
          title: 'Habla 10 minutos',
          objectiveType: 'speak_minutes',
          targetValue: target,
          currentValue: current,
          startedAt: DateTime(2026, 1, 1),
        );

    test('devuelve current/target (0.5) con target 10 y current 5', () {
      expect(instance().progress, 0.5);
    });

    test('clampa a 0.0 cuando current < 0', () {
      expect(instance(current: -3).progress, 0.0);
    });

    test('clampa a 1.0 cuando current supera el target', () {
      expect(instance(current: 20).progress, 1.0);
    });

    test('devuelve 1.0 en el límite exacto current == target', () {
      expect(instance(current: 10).progress, 1.0);
    });

    test('devuelve 0.0 cuando target es 0 (evita división por cero)', () {
      expect(instance(target: 0, current: 0).progress, 0.0);
    });
  });

  group('MissionInstance.isCompleted', () {
    MissionInstance instance({String status = 'completed', int current = 5, int target = 10}) =>
        MissionInstance(
          id: 'm1',
          userId: 'u1',
          missionType: 'daily',
          title: 'Título',
          objectiveType: 'speak_minutes',
          targetValue: target,
          currentValue: current,
          status: status,
          startedAt: DateTime(2026, 1, 1),
        );

    // NOTA: la implementación real (mission_models.dart:93) define
    // isCompleted según `status == 'completed'`, NO por current >= target.
    test('es true cuando status == "completed"', () {
      expect(instance().isCompleted, isTrue);
    });

    test('es false con status "active" aunque current >= target', () {
      expect(instance(status: 'active', current: 15, target: 10).isCompleted, isFalse);
    });

    test('es false con status desconocido', () {
      expect(instance(status: 'pending').isCompleted, isFalse);
    });
  });

  group('MissionInstance.isExpired', () {
    MissionInstance instance({DateTime? expiresAt}) => MissionInstance(
          id: 'm1',
          userId: 'u1',
          missionType: 'daily',
          title: 'Título',
          objectiveType: 'speak_minutes',
          expiresAt: expiresAt,
          startedAt: DateTime(2026, 1, 1),
        );

    test('es true cuando expiresAt está en el pasado', () {
      expect(instance(expiresAt: DateTime.now().subtract(const Duration(hours: 1))).isExpired, isTrue);
    });

    test('es false cuando expiresAt está en el futuro', () {
      expect(instance(expiresAt: DateTime.now().add(const Duration(hours: 1))).isExpired, isFalse);
    });

    test('es false cuando expiresAt es null', () {
      expect(instance().isExpired, isFalse);
    });
  });

  group('missionTypeIcon', () {
    test('devuelve el emoji de calendario para "daily"', () {
      expect(missionTypeIcon('daily'), '📅');
    });

    test('devuelve un emoji para cada tipo conocido', () {
      expect(missionTypeIcon('weekly'), '📆');
      expect(missionTypeIcon('secondary'), '📋');
      expect(missionTypeIcon('secret'), '🔮');
      expect(missionTypeIcon('emergency'), '⚡');
      expect(missionTypeIcon('guild'), '🏰');
      expect(missionTypeIcon('event'), '🌍');
    });

    test('devuelve el emoji por defecto para tipos desconocidos', () {
      expect(missionTypeIcon('unknown'), '📜');
    });
  });

  group('missionTypeColor', () {
    test('devuelve un Color válido para "emergency" (crimsonRed)', () {
      final color = missionTypeColor('emergency');
      expect(color, isA<Color>());
      expect(color, AppColors.crimsonRed);
    });

    test('devuelve el color por defecto (manaCyan) para tipos desconocidos', () {
      final color = missionTypeColor('unknown');
      expect(color, isA<Color>());
      expect(color, AppColors.manaCyan);
    });

    test('devuelve un Color válido para cada tipo conocido', () {
      for (final type in ['daily', 'weekly', 'secondary', 'secret', 'emergency', 'guild', 'collaborative', 'event']) {
        expect(missionTypeColor(type), isA<Color>(), reason: 'color válido para "$type"');
      }
    });
  });

  group('GuildMission', () {
    GuildMission mission({int target = 10, int current = 0}) => GuildMission(
          id: 'g1',
          title: 'Misión del gremio',
          objectiveType: 'speak_minutes',
          targetValue: target,
          currentValue: current,
          startsAt: DateTime(2026, 1, 1),
          expiresAt: DateTime(2026, 12, 31),
        );

    test('progress devuelve current/target (0.5)', () {
      expect(mission(current: 5).progress, 0.5);
    });

    test('progress clampa a 1.0 cuando current supera target', () {
      expect(mission(current: 99).progress, 1.0);
    });

    test('isCompleted es true cuando current >= target', () {
      expect(mission(current: 10).isCompleted, isTrue);
      expect(mission(current: 12).isCompleted, isTrue);
    });

    test('isCompleted es false cuando current < target', () {
      expect(mission(current: 9).isCompleted, isFalse);
    });
  });

  group('GlobalEvent.isRunning', () {
    GlobalEvent event({DateTime? startsAt, DateTime? expiresAt}) => GlobalEvent(
          id: 'e1',
          title: 'Evento',
          eventType: 'double_xp',
          startsAt: startsAt ?? DateTime.now().subtract(const Duration(days: 1)),
          expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 1)),
        );

    test('es true cuando ya inició y aún no expira', () {
      expect(event().isRunning, isTrue);
    });

    test('es false cuando aún no ha iniciado (startsAt futuro)', () {
      expect(
        event(startsAt: DateTime.now().add(const Duration(days: 1))).isRunning,
        isFalse,
      );
    });

    test('es false cuando ya expiró aunque haya iniciado', () {
      expect(
        event(expiresAt: DateTime.now().subtract(const Duration(days: 1))).isRunning,
        isFalse,
      );
    });
  });
}
