import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/curriculum/data/repositories/curriculum_repository.dart';
import 'package:tutorsaas/features/curriculum/domain/models/curriculum_pack.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

class _FakeRemote implements CurriculumRemoteDataSource {
  _FakeRemote({this.source = 'db', this.pack, this.failSource = false, this.failPack = false});

  final String source;
  final Map<String, dynamic>? pack;
  final bool failSource;
  final bool failPack;
  int packCalls = 0;

  @override
  Future<String> fetchSource() async {
    if (failSource) throw StateError('sin red');
    return source;
  }

  @override
  Future<Map<String, dynamic>> fetchPack(String levelId, {int sinceVersion = 0}) async {
    packCalls++;
    if (failPack) throw StateError('sin red');
    return pack ?? _pack();
  }
}

Map<String, dynamic> _pack({List<Map<String, dynamic>>? units}) => {
      'level': {'id': 'a1', 'cefr': 'A1', 'name': 'Aprendiz', 'order_index': 2},
      'content_version': 1763000000,
      'units': units ??
          [
            {
              'id': 'u1',
              'slug': 'a1-u1',
              'title': 'A1 · Unidad 1',
              'order_index': 1,
              'lessons': [
                {
                  'id': 'a1_ordering_coffee_at_a_cafe',
                  'title': 'Ordering Coffee',
                  'category': 'daily',
                  'difficulty': 1,
                  'order_index': 1,
                  'version': 1,
                  'objectives': [
                    {
                      'code': 'g1',
                      'description': 'Order a coffee drink',
                      'competency': 'speaking',
                      'order_index': 1,
                      'evidence_examples': {
                        'keywords': ['order', 'coffee'],
                        'example_phrase': 'Order a coffee drink',
                      },
                    },
                  ],
                  'phrases': [
                    {
                      'order_index': 1,
                      'phrase': 'Hello!',
                      'translation': '¡Hola!',
                      'translation_status': 'ok',
                    },
                  ],
                  'activities': const [],
                },
              ],
            },
          ],
    };

/// Pack completo de A1: la activación exige las 20 lecciones del catálogo.
Map<String, dynamic> _completePack() {
  final ids = LessonCatalog.catalog
      .where((lesson) => lesson.level == 'A1')
      .map((lesson) => lesson.id)
      .toList();
  final units = <Map<String, dynamic>>[];
  for (var index = 0; index < ids.length; index += 5) {
    final slice = ids.skip(index).take(5).toList();
    units.add({
      'id': 'u${index ~/ 5 + 1}',
      'slug': 'a1-u${index ~/ 5 + 1}',
      'title': 'A1 · Unidad ${index ~/ 5 + 1}',
      'order_index': index ~/ 5 + 1,
      'lessons': [
        for (var offset = 0; offset < slice.length; offset++)
          {
            'id': slice[offset],
            'title': LessonCatalog.getLessonById(slice[offset])?.title ?? slice[offset],
            'category': 'daily',
            'difficulty': 1,
            'order_index': offset + 1,
            'version': 1,
            'objectives': const [],
            'phrases': const [],
            'activities': const [],
          },
      ],
    });
  }
  return {
    'level': {'id': 'a1', 'cefr': 'A1', 'name': 'Aprendiz', 'order_index': 2},
    'content_version': 1794000000,
    'units': units,
  };
}

