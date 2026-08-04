import 'package:flutter/widgets.dart';

/// Tokens de elevación/sombra centralizados (DS-04).
class AppElevation {
  AppElevation._();

  /// Sin elevación.
  static const List<BoxShadow> none = [];

  /// Elevación sutil para cards (sin glow).
  static const List<BoxShadow> flat = [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Elevación de botones primarios (glow de acento).
  static const List<BoxShadow> accent = [
    BoxShadow(color: Color(0x5900E5FF), blurRadius: 12, offset: Offset(0, 2)),
  ];

  /// Elevación de recompensas/destacados (glow dorado).
  static const List<BoxShadow> reward = [
    BoxShadow(color: Color(0x59FFC700), blurRadius: 16, offset: Offset(0, 2)),
  ];
}
