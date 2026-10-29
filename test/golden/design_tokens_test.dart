import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/core/theme/app_radius.dart';
import 'package:tutorsaas/core/theme/app_theme.dart';
import 'package:tutorsaas/core/theme/app_typography.dart';
import 'package:tutorsaas/core/widgets/glass_card.dart';

/// Guard del design system: paleta, radios y tipografías.
///
/// **Fuente de verdad: el código**, no un documento.
/// - Paleta: `lib/core/theme/app_colors.dart` (se parsea en tiempo de test, así
///   que añadir un token allí basta; no hay lista duplicada).
/// - Radios: `lib/core/theme/app_radius.dart`.
/// - Familias: `lib/core/theme/app_typography.dart` + `assets/google_fonts/`.
///
/// Los tests 1 y 3 son *lints de fuente*: recorren `lib/` y fallan si aparece un
/// color literal, un radio o una familia tipográfica que no exista en los
/// tokens. Los tests 2, 4 y 5 afirman los tokens, el `ThemeData` real y
/// `AppTypography`.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Las tres familias empaquetadas (ver `test/bundled_fonts_test.dart`).
  const allowedFamilies = {'spacegrotesk', 'inter', 'jetbrainsmono'};

  /// `google_fonts` añade el peso a la familia (`SpaceGrotesk_700`).
  String normalizeFamily(String family) =>
      family.split('_').first.toLowerCase().replaceAll(RegExp(r'[\s-]'), '');

  /// Colores neutros universales que no necesitan token propio.
  const neutrals = {'FF000000', 'FFFFFFFF'};

  // Se lee como latin1 para no fallar si algún fichero no es UTF-8 válido;
  // los literales que se buscan son ASCII.
  String readSource(File file) => latin1.decode(file.readAsBytesSync());

  Iterable<File> libFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  /// ARGB `#AARRGGBB` de cada token de `app_colors.dart`.
  late final Set<String> paletteArgb = RegExp(r'0x([0-9A-Fa-f]{8})')
      .allMatches(readSource(File('lib/core/theme/app_colors.dart')))
      .map((match) => match.group(1)!.toUpperCase())
      .toSet();

  late final Set<String> paletteRgb = paletteArgb
      .map((argb) => argb.substring(2))
      .toSet();

  String argbOf(Color color) =>
      color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();

  bool isKnownColor(String argb) =>
      neutrals.contains(argb) ||
      paletteArgb.contains(argb) ||
      paletteRgb.contains(argb.substring(2));

  test('1. ningún color literal de lib/ sale de AppColors', () {
    final palette = paletteArgb;
    expect(palette, isNotEmpty, reason: 'la paleta se extrae del código');

    final violations = <String>[];
    for (final file in libFiles()) {
      if (file.uri.pathSegments.last == 'app_colors.dart') continue;
      final source = readSource(file);
      for (final match in RegExp(
        r'Color\(0x([0-9A-Fa-f]{8})\)',
      ).allMatches(source)) {
        final argb = match.group(1)!.toUpperCase();
        // Opaco: debe ser un token exacto. Translúcido: el RGB debe ser de la
        // paleta (velo/alfa) o negro puro (sombras).
        final allowed =
            isKnownColor(argb) ||
            (!argb.startsWith('FF') && argb.substring(2) == '000000');
        if (!allowed) {
          violations.add('${file.path}: Color(0x$argb)');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'usa AppColors.<token> (o añade el token a app_colors.dart):\n'
          '${violations.join('\n')}',
    );
  });

  test('2. los radios del design system salen de AppRadius', () {
    // Escala declarada en app_radius.dart.
    expect(AppRadius.sm, 4);
    expect(AppRadius.md, 8);
    expect(AppRadius.lg, 12);
    expect(AppRadius.circle, 999);

    expect(AppRadius.card, BorderRadius.circular(AppRadius.sm));
    expect(AppRadius.pill, BorderRadius.circular(AppRadius.lg));
    expect(AppRadius.circleBorder, BorderRadius.circular(AppRadius.circle));

    // GlassCard usa el token por defecto (no un literal).
    expect(const GlassCard(child: SizedBox()).borderRadius, AppRadius.sm);

    final theme = AppTheme.darkTheme;
    final shapes = <String, BorderRadiusGeometry?>{
      'elevatedButton':
          (theme.elevatedButtonTheme.style?.shape?.resolve({})
                  as RoundedRectangleBorder?)
              ?.borderRadius,
      'outlinedButton':
          (theme.outlinedButtonTheme.style?.shape?.resolve({})
                  as RoundedRectangleBorder?)
              ?.borderRadius,
      'textButton':
          (theme.textButtonTheme.style?.shape?.resolve({})
                  as RoundedRectangleBorder?)
              ?.borderRadius,
      'chip': (theme.chipTheme.shape as RoundedRectangleBorder?)?.borderRadius,
      'dialog':
          (theme.dialogTheme.shape as RoundedRectangleBorder?)?.borderRadius,
      'input': (theme.inputDecorationTheme.border as OutlineInputBorder?)
          ?.borderRadius,
    };

    for (final entry in shapes.entries) {
      expect(
        entry.value,
        AppRadius.card,
        reason: '${entry.key} debe usar AppRadius.card (4 px)',
      );
    }
  });

  test('3. lib/ solo pide las tres familias empaquetadas', () {
    final googleFontsCalls = <String>{};
    final fontFamilyLiterals = <String, String>{};

    for (final file in libFiles()) {
      final source = readSource(file);

      for (final match in RegExp(
        r'GoogleFonts\.(\w+)\(',
        multiLine: true,
      ).allMatches(source)) {
        googleFontsCalls.add(match.group(1)!);
      }
      for (final match in RegExp(
        r"fontFamily:\s*'([^']+)'",
      ).allMatches(source)) {
        fontFamilyLiterals[file.path] = match.group(1)!;
      }
    }

    // `config` es el interruptor de google_fonts, no una familia.
    googleFontsCalls.remove('config');
    expect(
      googleFontsCalls.map(normalizeFamily).toSet(),
      allowedFamilies,
      reason: 'lib/ solo debe pedir SpaceGrotesk, Inter o JetBrains Mono',
    );

    for (final entry in fontFamilyLiterals.entries) {
      expect(
        allowedFamilies,
        contains(normalizeFamily(entry.value)),
        reason: '${entry.key} declara la familia "${entry.value}"',
      );
    }

    // Cada familia declarada tiene que estar empaquetada.
    final bundled = Directory('assets/google_fonts')
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .where((name) => name.endsWith('.ttf'))
        .toList();
    for (final family in ['SpaceGrotesk', 'Inter', 'JetBrainsMono']) {
      expect(
        bundled.any((name) => name.startsWith('$family-')),
        isTrue,
        reason: 'falta la familia $family en assets/google_fonts/',
      );
    }
  });

  test('4. el tema solo usa familias y colores del sistema', () {
    void expectInPalette(Color? color, String where) {
      if (color == null) return;
      final argb = argbOf(color);
      expect(
        isKnownColor(argb),
        isTrue,
        reason: '$where usa 0x$argb, que no está en AppColors',
      );
    }

    final theme = AppTheme.darkTheme;
    final styles = <String, TextStyle?>{
      'displayLarge': theme.textTheme.displayLarge,
      'displayMedium': theme.textTheme.displayMedium,
      'displaySmall': theme.textTheme.displaySmall,
      'headlineLarge': theme.textTheme.headlineLarge,
      'headlineMedium': theme.textTheme.headlineMedium,
      'headlineSmall': theme.textTheme.headlineSmall,
      'titleLarge': theme.textTheme.titleLarge,
      'titleMedium': theme.textTheme.titleMedium,
      'titleSmall': theme.textTheme.titleSmall,
      'bodyLarge': theme.textTheme.bodyLarge,
      'bodyMedium': theme.textTheme.bodyMedium,
      'bodySmall': theme.textTheme.bodySmall,
      'labelLarge': theme.textTheme.labelLarge,
      'labelMedium': theme.textTheme.labelMedium,
      'labelSmall': theme.textTheme.labelSmall,
    };

    for (final entry in styles.entries) {
      final style = entry.value;
      if (style == null) continue;
      final family = normalizeFamily(style.fontFamily ?? '');
      if (family == 'roboto') continue; // deuda declarada abajo
      expect(
        allowedFamilies,
        contains(family),
        reason: 'textTheme.${entry.key} usa "${style.fontFamily}"',
      );
      expectInPalette(style.color, 'textTheme.${entry.key}');
    }

    // Deuda conocida (verificada 29-oct-2026): `app_theme.dart` define 11 de los
    // 15 estilos; estos 4 se quedan con la tipografía por defecto de Material
    // (Roboto), que no está empaquetada. Si se tokenizan, actualiza esta lista
    // (el test falla a propósito cuando cambia, para que la deuda no crezca ni
    // quede documentada de más).
    const untokenized = {
      'headlineSmall',
      'titleSmall',
      'bodySmall',
      'labelSmall',
    };
    final roboto = styles.entries
        .where(
          (entry) =>
              entry.value != null &&
              normalizeFamily(entry.value!.fontFamily ?? '') == 'roboto',
        )
        .map((entry) => entry.key)
        .toSet();
    expect(
      roboto,
      untokenized,
      reason: 'textTheme sin tokenizar: usa AppTypography en su lugar',
    );

    expect(theme.scaffoldBackgroundColor, AppColors.voidBg);
    expect(theme.colorScheme.primary, AppColors.manaCyan);
    expect(theme.colorScheme.secondary, AppColors.royalGold);
    expect(theme.colorScheme.tertiary, AppColors.runeViolet);
    expect(theme.colorScheme.error, AppColors.crimsonRed);

    final scheme = theme.colorScheme;
    final schemeColors = <String, Color>{
      'primary': scheme.primary,
      'onPrimary': scheme.onPrimary,
      'secondary': scheme.secondary,
      'tertiary': scheme.tertiary,
      'error': scheme.error,
      'surface': scheme.surface,
      'onSurface': scheme.onSurface,
      'onSecondary': scheme.onSecondary,
    };
    for (final entry in schemeColors.entries) {
      expectInPalette(entry.value, 'colorScheme.${entry.key}');
    }
  });

  testWidgets('5. AppTypography solo devuelve familias y colores del sistema', (
    WidgetTester tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (inner) {
            context = inner;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final styles = <String, TextStyle>{
      'headline': AppTypography.headline(context),
      'title': AppTypography.title(context),
      'subtitle': AppTypography.subtitle(context),
      'body': AppTypography.body(context),
      'bodyMuted': AppTypography.bodyMuted(context),
      'label': AppTypography.label(context),
      'stat': AppTypography.stat(context),
      'tiny': AppTypography.tiny(context),
    };

    for (final entry in styles.entries) {
      final style = entry.value;
      expect(
        allowedFamilies,
        contains(normalizeFamily(style.fontFamily ?? '')),
        reason: 'AppTypography.${entry.key} usa "${style.fontFamily}"',
      );
      expect(
        isKnownColor(argbOf(style.color!)),
        isTrue,
        reason:
            'AppTypography.${entry.key} usa '
            '0x${argbOf(style.color!)}, que no está en AppColors',
      );
    }
  });
}
