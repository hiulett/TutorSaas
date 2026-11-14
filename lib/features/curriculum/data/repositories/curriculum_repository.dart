import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import 'package:tutorsaas/features/curriculum/data/cache/curriculum_pack_store.dart';
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

/// Repositorio del currículo con selector de origen (CUR-16), activación
/// progresiva (CUR-24) y caché/offline (CUR-17).
///
/// El flag `curriculum_source` decide si se lee de PostgreSQL o del catálogo
/// Dart empaquetado. Cualquier fallo remoto, o un pack incompleto, cae a la
/// caché local si existe y, si no, al catálogo: quedarse sin currículo es peor
/// que servir contenido de la versión anterior.
class CurriculumRepository {
  CurriculumRepository({
    required CurriculumRemoteDataSource remote,
    CurriculumPackStore? store,
    this.isRemoteEnabled = true,
    DateTime Function()? now,
    this.sourceTtl = const Duration(seconds: 60),
  })  : _remote = remote,
        _store = store ?? const _NoopCurriculumPackStore(),
        _now = now ?? DateTime.now;

  final CurriculumRemoteDataSource _remote;
  final CurriculumPackStore _store;

  /// Interruptor local de seguridad: con `false` no se llama a la red.
  final bool isRemoteEnabled;

  /// Cuánto se recuerda el flag antes de volver a preguntarlo. Sesenta segundos
  /// hacen que apagar el flag (rollback) surta efecto sin reiniciar la app y sin
  /// preguntar en cada cambio de nivel.
  final Duration sourceTtl;

  final DateTime Function() _now;

  String? _lastSource;
  String? _lastSourceReason;
  String? _cachedSource;
  DateTime? _cachedSourceAt;
  final Map<String, CurriculumPack> _memory = {};

  /// Último origen usado (`db` o `dart`), para diagnósticos y analítica.
  String? get lastSource => _lastSource;

  /// Por qué se sirvió ese origen: `flag`, `memory`, `not_modified`,
  /// `offline_cache`, `flag_dart`, `remote_disabled`, `empty_pack`,
  /// `incomplete_pack`, `unknown_pack`, `duplicated_pack`, `wrong_level` o
  /// `network`. Útil para medir la activación y el modo offline.
  String? get lastSourceReason => _lastSourceReason;

  /// Fuerza a repreguntar el flag y a olvidar los packs en memoria en la próxima
  /// lectura (rollback inmediato). La caché en disco se conserva: se valida al
  /// usarla.
  void invalidateSource() {
    _cachedSource = null;
    _cachedSourceAt = null;
    _memory.clear();
  }

  Future<String> _resolveSource() async {
    final cachedAt = _cachedSourceAt;
    if (_cachedSource != null &&
        cachedAt != null &&
        _now().difference(cachedAt) < sourceTtl) {
      return _cachedSource!;
    }
    final source = await _remote.fetchSource();
    _cachedSource = source;
    _cachedSourceAt = _now();
    return source;
  }

  Future<CurriculumPack> getLevelPack(String levelId, {int sinceVersion = 0}) async {
    if (!isRemoteEnabled) {
      return _fromDart(levelId, 'remote_disabled');
    }

    try {
      final source = await _resolveSource();
      if (source != 'db') {
        return _fromDart(levelId, 'flag_dart');
      }

      // Dentro de la sesión no se vuelve a descargar el mismo nivel.
      if (sinceVersion <= 0) {
        final remembered = _memory[levelId];
        if (remembered != null) {
          _lastSource = 'db';
          _lastSourceReason = 'memory';
          return remembered;
        }
      }

      // Invalidación por versión: si el cliente pide solo lo cambiado y no hay
      // novedades, la caché vale y no se descarga el nivel completo.
      if (sinceVersion > 0) {
        final cached = await _readCached(levelId);
        if (cached != null) {
          final delta = await _remote.fetchPack(levelId, sinceVersion: sinceVersion);
          final changed = _lessonCount(delta);
          final version = (delta['content_version'] as num?)?.toInt() ?? 0;
          if (changed == 0 && version <= sinceVersion) {
            _remember(levelId, cached);
            _lastSource = 'db';
            _lastSourceReason = 'not_modified';
            return cached;
          }
        }
      }

      final json = await _remote.fetchPack(levelId, sinceVersion: 0);
      final pack = CurriculumPack.fromJson(json);
      final problem = _servingProblem(pack, levelId);
      if (problem != null) {
        _logFallback('curriculum.pack_$problem', levelId);
        return _fromDart(levelId, '${problem}_pack');
      }

      _remember(levelId, pack);
      await _store.write(levelId, json);
      _lastSource = 'db';
      _lastSourceReason = 'flag';
      return pack;
    } catch (error, stack) {
      ErrorTracker.logSilent('curriculum.getLevelPack', error, stackTrace: stack);
      // Sin red: se usa la última copia buena del nivel si existe.
      final cached = await _readCached(levelId);
      if (cached != null) {
        _remember(levelId, cached);
        _lastSource = 'db';
        _lastSourceReason = 'offline_cache';
        return cached;
      }
      return _fromDart(levelId, 'network');
    }
  }