void main() {
  group('CurriculumPack.fromJson', () {
    test('lee nivel, versión, unidades y lección', () {
      final pack = CurriculumPack.fromJson(_pack());
      expect(pack.level.id, 'a1');
      expect(pack.level.cefr, 'A1');
      expect(pack.contentVersion, 1763000000);
      expect(pack.units, hasLength(1));
      expect(pack.lessons.single.id, 'a1_ordering_coffee_at_a_cafe');
      expect(pack.source, 'db');
    });

    test('conserva palabras clave y estado de traducción', () {
      final lesson = CurriculumPack.fromJson(_pack()).lessons.single;
      expect(lesson.objectives.single.keywords, ['order', 'coffee']);
      expect(lesson.objectives.single.examplePhrase, 'Order a coffee drink');
      expect(lesson.phrases.single.isTranslated, isTrue);
    });

    test('tolera campos ausentes sin romper', () {
      final pack = CurriculumPack.fromJson({
        'level': {'id': 'b2'},
        'units': [
          {
            'slug': 'b2-u1',
            'lessons': [
              {'id': 'x'},
            ],
          },
        ],
      });
      expect(pack.level.cefr, '');
      expect(pack.contentVersion, 0);
      expect(pack.lessons.single.title, '');
      expect(pack.lessons.single.objectives, isEmpty);
    });

    test('lessonById encuentra y devuelve null si no está', () {
      final pack = CurriculumPack.fromJson(_pack());
      expect(pack.lessonById('a1_ordering_coffee_at_a_cafe'), isNotNull);
      expect(pack.lessonById('no_existe'), isNull);
    });
  });

  group('CurriculumRepository con flag', () {
    test('con fuente db lee el pack remoto', () async {
      final remote = _FakeRemote(pack: _completePack());
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'db');
      expect(repository.lastSource, 'db');
      expect(remote.packCalls, 1);
    });

    test('con flag dart no llama al pack y usa el catálogo', () async {
      final remote = _FakeRemote(source: 'dart');
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
      expect(remote.packCalls, 0);
      expect(pack.lessons, isNotEmpty);
      expect(pack.lessons.every((lesson) => lesson.id.startsWith('a1_')), isTrue);
    });

    test('si falla la red cae al catálogo', () async {
      final remote = _FakeRemote(failSource: true);
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('b1');
      expect(pack.source, 'dart');
      expect(pack.lessons, isNotEmpty);
    });

    test('si el pack falla cae al catálogo', () async {
      final remote = _FakeRemote(failPack: true);
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
      expect(pack.lessons, isNotEmpty);
    });

    test('si el pack llega sin unidades cae al catálogo', () async {
      final remote = _FakeRemote(pack: _pack(units: const []));
      final repository = CurriculumRepository(remote: remote);
      final pack = await repository.getLevelPack('a1');
      expect(pack.source, 'dart');
    });

    test('con el interruptor local apagado no toca la red', () async {
      final remote = _FakeRemote();
      final repository = CurriculumRepository(remote: remote, isRemoteEnabled: false);
      final pack = await repository.getLevelPack('a2');
      expect(pack.source, 'dart');
      expect(remote.packCalls, 0);
    });

    test('getLesson busca dentro del pack del nivel', () async {
      final repository = CurriculumRepository(remote: _FakeRemote(pack: _completePack()));
      final lesson = await repository.getLesson('a1', 'a1_ordering_coffee_at_a_cafe');
      expect(lesson, isNotNull);
      expect(
        lesson!.title,
        LessonCatalog.getLessonById('a1_ordering_coffee_at_a_cafe')!.title,
      );
    });
  });

  group('Fallback al catálogo Dart', () {
    test('cada nivel tiene sus 20 lecciones en 4 unidades de 5', () {
      for (final levelId in ['pre_a1', 'a1', 'a2', 'b1', 'b2', 'c1', 'c2']) {
        final pack = curriculumPackFromDart(levelId);
        expect(pack.lessons, hasLength(20), reason: '$levelId: ${pack.lessons.length}');
        expect(pack.units, hasLength(4), reason: levelId);
        expect(pack.units.every((unit) => unit.lessons.length == 5), isTrue);
      }
    });

    test('los ids del catálogo son los mismos que los importados', () {
      final ids = curriculumPackFromDart('a1').lessons.map((lesson) => lesson.id).toSet();
      expect(ids, contains('a1_ordering_coffee_at_a_cafe'));
      expect(ids.every((id) => id.startsWith('a1_')), isTrue);
    });

    test('describeCurriculumSource identifica el origen', () {
      expect(describeCurriculumSource(curriculumPackFromDart('c2')), 'dart:c2');
    });
  });
}
