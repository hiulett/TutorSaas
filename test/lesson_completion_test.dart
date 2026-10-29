import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';
import 'package:tutorsaas/features/dashboard/domain/models/lesson_completion.dart';
import 'package:tutorsaas/features/dashboard/domain/models/lesson_halo.dart';
import 'package:tutorsaas/features/dashboard/domain/models/lesson_unlock_service.dart';

/// P-38 (#123) — Una sola regla de "lección completada".
///
/// Desbloqueo (`LessonUnlockService`), halo (`LessonHalo`) y estrellas
/// (`LessonCompletion.stars`) deben coincidir siempre. El servidor replica la
/// regla en `public.lesson_completion_passed(completed, total)`.
void main() {
  LessonData makeLesson(String id, {int goals = 3}) => LessonData(
    id: id,
    title: id,
    description: 'd',
    level: 'A1',
    category: 'practice',
    interest: 'general',
    difficulty: 1,
    iconKey: 'school',
    mainObjective: 'obj',
    scenarioContext: 'c',
    assistantRole: 'r',
    userRole: 'u',
    initialAssistantMessage: 'hi',
    goals: List.generate(
      goals,
      (i) => ScenarioGoalItem(
        id: 'g${i + 1}',
        text: 'g${i + 1}',
        keywords: const ['x'],
      ),
    ),
    usefulPhrases: const [],
  );

  List<Map<String, dynamic>> doneGoals(String scenarioId, int n) =>
      List.generate(
        n,
        (i) => {
          'scenario_id': scenarioId,
          'goal_id': 'g${i + 1}',
          'is_completed': true,
        },
      );

  group('Regla canónica (paridad app ↔ servidor)', () {
    // Misma tabla que verifican las aserciones SQL de la migración
    // `single_lesson_completion_criterion`.
    const cases = <List<int>>[
      [0, 0, 1],
      [0, 3, 0],
      [1, 3, 0],
      [2, 3, 1],
      [2, 4, 0],
      [3, 4, 1],
      [4, 4, 1],
      [7, 10, 0],
      [8, 10, 1],
      [5, 7, 0],
      [6, 7, 1],
    ];

    for (final c in cases) {
      final completed = c[0];
      final total = c[1];
      final expected = c[2] == 1;
      test('$completed/$total → ${expected ? "superada" : "no superada"}', () {
        expect(LessonCompletion.isPassed(completed, total), expected);
        expect(LessonUnlockService.meetsThreshold(completed, total), expected);
      });
    }

    test('el umbral publicado sigue siendo 75 %', () {
      expect(LessonCompletion.passThreshold, 0.75);
      expect(LessonUnlockService.passThreshold, LessonCompletion.passThreshold);
      expect(LessonHalo.passThreshold, LessonCompletion.passThreshold);
    });

    test('meetsThreshold y isPassed coinciden en todo el espacio 0..12', () {
      for (var total = 0; total <= 12; total++) {
        for (var done = 0; done <= total; done++) {
          expect(
            LessonUnlockService.meetsThreshold(done, total),
            LessonCompletion.isPassed(done, total),
            reason: '$done/$total',
          );
        }
      }
    });
  });

  group('Halo coherente con el desbloqueo', () {
    test('halo superado ⇔ la lección desbloquea la siguiente', () {
      for (var total = 1; total <= 12; total++) {
        for (var done = 0; done <= total; done++) {
          final passed = LessonCompletion.isPassed(done, total);
          final tier = LessonHalo.tierForCounts(done, total);

          if (done == 0) {
            expect(tier, LessonHaloTier.locked, reason: '0/$total');
            continue;
          }
          if (passed) {
            expect(
              tier == LessonHaloTier.passed || tier == LessonHaloTier.mastered,
              isTrue,
              reason: '$done/$total debe pintarse superada (tier=$tier)',
            );
            expect(
              LessonHalo.colorForCounts(done, total),
              isNot(AppColors.manaCyan),
              reason: '$done/$total no puede quedar en color "en progreso"',
            );
            expect(
              LessonHalo.intensityForCounts(done, total),
              greaterThanOrEqualTo(0.50),
              reason: '$done/$total debe brillar como superada',
            );
          } else {
            expect(tier, LessonHaloTier.inProgress, reason: '$done/$total');
            expect(
              LessonHalo.colorForCounts(done, total),
              AppColors.manaCyan,
              reason: '$done/$total',
            );
          }
        }
      }
    });

    test('2/3 (67 %) es superada y el halo no la muestra en progreso', () {
      expect(LessonCompletion.isPassed(2, 3), isTrue);
      expect(LessonHalo.tierForCounts(2, 3), LessonHaloTier.passed);
      expect(LessonHalo.colorForCounts(2, 3), AppColors.runeViolet);
      // El ratio real sigue siendo 2/3 para la barra de progreso.
      expect(LessonHalo.displayRatio(2, 3), LessonHalo.passThreshold);
      expect(LessonCompletion.ratio(2, 3), closeTo(0.6667, 0.001));
    });

    test('maestría solo al 100 %', () {
      for (var total = 1; total <= 12; total++) {
        for (var done = 0; done <= total; done++) {
          expect(
            LessonHalo.tierForCounts(done, total) == LessonHaloTier.mastered,
            LessonCompletion.isMastered(done, total),
            reason: '$done/$total',
          );
        }
      }
    });

    test('sin metas → superada y maestría', () {
      expect(LessonCompletion.isPassed(0, 0), isTrue);
      expect(LessonCompletion.isMastered(0, 0), isTrue);
      expect(LessonHalo.tierForCounts(0, 0), LessonHaloTier.mastered);
    });
  });

  group('Estrellas derivadas de la misma regla', () {
    test('0 estrellas ⇔ no superada', () {
      for (var total = 1; total <= 12; total++) {
        for (var done = 0; done <= total; done++) {
          final stars = LessonCompletion.stars(
            completed: done,
            total: total,
            phrasesUsed: 0,
            phrasesTotal: 4,
          );
          expect(
            stars > 0,
            LessonCompletion.isPassed(done, total),
            reason: '$done/$total',
          );
        }
      }
    });

    test('escala 1–3 por uso de frases', () {
      expect(
        LessonCompletion.stars(
          completed: 2,
          total: 3,
          phrasesUsed: 0,
          phrasesTotal: 4,
        ),
        1,
      );
      expect(
        LessonCompletion.stars(
          completed: 2,
          total: 3,
          phrasesUsed: 2,
          phrasesTotal: 4,
        ),
        2,
      );
      expect(
        LessonCompletion.stars(
          completed: 3,
          total: 3,
          phrasesUsed: 4,
          phrasesTotal: 4,
        ),
        3,
      );
      expect(
        LessonCompletion.stars(
          completed: 3,
          total: 3,
          phrasesUsed: 0,
          phrasesTotal: 0,
        ),
        1,
        reason: 'sin frases declaradas no hay bonus',
      );
    });
  });

  group('Desbloqueo con la regla única', () {
    final catalog = <LessonData>[makeLesson('a1_one'), makeLesson('a1_two')];

    test('2/3 desbloquea la siguiente lección', () {
      final rows = doneGoals('a1_one', 2);
      expect(
        LessonUnlockService.classify(
          lesson: catalog[0],
          userCefr: 'A1',
          goalRows: rows,
          catalog: catalog,
        ),
        LessonUnlockState.completedByPlayer,
      );
      expect(
        LessonUnlockService.classify(
          lesson: catalog[1],
          userCefr: 'A1',
          goalRows: rows,
          catalog: catalog,
        ),
        LessonUnlockState.nextAvailable,
      );
    });

    test('1/3 no desbloquea la siguiente', () {
      final rows = doneGoals('a1_one', 1);
      expect(
        LessonUnlockService.classify(
          lesson: catalog[0],
          userCefr: 'A1',
          goalRows: rows,
          catalog: catalog,
        ),
        isNot(LessonUnlockState.completedByPlayer),
      );
      expect(
        LessonUnlockService.classify(
          lesson: catalog[1],
          userCefr: 'A1',
          goalRows: rows,
          catalog: catalog,
        ),
        LessonUnlockState.locked,
      );
    });
  });
}
