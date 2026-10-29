import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda si la mini-conversación inicial (P-25 / #110) ya se mostró.
///
/// Se guarda en el dispositivo y no en `user_settings`: `user_settings` no
/// tiene columna para esta marca y añadirla obligaría a una migración para un
/// flag de UX por instalación (mismo criterio que `NotificationPromptStore`).
///
/// La clave incluye el `user_id` para que dos cuentas en el mismo teléfono no
/// compartan la marca. Sin sesión (o en tests) se usa `anonymous`.
class MiniConversationStore {
  const MiniConversationStore();

  static const String _prefix = 'mini_conversation_seen_v1';

  String keyFor(String userId) {
    final id = userId.trim();
    return '${_prefix}_${id.isEmpty ? 'anonymous' : id}';
  }

  /// `true` = ya la vio (no se repite). Si el almacenamiento falla se devuelve
  /// `true` para no molestar en cada arranque.
  Future<bool> wasSeen(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyFor(userId)) ?? false;
    } catch (e) {
      debugPrint('MiniConversationStore: no se pudo leer la marca: $e');
      return true;
    }
  }

  Future<void> markSeen(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyFor(userId), true);
    } catch (e) {
      debugPrint('MiniConversationStore: no se pudo guardar la marca: $e');
    }
  }
}
