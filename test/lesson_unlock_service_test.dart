import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';
import 'package:tutorsaas/features/dashboard/domain/models/lesson_unlock_service.dart';

/// QA — Lógica centralizada de desbloqueo de lecciones (Progression).
///
/// Regla: si el usuario fue clasificado en nivel N, los niveles anteriores
/// quedan desbloqueados (unlockedByOracle), del nivel actual solo la primera
/// lección disponible (nextAvailable) y el resto secuencial (locked), y los
/// niveles superiores bloqueados (locked).
///
/// Una lección se considera "superada" (desbloquea la siguiente) cuando cumple
/// `LessonUnlockService.meetsThreshold` (issue #17): todas las metas, o como
/// máximo una fallada en lecciones de 4 metas o menos, o el 75 % en lecciones
/// largas.
void main() {
  LessonData make(String id, String level, {int goals = 4}) => LessonData(
        id: id,
        title: id,
        description: 'd',
        level: level,
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
            examplePhrase: 'x',
          ),
        ),
        usefulPhrases: const [],
      );

  /// Filas de `user_scenario_goals` con las primeras [n] metas completadas.
  List<Map<String, dynamic>> doneGoals(String scenarioId, int n) =>
      List.generate(
        n,
        (i) => {
          'scenario_id': scenarioId,
          'goal_id': 'g${i + 1}',
          'is_completed': true,
        },
      );

  // Catálogo de prueba con 2 lecciones por nivel A1 y B1 (4 metas c/u).
  final catalog = <LessonData>[
    make('a1_one', 'A1'),
    make('a1_two', 'A1'),
    make('b1_one', 'B1'),
    make('b1_two', 'B1'),
  ];

  LessonUnlockState classify(LessonData l, String cefr,
          [List<Map<String, dynamic>> goalRows = const []]) =>
      LessonUnlockService.classify(
        lesson: l,
        userCefr: cefr,
        goalRows: goalRows,
        catalog: catalog,
      );

  group('Usuario B1 — sin progreso', () {
    test('A1 lecciones → unlockedByOracle', () {
      expect(classify(catalog[0], 'B1'), LessonUnlockState.unlockedByOracle);
      expect(classify(catalog[1], 'B1'), LessonUnlockState.unlockedByOracle);
    });

    test('Primera lección de B1 → nextAvailable', () {
      expect(classify(catalog[2], 'B1'), LessonUnlockState.nextAvailable);
    });

    test('Segunda lección de B1 → locked (secuencial)', () {
      expect(classify(catalog[3], 'B1'), LessonUnlockState.locked);
    });
  });

  group('Usuario B1 — progreso de metas', () {
    test('4/4 metas → completedByPlayer y desbloquea la siguiente', () {
      final done = doneGoals('b1_one', 4);
      expect(classify(catalog[2], 'B1', done),
          LessonUnlockState.completedByPlayer);
      expect(classify(catalog[3], 'B1', done),
          LessonUnlockState.nextAvailable);
    });

    test('3/4 metas → se supera (issue #17)', () {
      final done = doneGoals('b1_one', 3);
      expect(classify(catalog[2], 'B1', done),
          LessonUnlockState.completedByPlayer);
      expect(classify(catalog[3], 'B1', done),
          LessonUnlockState.nextAvailable);
    });

    test('2/4 metas → NO se supera', () {
      final done = doneGoals('b1_one', 2);
      expect(classify(catalog[2], 'B1', done),
          isNot(LessonUnlockState.completedByPlayer));
      expect(classify(catalog[3], 'B1', done), LessonUnlockState.locked);
    });

    test('2/3 metas → se supera (una meta fallada de tres)', () {
      final short = make('s_one', 'B1', goals: 3);
      final rows = doneGoals('s_one', 2);
      expect(
        LessonUnlockService.classify(
          lesson: short,
          userCefr: 'B1',
          goalRows: rows,
          catalog: [short],
        ),
        LessonUnlockState.completedByPlayer,
      );
    });

    test('1/3 metas → NO se supera', () {
      final short = make('s_two', 'B1', goals: 3);
      final rows = doneGoals('s_two', 1);
      expect(
        LessonUnlockService.classify(
          lesson: short,
          userCefr: 'B1',
          goalRows: rows,
          catalog: [short],
        ),
        isNot(LessonUnlockState.completedByPlayer),
      );
    });

    test('Límite en lecciones largas: 8/10 supera, 7/10 no', () {
      final tenGoals = make('c_one', 'B1', goals: 10);
      final c80 = LessonUnlockService.completionRatio(
        doneGoals('c_one', 8),
        tenGoals,
      );
      final c70 = LessonUnlockService.completionRatio(
        doneGoals('c_one', 7),
        tenGoals,
      );
      expect(c80, closeTo(0.80, 0.0001));
      expect(c70, closeTo(0.70, 0.0001));
      expect(c80 >= LessonUnlockService.passThreshold, isTrue);
      expect(c70 >= LessonUnlockService.passThreshold, isFalse);
    });

    test('meetsThreshold cubre los casos límite', () {
      expect(LessonUnlockService.meetsThreshold(4, 4), isTrue);
      expect(LessonUnlockService.meetsThreshold(3, 4), isTrue);
      expect(LessonUnlockService.meetsThreshold(2, 4), isFalse);
      expect(LessonUnlockService.meetsThreshold(2, 3), isTrue);
      expect(LessonUnlockService.meetsThreshold(1, 3), isFalse);
      expect(LessonUnlockService.meetsThreshold(8, 10), isTrue);
      expect(LessonUnlockService.meetsThreshold(7, 10), isFalse);
      expect(LessonUnlockService.meetsThreshold(0, 0), isTrue);
    });

    test('Lección sin metas → se considera superada', () {
      final noGoals = make('d_one', 'B1', goals: 0);
      expect(LessonUnlockService.completionRatio(const [], noGoals), 1.0);
    });
  });

  group('Usuario A1', () {
    test('Primera de A1 → nextAvailable', () {
      expect(classify(catalog[0], 'A1'), LessonUnlockState.nextAvailable);
    });
    test('Segunda de A1 → locked', () {
      expect(classify(catalog[1], 'A1'), LessonUnlockState.locked);
    });
    test('B1 → locked', () {
      expect(classify(catalog[2], 'A1'), LessonUnlockState.locked);
    });
  });

  group('Usuario A2', () {
    test('A1 → unlockedByOracle', () {
      expect(classify(catalog[0], 'A2'), LessonUnlockState.unlockedByOracle);
      expect(classify(catalog[1], 'A2'), LessonUnlockState.unlockedByOracle);
    });
    test('B1 → locked', () {
      expect(classify(catalog[2], 'A2'), LessonUnlockState.locked);
    });
  });
}
