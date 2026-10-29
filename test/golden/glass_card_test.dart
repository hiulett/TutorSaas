import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/core/theme/app_motion.dart';
import 'package:tutorsaas/core/theme/app_radius.dart';
import 'package:tutorsaas/core/theme/app_spacing.dart';
import 'package:tutorsaas/core/widgets/glass_card.dart';

/// Red de regresión visual de `GlassCard` **sin pixel-golden**.
///
/// El PNG de este widget se generaba en Windows y el rasterizado de
/// `BackdropFilter`/`BoxShadow` difiere en Linux (0,04 % de píxeles), así que el
/// test quedó Windows-only y el CI perdió la red. En su lugar se afirman las
/// propiedades que definen el aspecto: color, opacidad, radio, borde, sombra,
/// padding, tamaño resultante y animación de prensado.
///
/// Fuente de los valores: `lib/core/theme/app_colors.dart`,
/// `app_radius.dart`, `app_spacing.dart` y `app_motion.dart` (tokens, no docs).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Center(child: child),
    ),
  );

  /// Contenedores internos que pinta `GlassCard`:
  /// `[0]` sombra, `[1]` superficie de vidrio (padding + decoración).
  List<Container> containers(WidgetTester tester) => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ),
      )
      .toList();

  testWidgets('el vidrio usa los tokens de color, radio y borde', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(const GlassCard(child: SizedBox(width: 200, height: 80))),
    );

    final card = tester.widget<GlassCard>(find.byType(GlassCard));
    expect(card.blur, AppColors.glassBlur);
    expect(card.opacity, AppColors.glassOpacity);
    expect(card.borderRadius, AppRadius.sm);
    expect(card.showRunicCorners, isFalse);

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(GlassCard),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(clip.borderRadius, AppRadius.card);

    final painted = containers(tester);
    expect(painted, hasLength(2));

    final glass = painted[1].decoration! as BoxDecoration;
    expect(
      glass.color,
      AppColors.surfaceGlass.withValues(alpha: AppColors.glassOpacity),
    );
    expect(glass.borderRadius, AppRadius.card);
    expect(
      glass.border,
      Border.all(
        color: AppColors.manaCyan.withValues(alpha: AppColors.glassBorderAlpha),
        width: 1,
      ),
    );
    expect(painted[1].padding, const EdgeInsets.all(AppSpacing.xxl));

    final shadow = painted[0].decoration! as BoxDecoration;
    expect(shadow.boxShadow, [
      BoxShadow(
        color: AppColors.manaCyan.withValues(alpha: 0.3),
        blurRadius: 8,
      ),
    ]);

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('tamaño = contenido + padding del token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(const GlassCard(child: SizedBox(width: 200, height: 80))),
    );

    // Container suma al tamaño el padding del token y el grosor del borde
    // (1 px por lado) de la decoración.
    const borderWidth = 1.0;
    expect(
      tester.getSize(find.byType(GlassCard)),
      const Size(
        200 + AppSpacing.xxl * 2 + borderWidth * 2,
        80 + AppSpacing.xxl * 2 + borderWidth * 2,
      ),
    );
  });

  testWidgets(
    'onTap dispara pese al GestureDetector interno (trampa AGENTS.md)',
    (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        host(
          GlassCard(
            onTap: () => tapped = true,
            child: const SizedBox(width: 200, height: 80),
          ),
        ),
      );

      await tester.tap(find.byType(GlassCard));
      await tester.pump();

      expect(tapped, isTrue);
    },
  );

  testWidgets('el prensado encoge a 0.98 y vuelve a 1.0', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(const GlassCard(child: SizedBox(width: 200, height: 80))),
    );

    double scale() => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byType(GlassCard),
                matching: find.byType(Transform),
              )
              .first,
        )
        // `getMaxScaleOnAxis` devuelve 1.0 por el eje Z: se lee la escala X.
        .transform
        .storage[0];

    expect(scale(), moreOrLessEquals(1.0, epsilon: 0.001));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(GlassCard)),
    );
    // El `onTapDown` se dispara tras `kPressTimeout` (100 ms); después corre la
    // animación de prensado (AppMotion.micro).
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(AppMotion.micro);
    await tester.pump(AppMotion.micro);
    expect(scale(), lessThan(1.0));
    expect(scale(), moreOrLessEquals(0.98, epsilon: 0.001));

    await gesture.up();
    await tester.pump(AppMotion.micro);
    await tester.pump(AppMotion.micro);
    expect(scale(), moreOrLessEquals(1.0, epsilon: 0.001));
  });

  testWidgets('respeta borde, radio y esquinas rúnicas explícitas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        const GlassCard(
          borderColor: AppColors.royalGold,
          borderRadius: AppRadius.lg,
          showRunicCorners: true,
          child: SizedBox(width: 120, height: 40),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(
      find.descendant(
        of: find.byType(GlassCard),
        matching: find.byType(ClipRRect),
      ),
    );
    expect(clip.borderRadius, AppRadius.pill);

    final glass = containers(tester)[1].decoration! as BoxDecoration;
    expect(
      glass.border,
      Border.all(
        color: AppColors.royalGold.withValues(
          alpha: AppColors.glassBorderAlpha,
        ),
        width: 1,
      ),
    );

    expect(
      find.descendant(
        of: find.byType(GlassCard),
        matching: find.byType(Positioned),
      ),
      findsNWidgets(4),
      reason: 'cuatro esquinas rúnicas',
    );
    expect(
      find.descendant(
        of: find.byType(GlassCard),
        matching: find.byType(ExcludeSemantics),
      ),
      findsNWidgets(4),
      reason: 'las esquinas son decorativas: fuera del árbol semántico',
    );
  });

  testWidgets('semanticLabel expone la tarjeta como un nodo de semántica', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      host(
        const GlassCard(
          semanticLabel: 'Níscalo 15 de 20',
          child: SizedBox(width: 140, height: 32),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Níscalo 15 de 20'), findsOneWidget);
    semantics.dispose();
  });
}
