import 'package:flutter/widgets.dart';

/// Tokens de radio/bordes centralizados (DS-04).
/// Estándar del proyecto: 4px (solo avatares/orbes usan >20px).
class AppRadius {
  AppRadius._();

  /// Radio estándar de cards/botones/inputs (4px).
  static const double sm = 4;

  /// Radio medio para contenedores destacados.
  static const double md = 8;

  /// Radio de pills/chips.
  static const double lg = 12;

  /// Radio completo (solo avatares/orbes).
  static const double circle = 999;

  static BorderRadius card = BorderRadius.circular(sm);
  static BorderRadius pill = BorderRadius.circular(lg);
  static BorderRadius circleBorder = BorderRadius.circular(circle);
}
