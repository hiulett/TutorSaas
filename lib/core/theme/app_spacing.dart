import 'package:flutter/widgets.dart';

/// Tokens de espaciado centralizados (DS-01 · grid de 4px).
/// Fuente única de padding/margins para toda la app.
class AppSpacing {
  AppSpacing._();

  /// Unidad base del grid (4px).
  static const double unit = 4;

  // Escala del grid (4 · n)
  static const double xs = 4;   // 4px
  static const double sm = 8;   // 8px
  static const double md = 12;  // 12px
  static const double lg = 16;  // 16px — gutter estándar
  static const double xl = 20;  // 20px — margen móvil
  static const double xxl = 24; // 24px — padding ventana
  static const double xxxl = 32;
  static const double huge = 48;

  // ── Padding presets ──────────────────────────────────────────────────────

  /// Margen/padding estándar de pantalla (24px horizontales).
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: xxl, vertical: lg);

  /// Padding de cards/ventanas (16px).
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Padding compacto (12px).
  static const EdgeInsets compact = EdgeInsets.all(md);

  /// Padding de botones (24x16).
  static const EdgeInsets button = EdgeInsets.symmetric(horizontal: xxl, vertical: lg);
}
