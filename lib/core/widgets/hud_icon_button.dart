import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Objetivo táctil mínimo exigido por accesibilidad (UX-03, issue #242).
///
/// 48 dp es el mínimo recomendado por las guías de Material y por WCAG 2.2
/// (2.5.8 · Target Size). Todo control icon-only debe alcanzarlo aunque el
/// icono visible sea más pequeño.
const double kHudMinTapTarget = 48.0;

/// Botón de HUD icon-only con área táctil garantizada.
///
/// El tamaño *visual* ([visualSize]) se mantiene igual que antes (círculo o
/// squircle con el icono dentro), pero el `RenderBox` del control nunca baja
/// de [minTapTarget] dp: el `InkWell` ocupa toda la caja y el icono queda
/// centrado. Así el aspecto cambia lo mínimo y el dedo acierta.
///
/// Uso:
/// ```dart
/// HudIconButton(
///   icon: Icons.arrow_back_rounded,
///   semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
///   onTap: () => context.pop(),
/// )
/// ```
class HudIconButton extends StatelessWidget {
  /// Icono mostrado.
  final IconData icon;

  /// Acción al tocar. `null` deja el control inerte (solo decorativo).
  final VoidCallback? onTap;

  /// Etiqueta para lectores de pantalla. Si es `null` y [tooltip] tampoco,
  /// el control se anuncia solo como «botón».
  final String? semanticLabel;

  /// Texto del tooltip largo-pulsación. Cae a [semanticLabel] si falta.
  final String? tooltip;

  /// Diámetro del círculo/squircle visible. No afecta al área táctil.
  final double visualSize;

  /// Tamaño del icono dentro del círculo.
  final double iconSize;

  /// Color del icono.
  final Color? color;

  /// Fondo del círculo visible (por defecto, velo translúcido del sistema).
  final Color? backgroundColor;

  /// Radio del squircle. `null` dibuja un círculo perfecto.
  final BorderRadius? borderRadius;

  /// Área táctil mínima. Por defecto [kHudMinTapTarget].
  final double minTapTarget;

  const HudIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.semanticLabel,
    this.tooltip,
    this.visualSize = 40,
    this.iconSize = 18,
    this.color,
    this.backgroundColor,
    this.borderRadius,
    this.minTapTarget = kHudMinTapTarget,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      minTapTarget >= kHudMinTapTarget,
      'El área táctil de HudIconButton no puede ser menor que $kHudMinTapTarget dp',
    );
    final hit = math.max(visualSize, math.max(minTapTarget, kHudMinTapTarget));
    final radius = borderRadius ?? BorderRadius.circular(visualSize / 2);
    final isInteractive = onTap != null;
    final effectiveTooltip = tooltip ?? (isInteractive ? semanticLabel : null);

    Widget button = SizedBox(
      width: hit,
      height: hit,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          child: Center(
            child: Container(
              width: visualSize,
              height: visualSize,
              decoration: BoxDecoration(
                color:
                    backgroundColor ??
                    AppColors.onSurface.withValues(alpha: 0.06),
                borderRadius: radius,
              ),
              child: Icon(
                icon,
                color: color ?? AppColors.onSurface,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );

    button = Semantics(
      button: isInteractive,
      enabled: isInteractive,
      label: semanticLabel,
      child: button,
    );

    if (effectiveTooltip != null) {
      button = Tooltip(message: effectiveTooltip, child: button);
    }

    return button;
  }
}
