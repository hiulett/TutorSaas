import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regresión de #49: los `.arb` no deben contener caracteres de reemplazo
/// (U+FFFD) ni controles C1, señal de que el archivo se guardó con una
/// codificación equivocada.
///
/// Ojo: letras como Ç (U+00C7), Ã (U+00C3) o Ê (U+00CA) son **válidas** en
/// portugués y español; no son mojibake.
void main() {
  test('los archivos .arb están en UTF-8 limpio', () {
    for (final locale in ['en', 'es', 'pt']) {
      final file = File('lib/l10n/app_$locale.arb');
      expect(file.existsSync(), isTrue, reason: 'falta ${file.path}');

      final content = file.readAsStringSync();

      expect(
        content.contains('\uFFFD'),
        isFalse,
        reason: 'app_$locale.arb contiene U+FFFD (carácter de reemplazo)',
      );

      final c1 = content.codeUnits.where((c) => c >= 0x80 && c <= 0x9F).toList();
      expect(
        c1,
        isEmpty,
        reason: 'app_$locale.arb contiene controles C1: $c1',
      );
    }
  });
}
