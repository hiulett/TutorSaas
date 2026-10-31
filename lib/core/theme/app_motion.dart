import 'package:flutter/material.dart';

/// Tokens de animación centralizados (Fase 10 · AN-A).
/// Fuente única de duraciones/curvas para microinteracciones consistentes.
class AppMotion {
  AppMotion._();

  // ── Duraciones ────────────────────────────────────────────────────────────
  /// Hover/press de cards y botones (150ms)
  static const Duration micro = Duration(milliseconds: 150);

  /// Cambios de estado, switchers (300ms)
  static const Duration fast = Duration(milliseconds: 300);

  /// Contadores, completar metas (600ms)
  static const Duration standard = Duration(milliseconds: 600);

  /// Recompensas, cofres, logros (1200ms)
  static const Duration reward = Duration(milliseconds: 1200);

  /// Loops ambientales (glow, pulso) (2000ms)
  static const Duration ambient = Duration(seconds: 2);

  // ── Curvas ───────────────────────────────────────────────────────────────
  /// Entradas/salidas estándar
  static const Curve curveStandard = Curves.easeOutCubic;

  /// "Pop" de logros y recompensas
  static const Curve curveSpring = Curves.easeOutBack;

  /// Interacción de cards/botones
  static const Curve curvePress = Curves.easeInOut;

  // ── Accesibilidad (A11Y-04 · reduce-motion global) ───────────────────────
  /// Retorna `true` si el sistema pide reducir animaciones
  /// ("remove animations" en Android / Reduce Motion en iOS).
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Duración efectiva de una animación respetando reduce-motion.
  /// Devuelve `Duration.zero` cuando `MediaQuery.disableAnimationsOf(context)`
  /// es `true`, y `normal` en caso contrario. Úsalo en vez de las constantes
  /// crudas para toda animación que deba desactivarse con accesibilidad.
  static Duration of(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;

  /// Multiplicador de duración: 0 cuando reduce-motion está activo.
  static Duration scaled(BuildContext context, Duration duration) =>
      of(context, duration);

  /// `true` cuando se permiten animaciones en bucle (lo contrario de
  /// [reduceMotion]). Úsalo para decidir si arrancar un `repeat()`.
  static bool loopsAllowed(BuildContext context) => !reduceMotion(context);

  /// Sincroniza un bucle infinito ([AnimationController.repeat]) con
  /// reduce-motion (UX-04).
  ///
  /// Con reduce-motion activo el controller queda **detenido** —sin `Ticker`
  /// vivo— en [stillValue], de modo que el widget se dibuja estático sin
  /// cambiar su aspecto base. Cuando el sistema vuelve a permitir animaciones
  /// el bucle se reanuda.
  ///
  /// Debe llamarse desde `didChangeDependencies()` (nunca desde `initState()`:
  /// allí `MediaQuery` todavía no es accesible) y tras cualquier cambio de
  /// estado que encienda o apague el bucle.
  static void syncLoop(
    AnimationController controller, {
    required bool allowed,
    bool reverse = false,
    double stillValue = 0.0,
  }) {
    if (!allowed) {
      if (controller.isAnimating) controller.stop();
      if (controller.value != stillValue) controller.value = stillValue;
      return;
    }
    if (!controller.isAnimating) controller.repeat(reverse: reverse);
  }
}
