import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import 'package:tutorsaas/features/curriculum/domain/models/curriculum_pack.dart';

/// Acceso remoto al currículo. Es una interfaz para poder probar el repositorio
/// sin Supabase: el fallback al catálogo Dart es lo que más se rompe.
abstract class CurriculumRemoteDataSource {
  Future<String> fetchSource();

  Future<Map<String, dynamic>> fetchPack(String levelId, {int sinceVersion = 0});
}

class SupabaseCurriculumDataSource implements CurriculumRemoteDataSource {
  SupabaseCurriculumDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<String> fetchSource() async {
    final result = await _client.rpc<dynamic>('get_curriculum_source');
    return result is String ? result : 'dart';
  }

  @override
  Future<Map<String, dynamic>> fetchPack(String levelId, {int sinceVersion = 0}) async {
    final result = await _client.rpc<dynamic>(
      'get_curriculum_pack',
      params: {'p_level': levelId, 'p_since_version': sinceVersion},
    );
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return result.cast<String, dynamic>();
    throw StateError('get_curriculum_pack devolvió ${result.runtimeType}');
  }
}

/// Repositorio del currículo con selector de origen (CUR-16).
///
/// El flag `curriculum_source` decide si se lee de PostgreSQL o del catálogo
/// Dart empaquetado. Cualquier fallo remoto cae al catálogo: quedarse sin
/// currículo es peor que servir el contenido de la versión anterior.
class CurriculumRepository {
  CurriculumRepository({
    required CurriculumRemoteDataSource remote,
    this.isRemoteEnabled = true,
  }) : _remote = remote;

  final CurriculumRemoteDataSource _remote;

  /// Interruptor local de seguridad: con `false` no se llama a la red.
  final bool isRemoteEnabled;

  String? _lastSource;

  /// Último origen usado (`db` o `dart`), para diagnósticos y analítica.
  String? get lastSource => _lastSource;

  Future<CurriculumPack> getLevelPack(String levelId, {int sinceVersion = 0}) async {
    if (!isRemoteEnabled) {
      _lastSource = 'dart';
      return curriculumPackFromDart(levelId);
    }

    try {
      final source = await _remote.fetchSource();
      if (source != 'db') {
        _lastSource = 'dart';
        return curriculumPackFromDart(levelId);
      }

      final pack = CurriculumPack.fromJson(
        await _remote.fetchPack(levelId, sinceVersion: sinceVersion),
      );
      if (pack.units.isEmpty) {
        // Un nivel sin unidades en la base es un error de contenido, no una
        // respuesta válida: mejor el catálogo que una pantalla vacía.
        ErrorTracker.logSilent(
          'curriculum.pack_empty',
          StateError('el pack de $levelId llegó sin unidades'),
        );
        _lastSource = 'dart';
        return curriculumPackFromDart(levelId);
      }

      _lastSource = 'db';
      return pack;
    } catch (error, stack) {
      ErrorTracker.logSilent('curriculum.getLevelPack', error, stackTrace: stack);
      _lastSource = 'dart';
      return curriculumPackFromDart(levelId);
    }
  }

  /// Lección suelta: se busca en el pack del nivel.
  Future<CurriculumLesson?> getLesson(String levelId, String lessonId) async {
    final pack = await getLevelPack(levelId);
    return pack.lessonById(lessonId);
  }
}

/// Atajo para producción: catálogo Dart mientras el flag esté en `dart`.
CurriculumRepository buildCurriculumRepository(SupabaseClient client) {
  return CurriculumRepository(remote: SupabaseCurriculumDataSource(client));
}

@visibleForTesting
String describeCurriculumSource(CurriculumPack pack) => '${pack.source}:${pack.level.id}';
