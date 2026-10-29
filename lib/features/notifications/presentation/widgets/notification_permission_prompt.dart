import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/analytics/analytics_taxonomy.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/notification_providers.dart';

/// Pantalla previa del permiso de notificaciones (Issue #106).
///
/// Se monta en el resumen de sesion: se muestra **una sola vez**, despues de la
/// primera leccion completada, y explica el beneficio antes de pedir el permiso
/// del sistema (Android 13+). No dibuja nada por si misma.
class NotificationPermissionPrompt extends ConsumerStatefulWidget {
  const NotificationPermissionPrompt({super.key});

  @override
  ConsumerState<NotificationPermissionPrompt> createState() =>
      _NotificationPermissionPromptState();
}

class _NotificationPermissionPromptState
    extends ConsumerState<NotificationPermissionPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  Future<void> _maybePrompt() async {
    final store = ref.read(notificationPromptStoreProvider);
    if (await store.wasShown()) return;
    await store.markShown();
    if (!mounted) return;

    // Si el recordatorio ya esta activo no hay nada que ofrecer.
    if (ref.read(reminderSettingsProvider).enabled) return;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          backgroundColor: AppColors.sheetBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: AppColors.royalGold.withValues(alpha: 0.5)),
          ),
          icon: const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.royalGold,
            size: 32,
          ),
          title: Text(
            l10n.notif_prompt_title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          content: Text(
            l10n.notif_prompt_body,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                l10n.notif_prompt_later,
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalGold,
                foregroundColor: AppColors.voidBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                l10n.notif_prompt_accept,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (accepted != true || !mounted) return;

    final granted = await ref
        .read(reminderSchedulerProvider)
        .requestPermission();
    trackNotificationEvent(
      ref.read(currentUserProvider)?.id ?? '',
      AnalyticsEvent.notificationPermission,
      properties: <String, dynamic>{
        'granted': granted,
        'source': 'post_lesson',
      },
    );
    if (!mounted) return;

    if (!granted) {
      SystemSnack.show(
        context,
        _l10n.notif_permission_denied,
        type: SystemSnackType.warning,
      );
      return;
    }

    try {
      await ref
          .read(userSettingsProvider.notifier)
          .updateSetting('notifications_enabled', true);
      if (!mounted) return;
      SystemSnack.show(
        context,
        _l10n.notif_enabled_ok,
        type: SystemSnackType.success,
      );
    } catch (e) {
      debugPrint(
        'NotificationPermissionPrompt: no se pudo activar el recordatorio: $e',
      );
      if (!mounted) return;
      SystemSnack.show(
        context,
        _l10n.notif_save_error,
        type: SystemSnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
