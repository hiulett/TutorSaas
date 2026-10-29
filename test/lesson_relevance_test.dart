import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/services/lesson_relevance.dart';

/// P-40 (#125) — La selección de lecciones responde a los intereses del alumno.
void main() {
  Map<String, dynamic> scenario({
    required String title,
    String category = '',
    String description = '',
    int minutes = 15,
  }) => {
    'title': title,
    'category': category,
    'description': description,
    'estimated_minutes': minutes,
  };

  group('LessonRelevance.interestHits', () {
    test('cuenta coincidencias en categoría, título y descripción', () {
      final lesson = scenario(
        title: 'Booking a hotel room',
        category: 'travel',
        description: 'Practise travel vocabulary',
      );

      expect(LessonRelevance.interestHits(lesson, ['travel']), 1);
      expect(LessonRelevance.interestHits(lesson, ['travel', 'hotel']), 2);
      expect(LessonRelevance.interestHits(lesson, ['hotel']), 1);
      expect(LessonRelevance.interestHits(lesson, ['music']), 0);
      expect(LessonRelevance.interestHits(lesson, const []), 0);
    });

    test('ignora intereses vacíos y mayúsculas', () {
      final lesson = scenario(title: 'Job interview', category: 'career');

      expect(LessonRelevance.interestHits(lesson, ['CAREER']), 1);
      expect(LessonRelevance.interestHits(lesson, ['  ', '']), 0);
    });
  });

  group('LessonRelevance.sortForUser', () {
    test('los intereses mandan sobre la duración', () {
      final lessons = [
        scenario(title: 'Airport check-in', category: 'travel', minutes: 15),
        scenario(title: 'Standup meeting', category: 'work', minutes: 10),
        scenario(title: 'Music festival', category: 'music', minutes: 25),
      ];

      LessonRelevance.sortForUser(
        lessons,
        interests: const ['music', 'travel'],
        dailyGoalMinutes: 15,
      );

      final titles = lessons.map((l) => l['title']).toList();
      expect(titles.first, 'Airport check-in');
      expect(titles.last, 'Standup meeting');
    });

    test('sin intereses ordena por cercanía a la meta diaria', () {
      final lessons = [
        scenario(title: 'Long', minutes: 45),
        scenario(title: 'Short', minutes: 5),
        scenario(title: 'Goal', minutes: 15),
      ];

      LessonRelevance.sortForUser(
        lessons,
        interests: const [],
        dailyGoalMinutes: 15,
      );

      expect(lessons.map((l) => l['title']).toList(), [
        'Goal',
        'Short',
        'Long',
      ]);
    });

    test('empate total se rompe por título (determinista)', () {
      final one = [scenario(title: 'Beta'), scenario(title: 'Alpha')];
      final other = [scenario(title: 'Alpha'), scenario(title: 'Beta')];

      LessonRelevance.sortForUser(
        one,
        interests: const [],
        dailyGoalMinutes: 15,
      );
      LessonRelevance.sortForUser(
        other,
        interests: const [],
        dailyGoalMinutes: 15,
      );

      expect(one.map((l) => l['title']).toList(), ['Alpha', 'Beta']);
      expect(other.map((l) => l['title']).toList(), ['Alpha', 'Beta']);
    });
  });
}
