import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regresión de #53: google_fonts debe encontrar cada variante en
/// `assets/google_fonts/`, con el nombre que espera el paquete
/// (`<Familia>-<Regular|Bold|Medium|…>.ttf`). Si falta una, el paquete intenta
/// descargarla y, sin red, lanza una excepción no manejada.
void main() {
  const expected = <String>[
    // Space Grotesk: 300-700
    'SpaceGrotesk-Light.ttf',
    'SpaceGrotesk-Regular.ttf',
    'SpaceGrotesk-Medium.ttf',
    'SpaceGrotesk-SemiBold.ttf',
    'SpaceGrotesk-Bold.ttf',
    // Inter: 100-900
    'Inter-Thin.ttf',
    'Inter-ExtraLight.ttf',
    'Inter-Light.ttf',
    'Inter-Regular.ttf',
    'Inter-Medium.ttf',
    'Inter-SemiBold.ttf',
    'Inter-Bold.ttf',
    'Inter-ExtraBold.ttf',
    'Inter-Black.ttf',
    // JetBrains Mono: 100-800
    'JetBrainsMono-Thin.ttf',
    'JetBrainsMono-ExtraLight.ttf',
    'JetBrainsMono-Light.ttf',
    'JetBrainsMono-Regular.ttf',
    'JetBrainsMono-Medium.ttf',
    'JetBrainsMono-SemiBold.ttf',
    'JetBrainsMono-Bold.ttf',
    'JetBrainsMono-ExtraBold.ttf',
  ];

  test('todas las variantes tipográficas están empaquetadas', () {
    for (final name in expected) {
      final file = File('assets/google_fonts/$name');
      expect(file.existsSync(), isTrue, reason: 'falta $name');
      expect(file.lengthSync(), greaterThan(1000), reason: '$name está vacío');
    }
  });

  test('no quedan nombres con peso numérico', () {
    final dir = Directory('assets/google_fonts');
    final bad = dir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => RegExp(r'-(100|200|300|400|500|600|700|800|900)\.ttf$').hasMatch(n))
        .toList();
    expect(bad, isEmpty, reason: 'google_fonts espera nombres cualitativos');
  });
}
