import 'reminder_settings.dart';

/// Recordatorio listo para programar: hora, dias y textos ya localizados.
class ReminderPlan {
  const ReminderPlan({
    required this.hour,
    required this.minute,
    required this.weekdays,
    required this.title,
    required this.body,
    this.route = '/home',
  });

  final int hour;
  final int minute;

  /// Dias ISO (1 = lunes ... 7 = domingo).
  final List<int> weekdays;
  final String title;
  final String body;

  /// Ruta que se abre al tocar la notificacion.
  final String route;

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  ReminderSettings get settings => ReminderSettings(
    enabled: true,
    hour: hour,
    minute: minute,
    weekdays: weekdays,
  );
}
