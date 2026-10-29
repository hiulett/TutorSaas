import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// P-34e (#119): tarjeta accionable cuando Android deniega el micrófono.
///
/// "Abrir ajustes" lanza la pantalla de permisos de la app; "Reintentar"
/// vuelve a pedir permiso sin salir de la conversación.
class MicPermissionCard extends StatelessWidget {
  const MicPermissionCard({
    super.key,
    required this.title,
    required this.body,
    required this.openSettingsLabel,
    required this.retryLabel,
    required this.onOpenSettings,
    required this.onRetry,
  });

  final String title;
  final String body;
  final String openSettingsLabel;
  final String retryLabel;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('mic-permission-card'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mic_off_rounded,
                color: AppColors.alertRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilledButton.icon(
                key: const Key('mic-open-settings'),
                onPressed: onOpenSettings,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.settings_rounded, size: 16),
                label: Text(
                  openSettingsLabel,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                key: const Key('mic-retry'),
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.manaCyan,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(retryLabel, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
