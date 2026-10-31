import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/core/theme/app_contrast.dart';

/// Bloquea regresiones de contraste (auditoría UX-02, UX-05, UX-18).
///
/// Cada par lo usa el tema o un componente real; si alguien vuelve a un color
/// que falla AA, este test rompe el build.
void main() {
  group('pares que usa el tema y componentes', () {
    test('texto principal sobre fondos base', () {
      expect(
        AppContrast.meetsAA(AppColors.onSurface, AppColors.voidBg),
        isTrue,
      );
      expect(
        AppContrast.meetsAA(AppColors.onSurface, AppColors.surface),
        isTrue,
      );
      expect(
        AppContrast.meetsAA(AppColors.onSurfaceVariant, AppColors.voidBg),
        isTrue,
      );
    });

    test('acentos como texto sobre voidBg', () {
      for (final accent in [
        AppColors.manaCyan,
        AppColors.royalGold,
        AppColors.emeraldGreen,
      ]) {
        expect(
          AppContrast.meetsAA(accent, AppColors.voidBg),
          isTrue,
          reason: 'acento $accent sobre voidBg',
        );
      }
    });

    test('RunicButton: blanco sobre runeViolet (UX-02)', () {
      expect(
        AppContrast.meetsAA(Colors.white, AppColors.runeViolet),
        isTrue,
        reason: 'el botón primario debe pasar AA',
      );
    });

    test('destructivo: voidBg sobre crimsonRed (UX-05)', () {
      expect(
        AppContrast.meetsAA(AppColors.voidBg, AppColors.crimsonRed),
        isTrue,
      );
    });

    test('hint de inputs con alfa 0.7 (UX-18)', () {
      final hint = AppColors.onSurfaceVariant.withValues(alpha: 0.7);
      final ratio = AppContrast.ratio(hint, AppColors.surfaceContainerLow);
      expect(
        ratio,
        greaterThanOrEqualTo(AppContrast.aaNormal),
        reason: 'ratio del hint: ${ratio.toStringAsFixed(2)}',
      );
    });
  });

  group('la fórmula WCAG da los valores conocidos', () {
    test('negro sobre blanco es 21', () {
      expect(
        AppContrast.ratio(Colors.black, Colors.white),
        closeTo(21.0, 0.01),
      );
    });

    test('mismo color es 1', () {
      expect(
        AppContrast.ratio(AppColors.manaCyan, AppColors.manaCyan),
        closeTo(1.0, 0.001),
      );
    });

    test('onSurface sobre voidBg supera 15', () {
      expect(
        AppContrast.ratio(AppColors.onSurface, AppColors.voidBg),
        greaterThan(15.0),
      );
    });
  });
}
