import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';
import 'package:tutorsaas/features/dashboard/domain/models/aura_system.dart';

/// QA — Sistema de Aura (System HUD).
///
/// Regla: el Aura no se tiene desde el principio. Se despierta al superar la
/// Etapa Básica (A1 + A2) o ser acreditado ≥ B1 (o rango ≥ C) por el Oráculo.
/// Una vez despierto, el poder acumula con el desarrollo de habilidades.
void main() {
  group('Acreditación del Oráculo', () {
    test('CEFR ≥ B1 → acreditado', () {
      expect(AuraSystem.accreditationLevelMet('B1'), isTrue);
      expect(AuraSystem.accreditationLevelMet('C2'), isTrue);
    });

    test('Rango inconsistente con CEFR no acredita (CEFR manda)', () {
      expect(AuraSystem.accreditationLevelMet('A1'), isFalse);
    });

    test('Niveles básicos sin acreditación → no acreditado', () {
      expect(AuraSystem.accreditationLevelMet('A1'), isFalse);
      expect(AuraSystem.accreditationLevelMet('A2'), isFalse);
    });

    test('Datos nulos/desconocidos → no acreditado', () {
      expect(AuraSystem.accreditationLevelMet(null), isFalse);
      expect(AuraSystem.accreditationLevelMet('XX'), isFalse);
    });
  });

  group('Etapa Básica (A1 + A2)', () {
    test('El catálogo tiene objetivos básicos para contar', () {
      final basic = AuraSystem.basicStageCounts(const []);
      expect(basic.total, greaterThan(0));
      expect(basic.done, 0);
    });

    test('Completar una lección A1 incrementa el progreso', () {
      final a1Lesson = LessonCatalog.catalog.firstWhere((l) => l.level == 'A1');
      final rows = a1Lesson.goals
          .map((g) => {
                'scenario_id': a1Lesson.id,
                'goal_id': g.id,
                'is_completed': true,
              })
          .toList();
      final basic = AuraSystem.basicStageCounts(rows);
      expect(basic.done, a1Lesson.goals.length);
      expect(basic.total, greaterThan(a1Lesson.goals.length));
    });

    test('Completar una lección PRE-A1 incrementa el progreso', () {
      final preA1Lesson = LessonCatalog.catalog
          .firstWhere((l) => l.level.toUpperCase() == 'PRE-A1');
      final rows = preA1Lesson.goals
          .map((g) => {
                'scenario_id': preA1Lesson.id,
                'goal_id': g.id,
                'is_completed': true,
              })
          .toList();
      final basic = AuraSystem.basicStageCounts(rows);
      expect(basic.done, preA1Lesson.goals.length);
      expect(basic.total, greaterThan(preA1Lesson.goals.length));
    });

    test('Solo cuenta objetivos completados', () {
      final a1Lesson = LessonCatalog.catalog.firstWhere((l) => l.level == 'A1');
      final rows = a1Lesson.goals
          .map((g) => {
                'scenario_id': a1Lesson.id,
                'goal_id': g.id,
                'is_completed': g.id == a1Lesson.goals.first.id,
              })
          .toList();
      final basic = AuraSystem.basicStageCounts(rows);
      expect(basic.done, 1);
    });

    test('Etapa completada solo al llegar al 100%', () {
      expect(AuraSystem.isBasicStageComplete(4, 5), isFalse);
      expect(AuraSystem.isBasicStageComplete(5, 5), isTrue);
      expect(AuraSystem.isBasicStageComplete(0, 0), isFalse);
    });
  });

  group('Poder acumulado y tiers', () {
    test('Sin habilidades → poder 0 → tier latente', () {
      // PRE-A1 → rango F (índice 0) → sin habilidades el poder es exactamente 0.
      final power = AuraSystem.computePower(
        radar: const {'fluency': 0, 'vocab': 0, 'phonetics': 0, 'grammar': 0, 'goals': 0},
        streak: 0,
        cefr: 'PRE-A1',
      );
      expect(power, 0.0);
      expect(AuraSystem.tierFor(power), AuraTier.latente);
    });

    test('Maestría total → tier abisal', () {
      final power = AuraSystem.computePower(
        radar: const {'fluency': 100, 'vocab': 100, 'phonetics': 100, 'grammar': 100, 'goals': 100},
        streak: 30,
        cefr: 'C2',
      );
      expect(power, greaterThan(0.9));
      expect(AuraSystem.tierFor(power), AuraTier.abisal);
    });

    test('La racha se satura a los 30 días', () {
      final a = AuraSystem.computePower(
        radar: const {'fluency': 50, 'vocab': 50, 'phonetics': 50, 'grammar': 50, 'goals': 50},
        streak: 60,
        cefr: 'A1',
      );
      final b = AuraSystem.computePower(
        radar: const {'fluency': 50, 'vocab': 50, 'phonetics': 50, 'grammar': 50, 'goals': 50},
        streak: 30,
        cefr: 'A1',
      );
      expect(a, b);
    });

    test('Un rango inconsistente no infla el poder (deriva del CEFR)', () {
      // A1 → rango esperado E (índice 1 de 8 → factor base 0.05*1/8 = 0.00625).
      // Aunque la BD guarde game_rank 'C', el factor se deriva del CEFR, así
      // que el poder es la línea base de E y no se infla por 'C'.
      final power = AuraSystem.computePower(
        radar: const {'fluency': 0, 'vocab': 0, 'phonetics': 0, 'grammar': 0, 'goals': 0},
        streak: 0,
        cefr: 'A1',
      );
      expect(power, closeTo(0.00625, 0.000001));
      expect(AuraSystem.expectedRank('A1'), 'E');
    });

    test('Fronteras de tier', () {
      expect(AuraSystem.tierFor(0.24), AuraTier.latente);
      expect(AuraSystem.tierFor(0.25), AuraTier.revelada);
      expect(AuraSystem.tierFor(0.44), AuraTier.revelada);
      expect(AuraSystem.tierFor(0.45), AuraTier.abierta);
      expect(AuraSystem.tierFor(0.64), AuraTier.abierta);
      expect(AuraSystem.tierFor(0.65), AuraTier.dominante);
      expect(AuraSystem.tierFor(0.84), AuraTier.dominante);
      expect(AuraSystem.tierFor(0.85), AuraTier.abisal);
    });
  });

  group('Validación cruzada CEFR ↔ rango', () {
    test('Rango derivado del CEFR', () {
      expect(AuraSystem.expectedRank('PRE-A1'), 'F');
      expect(AuraSystem.expectedRank('A1'), 'E');
      expect(AuraSystem.expectedRank('A2'), 'D');
      expect(AuraSystem.expectedRank('B1'), 'C');
      expect(AuraSystem.expectedRank('C2'), 'S');
    });

    test('PRE-A1 se valida contra su rango F', () {
      expect(AuraSystem.hasRankMismatch('PRE-A1', 'F'), isFalse);
      expect(AuraSystem.hasRankMismatch('PRE-A1', 'E'), isTrue);
    });

    test('Detecta inconsistencia CEFR/rango', () {
      expect(AuraSystem.hasRankMismatch('A1', 'C'), isTrue);
      expect(AuraSystem.hasRankMismatch('B1', 'E'), isTrue);
    });

    test('Rango consistente → sin inconsistencia', () {
      expect(AuraSystem.hasRankMismatch('A1', 'E'), isFalse);
      expect(AuraSystem.hasRankMismatch('B1', 'C'), isFalse);
      expect(AuraSystem.hasRankMismatch('C2', 'S'), isFalse);
    });

    test('Rango nulo o CEFR desconocido → sin inconsistencia', () {
      expect(AuraSystem.hasRankMismatch('A1', null), isFalse);
      expect(AuraSystem.hasRankMismatch(null, 'C'), isFalse);
      expect(AuraSystem.hasRankMismatch('XX', 'S'), isFalse);
    });
  });
}
