import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/features/dashboard/presentation/widgets/league_leaderboard_widget.dart';
import 'package:tutorsaas/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  setUpAll(() async {
    // Initialize Supabase with mock URL/Key for widget testing
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

    await tester.pumpAndSettle();

    FlutterError.onError = originalOnError;

    expect(exceptions, isEmpty);
  });

  testWidgets('DashboardScreen does not overflow at width 312', (WidgetTester tester) async {
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
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 312,
              child: DashboardScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    FlutterError.onError = originalOnError;

    expect(exceptions, isEmpty);
  });
}
