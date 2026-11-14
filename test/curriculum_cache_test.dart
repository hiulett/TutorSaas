import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/curriculum/data/cache/curriculum_pack_store.dart';
import 'package:tutorsaas/features/curriculum/data/repositories/curriculum_repository.dart';
import 'package:tutorsaas/features/curriculum/domain/models/curriculum_pack.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

const _cachedVersion = 1794000000;

List<String> catalogIds(String levelId) =>
    catalogLessonsForLevel(levelId).map((lesson) => lesson.id).toList();

/// Pack mínimo con las lecciones en el orden pedido (5 por unidad).
Map<String, dynamic> packFromIds(
  String levelId,
  List<String> ids, {
  int contentVersion = _cachedVersion,
}) {
  final units = <Map<String, dynamic>>[];
  for (var index = 0; index < ids.length; index += 5) {
    final slice = ids.skip(index).take(5).toList();
    units.add({
      'id': '$levelId-u${index ~/ 5 + 1}',
      'slug': '$levelId-u${index ~/ 5 + 1}',
      'title': '$levelId unidad ${index ~/ 5 + 1}',
      'order_index': index ~/ 5 + 1,
      'lessons': [
        for (var offset = 0; offset < slice.length; offset++)
          {
            'id': slice[offset],
            'title': LessonCatalog.getLessonById(slice[offset])?.title ?? slice[offset],
            'order_index': offset + 1,
          },
      ],
    });
  }
  return {
    'level': {'id': levelId, 'cefr': levelId.toUpperCase()},
    'content_version': contentVersion,
    'units': units,
  };
}

Map<String, dynamic> emptyDelta(String levelId, int contentVersion) => {
      'level': {'id': levelId, 'cefr': levelId.toUpperCase()},
      'content_version': contentVersion,
      'units': const [],
    };

class _FakeRemote implements CurriculumRemoteDataSource {
  _FakeRemote({
    this.source = 'db',
    this.fullPack,
    this.deltaPack,
    this.failPack = false,
  });

  String source;
  Map<String, dynamic>? fullPack;
  Map<String, dynamic>? deltaPack;
  bool failPack;
  int packCalls = 0;
  int deltaCalls = 0;

  @override
  Future<String> fetchSource() async => source;

  @override
  Future<Map<String, dynamic>> fetchPack(String levelId, {int sinceVersion = 0}) async {
    packCalls++;
    if (failPack) throw StateError('sin red');
    if (sinceVersion > 0) {
      deltaCalls++;
      return deltaPack ?? emptyDelta(levelId, sinceVersion);
    }
    return fullPack ?? packFromIds(levelId, catalogIds(levelId));
  }
}

class _FakeStore implements CurriculumPackStore {
  final Map<String, Map<String, dynamic>> data = {};
  int writes = 0;
  int reads = 0;
  int removes = 0;

  @override
  Future<Map<String, dynamic>?> read(String levelId) async {
    reads++;
    return data[levelId];
  }

  @override
  Future<void> write(String levelId, Map<String, dynamic> pack) async {
    writes++;
    data[levelId] = pack;
  }

  @override
  Future<void> remove(String levelId) async {
    removes++;
    data.remove(levelId);
  }
}

List<String> idsOf(CurriculumPack pack) =>
    pack.lessons.map((lesson) => lesson.id).toList();

