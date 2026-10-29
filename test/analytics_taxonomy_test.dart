import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/analytics/analytics_taxonomy.dart';

/// Contrato de la taxonomía de eventos (P-15 / #100).
///
/// Tres invariantes:
///  1. `AnalyticsEvent` es la única fuente de nombres: `all` coincide con las
///     constantes declaradas y ningún punto de emisión usa un literal.
///  2. `sanitizeAnalyticsProperties` nunca deja pasar PII ni texto libre.
///  3. Los nombres son `snake_case` y no se repiten.
void main() {
  final taxonomySource = File(
    'lib/core/analytics/analytics_taxonomy.dart',
  ).readAsStringSync();
  final declaredConstants = RegExp(
    r"static const (\w+) = '([a-z0-9_]+)';",
  ).allMatches(taxonomySource).toList();
  final declared = declaredConstants.map((m) => m.group(2)!).toSet();
  final declaredNames = declaredConstants.map((m) => m.group(1)!).toSet();

  group('taxonomía', () {
    test('todas las constantes están registradas en `all`', () {
      expect(declared, isNotEmpty);
      expect(
        AnalyticsEvent.all,
        containsAll(declared),
        reason: 'una constante nueva debe entrar en `all` (vistas y panel)',
      );
    });

    test('`all` no tiene duplicados ni nombres mal formados', () {
      expect(AnalyticsEvent.all.length, declared.length);
      for (final name in AnalyticsEvent.all) {
        expect(
          RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name),
          isTrue,
          reason: 'nombre no snake_case: $name',
        );
      }
    });

    test('ningún punto de emisión usa un literal como nombre de evento', () {
      final literalTrack = RegExp(r"""(?:\.track|\b_track)\(\s*[^,)]*,\s*'""");
      final singleArgLiteral = RegExp(r"""\b_track\(\s*'""");
      final offenders = <String>[];

      for (final file in _dartSources()) {
        final content = file.readAsStringSync();
        if (literalTrack.hasMatch(content) ||
            singleArgLiteral.hasMatch(content)) {
          offenders.add(file.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'usa AnalyticsEvent.<evento> en su lugar: $offenders',
      );
    });

    test('todos los eventos usados en lib/ están declarados', () {
      final used = <String>{};
      for (final file in _dartSources()) {
        for (final match in RegExp(
          r'AnalyticsEvent\.(\w+)',
        ).allMatches(file.readAsStringSync())) {
          used.add(match.group(1)!);
        }
      }

      expect(used, isNotEmpty);
      // `all` es el nombre del propio conjunto de constantes.
      final known = <String>{...declaredNames, 'all'};
      expect(used.difference(known), isEmpty);
    });
  });

  group('sanitizeAnalyticsProperties', () {
    test('descarta claves con PII o texto libre', () {
      final clean = sanitizeAnalyticsProperties({
        'email': 'student@example.com',
        'full_name': 'Ada',
        'message': 'hola profe',
        'transcript': 'audio transcrito',
        'content': 'texto del tutor',
        'token': 'jwt',
        'audio': 'path.m4a',
        'scenario_id': 'cafe_01',
      });

      expect(clean, {'scenario_id': 'cafe_01'});
    });

    test('solo conserva primitivos y descarta listas y mapas', () {
      final clean = sanitizeAnalyticsProperties({
        'step': 2,
        'minutes': 12.5,
        'oracle': true,
        'level': 'B1',
        'interests': ['travel', 'music'],
        'nested': {'a': 1},
      });

      expect(clean, {
        'step': 2,
        'minutes': 12.5,
        'oracle': true,
        'level': 'B1',
      });
    });

    test('trunca textos largos y limita el número de claves', () {
      final long = 'x' * 500;
      final clean = sanitizeAnalyticsProperties({'reason': long});
      expect((clean['reason'] as String).length, 200);

      final many = <String, dynamic>{for (var i = 0; i < 40; i++) 'k$i': i};
      expect(sanitizeAnalyticsProperties(many).length, 20);
    });

    test('entrada nula o vacía devuelve un mapa vacío', () {
      expect(sanitizeAnalyticsProperties(null), isEmpty);
      expect(sanitizeAnalyticsProperties(const {}), isEmpty);
    });
  });
}

Iterable<File> _dartSources() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart') ||
        entity.path.endsWith('.freezed.dart') ||
        entity.path.endsWith('.gr.dart')) {
      continue;
    }
    yield entity;
  }
}
