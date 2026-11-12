import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// #275: red de seguridad contra el mojibake (UTF-8 leído como Latin-1/CP1252).
///
/// Todo `lib/` (`.dart` y `.arb`) se guarda en UTF-8. Cuando una herramienta lo
/// lee con otra codificación y lo vuelve a escribir, cada acento se convierte
/// en su pareja mojibake: `ó` → `Ã³`, `í` → `Ã­`, `ñ` → `Ã±`, `—` → `â€”`,
/// `º` → `Âº`. Es un fallo silencioso: compila igual y solo se nota al mirar la
/// UI, así que esta prueba lo cierra.
///
/// **Criterio (importante):** no se busca el carácter `Ã` a secas, porque es
/// portugués legítimo y aparece en `lib/l10n/app_pt.arb` y en
/// `lib/core/i18n/app_translations.dart` (`MISSÃO`, `AVALIAÇÃO`, `SESSÃO`,
/// `NÃO`). La firma real del mojibake es:
///
///   * `Ã`, `Â`, `â`, `ð` (o `Å`) seguidas de un carácter del bloque C1
///     (U+0080–U+00BF) o de un carácter que solo existe en CP1252
///     (`€`, `’`, `œ`, `Ÿ`, `™`, …), que es justo lo que produce la doble
///     decodificación; y
///   * el carácter de reemplazo U+FFFD, señal de que el archivo ni siquiera es
///     UTF-8 válido.
///
/// Se excluyen `lib/l10n/app_localizations_*.dart`: son generados por
/// `flutter gen-l10n` y se regeneran desde los `.arb`. No se lee `assets/`.
///
/// Ejecutar con: `flutter test test/encoding_test.dart`.
void main() {
  group('#275 — codificación de lib/', () {
    test('lib/ no contiene mojibake ni U+FFFD', () {
      final violations = _scanLib();

      if (violations.isNotEmpty) {
        final report = StringBuffer()
          ..writeln(
            'Mojibake detectado en ${violations.length} línea(s). '
            'Reescribe el texto con su carácter correcto (ó, á, é, í, ú, ñ, '
            'É, Ó, ü, ö, ä, º, ª, —):',
          );
        for (final violation in violations) {
          report.writeln('  • $violation');
        }
        // Se imprime además del `expect` para que la lista quede en el log.
        // ignore: avoid_print
        print(report.toString());
      }

      expect(
        violations,
        isEmpty,
        reason: violations.isEmpty
            ? null
            : 'Hay ${violations.length} línea(s) con mojibake (ver el '
                'listado impreso arriba)',
      );
    });

    test('el detector acepta el portugués correcto (sin falsos positivos)', () {
      // Estos textos contienen `Ã` legítima: no deben marcarse.
      expect(_findInLine('MISSÃO URGENTE', 'muestra.arb', 1), isEmpty);
      expect(_findInLine('SESSÃO CONCLUÍDA', 'muestra.po', 2), isEmpty);
      expect(_findInLine('PRECISÃO (EST.) · 90ª/5º', 'muestra.po', 3), isEmpty);
      expect(
        _findInLine('¿Qué idioma quieres aprender? «botón»', 'muestra.po', 4),
        isEmpty,
      );
    });

    test('el detector caza las secuencias de mojibake', () {
      expect(_findInLine('lecciÃ³n', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('sesiÃ³n', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('reenvÃ­ado', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('espaÃ±ol', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('aÃ±adir', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('GestiÃ³n', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('Âº', 'muestra.arb', 1), hasLength(1));
      expect(_findInLine('Âª', 'muestra.arb', 1), hasLength(1));
      expect(_findInLine('guía â€” oculto', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('itâ€™s', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('ðŸ”¥', 'muestra.dart', 1), hasLength(1));
      expect(_findInLine('texto \uFFFD roto', 'muestra.dart', 1), hasLength(1));
    });

    test('las secuencias se reportan con su número de línea', () {
      final violations = _findInLine('lecciÃ³n', 'lib/x.dart', 42);
      expect(violations, hasLength(1));
      expect(violations.single.line, 42);
      expect(violations.single.path, 'lib/x.dart');
      expect(violations.single.toString(), startsWith('lib/x.dart:42'));
    });
  });
}

/// Un hallazgo: archivo, línea (1-based) y la firma encontrada.
class _Violation {
  const _Violation(this.path, this.line, this.detail);

  final String path;
  final int line;
  final String detail;

  @override
  String toString() => '$path:$line — $detail';
}

/// Recorre `lib/**/*.dart` y `lib/**/*.arb` (incluido `lib/l10n/*.arb`).
///
/// `flutter test` se ejecuta con la raíz del paquete como directorio actual.
List<_Violation> _scanLib() {
  final root = Directory('lib');
  expect(root.existsSync(), isTrue, reason: 'No se encontró el directorio lib/');

  final files = root
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => _isTarget(file.path))
      .toList()
    ..sort((a, b) => _relative(a.path).compareTo(_relative(b.path)));

  final violations = <_Violation>[];
  for (final file in files) {
    violations.addAll(_scanFile(file));
  }
  return violations;
}

/// Solo `.dart` y `.arb`, excluyendo los localizadores generados.
bool _isTarget(String rawPath) {
  final path = _relative(rawPath);
  final isArb = path.endsWith('.arb');
  final isDart = path.endsWith('.dart');
  if (!isArb && !isDart) return false;
  if (isDart &&
      RegExp(r'(^|/)lib/l10n/app_localizations_[^/]+\.dart$').hasMatch(path)) {
    return false;
  }
  return true;
}

/// Ruta normalizada con `/` para que el reporte sea igual en Windows y POSIX.
String _relative(String rawPath) => rawPath.replaceAll('\\', '/');

/// Lee el archivo y devuelve todas las líneas con firma de mojibake.
List<_Violation> _scanFile(File file) {
  final path = _relative(file.path);
  final bytes = file.readAsBytesSync();
  String text;
  try {
    // Estricto a propósito: si no es UTF-8 válido, ya hay corrupción.
    text = utf8.decode(bytes);
  } on FormatException {
    text = utf8.decode(bytes, allowMalformed: true);
  }

  final violations = <_Violation>[];
  final lines = const LineSplitter().convert(text);
  for (var i = 0; i < lines.length; i++) {
    violations.addAll(_findInLine(lines[i], path, i + 1));
  }
  return violations;
}

/// Devuelve como máximo un hallazgo por línea (el primero), para que la lista
/// de rutas culpables sea legible.
List<_Violation> _findInLine(String line, String path, [int lineNumber = 0]) {
  for (var i = 0; i < line.length; i++) {
    final code = line.codeUnitAt(i);

    if (code == 0xFFFD) {
      return <_Violation>[
        _Violation(
          path,
          lineNumber,
          'carácter de reemplazo U+FFFD: el tramo no es UTF-8 válido',
        ),
      ];
    }

    // Controles C1 (U+0080–U+009F): no son texto legítimo en un archivo fuente.
    if (code >= 0x0080 && code <= 0x009F) {
      return <_Violation>[
        _Violation(
          path,
          lineNumber,
          'carácter de control C1 U+${_hex(code)}',
        ),
      ];
    }

    if (!_isMojibakeLead(code) || i + 1 >= line.length) continue;
    final next = line.codeUnitAt(i + 1);
    if (_isMojibakeFollower(next)) {
      return <_Violation>[
        _Violation(
          path,
          lineNumber,
          'secuencia mojibake U+${_hex(code)} U+${_hex(next)}',
        ),
      ];
    }
  }
  return const <_Violation>[];
}

/// Primer byte de un carácter UTF-8 (2, 3 o 4 bytes) leído como Latin-1/CP1252.
bool _isMojibakeLead(int code) {
  const leads = <int>{
    0x00C2, // Â  (empieza las secuencias de 2 bytes: Âº, Âª, Â¡)
    0x00C3, // Ã  (empieza ó, á, é, í, ú, ñ, ü, ö, ä, É, Ó...)
    0x00E2, // â  (empieza —, ’, “, ”, …)
    0x00F0, // ð  (empiezan los emoji de 4 bytes: ðŸ”¥)
    0x00C5, // Å  (variante CP1252: Å“ = œ, Å¸ = Ÿ)
  };
  return leads.contains(code);
}

/// Segundo carácter que delata la doble decodificación.
bool _isMojibakeFollower(int code) {
  // Bloque C1: continuadores UTF-8 re-interpretados como Latin-1
  // (³, ©, º, ½, ±, ¼, ¾, ...).
  if (code >= 0x0080 && code <= 0x00BF) return true;

  // Extras de CP1252 que no caen en el bloque C1 pero forman parte de las
  // secuencias clásicas: â€” (—), â€™ (’), Å“ (œ), Å¸ (Ÿ), â„¢ (™).
  const extraCp1252 = <int>{
    0x20AC, // €
    0x201A, // ‚
    0x0192, // ƒ
    0x201E, // „
    0x2026, // …
    0x2020, // †
    0x2021, // ‡
    0x02C6, // ˆ
    0x2030, // ‰
    0x0160, // Š
    0x2039, // ‹
    0x0152, // Œ
    0x017D, // Ž
    0x2018, // ‘
    0x2019, // ’
    0x201C, // “
    0x201D, // ”
    0x2022, // •
    0x2013, // –
    0x2014, // —
    0x02DC, // ˜
    0x2122, // ™
    0x0161, // š
    0x203A, // ›
    0x0153, // œ
    0x017E, // ž
    0x0178, // Ÿ
  };
  return extraCp1252.contains(code);
}

String _hex(int code) => code.toRadixString(16).toUpperCase().padLeft(4, '0');
