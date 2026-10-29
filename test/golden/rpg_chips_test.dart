import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/core/theme/app_spacing.dart';
import 'package:tutorsaas/core/widgets/glass_card.dart';

/// Red de regresión visual de los chips RPG (HUD) **sin pixel-golden**.
///
/// El PNG se generaba en Windows y las fuentes rasterizan distinto en Linux
/// (0,53 % de píxeles), así que el test quedó Windows-only. Aquí se afirman las
/// propiedades que definen el chip: color de borde por token, tamaño, separación
/// y estilo de texto. Los valores salen de `app_colors.dart` / `app_spacing.dart`.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const chipStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  Future<void> pumpChips(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 3.0, 300 * 3.0);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.voidBg,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassCard(
                  borderColor: AppColors.manaCyan,
                  child: SizedBox(
                    width: 140,
                    height: 32,
                    child: Center(child: Text('NÍSCALO 15/20')),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                GlassCard(
                  borderColor: AppColors.royalGold,
                  child: SizedBox(
                    width: 140,
                    height: 32,
                    child: Center(child: Text('RANGO A1')),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                GlassCard(
                  borderColor: AppColors.runeViolet,
                  child: SizedBox(
                    width: 140,
                    height: 32,
                    child: Center(child: Text('ORÁCULO', style: chipStyle)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration glassDecoration(WidgetTester tester, int index) {
    final containers = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(GlassCard).at(index),
            matching: find.byType(Container),
          ),
        )
        .toList();
    return containers[1].decoration! as BoxDecoration;
  }

  testWidgets('cada chip lleva su color de borde desde AppColors', (
    WidgetTester tester,
  ) async {
    await pumpChips(tester);

    const expected = [
      AppColors.manaCyan,
      AppColors.royalGold,
      AppColors.runeViolet,
    ];

    expect(find.byType(GlassCard), findsNWidgets(expected.length));

    for (var i = 0; i < expected.length; i++) {
      final card = tester.widget<GlassCard>(find.byType(GlassCard).at(i));
      expect(card.borderColor, expected[i]);

      final border = glassDecoration(tester, i).border! as Border;
      expect(
        border.top,
        BorderSide(
          color: expected[i].withValues(alpha: AppColors.glassBorderAlpha),
          width: 1,
        ),
        reason: 'el borde pintado debe ser el token al 80 % de alfa',
      );
    }
  });

  testWidgets('el chip mide 140x32 + padding y los separa AppSpacing.lg', (
    WidgetTester tester,
  ) async {
    await pumpChips(tester);

    final rects = [
      for (var i = 0; i < 3; i++) tester.getRect(find.byType(GlassCard).at(i)),
    ];

    for (final rect in rects) {
      expect(
        rect.size,
        // 140x32 + padding 24 + borde 1 px por lado.
        const Size(140 + AppSpacing.xxl * 2 + 2, 32 + AppSpacing.xxl * 2 + 2),
      );
    }

    expect(rects[1].top - rects[0].bottom, AppSpacing.lg);
    expect(rects[2].top - rects[1].bottom, AppSpacing.lg);
    expect(rects[0].left, rects[2].left, reason: 'columna centrada');
  });

  testWidgets('los textos y el estilo del chip se mantienen', (
    WidgetTester tester,
  ) async {
    await pumpChips(tester);

    expect(find.text('NÍSCALO 15/20'), findsOneWidget);
    expect(find.text('RANGO A1'), findsOneWidget);
    expect(find.text('ORÁCULO'), findsOneWidget);

    final oracle = tester.widget<Text>(find.text('ORÁCULO'));
    expect(oracle.style?.fontSize, 14);
    expect(oracle.style?.fontWeight, FontWeight.w900);
    expect(oracle.style?.color, Colors.white);
    expect(oracle.style?.letterSpacing, 1.2);

    final column = tester.widget<Column>(
      find.descendant(of: find.byType(Center), matching: find.byType(Column)),
    );
    expect(column.mainAxisSize, MainAxisSize.min);
    expect(column.crossAxisAlignment, CrossAxisAlignment.center);
  });

  testWidgets('sin overflow al tamaño de móvil del HUD', (
    WidgetTester tester,
  ) async {
    await pumpChips(tester);

    expect(tester.takeException(), isNull);
  });
}
