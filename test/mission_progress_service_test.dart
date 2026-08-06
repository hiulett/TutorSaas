import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/mission_progress_service.dart';

void main() {
  group('MissionProgressService.lessonProgress', () {
    test('Caso 1 — 0/5 objetivos → 0%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 0,
          totalGoals: 5,
        ),
        0.0,
      );
    });

    test('Caso 2 — 1/5 objetivos → 20%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 1,
          totalGoals: 5,
        ),
        0.2,
      );
    });

    test('Caso 3 — 2/5 objetivos → 40%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 2,
          totalGoals: 5,
        ),
        0.4,
      );
    });

    test('Caso 4 — 3/5 objetivos → 60%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 3,
          totalGoals: 5,
        ),
        0.6,
      );
    });

    test('Caso 5 — 4/5 objetivos → 80%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 4,
          totalGoals: 5,
        ),
        0.8,
      );
    });

    test('Caso 6 — 5/5 objetivos → 100%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 5,
          totalGoals: 5,
        ),
        1.0,
      );
    });

    test('Sin objetivos totales → 0% (evita división por cero)', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 0,
          totalGoals: 0,
        ),
        0.0,
      );
    });

    test('Más completados que totales → clamp a 100%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: 7,
          totalGoals: 5,
        ),
        1.0,
      );
    });

    test('Completados negativos → clamp a 0%', () {
      expect(
        MissionProgressService.lessonProgress(
          completedGoals: -1,
          totalGoals: 5,
        ),
        0.0,
      );
    });
  });

  group('MissionProgressService.countCompletedGoals', () {
    test('Cuenta objetivos true en el estado en memoria', () {
      expect(
        MissionProgressService.countCompletedGoals({
          'g1': true,
          'g2': true,
          'g3': false,
          'g4': false,
          'g5': false,
        }),
        2,
      );
    });

    test('Mapa vacío → 0', () {
      expect(MissionProgressService.countCompletedGoals({}), 0);
    });
  });

  group('MissionProgressService.completedGoalsForScenario', () {
    final rows = [
      {'scenario_id': 'a1_greetings', 'goal_id': 'g1', 'is_completed': true},
      {'scenario_id': 'a1_greetings', 'goal_id': 'g2', 'is_completed': true},
      {'scenario_id': 'a1_greetings', 'goal_id': 'g3', 'is_completed': false},
      {'scenario_id': 'a1_greetings', 'goal_id': 'g4', 'is_completed': false},
      {'scenario_id': 'a1_greetings', 'goal_id': 'g5', 'is_completed': false},
      {'scenario_id': 'a1_other', 'goal_id': 'g1', 'is_completed': true},
    ];

    test('2/5 objetivos de a1_greetings → 2 (ignora filas de otras misiones)', () {
      expect(
        MissionProgressService.completedGoalsForScenario(rows, 'a1_greetings'),
        2,
      );
    });

    test('Misión sin filas → 0', () {
      expect(
        MissionProgressService.completedGoalsForScenario(rows, 'a2_unknown'),
        0,
      );
    });

    test('Solo cuenta is_completed == true', () {
      expect(
        MissionProgressService.completedGoalsForScenario(rows, 'a1_other'),
        1,
      );
    });
  });
}
