import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/scenario_band.dart';
import 'package:tutorsaas/features/conversation/domain/models/tutor_adaptation.dart';
import 'package:tutorsaas/features/conversation/domain/services/tutor_prompt_builder.dart';

/// P-40b (#221) — La banda CEFR del escenario se adapta al alumno sin IA.
void main() {
  group('ScenarioBand — escala', () {
    test('orden y vecinos', () {
      expect(ScenarioBand.indexOf('b1'), 3);
      expect(ScenarioBand.indexOf('no-existe'), -1);
      expect(ScenarioBand.adjacentDown('A2'), 'A1');
      expect(ScenarioBand.adjacentUp('A1'), 'A2');
      expect(ScenarioBand.adjacentDown('PRE-A1'), isNull);
      expect(ScenarioBand.adjacentUp('C2'), isNull);
    });

    test('nivel de refuerzo: una banda por debajo, sin salir de la escala', () {
      expect(ScenarioBand.remedialLevel('B1'), 'A2');
      expect(ScenarioBand.remedialLevel('A2'), 'A1');
      expect(ScenarioBand.remedialLevel('PRE-A1'), 'PRE-A1');
      expect(ScenarioBand.remedialLevel(''), '');
    });
  });

  group('ScenarioBand.plan', () {
    test('un escenario por encima del nivel real se recorta al alumno', () {
      final plan = ScenarioBand.plan(
        learnerLevel: 'A1',
        scenarioLevel: 'B1',
        totalGoals: 5,
      );

      expect(plan.effectiveLevel, 'A1');
      expect(plan.scenarioAboveLearner, isTrue);
      expect(plan.changesBand, isTrue);
      // Hueco de 2 bandas → 40 % de 5 objetivos = 2.
      expect(plan.goalBudget, 2);
    });

    test('un escenario una banda por encima deja 60 % de objetivos', () {
      final plan = ScenarioBand.plan(
        learnerLevel: 'A1',
        scenarioLevel: 'A2',
        totalGoals: 5,
      );

      expect(plan.effectiveLevel, 'A1');
      expect(plan.goalBudget, 3);
    });

    test('misma banda: no cambia nada ni limita objetivos', () {
      final plan = ScenarioBand.plan(
        learnerLevel: 'A2',
        scenarioLevel: 'A2',
        totalGoals: 4,
      );

      expect(plan.effectiveLevel, 'A2');
      expect(plan.changesBand, isFalse);
      expect(plan.limitsGoals, isFalse);
    });

    test('dos fallos seguidos bajan una banda y recortan objetivos', () {
      final plan = ScenarioBand.plan(
        learnerLevel: 'A2',
        scenarioLevel: 'A2',
        adaptation: TutorDifficultyAdjustment.simplify,
        totalGoals: 4,
      );

      expect(plan.effectiveLevel, 'A1');
      expect(plan.simplified, isTrue);
      expect(plan.changesBand, isTrue);
      expect(plan.goalBudget, 2);
    });

    test('tres aciertos seguidos suben una banda', () {
      final plan = ScenarioBand.plan(
        learnerLevel: 'A2',
        scenarioLevel: 'A2',
        adaptation: TutorDifficultyAdjustment.stretch,
      );

      expect(plan.effectiveLevel, 'B1');
      expect(plan.stretched, isTrue);
    });

    test(
      'la simplificación no baja de PRE-A1 ni el estiramiento pasa de C2',
      () {
        final floor = ScenarioBand.plan(
          learnerLevel: 'PRE-A1',
          scenarioLevel: 'PRE-A1',
          adaptation: TutorDifficultyAdjustment.simplify,
        );
        final ceiling = ScenarioBand.plan(
          learnerLevel: 'C2',
          scenarioLevel: 'C2',
          adaptation: TutorDifficultyAdjustment.stretch,
        );

        expect(floor.effectiveLevel, 'PRE-A1');
        expect(floor.simplified, isFalse);
        expect(ceiling.effectiveLevel, 'C2');
        expect(ceiling.stretched, isFalse);
      },
    );

    test('sin nivel de alumno manda el escenario (no se inventa banda)', () {
      final plan = ScenarioBand.plan(
        learnerLevel: '',
        scenarioLevel: 'B1',
        totalGoals: 4,
      );

      expect(plan.effectiveLevel, 'B1');
      expect(plan.changesBand, isFalse);
      expect(plan.limitsGoals, isFalse);
    });

    test('nunca deja un presupuesto de un solo objetivo', () {
      final plan = ScenarioBand.plan(
        learnerLevel: 'PRE-A1',
        scenarioLevel: 'B2',
        totalGoals: 4,
      );

      expect(plan.goalBudget, greaterThanOrEqualTo(ScenarioBand.minGoalBudget));
    });
  });

  group('TutorPromptBuilder — banda adaptada', () {
    test('declara la banda real y no empuja por encima del alumno', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          cefrLevel: 'A1',
          scenarioLevel: 'B1',
        ),
      );

      expect(prompt, contains('The student level is A1'));
      expect(prompt, contains('LEVEL ADAPTATION'));
      expect(prompt, contains('written for CEFR B1'));
      expect(prompt, contains('Do not push the student above A1'));
    });

    test('sin diferencia de banda no añade ruido al prompt', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          cefrLevel: 'B1',
          scenarioLevel: 'B1',
        ),
      );

      expect(prompt, isNot(contains('LEVEL ADAPTATION')));
    });
  });
}
