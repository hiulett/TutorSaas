import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/features/dashboard/domain/models/lesson_halo.dart';

/// QA — Escala visual del halo por % de metas completadas.
///
/// 0% sin halo; (0, 75%) cian en progreso; [75%, 100%) violeta superada;
/// 100% dorado maestría. Intensidad creciente hasta 0.95 en maestría.
///
/// El umbral se unificó con `LessonUnlockService.passThreshold` (issue #17).
void main() {
  group('Tier del halo', () {
    test('bloqueada / en progreso / superada / maestría', () {
      expect(LessonHalo.tierFor(0), LessonHaloTier.locked);
      expect(LessonHalo.tierFor(0.5), LessonHaloTier.inProgress);
      expect(LessonHalo.tierFor(0.7), LessonHaloTier.inProgress);
      expect(LessonHalo.tierFor(0.75), LessonHaloTier.passed);
      expect(LessonHalo.tierFor(0.99), LessonHaloTier.passed);
      expect(LessonHalo.tierFor(1), LessonHaloTier.mastered);
    });
  });

  group('Color del halo', () {
    test('dorado solo en maestría', () {
      expect(LessonHalo.colorFor(1), AppColors.royalGold);
      expect(LessonHalo.colorFor(0.85), AppColors.runeViolet);
    });
    test('violeta en superada (≥75%)', () {
      expect(LessonHalo.colorFor(0.75), AppColors.runeViolet);
      expect(LessonHalo.colorFor(0.99), AppColors.runeViolet);
    });
    test('cian en progreso', () {
      expect(LessonHalo.colorFor(0.5), AppColors.manaCyan);
      expect(LessonHalo.colorFor(0.7), AppColors.manaCyan);
    });
    test('gris bloqueada', () {
      expect(LessonHalo.colorFor(0), AppColors.onSurface);
    });
  });

  group('Intensidad (alpha)', () {
    test('0 sin brillo, 0.95 en maestría', () {
      expect(LessonHalo.intensityFor(0), 0);
      expect(LessonHalo.intensityFor(1), 0.95);
    });
    test('escala intermedia', () {
      expect(LessonHalo.intensityFor(0.35), closeTo(0.29, 0.0001));
      expect(LessonHalo.intensityFor(0.70), closeTo(0.43, 0.0001));
      expect(LessonHalo.intensityFor(0.75), closeTo(0.50, 0.0001));
      expect(LessonHalo.intensityFor(0.85), closeTo(0.66, 0.0001));
    });
    test('monótona creciente', () {
      var prev = LessonHalo.intensityFor(0.0);
      for (var p = 0.1; p <= 1.0; p += 0.1) {
        final cur = LessonHalo.intensityFor(p);
        expect(cur, greaterThanOrEqualTo(prev));
        prev = cur;
      }
    });
  });

  group('Radio de desenfoque (blur)', () {
    test('0 sin brillo, máximo en maestría', () {
      expect(LessonHalo.blurFor(0), 0);
      expect(LessonHalo.blurFor(1), greaterThanOrEqualTo(24));
    });
    test('crece con el %', () {
      expect(LessonHalo.blurFor(0.35), closeTo(12.06, 0.001));
      expect(LessonHalo.blurFor(0.70), closeTo(14.02, 0.001));
      expect(LessonHalo.blurFor(0.85), closeTo(19.20, 0.001));
    });
  });

  test('Umbral unificado con el desbloqueo (0.75)', () {
    expect(LessonHalo.passThreshold, 0.75);
  });
}
