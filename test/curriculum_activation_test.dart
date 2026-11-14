import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/curriculum/data/repositories/curriculum_repository.dart';
import 'package:tutorsaas/features/curriculum/domain/models/curriculum_pack.dart';
import 'package:tutorsaas/features/curriculum/presentation/providers/curriculum_providers.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

const _levels = ['pre_a1', 'a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

class _FakeRemote implements CurriculumRemoteDataSource {
  _FakeRemote({this.source = 'dart', this.pack, this.failPack = false});

  String source;
  Map<String, dynamic>? pack;
  bool failPack;
  int sourceCalls = 0;
  int packCalls = 0;

  @override
  Future<String> fetchSource() async {
    sourceCalls++;
    return source;
  }

  @override
  Future<Map<String, dynamic>> fetchPack(String levelId, {int sinceVersion = 0}) async {
    packCalls++;
    if (failPack) throw StateError('sin red');
    return pack ?? packFromIds(levelId, catalogIds(levelId));
  }
}

class _StubRepository extends CurriculumRepository {
  _StubRepository(this.pack) : super(remote: _FakeRemote());

  final CurriculumPack pack;

  @override
  Future<CurriculumPack> getLevelPack(String levelId, {int sinceVersion = 0}) async => pack;
}

/// Pack mínimo con las lecciones en el orden pedido (5 por unidad).
Map<String, dynamic> packFromIds(String levelId, List<String> ids) {
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
    'content_version': 1794000000,
    'units': units,
  };
}

List<String> catalogIds(String levelId) =>
    catalogLessonsForLevel(levelId).map((lesson) => lesson.id).toList();

ProviderContainer _containerFor(CurriculumRepository repository) {
  final container = ProviderContainer(
    overrides: [curriculumRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

List<String> _ids(List<LessonData> lessons) => lessons.map((lesson) => lesson.id).toList();

void main() {
  group('flag en dart: no cambia el comportamiento', () {
    test('la Ruta recibe el catálogo exacto en los 7 niveles', () async {
      for (final levelId in _levels) {
        final repository = CurriculumRepository(remote: _FakeRemote(source: 'dart'));
        final lessons = await _containerFor(repository)
            .read(curriculumLevelLessonsProvider(levelId).future);
        expect(_ids(lessons), catalogIds(levelId), reason: levelId);
        expect(repository.lastSource, 'dart');
        expect(repository.lastSourceReason, 'flag_dart');
      }
    });

    test('el adaptador Dart respeta el orden pedagógico, no el alfabético', () {
      final pack = curriculumPackFromDart('a1');
      expect(pack.lessons.map((lesson) => lesson.id).toList(), catalogIds('a1'));
      expect(pack.lessons.first.id, 'a1_ordering_coffee_at_a_cafe');
    });

    test('curriculumLevelIdForCefr traduce el CEFR de la pantalla', () {
      expect(curriculumLevelIdForCefr('PRE-A1'), 'pre_a1');
      expect(curriculumLevelIdForCefr('B1'), 'b1');
      expect(curriculumLevelIdForCefr(' c2 '), 'c2');
    });
  });

  group('encender db', () {
    test('sirve el pack remoto con su orden', () async {
      final ids = catalogIds('a1').reversed.toList();
      final remote = _FakeRemote(source: 'db', pack: packFromIds('a1', ids));
      final repository = CurriculumRepository(remote: remote);
      final lessons =
          await _containerFor(repository).read(curriculumLevelLessonsProvider('a1').future);
      expect(_ids(lessons), ids);
      expect(repository.lastSource, 'db');
      expect(repository.lastSourceReason, 'flag');
    });

    test('un pack incompleto cae al catálogo', () async {
      final ids = catalogIds('a1')..removeLast();
      final remote = _FakeRemote(source: 'db', pack: packFromIds('a1', ids));
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
      expect(repository.lastSourceReason, 'incomplete_pack');
      expect(pack.lessons, hasLength(20));
    });

    test('un pack con lecciones que la app no sabe renderizar se descarta entero', () async {
      // Defensa del provider: aunque el repositorio sirviera el pack, enseñar
      // 19 de 20 lecciones es peor que repetir el catálogo completo.
      final ids = [...catalogIds('a1').take(19), 'a1_leccion_que_no_existe_en_la_app'];
      final repository = _StubRepository(CurriculumPack.fromJson(packFromIds('a1', ids)));
      final lessons = await _containerFor(repository)
          .read(curriculumLevelLessonsProvider('a1').future);
      expect(_ids(lessons), catalogIds('a1'));
    });

    test('una lección que la app no conoce hace caer el nivel al catálogo', () async {
      final ids = [...catalogIds('a1'), 'a1_leccion_nueva_sin_renderer'];
      final remote = _FakeRemote(source: 'db', pack: packFromIds('a1', ids));
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
      expect(repository.lastSourceReason, 'unknown_pack');
      expect(pack.lessons, hasLength(20));
    });

    test('un pack vacío cae al catálogo', () async {
      final remote = _FakeRemote(source: 'db', pack: packFromIds('a1', const []));
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
      expect(repository.lastSourceReason, 'empty_pack');
    });

    test('si la red falla, la app sigue enseñando el catálogo', () async {
      final repository = CurriculumRepository(remote: _FakeRemote(source: 'db', failPack: true));
      final pack = await repository.getLevelPack('b1');
      expect(pack.source, 'dart');
      expect(pack.lessons, hasLength(20));
      expect(repository.lastSourceReason, 'network');
    });

    test('sin caché, since_version cae a la descarga completa', () async {
      final repository = CurriculumRepository(remote: _FakeRemote(source: 'db'));
      final pack = await repository.getLevelPack('a2', sinceVersion: 1794000000);
      expect(pack.source, 'db');
      expect(pack.lessons, hasLength(20));
    });
  });

  group('rollback a dart', () {
    test('apagar el flag devuelve el catálogo tras la ventana de caché', () async {
      var now = DateTime(2026, 11, 13, 12);
      final remote = _FakeRemote(
        source: 'db',
        pack: packFromIds('a1', catalogIds('a1').reversed.toList()),
      );
      final repository = CurriculumRepository(remote: remote, now: () => now);

      final first = await repository.getLevelPack('a1');
      expect(first.source, 'db');

      remote.source = 'dart';
      now = now.add(const Duration(seconds: 61));

      final second = await repository.getLevelPack('a1');
      expect(second.source, 'dart');
      expect(repository.lastSourceReason, 'flag_dart');
      expect(second.lessons.map((lesson) => lesson.id).toList(), catalogIds('a1'));
    });

    test('invalidateSource aplica el rollback sin esperar la ventana', () async {
      final remote = _FakeRemote(source: 'db', pack: packFromIds('a1', catalogIds('a1')));
      final repository = CurriculumRepository(remote: remote);
      expect((await repository.getLevelPack('a1')).source, 'db');

      remote.source = 'dart';
      repository.invalidateSource();
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
    });

    test('el flag se pregunta una vez por ventana, no en cada nivel', () async {
      var now = DateTime(2026, 11, 13, 12);
      final remote = _FakeRemote(source: 'dart');
      final repository = CurriculumRepository(remote: remote, now: () => now);

      await repository.getLevelPack('a1');
      await repository.getLevelPack('a2');
      expect(remote.sourceCalls, 1);

      now = now.add(const Duration(seconds: 61));
      await repository.getLevelPack('b1');
      expect(remote.sourceCalls, 2);
    });
  });
}
