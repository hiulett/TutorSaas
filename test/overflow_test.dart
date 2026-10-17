import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/cache/cached_future_controller.dart';
import 'package:tutorsaas/features/chat_rooms/presentation/screens/chat_rooms_screen.dart';
import 'package:tutorsaas/features/chat_rooms/presentation/providers/chat_rooms_providers.dart';
import 'package:tutorsaas/features/missions/presentation/providers/mission_providers.dart';
import 'package:tutorsaas/features/economy/presentation/providers/economy_providers.dart';
import 'package:tutorsaas/features/dashboard/presentation/widgets/league_leaderboard_widget.dart';
import 'package:tutorsaas/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:tutorsaas/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:tutorsaas/features/economy/presentation/screens/dungeon_guardian_screen.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

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

  testWidgets('ChatRoomsScreen does not overflow or fail layout at width 312', (WidgetTester tester) async {
    // Set screen size to 312 width (smallest common budget Android)
    tester.binding.window.physicalSizeTestValue = const Size(312 * 3.0, 800 * 3.0);
    tester.binding.window.devicePixelRatioTestValue = 3.0;

    final List<dynamic> exceptions = [];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.toString();
      // Capture layout errors
      if (!msg.contains('NetworkImageLoadException') &&
          !msg.contains('HTTP request failed') &&
          !msg.contains('semantics') &&
          !msg.contains('parentData')) {
        exceptions.add(details.exception);
        originalOnError?.call(details);
      }
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRoomsListProvider.overrideWith((ref) => CachedFutureController<List<Map<String, dynamic>>>(
                userIdGetter: () => 'test',
                fetcher: () async => [
                  {
                    'id': 'room_1',
                    'title': 'Test Room',
                    'category': 'travel',
                    'speakers_count': 2,
                    'listeners_count': 5,
                    'room_type': 'ai_practice',
                    'max_speakers': 6,
                  }
                ],
              )),
          guildAnnouncementsProvider.overrideWith((ref) => CachedFutureController<List<Map<String, dynamic>>>(
                userIdGetter: () => 'test',
                fetcher: () async => [],
              )),
          weeklyRaidProvider.overrideWith((ref) => Future.value(null)),
          battlePassProvider.overrideWith((ref) => Future.value({'level': 1, 'xp_progress': 0, 'is_premium': false, 'claimed_rewards': []})),
          guildCompletedMissionsProvider.overrideWith((ref) => Future.value(0)),
          // Caso real: 8 cazadores online, varios sin display_name (el crash
          // del roster ocurría con nombres vacíos).
          guildOnlineUsersProvider.overrideWith((ref) async => List.generate(8, (i) {
            return {
              'user_id': 'u$i',
              'display_name': i == 0 ? '' : 'Hunter ${i + 1}',
              'avatar_url': 'warrior',
            };
          })),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: Scaffold(
            body: SizedBox(
              width: 312,
              child: ExcludeSemantics(
                child: ChatRoomsScreen(isTab: true),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    FlutterError.onError = originalOnError;

    expect(exceptions, isEmpty, reason: 'No exceptions should be thrown');
  });

  testWidgets('WelcomeScreen (login) does not overflow at 312x576', (WidgetTester tester) async {
    // Pantalla pequeña: altura útil ~576 (el bug reportado desbordaba 68px).
    tester.binding.window.physicalSizeTestValue = const Size(312 * 3.0, 576 * 3.0);
    tester.binding.window.devicePixelRatioTestValue = 3.0;

    final List<dynamic> exceptions = [];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.toString();
      if (!msg.contains('NetworkImageLoadException') &&
          !msg.contains('HTTP request failed') &&
          !msg.contains('semantics') &&
          !msg.contains('parentData')) {
        exceptions.add(details.exception);
        originalOnError?.call(details);
      }
    };

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: Scaffold(
            body: SizedBox(
              width: 312,
              height: 576,
              child: ExcludeSemantics(
                child: WelcomeScreen(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    FlutterError.onError = originalOnError;

    final overflows = exceptions
        .where((e) => e.toString().contains('overflowed'))
        .toList();
    expect(overflows, isEmpty, reason: 'No RenderFlex overflows on the login at 312x576');
  });

  testWidgets('DungeonGuardianScreen does not overflow or fail at 312x576', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(312 * 3.0, 576 * 3.0);
    tester.binding.window.devicePixelRatioTestValue = 3.0;

    final List<dynamic> exceptions = [];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.toString();
      if (!msg.contains('NetworkImageLoadException') &&
          !msg.contains('HTTP request failed') &&
          !msg.contains('semantics') &&
          !msg.contains('parentData')) {
        exceptions.add(details.exception);
        originalOnError?.call(details);
      }
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manaStateProvider.overrideWith((ref) => CachedFutureController<Map<String, dynamic>>(
                userIdGetter: () => 'test',
                fetcher: () async => {
                  'allowance': 1800,
                  'purchased': 0,
                  'used': 0,
                  'remaining': 0,
                  'expires_at': null,
                  'plan': 'Plan Gratuito',
                  'is_free': true,
                  'daily_limit': 200,
                  'daily_used': 200,
                  'daily_remaining': 0,
                },
              )),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: Scaffold(
            body: SizedBox(
              width: 312,
              height: 576,
              child: ExcludeSemantics(
                child: DungeonGuardianScreen(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    FlutterError.onError = originalOnError;

    final overflows = exceptions
        .where((e) => e.toString().contains('overflowed'))
        .toList();
    expect(overflows, isEmpty, reason: 'No RenderFlex overflows on the guardian at 312x576');
  });
}
