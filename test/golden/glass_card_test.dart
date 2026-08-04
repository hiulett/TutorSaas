import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/widgets/glass_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('GlassCard golden test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(400 * 3.0, 300 * 3.0);
    tester.binding.window.devicePixelRatioTestValue = 3.0;

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF05070E),
          body: Center(
            child: GlassCard(
              child: SizedBox(width: 200, height: 80),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(GlassCard),
      matchesGoldenFile('goldens/glass_card.png'),
    );
  });
}
