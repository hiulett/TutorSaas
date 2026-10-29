import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/models/reminder_plan.dart';
import '../domain/services/reminder_schedule.dart';
import '../domain/services/reminder_scheduler.dart';

/// Implementacion del recordatorio local con `flutter_local_notifications`.
///
/// Solo Android. No usa alarmas exactas (`inexactAllowWhileIdle`): Android 12+
/// solo exige `SCHEDULE_EXACT_ALARM` para alarmas exactas y Play la revisa; un
/// recordatorio diario no necesita precision al segundo.
///
/// Todo el servicio degrada a no-op: si el plugin no esta disponible (tests,
/// escritorio, permiso denegado) devuelve `false` y registra el motivo en vez
/// de romper la app.
class LocalNotificationsScheduler implements ReminderScheduler {
  LocalNotificationsScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    this.onRouteSelected,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Se invoca cuando el usuario toca una notificacion o cuando la app se abre
  /// a partir de una. La ruta ya viene saneada por [ReminderSchedule].
  final void Function(String route)? onRouteSelected;

  static const String channelId = 'daily_reminder';
  static const String channelName = 'Daily reminder';
  static const String channelDescription =
      'Recordatorio diario de practica (maximo uno al dia).';

  /// Los ids de notificacion se derivan del dia ISO para que reprogramar un dia
  /// reemplace el aviso anterior en lugar de duplicarlo.
  static const int _idBase = 10600;

  bool _initialized = false;
  bool _initFailed = false;

  static int notificationIdForWeekday(int weekday) => _idBase + weekday;

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    if (_initFailed) return false;
    try {
      tz_data.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (e) {
        // Sin zona horaria del dispositivo, `tz.local` queda en UTC: el aviso
        // sonaria a la hora equivocada. Se registra para no fallar en silencio.
        debugPrint(
          'LocalNotificationsScheduler: no se pudo resolver la zona horaria '
          'del dispositivo, se usa tz.local por defecto: $e',
        );
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final route = ReminderSchedule.routeFromPayload(response.payload);
          onRouteSelected?.call(route);
        },
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.defaultImportance,
            ),
          );

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch != null && launch.didNotificationLaunchApp) {
        final route = ReminderSchedule.routeFromPayload(
          launch.notificationResponse?.payload,
        );
        onRouteSelected?.call(route);
      }

      _initialized = true;
      return true;
    } catch (e) {
      _initFailed = true;
      debugPrint(
        'LocalNotificationsScheduler: no se pudo inicializar el plugin de '
        'notificaciones, el recordatorio queda desactivado: $e',
      );
      return false;
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() async {
    try {
      if (!await _ensureInitialized()) return false;
      final granted = await _android?.requestNotificationsPermission();
      debugPrint(
        'LocalNotificationsScheduler: permiso POST_NOTIFICATIONS -> $granted',
      );
      return granted ?? false;
    } catch (e) {
      debugPrint('LocalNotificationsScheduler: error pidiendo permiso: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      if (!await _ensureInitialized()) return false;
      final enabled = await _android?.areNotificationsEnabled();
      return enabled ?? false;
    } catch (e) {
      debugPrint('LocalNotificationsScheduler: error consultando permiso: $e');
      return false;
    }
  }

  @override
  Future<bool> openSystemSettings() async {
    try {
      if (!await _ensureInitialized()) return false;
      final opened = await _android?.openAppNotificationSettings();
      return opened ?? false;
    } catch (e) {
      debugPrint(
        'LocalNotificationsScheduler: error abriendo ajustes de notificaciones: '
        '$e',
      );
      return false;
    }
  }

  @override
  Future<void> apply(ReminderPlan plan) async {
    try {
      if (!await _ensureInitialized()) return;
      if (!await hasPermission()) {
        debugPrint(
          'LocalNotificationsScheduler: sin permiso de notificaciones, no se '
          'programa el recordatorio diario',
        );
        return;
      }

      await _plugin.cancelAllPendingNotifications();

      final payload = ReminderSchedule.encodePayload(route: plan.route);
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );

      final now = DateTime.now();
      for (final weekday in plan.weekdays) {
        final next = ReminderSchedule.nextOccurrence(
          now: now,
          hour: plan.hour,
          minute: plan.minute,
          weekdays: <int>[weekday],
        );
        if (next == null) continue;
        await _plugin.zonedSchedule(
          id: notificationIdForWeekday(weekday),
          title: plan.title,
          body: plan.body,
          payload: payload,
          scheduledDate: tz.TZDateTime.from(next, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          // Repite semanalmente el mismo dia y hora: como maximo un aviso diario.
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      debugPrint(
        'LocalNotificationsScheduler: recordatorio programado a las '
        '${plan.timeLabel} para los dias ${plan.weekdays}',
      );
    } catch (e) {
      debugPrint(
        'LocalNotificationsScheduler: error programando el recordatorio: $e',
      );
    }
  }

  @override
  Future<void> cancel() async {
    try {
      if (!await _ensureInitialized()) return;
      await _plugin.cancelAllPendingNotifications();
      debugPrint(
        'LocalNotificationsScheduler: recordatorios pendientes cancelados',
      );
    } catch (e) {
      debugPrint(
        'LocalNotificationsScheduler: error cancelando el recordatorio: $e',
      );
    }
  }
}
