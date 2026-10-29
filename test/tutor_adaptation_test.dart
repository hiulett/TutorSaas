import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/tutor_adaptation.dart';

/// P-40 (#125) — Rachas de acierto/fallo que mueven la dificultad del tutor.
///
/// El ajuste no cuesta ninguna llamada al modelo: se deriva de las correcciones
/// del turno y de las metas ya evaluadas.
void main() {
  TutorTurnOutcome struggle({int corrections = 1}) =>
      TutorTurnOutcome(corrections: corrections, wordCount: 12);
  TutorTurnOutcome clean({int wordCount = 10, int goals = 0}) =>
      TutorTurnOutcome(
        corrections: 0,
        wordCount: wordCount,
        goalsCompleted: goals,
      );

  group('TutorAdaptationTracker', () {
    test('arranca neutro y umbrales configurados', () {
      final tracker = TutorAdaptationTracker();
      expect(tracker.adjustment, TutorDifficultyAdjustment.steady);
      expect(tracker.struggleStreak, 0);
      expect(tracker.successStreak, 0);
      expect(TutorAdaptationTracker.struggleThreshold, 2);
      expect(TutorAdaptationTracker.stretchThreshold, 3);
    });

    test('un fallo aislado no simplifica; dos seguidos sí', () {
      final tracker = TutorAdaptationTracker();

      expect(tracker.record(struggle()), TutorDifficultyAdjustment.steady);
      expect(tracker.record(struggle()), TutorDifficultyAdjustment.simplify);
      expect(tracker.struggleStreak, 2);
    });

    test('tres aciertos seguidos suben el listón', () {
      final tracker = TutorAdaptationTracker();

      tracker.record(clean());
      tracker.record(clean(goals: 1));
      expect(tracker.adjustment, TutorDifficultyAdjustment.steady);
      tracker.record(clean());
      expect(tracker.adjustment, TutorDifficultyAdjustment.stretch);
      expect(tracker.successStreak, 3);
    });

    test('un acierto corta la racha de fallos', () {
      final tracker = TutorAdaptationTracker();

      tracker.record(struggle());
      tracker.record(struggle());
      expect(tracker.adjustment, TutorDifficultyAdjustment.simplify);

      tracker.record(clean());
      expect(tracker.struggleStreak, 0);
      expect(tracker.adjustment, TutorDifficultyAdjustment.steady);
    });

    test('un fallo corta la racha de aciertos', () {
      final tracker = TutorAdaptationTracker();

      tracker.record(clean());
      tracker.record(clean());
      tracker.record(clean());
      expect(tracker.adjustment, TutorDifficultyAdjustment.stretch);

      tracker.record(struggle(corrections: 2));
      expect(tracker.successStreak, 0);
      expect(tracker.adjustment, TutorDifficultyAdjustment.steady);
    });

    test('un turno limpio pero vacío no premia ni castiga', () {
      final tracker = TutorAdaptationTracker();

      tracker.record(clean());
      tracker.record(clean());
      tracker.record(clean(wordCount: 1));
      expect(tracker.successStreak, 2);
      expect(tracker.struggleStreak, 0);
      expect(tracker.adjustment, TutorDifficultyAdjustment.steady);

      tracker.record(struggle());
      tracker.record(clean(wordCount: 1));
      expect(tracker.struggleStreak, 1);
    });

    test('reset limpia las rachas al abrir otra sesión', () {
      final tracker = TutorAdaptationTracker();
      tracker.record(struggle());
      tracker.record(struggle());

      tracker.reset();

      expect(tracker.adjustment, TutorDifficultyAdjustment.steady);
      expect(tracker.struggleStreak, 0);
      expect(tracker.successStreak, 0);
    });
  });

  group('TutorTurnOutcome', () {
    test('una corrección ya es señal de fallo', () {
      expect(
        const TutorTurnOutcome(corrections: 1, wordCount: 30).isStruggle,
        isTrue,
      );
    });

    test('turno limpio y largo es éxito', () {
      const outcome = TutorTurnOutcome(corrections: 0, wordCount: 9);
      expect(outcome.isSuccess, isTrue);
      expect(outcome.isStruggle, isFalse);
    });

    test('meta cumplida con dos palabras también cuenta como éxito', () {
      const outcome = TutorTurnOutcome(
        corrections: 0,
        wordCount: 2,
        goalsCompleted: 1,
      );
      expect(outcome.isSuccess, isTrue);
    });

    test('turno limpio de una palabra es neutro', () {
      const outcome = TutorTurnOutcome(corrections: 0, wordCount: 1);
      expect(outcome.isSuccess, isFalse);
      expect(outcome.isStruggle, isFalse);
    });
  });
}
