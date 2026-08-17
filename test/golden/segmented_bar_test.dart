import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/widgets/segmented_bar.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('SegmentedBar golden test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 3.0, 300 * 3.0);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF05070E),
          body: Center(
            child: SizedBox(
              width: 200,
              child: SegmentedBar(value: 0.6),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(SegmentedBar),
      matchesGoldenFile('goldens/segmented_bar.png'),
    );
  });
}
