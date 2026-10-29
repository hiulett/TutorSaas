import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/reminder_settings.dart';

/// Calculo de la proxima vez que debe sonar el recordatorio (logica pura).
class ReminderSchedule {
  const ReminderSchedule._();

  /// Ruta por defecto al tocar la notificacion.
  static const String homeRoute = '/home';

  /// Tipo de notificacion que viaja en el payload.
  static const String dailyReminderKind = 'daily_reminder';

  /// Proxima ocurrencia **en hora local** de un recordatorio a [hour]:[minute]
  /// en alguno de los [weekdays]. Devuelve `null` si no hay dias validos.
  ///
  /// Si hoy es un dia valido y la hora aun no ha pasado, la ocurrencia es hoy;
  /// si ya paso, el siguiente dia valido de la semana.
  static DateTime? nextOccurrence({
    required DateTime now,
    required int hour,
    required int minute,
    required Iterable<int> weekdays,
  }) {
    final days = ReminderSettings.normalizeDays(weekdays.toList());
    if (days.isEmpty) return null;

    for (var offset = 0; offset <= 7; offset++) {
      final candidate = DateTime(
        now.year,
        now.month,
        now.day + offset,
        hour,
        minute,
      );
      if (candidate.isBefore(now)) continue;
      if (!days.contains(candidate.weekday)) continue;
      return candidate;
    }
    return null;
  }

  /// Payload JSON que se adjunta a la notificacion programada.
  static String encodePayload({
    String route = homeRoute,
    String kind = dailyReminderKind,
  }) => jsonEncode(<String, String>{'kind': kind, 'route': route});

  /// Ruta a abrir cuando el usuario toca la notificacion. Tolerante a payloads
  /// vacios, corruptos o de otras notificaciones.
  static String routeFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return homeRoute;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        final route = decoded['route'];
        if (route is String && route.startsWith('/') && route.length > 1) {
          return route;
        }
      }
    } catch (e) {
      debugPrint('ReminderSchedule: payload no es JSON valido ($e): $payload');
    }
    return homeRoute;
  }
}
