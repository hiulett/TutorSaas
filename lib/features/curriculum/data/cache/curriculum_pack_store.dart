import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorsaas/core/cache/json_disk_cache.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';

/// Caché local del pack de un nivel (CUR-17).
///
/// Se guarda el `get_curriculum_pack` completo con su `content_version`, que es
/// lo que permite invalidarlo. La interfaz existe para probar el modo offline
/// sin tocar disco.
abstract class CurriculumPackStore {
  Future<Map<String, dynamic>?> read(String levelId);

  Future<void> write(String levelId, Map<String, dynamic> pack);

  Future<void> remove(String levelId);
}

/// Implementación real sobre `SharedPreferences`, igual que el resto de cachés
/// del proyecto. Nunca lanza: un fallo de disco degrada a "sin caché".
class SharedPreferencesCurriculumPackStore implements CurriculumPackStore {
  const SharedPreferencesCurriculumPackStore();

  static String keyFor(String levelId) => 'curriculum_pack_v1_$levelId';

  @override
  Future<Map<String, dynamic>?> read(String levelId) async {
    final raw = await JsonDiskCache.readString(keyFor(levelId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['pack'] is! Map) return null;
      return (decoded['pack'] as Map).cast<String, dynamic>();
    } catch (error, stack) {
      ErrorTracker.logSilent('curriculum.cache_read', error, stackTrace: stack);
      return null;
    }
  }

  @override
  Future<void> write(String levelId, Map<String, dynamic> pack) async {
    try {
      await JsonDiskCache.writeString(
        keyFor(levelId),
        jsonEncode({
          'saved_at': DateTime.now().toUtc().toIso8601String(),
          'pack': pack,
        }),
      );
    } catch (error, stack) {
      ErrorTracker.logSilent('curriculum.cache_write', error, stackTrace: stack);
    }
  }

  @override
  Future<void> remove(String levelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyFor(levelId));
    } catch (error, stack) {
      ErrorTracker.logSilent('curriculum.cache_remove', error, stackTrace: stack);
    }
  }
}
