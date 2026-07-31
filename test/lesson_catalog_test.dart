import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

void main() {
  group('LessonCatalog Tests', () {
    test('getLessonById is null-safe and returns safe fallback', () {
      final lesson = LessonCatalog.getLessonById(null, title: null);
      expect(lesson, isNotNull);
      expect(lesson!.id, isNotEmpty);
    });

    test('getLessonById returns exact match by ID', () {
      final lesson = LessonCatalog.getLessonById('a1_greetings');
      expect(lesson, isNotNull);
      expect(lesson!.id, 'a1_greetings');
      expect(lesson.title, 'Saludos y Presentaciones');
    });

    test('getLessonById returns exact match by Title', () {
      final lesson = LessonCatalog.getLessonById(null, title: 'Saludos y Presentaciones');
      expect(lesson, isNotNull);
      expect(lesson!.id, 'a1_greetings');
    });

    test('C2 lessons are populated and present', () {
      final debate = LessonCatalog.getLessonById('c2_academic_debate');
      final critique = LessonCatalog.getLessonById('c2_literary_critique');
      final crisis = LessonCatalog.getLessonById('c2_corporate_crisis');
      final philosophy = LessonCatalog.getLessonById('c2_philosophical_discourse');

      expect(debate, isNotNull);
      expect(debate!.level, 'C2');

      expect(critique, isNotNull);
      expect(critique!.level, 'C2');

      expect(crisis, isNotNull);
      expect(crisis!.level, 'C2');

      expect(philosophy, isNotNull);
      expect(philosophy!.level, 'C2');
    });

    test('LessonData targetLanguageCode defaults to en', () {
      final lesson = LessonCatalog.getLessonById('a1_greetings');
      expect(lesson!.targetLanguageCode, 'en');
    });
  });
}
