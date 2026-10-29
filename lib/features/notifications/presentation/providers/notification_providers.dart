import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/language_settings.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/local_notifications_scheduler.dart';
import '../../data/notification_prompt_store.dart';
import '../../domain/models/reminder_plan.dart';
import '../../domain/models/reminder_settings.dart';
import '../../domain/services/reminder_schedule.dart';
import '../../domain/services/reminder_scheduler.dart';

/// Ruta que debe abrir la app cuando el usuario toca una notificacion.
///
/// La escribe el scheduler (payload de la notificacion) y la consume
/// `TutorSaaSApp`, que es quien tiene el `GoRouter`.
final notificationTapRouteProvider = StateProvider<String?>((ref) => null);

final notificationPromptStoreProvider = Provider<NotificationPromptStore>(
  (ref) => const NotificationPromptStore(),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return LocalNotificationsScheduler(
    onRouteSelected: (route) {
      ref.read(notificationTapRouteProvider.notifier).state = route;
    },
  );
});

/// Textos del recordatorio ya localizados.
///
/// Se resuelven sin `BuildContext` porque el aviso se programa en el arranque
/// (antes de que exista una pantalla) y desde Ajustes.
class ReminderTexts {
  const ReminderTexts({required this.title, required this.body});

  final String title;
  final String body;

  factory ReminderTexts.forLanguage(String languageCode) {
    final code = supportedUiLanguages.contains(languageCode)
        ? languageCode
        : 'es';
    final l10n = lookupAppLocalizations(Locale(code));
    return ReminderTexts(
      title: l10n.notif_reminder_title,
      body: l10n.notif_reminder_body,
    );
  }
}

final reminderTextsProvider = Provider<ReminderTexts>((ref) {
  return ReminderTexts.forLanguage(ref.watch(effectiveUiLanguageProvider));
});

/// Ajustes del recordatorio derivados de la fila real de `user_settings`.
final reminderSettingsProvider = Provider<ReminderSettings>((ref) {
  return ReminderSettings.fromRow(ref.watch(userSettingsProvider).toJson());
});

/// Mantiene el aviso programado alineado con `user_settings`.
///
/// No escucha nada por si mismo: `reminderStartupSyncProvider` lo engancha a
/// `user_settings` solo con sesión activa, para que el arranque sin usuario no
/// toque Supabase ni el plugin.
class ReminderSync {
  ReminderSync(this._ref);

  final Ref _ref;
  bool _running = false;
  ReminderSettings? _queued;

  Future<void> apply(ReminderSettings settings) async {
    if (_running) {
      _queued = settings;
      return;
    }
    _running = true;
    try {
      final scheduler = _ref.read(reminderSchedulerProvider);
      if (!settings.enabled) {
        await scheduler.cancel();
        return;
      }
      final texts = _ref.read(reminderTextsProvider);
      await scheduler.apply(
        ReminderPlan(
          hour: settings.hour,
          minute: settings.minute,
          weekdays: settings.weekdays,
          title: texts.title,
          body: texts.body,
          route: ReminderSchedule.homeRoute,
        ),
      );
    } catch (e) {
      debugPrint('ReminderSync: no se pudo sincronizar el recordatorio: $e');
    } finally {
      _running = false;
      final queued = _queued;
      _queued = null;
      if (queued != null && queued != settings) {
        unawaited(apply(queued));
      }
    }
  }
}

final reminderSyncProvider = Provider<ReminderSync>((ref) {
  return ReminderSync(ref);
});

/// Engancha [reminderSyncProvider] a `user_settings`.
///
/// Se lee solo con sesión activa (ver `TutorSaaSApp`): sin usuario no existe
/// fila de ajustes ni permiso que programar, y en tests evita tocar Supabase.
final reminderStartupSyncProvider = Provider<void>((ref) {
  final sync = ref.watch(reminderSyncProvider);
  ref.listen<ReminderSettings>(reminderSettingsProvider, (previous, next) {
    if (previous == next) return;
    unawaited(sync.apply(next));
  }, fireImmediately: true);
});

/// Eventos de notificaciones (taxonomia de `analytics_events`).
///
/// `notification_sent` no se emite aqui a proposito: la entrega la hace el
/// sistema operativo y no es observable sin push remoto (FCM).
void trackNotificationEvent(
  String userId,
  String eventName, {
  Map<String, dynamic>? properties,
}) {
  if (userId.isEmpty) return;
  unawaited(
    RetentionAnalytics.instance.track(
      userId,
      eventName,
      properties: properties,
    ),
  );
}
