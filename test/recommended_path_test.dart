import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';
import 'package:tutorsaas/features/dashboard/domain/models/recommended_path.dart';
import 'package:tutorsaas/features/dashboard/domain/services/path_order.dart';

/// P-40a (#220) — La Ruta consume la ruta recomendada del servidor y cae al
/// orden del catálogo cuando no hay datos.
void main() {
  LessonData lesson(String id, String title, {String level = 'A1'}) =>
      LessonData(
        id: id,
        title: title,
        description: 'desc',
        level: level,
        category: 'daily',
        interest: 'daily',
        difficulty: 1,
        iconKey: 'school',
        mainObjective: 'objective',
        scenarioContext: 'context',
        assistantRole: 'Tutor',
        userRole: 'Student',
        initialAssistantMessage: 'Hello',
        goals: const [],
        usefulPhrases: const [],
      );

  Map<String, dynamic> step({
    required int position,
    String title = 'Ordering Coffee',
    String level = 'A1',
    String? lessonKey,
    String scenarioId = '00000000-0000-0000-0000-000000000001',
    String reason = 'next',
    int minutes = 10,
  }) => {
    'scenario_id': scenarioId,
    'lesson_key': lessonKey,
    'title': title,
    'level': level,
    'category': 'daily',
    'estimated_minutes': minutes,
    'position': position,
    'reason': reason,
  };

  group('RecommendedPathStep.listFromRpc', () {
    test('ordena por position y tolera filas incompletas', () {
      final steps = RecommendedPathStep.listFromRpc([
        step(position: 2, title: 'Second', lessonKey: 'a1_second'),
        {'scenario_id': 'x'},
        step(position: 1, title: 'First', lessonKey: 'a1_first'),
      ]);

      expect(steps.length, 2);
      expect(steps.first.title, 'First');
      expect(steps.first.position, 1);
      expect(steps.last.title, 'Second');
    });

    test('mapea los códigos de motivo y usa el id si falta lesson_key', () {
      final steps = RecommendedPathStep.listFromRpc([
        step(position: 1, reason: 'interest'),
        step(position: 2, reason: 'recurring_error', lessonKey: 'a1_x'),
        step(position: 3, reason: 'review'),
        step(position: 4, reason: 'otro'),
      ]);

      expect(steps[0].reason, RecommendedPathReason.interest);
      expect(steps[1].reason, RecommendedPathReason.recurringError);
      expect(steps[2].reason, RecommendedPathReason.review);
      expect(steps[3].reason, RecommendedPathReason.next);
      expect(steps[0].key, '00000000-0000-0000-0000-000000000001');
      expect(steps[1].key, 'a1_x');
    });

    test('acepta pasos sin uuid cuando traen lesson_key (B2/C1)', () {
      final steps = RecommendedPathStep.listFromRpc([
        step(position: 1, title: 'C1 only', lessonKey: 'c1_x')
          ..['scenario_id'] = null,
      ]);

      expect(steps.length, 1);
      expect(steps.first.scenarioId, isEmpty);
      expect(steps.first.key, 'c1_x');
    });

    test('una respuesta que no es lista devuelve vacío', () {
      expect(RecommendedPathStep.listFromRpc(null), isEmpty);
      expect(RecommendedPathStep.listFromRpc({'x': 1}), isEmpty);
    });
  });

  group('PathOrder.apply', () {
    test('ordena por lesson_key', () {
      final lessons = [
        lesson('a1_c', 'Third'),
        lesson('a1_a', 'First'),
        lesson('a1_b', 'Second'),
      ];
      final path = RecommendedPathStep.listFromRpc([
        step(position: 1, title: 'First', lessonKey: 'a1_a'),
        step(position: 2, title: 'Second', lessonKey: 'a1_b'),
        step(position: 3, title: 'Third', lessonKey: 'a1_c'),
      ]);

      final ordered = PathOrder.apply(lessons, path);

      expect(ordered.map((l) => l.id), ['a1_a', 'a1_b', 'a1_c']);
    });

    test('cruza por nivel + título cuando el catálogo no tiene lesson_key', () {
      final lessons = [
        lesson('a1_local_b', 'B title'),
        lesson('a1_local_a', 'A title'),
      ];
      final path = RecommendedPathStep.listFromRpc([
        step(position: 1, title: 'B title', lessonKey: 'otro_id'),
        step(position: 2, title: 'A title', lessonKey: null),
      ]);

      final ordered = PathOrder.apply(lessons, path);

      expect(ordered.map((l) => l.title), ['B title', 'A title']);
    });

    test('sin ruta conserva el orden actual (fallback)', () {
      final lessons = [lesson('a1_c', 'Third'), lesson('a1_a', 'First')];

      expect(PathOrder.apply(lessons, const []), lessons);
    });

    test(
      'las lecciones no mencionadas quedan al final en su orden original',
      () {
        final lessons = [
          lesson('a1_x', 'Not in path'),
          lesson('a1_b', 'Second'),
          lesson('a1_y', 'Also not in path'),
        ];
        final path = RecommendedPathStep.listFromRpc([
          step(position: 1, title: 'Second', lessonKey: 'a1_b'),
        ]);

        final ordered = PathOrder.apply(lessons, path);

        expect(ordered.map((l) => l.id), ['a1_b', 'a1_x', 'a1_y']);
      },
    );

    test('una ruta de otra etapa no altera el orden', () {
      final lessons = [
        lesson('a2_b', 'B', level: 'A2'),
        lesson('a2_a', 'A', level: 'A2'),
      ];
      final path = RecommendedPathStep.listFromRpc([
        step(position: 1, title: 'B', level: 'B1', lessonKey: 'b1_b'),
      ]);

      expect(PathOrder.apply(lessons, path), lessons);
    });
  });

  group('PathOrder.firstRecommended', () {
    test('salta las lecciones superadas', () {
      final lessons = [lesson('a1_a', 'First'), lesson('a1_b', 'Second')];
      final path = RecommendedPathStep.listFromRpc([
        step(position: 1, title: 'First', lessonKey: 'a1_a', reason: 'review'),
        step(position: 2, title: 'Second', lessonKey: 'a1_b'),
      ]);

      final next = PathOrder.firstRecommended(
        lessons,
        path,
        isCompleted: (l) => l.id == 'a1_a',
      );

      expect(next?.id, 'a1_b');
    });

    test('sin ruta devuelve null para no inventar una recomendación', () {
      expect(
        PathOrder.firstRecommended([lesson('a1_a', 'First')], const []),
        isNull,
      );
    });
  });
}
