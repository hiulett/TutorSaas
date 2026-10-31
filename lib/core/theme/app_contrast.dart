import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Utilidades de contraste WCAG 2.1 (AA) para los pares texto/fondo del tema.
///
/// Se usa en tests para bloquear regresiones: cualquier par por debajo del
/// umbral hace fallar la suite (auditoría UX-02/UX-05/UX-18).
class AppContrast {
  AppContrast._();

  /// Umbral AA para texto normal.
  static const double aaNormal = 4.5;

  /// Umbral AA para texto grande (>= 18.66 px bold o >= 24 px).
  static const double aaLarge = 3.0;

  /// Luminancia relativa según WCAG.
  static double relativeLuminance(Color color) {
    double channel(double c) => c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  /// Ratio de contraste entre dos colores (1.0 a 21.0).
  static double ratio(Color a, Color b) {
    final la = relativeLuminance(a);
    final lb = relativeLuminance(b);
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsAA(
    Color foreground,
    Color background, {
    bool largeText = false,
  }) => ratio(foreground, background) >= (largeText ? aaLarge : aaNormal);
}
