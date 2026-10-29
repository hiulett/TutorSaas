import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/analytics/analytics_taxonomy.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/models/reminder_settings.dart';
import '../providers/notification_providers.dart';

/// Interruptor + hora + dias del recordatorio diario local (Issue #106).
///
/// Se guarda al instante en `user_settings` (no espera al boton de guardar de
/// Ajustes) para que el aviso se reprograme en cuanto el usuario cambia algo.
class ReminderSettingsCard extends ConsumerStatefulWidget {
  const ReminderSettingsCard({super.key});

  @override
  ConsumerState<ReminderSettingsCard> createState() =>
      _ReminderSettingsCardState();
}

class _ReminderSettingsCardState extends ConsumerState<ReminderSettingsCard> {
  bool _busy = false;
  bool _systemPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkSystemPermission(),
    );
  }

  Future<void> _checkSystemPermission() async {
    final settings = ref.read(reminderSettingsProvider);
    if (!settings.enabled) return;
    final granted = await ref.read(reminderSchedulerProvider).hasPermission();
    if (!mounted || granted) return;
    setState(() => _systemPermissionDenied = true);
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  Future<void> _persist(Map<String, dynamic> patch) async {
    final notifier = ref.read(userSettingsProvider.notifier);
    try {
      for (final entry in patch.entries) {
        await notifier.updateSetting(entry.key, entry.value);
      }
    } catch (e) {
      debugPrint(
        'ReminderSettingsCard: error guardando recordatorio ($patch): $e',
      );
      if (!mounted) return;
      SystemSnack.show(
        context,
        _l10n.notif_save_error,
        type: SystemSnackType.error,
      );
    }
  }

  Future<void> _onToggle(bool value) async {
    final userId = ref.read(currentUserProvider)?.id ?? '';
    if (!value) {
      setState(() => _systemPermissionDenied = false);
      await _persist(<String, dynamic>{'notifications_enabled': false});
      return;
    }

    setState(() => _busy = true);
    final granted = await ref
        .read(reminderSchedulerProvider)
        .requestPermission();
    trackNotificationEvent(
      userId,
      AnalyticsEvent.notificationPermission,
      properties: <String, dynamic>{'granted': granted, 'source': 'settings'},
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _systemPermissionDenied = !granted;
    });

    if (!granted) {
      SystemSnack.show(
        context,
        _l10n.notif_permission_denied,
        type: SystemSnackType.warning,
      );
      return;
    }

    await _persist(<String, dynamic>{'notifications_enabled': true});
    if (!mounted) return;
    SystemSnack.show(
      context,
      _l10n.notif_enabled_ok,
      type: SystemSnackType.success,
    );
  }

  Future<void> _pickTime(ReminderSettings settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
      helpText: _l10n.notif_time_label,
    );
    if (picked == null || !mounted) return;

    final hour = ReminderSettings.clampHour(picked.hour);
    final minute = hour == picked.hour ? picked.minute : 0;
    final warned = hour != picked.hour;

    await _persist(<String, dynamic>{
      'notification_time':
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00',
    });
    if (!mounted) return;
    if (warned) {
      SystemSnack.show(
        context,
        _l10n.notif_quiet_hours,
        type: SystemSnackType.warning,
      );
      return;
    }
    SystemSnack.show(
      context,
      _l10n.notif_time_updated(
        settings.copyWith(hour: hour, minute: minute).label,
      ),
      type: SystemSnackType.info,
    );
  }

  Future<void> _toggleDay(ReminderSettings settings, int isoDay) async {
    final days = List<int>.from(settings.weekdays);
    if (days.contains(isoDay)) {
      // Nunca dejamos la lista vacia: sin dias no habria recordatorio.
      if (days.length == 1) return;
      days.remove(isoDay);
    } else {
      days.add(isoDay);
      days.sort();
    }
    await _persist(<String, dynamic>{'notification_days': days});
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(reminderSettingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.royalGold,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notif_settings_title,
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.notif_settings_desc,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.enabled,
                activeThumbColor: AppColors.manaCyan,
                activeTrackColor: AppColors.manaCyan.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.onSurfaceVariant,
                inactiveTrackColor: AppColors.onSurface.withValues(alpha: 0.1),
                onChanged: _busy ? null : _onToggle,
              ),
            ],
          ),
          if (settings.enabled) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.deepSlate),
            const SizedBox(height: 8),
            // La accion va en el InkWell hijo: GlassCard envuelve todo en un
            // GestureDetector que ganaria la arena si el tap se pusiera fuera.
            InkWell(
              onTap: _busy ? null : () => _pickTime(settings),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.manaCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.notif_time_label,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      settings.label,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.manaCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notif_days_label,
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var isoDay = 1; isoDay <= 7; isoDay++)
                  _DayChip(
                    label: _dayLabel(context, isoDay),
                    selected: settings.weekdays.contains(isoDay),
                    onTap: _busy ? null : () => _toggleDay(settings, isoDay),
                  ),
              ],
            ),
            if (_systemPermissionDenied) ...[
              const SizedBox(height: 12),
              Text(
                l10n.notif_permission_denied,
                style: const TextStyle(
                  color: AppColors.guildAmber,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final opened = await ref
                      .read(reminderSchedulerProvider)
                      .openSystemSettings();
                  if (!opened) {
                    debugPrint(
                      'ReminderSettingsCard: no se pudo abrir los ajustes de '
                      'notificaciones del sistema',
                    );
                  }
                },
                child: Text(
                  l10n.notif_permission_open_settings,
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.manaCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Etiqueta corta del dia ISO usando la locale de la interfaz.
  String _dayLabel(BuildContext context, int isoDay) {
    final localizations = MaterialLocalizations.of(context);
    // `narrowWeekdays` empieza en domingo; ISO 1 = lunes.
    final index = isoDay % 7;
    return localizations.narrowWeekdays[index];
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 36,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.manaCyan.withValues(alpha: 0.16)
              : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.manaCyan : AppColors.deepSlate,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected ? AppColors.manaCyan : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
