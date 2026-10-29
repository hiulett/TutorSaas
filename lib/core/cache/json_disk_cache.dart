import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';

/// Persistencia JSON ligera (SharedPreferences) para caches de datos que
/// cambian poco (catálogos). Permite pintar al instante en el cold start y
/// refrescar desde la red en segundo plano. Nunca lanza.
class JsonDiskCache {
  static Future<String?> readString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeString(String key, String json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json);
    } catch (e, st) {
      ErrorTracker.logSilent('lib/core/cache/json_disk_cache.dart:22', e, stackTrace: st);
    }
  }

  static Future<List<Map<String, dynamic>>?> readList(String key) async {
    try {
      final raw = await readString(key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    await writeString(key, jsonEncode(value));
  }
}
