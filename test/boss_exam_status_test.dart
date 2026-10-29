import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/boss_exam/domain/models/boss_exam_outcome.dart';
import 'package:tutorsaas/features/boss_exam/domain/models/boss_exam_status.dart';

/// P-31 (#116): contrato con `boss_exam_status` y `evaluate-placement`.
void main() {
  group('BossExamStatus', () {
    test('lee el estado listo con requisitos cumplidos', () {
      final status = BossExamStatus.fromMap(const {
        'current_level': 'b1',
        'current_rank': 'c',
        'state': 'ready',
        'ready': true,
        'objectives_completed': 9,
        'objectives_target': 6,
        'minutes_practiced': 42,
        'minutes_target': 30,
        'current_streak': 4,
        'streak_target': 2,
        'lessons_passed': 7,
        'cooldown_until': null,
        'requirements': [
          {'id': 'level', 'met': true, 'current': 1, 'target': 1},
          {'id': 'practice', 'met': true, 'current': 9, 'target': 6},
          {'id': 'cooldown', 'met': true, 'current': 0, 'target': 1},
        ],
      });

      expect(status.currentLevel, 'B1');
      expect(status.currentRank, 'C');
      expect(status.isReady, isTrue);
      expect(status.isLocked, isFalse);
      expect(status.isOnCooldown, isFalse);
      expect(status.requirements, hasLength(3));
      expect(status.blocking, isEmpty);
      expect(status.cooldownRemaining(DateTime.now()), isNull);
    });

    test('bloqueado: expone los requisitos pendientes', () {
      final status = BossExamStatus.fromMap(const {
        'current_level': 'A1',
        'state': 'locked',
        'requirements': [
          {'id': 'level', 'met': true, 'current': 1, 'target': 1},
          {'id': 'practice', 'met': false, 'current': 2, 'target': 6},
          {'id': 'cooldown', 'met': true, 'current': 0, 'target': 1},
        ],
      });

      expect(status.isLocked, isTrue);
      expect(status.blocking, hasLength(1));
      expect(status.blocking.single.id, 'practice');
      expect(status.blocking.single.progress, closeTo(2 / 6, 0.001));
    });

    test('cooldown: calcula el tiempo restante', () {
      final until = DateTime.now().add(const Duration(hours: 3));
      final status = BossExamStatus.fromMap({
        'current_level': 'B1',
        'state': 'cooldown',
        'cooldown_until': until.toUtc().toIso8601String(),
      });

      expect(status.isOnCooldown, isTrue);
      final remaining = status.cooldownRemaining(DateTime.now());
      expect(remaining, isNotNull);
      expect(remaining!.inMinutes, closeTo(180, 2));
    });

    test('cooldown vencido devuelve cero, no negativo', () {
      final status = BossExamStatus.fromMap({
        'current_level': 'B1',
        'state': 'cooldown',
        'cooldown_until': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toUtc()
            .toIso8601String(),
      });

      expect(status.cooldownRemaining(DateTime.now()), Duration.zero);
    });

    test('un mapa vacío queda bloqueado y no rompe', () {
      final status = BossExamStatus.fromMap(const {});
      expect(status.currentLevel, isEmpty);
      expect(status.isLocked, isTrue);
      expect(status.requirements, isEmpty);
      expect(status.objectivesTarget, 6);
    });

    test('tipos inesperados no rompen la lectura', () {
      final status = BossExamStatus.fromMap(const {
        'current_level': 42,
        'state': '???',
        'requirements': 'nope',
        'objectives_completed': '7',
      });

      expect(status.currentLevel, '42');
      expect(status.isLocked, isTrue);
      expect(status.requirements, isEmpty);
      expect(status.objectivesCompleted, 7);
    });
  });

  group('BossExamOutcome', () {
    test('ascenso: veredicto y rúbrica del servidor', () {
      final outcome = BossExamOutcome.fromMap(const {
        'cefr_level': 'b2',
        'game_rank': 'b',
        'previous_cefr_level': 'B1',
        'decision': 'promoted',
        'promoted': true,
        'reason_code': null,
        'rubric': {
          'average': 78,
          'passed': true,
          'dimensions': {
            'listening': 80,
            'fluency': 78,
            'grammar': 74,
            'vocabulary': 80,
            'pronunciation': 78,
            'naturalness': 78,
          },
        },
        'forced': false,
        'turns': 6,
        'next_attempt_at': null,
      });

      expect(outcome.level, 'B2');
      expect(outcome.previousLevel, 'B1');
      expect(outcome.verdict, BossExamVerdict.promoted);
      expect(outcome.promoted, isTrue);
      expect(outcome.hasReason, isFalse);
      expect(outcome.rubric.passed, isTrue);
      expect(outcome.turns, 6);
      expect(outcome.nextAttemptAt, isNull);
    });

    test('mantiene nivel con motivo y fecha de reintento', () {
      final next = DateTime.now().add(const Duration(hours: 12));
      final outcome = BossExamOutcome.fromMap({
        'cefr_level': 'B1',
        'game_rank': 'C',
        'previous_cefr_level': 'B1',
        'decision': 'maintained',
        'reason_code': 'rubric_below_threshold',
        'next_attempt_at': next.toUtc().toIso8601String(),
        'forced': true,
      });

      expect(outcome.maintained, isTrue);
      expect(outcome.promoted, isFalse);
      expect(outcome.reasonCode, 'rubric_below_threshold');
      expect(outcome.hasReason, isTrue);
      expect(outcome.forced, isTrue);
      expect(outcome.nextAttemptAt, isNotNull);
    });

    test('sin decision explícita no inventa ascenso', () {
      final outcome = BossExamOutcome.fromMap(const {
        'cefr_level': 'B1',
        'previous_cefr_level': 'B1',
      });
      expect(outcome.verdict, BossExamVerdict.maintained);
    });

    test('sin nivel previo es placement inicial', () {
      final outcome = BossExamOutcome.fromMap(const {'cefr_level': 'A2'});
      expect(outcome.verdict, BossExamVerdict.initial);
      expect(outcome.isInitial, isTrue);
    });

    test('rúbrica se puede reconstruir desde scores si falta el bloque', () {
      final outcome = BossExamOutcome.fromMap(const {
        'cefr_level': 'B1',
        'decision': 'maintained',
        'scores': {
          'listening': 70,
          'fluency': 70,
          'grammar': 70,
          'vocabulary': 70,
          'pronunciation': 70,
          'naturalness': 70,
        },
      });

      expect(outcome.rubric.complete, isTrue);
      expect(outcome.rubric.passed, isTrue);
    });
  });
}
