import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

void main() {
  group('LessonCatalog Tests', () {
    test('getLessonById is null-safe and returns safe fallback', () {
      final lesson = LessonCatalog.getLessonById(null, title: null);
      expect(lesson, isNotNull);
      expect(lesson!.id, isNotEmpty);
    });

    test('currículo oficial: 20 lecciones por nivel y 140 en total', () {
      final catalog = LessonCatalog.catalog;
      expect(catalog.length, 140);

      final byLevel = <String, int>{};
      for (final l in catalog) {
        byLevel[l.level.toUpperCase()] = (byLevel[l.level.toUpperCase()] ?? 0) + 1;
      }
      for (final lv in ['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
        expect(byLevel[lv], 20, reason: 'Nivel $lv debe tener 20 lecciones');
      }
    });

    test('currículo oficial: sin IDs duplicados y sin títulos duplicados por nivel', () {
      final ids = LessonCatalog.catalog.map((l) => l.id).toSet();
      expect(ids.length, 140, reason: 'IDs de lección deben ser únicos');

      for (final lv in ['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
        final titles = LessonCatalog.catalog
            .where((l) => l.level.toUpperCase() == lv)
            .map((l) => l.title.toLowerCase());
        expect(titles.toSet().length, 20, reason: 'Títulos únicos por nivel $lv');
      }
    });

    test('todas las lecciones tienen goals y usefulPhrases', () {
      for (final l in LessonCatalog.catalog) {
        expect(l.goals, isNotEmpty, reason: '${l.id} sin goals');
        expect(l.goals.length >= 3, isTrue, reason: '${l.id} con <3 goals');
        expect(l.usefulPhrases, isNotEmpty, reason: '${l.id} sin usefulPhrases');
        expect(l.mainObjective, isNotEmpty, reason: '${l.id} sin mainObjective');
        expect(l.initialAssistantMessage, isNotEmpty, reason: '${l.id} sin initialAssistantMessage');
      }
    });

    test('getLessonById returns exact match by ID', () {
      final lesson = LessonCatalog.getLessonById('a1_ordering_coffee_at_a_cafe');
      expect(lesson, isNotNull);
      expect(lesson!.id, 'a1_ordering_coffee_at_a_cafe');
      expect(lesson.level, 'A1');
    });

    test('getLessonById returns exact match by Title', () {
      final lesson = LessonCatalog.getLessonById(null, title: 'Ordering Coffee at a Cafe');
      expect(lesson, isNotNull);
      expect(lesson!.level, 'A1');
    });

    test('C2 lessons are populated and present', () {
      final c2 = LessonCatalog.catalog.where((l) => l.level == 'C2').toList();
      expect(c2.length, 20);
      for (final l in c2) {
        expect(l.goals, isNotEmpty);
        expect(l.mainObjective, isNotEmpty);
      }
    });

    test('PRE-A1 lessons are populated and present', () {
      final preA1 = LessonCatalog.catalog
          .where((l) => l.level.toUpperCase() == 'PRE-A1')
          .toList();
      expect(preA1.length, 20);
      for (final l in preA1) {
        expect(l.goals.length >= 3, isTrue, reason: '${l.id} con <3 goals');
        expect(l.usefulPhrases, isNotEmpty);
        expect(l.mainObjective, isNotEmpty);
        expect(l.initialAssistantMessage, isNotEmpty);
      }
    });

    test('LessonData targetLanguageCode defaults to en', () {
      final lesson = LessonCatalog.getLessonById('a1_ordering_coffee_at_a_cafe');
      expect(lesson!.targetLanguageCode, 'en');
    });

    test('levelAppropriateOpening grades the initial message by CEFR level', () {
      final a1 = LessonCatalog.levelAppropriateOpening('A1', 'Greetings');
      final b1 = LessonCatalog.levelAppropriateOpening('B1', 'Tech');
      final c2 = LessonCatalog.levelAppropriateOpening('C2', 'Debate');

      expect(a1.toLowerCase(), contains('what is your name'));
      expect(a1.toLowerCase(), isNot(contains('sophisticated')));
      expect(b1.toLowerCase(), contains('opinion'));
      expect(c2.toLowerCase(), contains('sophisticated'));
      expect(c2.toLowerCase(), isNot(contains('what is your name')));
    });

    test('levelAppropriateOpening handles multi-band and unknown levels', () {
      final multi = LessonCatalog.levelAppropriateOpening('A1-C2', 'Custom');
      final unknown = LessonCatalog.levelAppropriateOpening('ZZ', 'X');
      expect(multi, isNotEmpty);
      expect(unknown, isNotEmpty);
    });
  });
}
