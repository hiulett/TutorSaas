import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';
import 'package:tutorsaas/features/dashboard/domain/models/lesson_unlock_service.dart';

/// QA — Lógica centralizada de desbloqueo de lecciones (Progression).
///
/// Regla: si el usuario fue clasificado en nivel N, los niveles anteriores
/// quedan desbloqueados (unlockedByOracle), del nivel actual solo la primera
/// lección disponible (nextAvailable) y el resto secuencial (locked), y los
/// niveles superiores bloqueados (locked).
void main() {
  LessonData make(String id, String level) => LessonData(
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
        goals: const [],
        usefulPhrases: const [],
      );

  // Catálogo de prueba con 2 lecciones por nivel A1 y B1.
  final catalog = <LessonData>[
    make('a1_one', 'A1'),
    make('a1_two', 'A1'),
    make('b1_one', 'B1'),
    make('b1_two', 'B1'),
  ];

  LessonUnlockState classify(LessonData l, String cefr,
          [List<Map<String, dynamic>> done = const []]) =>
      LessonUnlockService.classify(
        lesson: l,
        userCefr: cefr,
        completedLessons: done,
        catalog: catalog,
      );

  group('Usuario B1 — sin historial', () {
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

  group('Usuario B1 — con historial parcial', () {
    final doneB1One = [
      {'scenario_id': 'b1_one', 'score': 85},
    ];

    test('Completada → completedByPlayer', () {
      expect(classify(catalog[2], 'B1', doneB1One),
          LessonUnlockState.completedByPlayer);
    });

    test('Segunda de B1 disponible tras completar la primera', () {
      expect(classify(catalog[3], 'B1', doneB1One),
          LessonUnlockState.nextAvailable);
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
