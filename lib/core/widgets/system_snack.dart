import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// SnackBars elegantes del System HUD (Auditoría 4 — Onboarding Revamp).
///
/// Fondo: `surfaceContainerHigh` + borde de acento semántico (no colores planos
/// brillantes). Éxito→esmeralda, error→carmesí, aviso→ámbar, info→cian tenue,
/// recompensa→dorado suave.
class SystemSnack {
  SystemSnack._();

  static void show(
    BuildContext context,
    String message, {
    SystemSnackType type = SystemSnackType.info,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    final accent = switch (type) {
      SystemSnackType.success => AppColors.emeraldGreen,
      SystemSnackType.error => AppColors.crimsonRed,
      SystemSnackType.warning => AppColors.guildAmber,
      SystemSnackType.info => AppColors.manaCyan,
      SystemSnackType.reward => AppColors.royalGold,
    };
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: accent.withValues(alpha: 0.6), width: 1),
        ),
      ),
    );
  }
}

enum SystemSnackType { success, error, warning, info, reward }
