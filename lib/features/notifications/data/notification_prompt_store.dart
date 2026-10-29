import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda si ya se mostro la pantalla previa de permisos de notificaciones.
///
/// El criterio de la historia (#106) es pedir el permiso **despues de la
/// primera leccion completada** y no volver a insistir. Se guarda en el
/// dispositivo (no en `user_settings`): el aviso es una decision de UX por
/// instalacion, no un ajuste de la cuenta.
class NotificationPromptStore {
  const NotificationPromptStore();

  static const String _key = 'notifications_permission_prompt_shown_v1';

  Future<bool> wasShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (e) {
      // Si el almacenamiento falla, no se muestra el aviso: mejor no molestar
      // en cada sesion que repetir el dialogo indefinidamente.
      debugPrint(
        'NotificationPromptStore: no se pudo leer $_key, se omite el aviso: $e',
      );
      return true;
    }
  }

  Future<void> markShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (e) {
      debugPrint('NotificationPromptStore: no se pudo guardar $_key: $e');
    }
  }
}
