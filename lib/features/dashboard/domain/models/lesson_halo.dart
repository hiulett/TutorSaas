import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'lesson_unlock_service.dart';

/// Tier de brillo de una lección según el % de metas completadas.
enum LessonHaloTier { locked, inProgress, passed, mastered }

/// Escala visual del halo según el porcentaje de metas completadas (0..1).
///
/// - 0% → sin halo (bloqueada).
/// - (0, 70%) → halo cian tenue, intensidad creciente (en progreso).
/// - [70%, 100%) → halo violeta fuerte (superada; desbloquea la siguiente).
/// - 100% → halo dorado máximo con pulso (maestría).
class LessonHalo {
  const LessonHalo._();

  /// Umbral de metas para considerar la lección superada.
  static const double passThreshold = LessonUnlockService.passThreshold;

  static LessonHaloTier tierFor(double p) {
    if (p <= 0) return LessonHaloTier.locked;
    if (p >= 1) return LessonHaloTier.mastered;
    if (p >= passThreshold) return LessonHaloTier.passed;
    return LessonHaloTier.inProgress;
  }

  /// Color del halo según el % de metas.
  static Color colorFor(double p) {
    if (p >= 1) return AppColors.royalGold;
    if (p >= passThreshold) return AppColors.runeViolet;
    if (p > 0) return AppColors.manaCyan;
    return AppColors.onSurface;
  }

  /// Intensidad (alpha) del halo, de 0 (sin brillo) a 0.95 (maestría).
  static double intensityFor(double p) {
    if (p <= 0) return 0;
    if (p >= 1) return 0.95;
    if (p < passThreshold) return 0.15 + (p / passThreshold) * 0.30;
    return 0.50 + ((p - passThreshold) / (1 - passThreshold)) * 0.40;
  }

  /// Radio de desenfoque del halo en píxeles.
  static double blurFor(double p) {
    if (p <= 0) return 0;
    final alpha = intensityFor(p);
    if (p < passThreshold) return 8 + alpha * 14;
    return 16 + (alpha - 0.50) * 20;
  }
}
