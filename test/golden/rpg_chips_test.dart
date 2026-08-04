import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/core/widgets/glass_card.dart';

void main() {
  testWidgets('RPG chips golden test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(400 * 3.0, 300 * 3.0);
    tester.binding.window.devicePixelRatioTestValue = 3.0;

    final chipStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: 1.2,
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.voidBg,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlassCard(
                  borderColor: AppColors.manaCyan,
                  child: SizedBox(
                    width: 140,
                    height: 32,
                    child: Center(child: Text('NÚCLEO 15/20')),
                  ),
                ),
                const SizedBox(height: 16),
                const GlassCard(
                  borderColor: AppColors.royalGold,
                  child: SizedBox(
                    width: 140,
                    height: 32,
                    child: Center(child: Text('RANGO A1')),
                  ),
                ),
                const SizedBox(height: 16),
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

    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/rpg_chips.png'),
    );
  });
}
