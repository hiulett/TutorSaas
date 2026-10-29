import '../models/reminder_plan.dart';

/// Contrato del programador de recordatorios.
///
/// Existe para que la logica de negocio no dependa del plugin: los tests usan
/// un doble y, cuando se anada push remoto (FCM), se puede envolver o sustituir
/// sin tocar pantallas.
abstract class ReminderScheduler {
  /// Pide el permiso de notificaciones (Android 13+). `true` si quedo concedido.
  Future<bool> requestPermission();

  /// `true` si el sistema permite mostrar notificaciones a la app.
  Future<bool> hasPermission();

  /// Abre los ajustes de notificaciones del sistema. `true` si se pudo abrir.
  Future<bool> openSystemSettings();

  /// Cancela los recordatorios programados y programa [plan].
  ///
  /// Es idempotente: se puede llamar en cada arranque sin duplicar avisos.
  Future<void> apply(ReminderPlan plan);

  /// Cancela cualquier recordatorio pendiente (el usuario lo desactivo).
  Future<void> cancel();
}