void main() {
  group('caché del pack', () {
    test('guarda el pack tras leerlo de la base', () async {
      final store = _FakeStore();
      final repository = CurriculumRepository(remote: _FakeRemote(), store: store);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'db');
      expect(store.writes, 1);
      expect(store.data['a1']?['content_version'], _cachedVersion);
    });

    test('sin red usa la caché aunque el pack tenga otro orden', () async {
      final store = _FakeStore();
      final cachedIds = catalogIds('a1').reversed.toList();
      store.data['a1'] = packFromIds('a1', cachedIds);

      final repository = CurriculumRepository(
        remote: _FakeRemote(failPack: true),
        store: store,
      );
      final pack = await repository.getLevelPack('a1');

      expect(pack.source, 'db');
      expect(repository.lastSource, 'db');
      expect(repository.lastSourceReason, 'offline_cache');
      expect(idsOf(pack), cachedIds);
      expect(store.reads, 1);
    });

    test('sin red y sin caché cae al catálogo', () async {
      final repository = CurriculumRepository(
        remote: _FakeRemote(failPack: true),
        store: _FakeStore(),
      );
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
      expect(repository.lastSourceReason, 'network');
    });

    test('una caché que ya no se puede renderizar se descarta', () async {
      final store = _FakeStore();
      store.data['a1'] = packFromIds('a1', catalogIds('a1').sublist(0, 19));

      final repository = CurriculumRepository(
        remote: _FakeRemote(failPack: true),
        store: store,
      );
      final pack = await repository.getLevelPack('a1');

      expect(pack.source, 'dart');
      expect(repository.lastSourceReason, 'network');
      expect(store.removes, 1);
      expect(store.data.containsKey('a1'), isFalse);
    });

    test('una caché de otro nivel se descarta', () async {
      final store = _FakeStore();
      store.data['a1'] = packFromIds('a2', catalogIds('a2'));

      final repository = CurriculumRepository(
        remote: _FakeRemote(failPack: true),
        store: store,
      );
      final pack = await repository.getLevelPack('a1');

      expect(pack.source, 'dart');
      expect(store.removes, 1);
    });

    test('con el flag en dart la caché ni se lee', () async {
      final store = _FakeStore();
      store.data['a1'] = packFromIds('a1', catalogIds('a1').reversed.toList());

      final repository = CurriculumRepository(
        remote: _FakeRemote(source: 'dart'),
        store: store,
      );
      final pack = await repository.getLevelPack('a1');

      expect(pack.source, 'dart');
      expect(repository.lastSourceReason, 'flag_dart');
      expect(store.reads, 0);
    });
  });

  group('invalidación por content_version', () {
    test('si la versión no cambió, sirve la caché sin descargar el nivel', () async {
      final store = _FakeStore();
      final cachedIds = catalogIds('a1').reversed.toList();
      store.data['a1'] = packFromIds('a1', cachedIds);
      final remote = _FakeRemote();
      final repository = CurriculumRepository(remote: remote, store: store);

      final pack = await repository.getLevelPack('a1', sinceVersion: _cachedVersion);

      expect(pack.source, 'db');
      expect(repository.lastSourceReason, 'not_modified');
      expect(idsOf(pack), cachedIds);
      expect(remote.deltaCalls, 1);
      expect(remote.packCalls, 1);
    });

    test('si hay cambios, descarga el nivel completo y reemplaza la caché', () async {
      final store = _FakeStore();
      store.data['a1'] = packFromIds('a1', catalogIds('a1').reversed.toList());
      final remote = _FakeRemote(
        deltaPack: packFromIds('a1', [catalogIds('a1').first], contentVersion: 2),
        fullPack: packFromIds('a1', catalogIds('a1'), contentVersion: 2),
      );
      final repository = CurriculumRepository(remote: remote, store: store);

      final pack = await repository.getLevelPack('a1', sinceVersion: _cachedVersion);

      expect(repository.lastSourceReason, 'flag');
      expect(idsOf(pack), catalogIds('a1'));
      expect(remote.deltaCalls, 1);
      expect(remote.packCalls, 2);
      expect(store.data['a1']?['content_version'], 2);
    });
  });

  group('memoria de sesión', () {
    test('la segunda lectura no vuelve a la red', () async {
      final remote = _FakeRemote();
      final repository = CurriculumRepository(remote: remote, store: _FakeStore());

      final first = await repository.getLevelPack('a1');
      final second = await repository.getLevelPack('a1');

      expect(remote.packCalls, 1);
      expect(repository.lastSourceReason, 'memory');
      expect(idsOf(second), idsOf(first));
    });

    test('invalidateSource olvida el pack y aplica el rollback', () async {
      final remote = _FakeRemote();
      final repository = CurriculumRepository(remote: remote, store: _FakeStore());
      expect((await repository.getLevelPack('a1')).source, 'db');

      remote.source = 'dart';
      repository.invalidateSource();
      final pack = await repository.getLevelPack('a1');

      expect(pack.source, 'dart');
      expect(repository.lastSourceReason, 'flag_dart');
      expect(idsOf(pack), catalogIds('a1'));
    });
  });
}
