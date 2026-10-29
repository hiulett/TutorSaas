import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/corrections/domain/models/turn_correction.dart';
import 'package:tutorsaas/features/dashboard/domain/models/remedial_lesson.dart';

/// P-42 (#127) — Lección de refuerzo: lógica pura.
///
/// Cubre los dos fallos del hallazgo H-42:
///  1. `weakestSkill` devolvía `comprehension`/`naturalness`, ejes que el
///     generador rechaza con 400 y que sin datos del Oráculo valen 0.
///  2. El refuerzo se decidía por el radar, no por los errores reales (P-29).
void main() {
  CorrectionGroup error(
    CorrectionType type, {
    required int occurrences,
    String original = 'I go',
    String corrected = 'I went',
  }) {
    return CorrectionGroup(
      type: type,
      original: original,
      corrected: corrected,
      occurrences: occurrences,
    );
  }

  group('weakestSkillFromRadar', () {
    test('ignora comprehension/naturalness aunque valgan 0', () {
      final radar = <String, double>{
        'fluency': 55,
        'vocab': 40,
        'phonetics': 62,
        'grammar': 48,
        'goals': 70,
        'comprehension': 0,
        'naturalness': 0,
      };
      expect(weakestSkillFromRadar(radar), 'vocab');
    });

    test('sin datos del Oráculo no elige un eje sin medición', () {
      final radar = <String, double>{
        'fluency': 0,
        'vocab': 0,
        'phonetics': 0,
        'grammar': 0,
        'goals': 0,
        'comprehension': 0,
        'naturalness': 0,
      };
      final skill = weakestSkillFromRadar(radar);
      expect(remedialSkillFocuses.contains(skill), isTrue);
      expect(nonRemediableRadarAxes.contains(skill), isFalse);
      // Empate entre los cinco ejes canónicos: alfabético → fluency.
      expect(skill, 'fluency');
    });

    test('un radar vacío cae en grammar', () {
      expect(weakestSkillFromRadar(const {}), 'grammar');
    });

    test('descarta claves desconocidas', () {
      final radar = <String, double>{
        'comprehension': 0,
        'naturalness': 1,
        'x': 0,
      };
      expect(weakestSkillFromRadar(radar), 'grammar');
    });

    test('empate determinista por orden alfabético', () {
      final radar = <String, double>{'goals': 20, 'grammar': 20};
      expect(weakestSkillFromRadar(radar), 'goals');
    });
  });

  group('skillFocusForCorrectionType', () {
    test('mapea los tipos reales de P-29', () {
      expect(skillFocusForCorrectionType(CorrectionType.grammar), 'grammar');
      expect(skillFocusForCorrectionType(CorrectionType.vocabulary), 'vocab');
      expect(skillFocusForCorrectionType(CorrectionType.wordChoice), 'vocab');
      expect(
        skillFocusForCorrectionType(CorrectionType.pronunciationHint),
        'phonetics',
      );
    });

    test('un typo de STT no dirige una lección', () {
      expect(skillFocusForCorrectionType(CorrectionType.typoStt), isNull);
    });
  });

  group('buildRemedialPlan', () {
    test('sin errores ni metas falladas no hay plan (no se cobra maná)', () {
      final plan = buildRemedialPlan(
        radar: const {'grammar': 10},
        recurringErrors: const [],
        failedGoals: const [],
      );
      expect(plan, isNull);
    });

    test('solo metas falladas: usa el radar y las nombra', () {
      final plan = buildRemedialPlan(
        radar: const {'grammar': 10, 'vocab': 80},
        recurringErrors: const [],
        failedGoals: const ['Order a coffee politely'],
      )!;
      expect(plan.skillFocus, 'grammar');
      expect(plan.fromRecurringErrors, isFalse);
      expect(plan.weakness, contains('Order a coffee politely'));
      expect(plan.failedGoals, ['Order a coffee politely']);
    });

    test('errores recurrentes mandan sobre el radar', () {
      final plan = buildRemedialPlan(
        radar: const {'grammar': 5, 'vocab': 90},
        recurringErrors: [
          error(
            CorrectionType.vocabulary,
            occurrences: 4,
            original: 'make a photo',
            corrected: 'take a photo',
          ),
          error(CorrectionType.grammar, occurrences: 2),
        ],
        failedGoals: const ['Describe your routine'],
      )!;
      expect(plan.skillFocus, 'vocab');
      expect(plan.fromRecurringErrors, isTrue);
      expect(
        plan.weakness,
        contains('objective not met: Describe your routine'),
      );
      expect(plan.weakness, contains('make a photo'));
      // El detalle de errores se limita a maxErrors y no repite el objetivo.
      expect('objective not met'.allMatches(plan.weakness).length, 1);
    });

    test('un error no recurrente (1 vez) no es evidencia', () {
      final plan = buildRemedialPlan(
        radar: const {},
        recurringErrors: [error(CorrectionType.grammar, occurrences: 1)],
        failedGoals: const [],
      );
      expect(plan, isNull);
    });

    test('solo typos de STT no son evidencia', () {
      final plan = buildRemedialPlan(
        radar: const {'grammar': 10},
        recurringErrors: [
          error(
            CorrectionType.typoStt,
            occurrences: 5,
            original: 'se',
            corrected: 'see',
          ),
        ],
        failedGoals: const [],
      );
      expect(plan, isNull);
    });

    test('respeta el tope de metas y errores', () {
      final plan = buildRemedialPlan(
        radar: const {},
        recurringErrors: [
          error(CorrectionType.grammar, occurrences: 5),
          error(CorrectionType.vocabulary, occurrences: 4),
          error(CorrectionType.pronunciationHint, occurrences: 3),
        ],
        failedGoals: const ['a', 'b', 'c'],
      )!;
      expect(plan.failedGoals, ['a', 'b']);
      expect(plan.weakness, contains('grammar: "I go"'));
      // maxErrors=2: el tercer error no entra en el prompt.
      expect(plan.weakness, isNot(contains('pronunciation_hint')));
    });
  });

  group('RemedialLessonResult', () {
    test('respuesta generada', () {
      final result = RemedialLessonResult.fromResponse({
        'success': true,
        'reused': false,
        'cost': 100,
        'scenario': {'id': 'uuid-1', 'title': 'Past tense rescue'},
      });
      expect(result.status, RemedialLessonStatus.generated);
      expect(result.isPlayable, isTrue);
      expect(result.scenarioId, 'uuid-1');
      expect(result.cost, 100);
    });

    test('respuesta reutilizada no cobra', () {
      final result = RemedialLessonResult.fromResponse({
        'success': true,
        'reused': true,
        'scenario': {'id': 'uuid-2', 'title': 'Library lesson'},
      });
      expect(result.status, RemedialLessonStatus.reused);
      expect(result.cost, 0);
      expect(result.isPlayable, isTrue);
    });

    test('respuesta sin escenario es fallo, no pantalla en blanco', () {
      final result = RemedialLessonResult.fromResponse({'success': true});
      expect(result.status, RemedialLessonStatus.failed);
      expect(result.isPlayable, isFalse);
      expect(result.isRetryable, isTrue);
      expect(result.detail, isNotEmpty);
    });

    test('responses nulas no rompen', () {
      expect(
        RemedialLessonResult.fromResponse(null).status,
        RemedialLessonStatus.failed,
      );
    });

    test('422 → sin evidencia', () {
      final result = RemedialLessonResult.fromFailure(
        status: 422,
        code: 'no_evidence',
      );
      expect(result.status, RemedialLessonStatus.noEvidence);
      expect(result.isPlayable, isFalse);
      expect(result.isRetryable, isFalse);
    });

    test('402 → maná insuficiente', () {
      final result = RemedialLessonResult.fromFailure(
        status: 402,
        code: 'insufficient_mana',
      );
      expect(result.status, RemedialLessonStatus.insufficientMana);
      expect(result.isPlayable, isFalse);
    });

    test('502 con reembolso → fallo reintentable', () {
      final result = RemedialLessonResult.fromFailure(
        status: 502,
        code: 'generation_failed',
      );
      expect(result.status, RemedialLessonStatus.failed);
      expect(result.isRetryable, isTrue);
      expect(result.detail, '502:generation_failed');
    });

    test('error desconocido → fallo', () {
      final result = RemedialLessonResult.fromFailure(code: 'boom');
      expect(result.status, RemedialLessonStatus.failed);
      expect(result.detail, contains('boom'));
    });
  });
}
