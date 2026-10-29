import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/boss_exam/domain/models/boss_exam_rubric.dart';
import 'package:tutorsaas/features/boss_exam/domain/services/boss_exam_rules.dart';

/// P-31 (#116): reglas puras del examen de promoción ("jefe de mazmorra").
void main() {
  group('tope de turnos y tiempo', () {
    test('no cierra antes del octavo turno', () {
      expect(
        BossExamRules.shouldForceClose(
          turns: 7,
          elapsed: const Duration(minutes: 1),
        ),
        isFalse,
      );
    });

    test('cierra al alcanzar el tope duro de turnos', () {
      expect(
        BossExamRules.shouldForceClose(
          turns: BossExamRules.maxTurns,
          elapsed: const Duration(minutes: 1),
        ),
        isTrue,
      );
      expect(
        BossExamRules.shouldForceClose(
          turns: BossExamRules.maxTurns + 3,
          elapsed: Duration.zero,
        ),
        isTrue,
      );
    });

    test('cierra al agotarse el tiempo aunque queden turnos', () {
      expect(
        BossExamRules.shouldForceClose(
          turns: 2,
          elapsed: BossExamRules.timeLimit,
        ),
        isTrue,
      );
      expect(
        BossExamRules.shouldForceClose(
          turns: 2,
          elapsed: const Duration(seconds: 30),
        ),
        isFalse,
      );
    });
  });

  group('evidencia mínima', () {
    test('menos de 5 respuestas no cuentan', () {
      expect(BossExamRules.hasEnoughEvidence(4), isFalse);
      expect(BossExamRules.hasEnoughEvidence(0), isFalse);
    });

    test('5 respuestas ya son evidencia suficiente', () {
      expect(BossExamRules.hasEnoughEvidence(5), isTrue);
    });
  });

  group('salud visual del jefe', () {
    test('baja con cada turno y no pasa de 0 ni de 100', () {
      expect(BossExamRules.bossHealthPercent(0), 100);
      expect(BossExamRules.bossHealthPercent(4), 50);
      expect(BossExamRules.bossHealthPercent(8), 0);
      expect(BossExamRules.bossHealthPercent(40), 0);
      expect(BossExamRules.bossHealthPercent(-2), 100);
    });
  });

  group('decisión local (espejo del servidor)', () {
    test('sin nivel previo es placement inicial', () {
      final verdict = BossExamRules.decide(
        previousLevel: '',
        evaluatedLevel: 'B1',
        scores: const {},
      );
      expect(verdict.initial, isTrue);
      expect(verdict.promoted, isFalse);
    });

    test('subir de banda sin rúbrica aprobada no asciende', () {
      final verdict = BossExamRules.decide(
        previousLevel: 'A2',
        evaluatedLevel: 'B1',
        scores: const {
          'listening': 60,
          'fluency': 60,
          'grammar': 40,
          'vocabulary': 60,
          'pronunciation': 60,
          'naturalness': 60,
        },
      );
      expect(verdict.promoted, isFalse);
      expect(verdict.reasonCode, 'rubric_below_threshold');
    });

    test('subir de banda con rúbrica aprobada asciende', () {
      final verdict = BossExamRules.decide(
        previousLevel: 'A2',
        evaluatedLevel: 'B1',
        scores: const {
          'listening': 70,
          'fluency': 70,
          'grammar': 66,
          'vocabulary': 70,
          'pronunciation': 70,
          'naturalness': 70,
        },
      );
      expect(verdict.promoted, isTrue);
      expect(verdict.reasonCode, isEmpty);
    });

    test('mismo nivel o inferior se mantiene con motivo', () {
      final verdict = BossExamRules.decide(
        previousLevel: 'B1',
        evaluatedLevel: 'B1',
        scores: const {
          'listening': 90,
          'fluency': 90,
          'grammar': 90,
          'vocabulary': 90,
          'pronunciation': 90,
          'naturalness': 90,
        },
      );
      expect(verdict.promoted, isFalse);
      expect(verdict.reasonCode, 'no_improvement');
    });
  });

  group('rúbrica de 6 dimensiones', () {
    Map<String, dynamic> perfect() => {
      'listening': 80,
      'fluency': 80,
      'grammar': 80,
      'vocabulary': 80,
      'pronunciation': 80,
      'naturalness': 80,
    };

    test('las 6 dimensiones por encima del umbral aprueban', () {
      final rubric = BossExamRubric.fromScores(perfect());
      expect(rubric.complete, isTrue);
      expect(rubric.average, 80);
      expect(rubric.passed, isTrue);
      expect(rubric.failingDimensions, isEmpty);
    });

    test('una dimensión bajo el suelo suspende aunque la media sea alta', () {
      final rubric = BossExamRubric.fromScores({
        ...perfect(),
        'grammar': BossExamRubric.minDimension - 1,
      });
      expect(rubric.average, greaterThan(BossExamRubric.passAverage));
      expect(rubric.passed, isFalse);
      expect(rubric.failingDimensions, ['grammar']);
      expect(rubric.weakestDimension, 'grammar');
    });

    test('una media baja suspende aunque todas pasen el suelo', () {
      final rubric = BossExamRubric.fromScores({
        'listening': 50,
        'fluency': 50,
        'grammar': 50,
        'vocabulary': 50,
        'pronunciation': 50,
        'naturalness': 50,
      });
      expect(rubric.passed, isFalse);
      expect(rubric.failingDimensions, isEmpty);
    });

    test('faltan dimensiones: no se puede aprobar', () {
      final rubric = BossExamRubric.fromScores(const {
        'listening': 90,
        'fluency': 90,
      });
      expect(rubric.complete, isFalse);
      expect(rubric.passed, isFalse);
      expect(rubric.average, 90);
    });

    test('valores fuera de rango se recortan a 0..100', () {
      final rubric = BossExamRubric.fromScores({
        ...perfect(),
        'listening': 250,
        'fluency': -10,
      });
      expect(rubric.dimensions['listening'], 100);
      expect(rubric.dimensions['fluency'], 0);
    });
  });
}
