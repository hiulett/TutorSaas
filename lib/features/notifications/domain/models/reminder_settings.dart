/// Ajustes del recordatorio diario (Issue #106 / P-21).
///
/// Logica pura: no depende de Flutter ni de ningun plugin, para que la
/// programacion del recordatorio se pueda probar sin dispositivo.
class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.weekdays,
  });

  /// Ventana de silencio nocturno (hora local del dispositivo): 22:00-08:00.
  /// El recordatorio nunca se programa dentro de esta franja.
  static const int quietStartHour = 22;
  static const int quietEndHour = 8;

  /// Valor por defecto: 20:00. La columna `user_settings.notification_time`
  /// arrastra `09:00` del esquema antiguo, pero la app usa 20:00 cuando la fila
  /// no existe todavia.
  static const int defaultHour = 20;
  static const int defaultMinute = 0;

  /// Dias ISO: 1 = lunes ... 7 = domingo.
  static const List<int> everyDay = <int>[1, 2, 3, 4, 5, 6, 7];

  final bool enabled;
  final int hour;
  final int minute;
  final List<int> weekdays;

  factory ReminderSettings.defaults() => const ReminderSettings(
    enabled: false,
    hour: defaultHour,
    minute: defaultMinute,
    weekdays: everyDay,
  );

  /// Lee los tres campos de una fila de `user_settings`.
  factory ReminderSettings.fromRow(Map<String, dynamic> row) {
    final (parsedHour, parsedMinute) = parseTime(row['notification_time']);
    final hour = clampHour(parsedHour);
    return ReminderSettings(
      enabled: row['notifications_enabled'] as bool? ?? false,
      hour: hour,
      // Si la hora cae en el silencio nocturno se mueve a las 08:00 en punto.
      minute: hour == parsedHour ? parsedMinute : 0,
      weekdays: normalizeDays(row['notification_days']),
    );
  }

  /// `true` si [hour] cae dentro del silencio nocturno.
  static bool isQuietHour(int hour) =>
      hour >= quietStartHour || hour < quietEndHour;

  /// Primera hora permitida si [hour] cae en el silencio nocturno.
  static int clampHour(int hour) => isQuietHour(hour) ? quietEndHour : hour;

  /// Convierte `20:00:00` / `20:00` en (hora, minuto). Valores invalidos caen
  /// a los defaults.
  static (int, int) parseTime(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      final parts = raw.split(':');
      final hour = int.tryParse(parts[0]);
      final minute = parts.length > 1 ? int.tryParse(parts[1]) : 0;
      if (hour != null && hour >= 0 && hour <= 23) {
        final safeMinute = (minute != null && minute >= 0 && minute <= 59)
            ? minute
            : 0;
        return (hour, safeMinute);
      }
    }
    return (defaultHour, defaultMinute);
  }

  /// Dias ISO validos, ordenados y sin duplicados. Una lista vacia o invalida
  /// significa "todos los dias" (nunca dejamos al usuario sin recordatorio por
  /// un dato corrupto).
  static List<int> normalizeDays(Object? raw) {
    final days = <int>{};
    if (raw is List) {
      for (final value in raw) {
        final day = value is num ? value.toInt() : int.tryParse('$value');
        if (day != null && day >= 1 && day <= 7) days.add(day);
      }
    }
    if (days.isEmpty) return everyDay;
    return days.toList()..sort();
  }

  /// `HH:MM:SS`, el formato de `user_settings.notification_time` (time).
  String get sqlTime =>
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:00';

  /// `HH:MM` para mostrar en la interfaz.
  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Campos de `user_settings` que gobiernan el recordatorio.
  Map<String, dynamic> toRow() => <String, dynamic>{
    'notifications_enabled': enabled,
    'notification_time': sqlTime,
    'notification_days': weekdays,
  };

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    List<int>? weekdays,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderSettings &&
        other.enabled == enabled &&
        other.hour == hour &&
        other.minute == minute &&
        _sameDays(other.weekdays, weekdays);
  }

  @override
  int get hashCode =>
      Object.hash(enabled, hour, minute, Object.hashAll(weekdays));

  @override
  String toString() =>
      'ReminderSettings(enabled: $enabled, time: $label, days: $weekdays)';

  static bool _sameDays(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
