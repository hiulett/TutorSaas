import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/features/dashboard/presentation/widgets/league_leaderboard_widget.dart';
import 'package:tutorsaas/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences so Supabase can initialize in test environment
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        publishableKey: 'placeholder',
      );
    } catch (_) {
      // Already initialized
    }
  });

  testWidgets('LeagueLeaderboardWidget does not overflow at width 312', (WidgetTester tester) async {
    // Set screen size to 312 width
    tester.binding.window.physicalSizeTestValue = const Size(312 * 3.0, 800 * 3.0);
    tester.binding.window.devicePixelRatioTestValue = 3.0;

    final List<dynamic> exceptions = [];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.toString().contains('NetworkImageLoadException') &&
          !details.toString().contains('HTTP request failed')) {
        exceptions.add(details.exception);
        originalOnError?.call(details);
      }
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 312,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    LeagueLeaderboardWidget(
                      activeLeague: 'Liga Plata 🥈',
                      userRank: 3,
                      userXp: 1200,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // pump con duración fija en lugar de pumpAndSettle: evita el timeout por
    // imágenes de red / animaciones de entrada que nunca se asientan.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    FlutterError.onError = originalOnError;

    expect(exceptions, isEmpty);
  });

  testWidgets('DashboardScreen does not overflow at width 312', (WidgetTester tester) async {
    // Set screen size to 312 width (smallest common budget Android)
    tester.binding.window.physicalSizeTestValue = const Size(312 * 3.0, 800 * 3.0);
    tester.binding.window.devicePixelRatioTestValue = 3.0;

    final List<dynamic> overflowExceptions = [];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.toString();
      // Ignore network errors; capture overflow/layout errors only
      if (!msg.contains('NetworkImageLoadException') &&
          !msg.contains('HTTP request failed') &&
          !msg.contains('semantics') &&
          !msg.contains('parentData')) {
        overflowExceptions.add(details.exception);
        originalOnError?.call(details);
      }
    };

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 312,
              // ExcludeSemantics prevents infinite recursion in flushSemantics
              // caused by Scrollable widgets in a constrained test environment.
              // This test is only about layout overflow, not accessibility.
              child: ExcludeSemantics(
                child: DashboardScreen(),
              ),
            ),
          ),
        ),
      ),
    );

    // DashboardScreen has continuous animations (CyberManhwaBackground,
    // flutter_animate) — pumpAndSettle never resolves. Instead pump a fixed
    // number of frames sufficient to trigger layout and catch overflow errors.
    await tester.pump();                                  // first build frame
    await tester.pump(const Duration(milliseconds: 100)); // first animation tick
    await tester.pump(const Duration(milliseconds: 400)); // settle visuals

    FlutterError.onError = originalOnError;

    // Only overflow/layout errors should fail the test
    final overflows = overflowExceptions
        .where((e) => e.toString().contains('overflowed'))
        .toList();
    expect(overflows, isEmpty, reason: 'No RenderFlex overflows at 312px width');
  });
}
