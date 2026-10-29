import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/notifications/domain/models/reminder_settings.dart';
import 'package:tutorsaas/features/notifications/domain/services/reminder_schedule.dart';

void main() {
  group('ReminderSettings.parseTime', () {
    test('acepta HH:MM:SS y HH:MM', () {
      expect(ReminderSettings.parseTime('20:30:00'), (20, 30));
      expect(ReminderSettings.parseTime('08:05'), (8, 5));
    });

    test('cae a 20:00 con valores ausentes o invalidos', () {
      expect(ReminderSettings.parseTime(null), (20, 0));
      expect(ReminderSettings.parseTime(''), (20, 0));
      expect(ReminderSettings.parseTime('99:00:00'), (20, 0));
      expect(ReminderSettings.parseTime('basura'), (20, 0));
      expect(ReminderSettings.parseTime('21:99:00'), (21, 0));
    });
  });

  group('ReminderSettings.normalizeDays', () {
    test('ordena, deduplica y descarta dias fuera de 1..7', () {
      expect(ReminderSettings.normalizeDays([5, 1, 5, 9, 0]), [1, 5]);
    });

    test('lista vacia o invalida significa todos los dias', () {
      expect(
        ReminderSettings.normalizeDays(const []),
        ReminderSettings.everyDay,
      );
      expect(ReminderSettings.normalizeDays(null), ReminderSettings.everyDay);
      expect(
        ReminderSettings.normalizeDays('basura'),
        ReminderSettings.everyDay,
      );
    });

    test('acepta numeros serializados como texto', () {
      expect(ReminderSettings.normalizeDays(['2', 3]), [2, 3]);
    });
  });

  group('silencio nocturno', () {
    test('22:00-08:00 esta bloqueado', () {
      expect(ReminderSettings.isQuietHour(22), isTrue);
      expect(ReminderSettings.isQuietHour(23), isTrue);
      expect(ReminderSettings.isQuietHour(3), isTrue);
      expect(ReminderSettings.isQuietHour(7), isTrue);
    });

    test('08:00-21:59 esta permitido', () {
      expect(ReminderSettings.isQuietHour(8), isFalse);
      expect(ReminderSettings.isQuietHour(20), isFalse);
      expect(ReminderSettings.isQuietHour(21), isFalse);
    });

    test('clampHour mueve la hora nocturna a las 08:00', () {
      expect(ReminderSettings.clampHour(23), 8);
      expect(ReminderSettings.clampHour(5), 8);
      expect(ReminderSettings.clampHour(20), 20);
    });
  });

  group('ReminderSettings.fromRow / toRow', () {
    test('lee la fila real de user_settings', () {
      final settings = ReminderSettings.fromRow(<String, dynamic>{
        'notifications_enabled': true,
        'notification_time': '19:45:00',
        'notification_days': <int>[3, 1],
      });

      expect(settings.enabled, isTrue);
      expect(settings.hour, 19);
      expect(settings.minute, 45);
      expect(settings.weekdays, [1, 3]);
      expect(settings.label, '19:45');
    });

    test('una hora nocturna guardada antes de la regla se corrige a 08:00', () {
      final settings = ReminderSettings.fromRow(<String, dynamic>{
        'notification_time': '23:15:00',
      });
      expect(settings.hour, 8);
      expect(settings.minute, 0);
    });

    test('toRow devuelve el formato que espera Postgres', () {
      const settings = ReminderSettings(
        enabled: true,
        hour: 20,
        minute: 0,
        weekdays: [1, 2, 3, 4, 5],
      );
      expect(settings.toRow(), <String, dynamic>{
        'notifications_enabled': true,
        'notification_time': '20:00:00',
        'notification_days': [1, 2, 3, 4, 5],
      });
    });
  });

  group('ReminderSchedule.nextOccurrence', () {
    // Miercoles 29-oct-2026, 18:00 (hora local).
    final wednesday = DateTime(2026, 10, 29, 18, 0);

    test('hoy si la hora aun no ha pasado', () {
      final next = ReminderSchedule.nextOccurrence(
        now: wednesday,
        hour: 20,
        minute: 0,
        weekdays: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(next, DateTime(2026, 10, 29, 20, 0));
    });

    test('manana si la hora ya paso', () {
      final next = ReminderSchedule.nextOccurrence(
        now: wednesday,
        hour: 9,
        minute: 30,
        weekdays: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(next, DateTime(2026, 10, 30, 9, 30));
    });

    test('respeta los dias elegidos (solo fin de semana)', () {
      final next = ReminderSchedule.nextOccurrence(
        now: wednesday,
        hour: 20,
        minute: 0,
        weekdays: const [6, 7],
      );
      expect(next, DateTime(2026, 10, 31, 20, 0));
      expect(next!.weekday, DateTime.saturday);
    });

    test('si la hora es exactamente ahora, dispara hoy', () {
      final next = ReminderSchedule.nextOccurrence(
        now: wednesday,
        hour: 18,
        minute: 0,
        weekdays: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(next, wednesday);
    });

    test('cruza el cambio de mes', () {
      final next = ReminderSchedule.nextOccurrence(
        now: DateTime(2026, 10, 31, 23, 0),
        hour: 8,
        minute: 0,
        weekdays: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(next, DateTime(2026, 11, 1, 8, 0));
    });

    test('una lista sin dias validos cae a todos los dias', () {
      final next = ReminderSchedule.nextOccurrence(
        now: wednesday,
        hour: 20,
        minute: 0,
        weekdays: const <int>[],
      );
      expect(next, DateTime(2026, 10, 29, 20, 0));
    });
  });

  group('payload de la notificacion', () {
    test('ida y vuelta', () {
      final payload = ReminderSchedule.encodePayload(route: '/home');
      expect(ReminderSchedule.routeFromPayload(payload), '/home');
    });

    test('payload vacio, nulo o corrupto cae a /home', () {
      expect(ReminderSchedule.routeFromPayload(null), '/home');
      expect(ReminderSchedule.routeFromPayload(''), '/home');
      expect(ReminderSchedule.routeFromPayload('{no-json'), '/home');
      expect(ReminderSchedule.routeFromPayload('{"route": 42}'), '/home');
      expect(ReminderSchedule.routeFromPayload('{"route": "home"}'), '/home');
    });
  });
}