  /// Lección suelta: se busca en el pack del nivel.
  Future<CurriculumLesson?> getLesson(String levelId, String lessonId) async {
    final pack = await getLevelPack(levelId);
    return pack.lessonById(lessonId);
  }

  void _remember(String levelId, CurriculumPack pack) {
    _memory[levelId] = pack;
  }

  Future<CurriculumPack?> _readCached(String levelId) async {
    final json = await _store.read(levelId);
    if (json == null) return null;
    try {
      final pack = CurriculumPack.fromJson(json);
      final problem = _servingProblem(pack, levelId);
      if (problem != null) {
        ErrorTracker.logSilent(
          'curriculum.cache_$problem',
          StateError('la cache de $levelId ya no es servible'),
        );
        await _store.remove(levelId);
        return null;
      }
      return pack;
    } catch (error, stack) {
      ErrorTracker.logSilent('curriculum.cache_invalid', error, stackTrace: stack);
      await _store.remove(levelId);
      return null;
    }
  }

  int _lessonCount(Map<String, dynamic> json) {
    final units = json['units'];
    if (units is! List) return 0;
    var total = 0;
    for (final unit in units.whereType<Map>()) {
      final lessons = unit['lessons'];
      if (lessons is List) total += lessons.length;
    }
    return total;
  }

  /// `null` si el pack sirve exactamente las lecciones que la app ya sabe
  /// renderizar para el nivel; si no, el nombre del problema.
  ///
  /// La base puede tener **más** contenido que el catálogo (ese es el objetivo
  /// del plan), pero mientras los renderers vivan en código una lección que la
  /// app no conoce no se puede enseñar: se considera pack inválido y se sirve
  /// la caché o el catálogo entero. Es la red de seguridad de la activación.
  String? _servingProblem(CurriculumPack pack, String levelId) {
    if (pack.level.id != levelId && pack.level.id.isNotEmpty) return 'wrong_level';
    if (pack.units.isEmpty) return 'empty';

    final ids = pack.lessons.map((lesson) => lesson.id).toList(growable: false);
    if (ids.toSet().length != ids.length) return 'duplicated';

    final known = {for (final lesson in catalogLessonsForLevel(levelId)) lesson.id};
    if (known.difference(ids.toSet()).isNotEmpty) return 'incomplete';
    if (ids.toSet().difference(known).isNotEmpty) return 'unknown';
    return null;
  }

  void _logFallback(String key, String levelId) {
    ErrorTracker.logSilent(key, StateError('el pack de $levelId no es servible'));
  }

  CurriculumPack _fromDart(String levelId, String reason) {
    _lastSource = 'dart';
    _lastSourceReason = reason;
    return curriculumPackFromDart(levelId);
  }
}

class _NoopCurriculumPackStore implements CurriculumPackStore {
  const _NoopCurriculumPackStore();

  @override
  Future<Map<String, dynamic>?> read(String levelId) async => null;

  @override
  Future<void> remove(String levelId) async {}

  @override
  Future<void> write(String levelId, Map<String, dynamic> pack) async {}
}

/// Atajo para producción: catálogo Dart mientras el flag esté en `dart`.
CurriculumRepository buildCurriculumRepository(SupabaseClient client) {
  return CurriculumRepository(
    remote: SupabaseCurriculumDataSource(client),
    store: const SharedPreferencesCurriculumPackStore(),
  );
}

@visibleForTesting
String describeCurriculumSource(CurriculumPack pack) => '${pack.source}:${pack.level.id}';
