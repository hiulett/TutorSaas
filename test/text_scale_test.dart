import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:tutorsaas/features/economy/presentation/screens/dungeon_guardian_screen.dart';
import 'package:tutorsaas/features/onboarding/presentation/screens/welcome_screen.dart';

/// Issue #33: la app no se probaba con tamaños de texto grandes.
/// Este test monta las pantallas principales con `textScaler` 1.5 y 2.0 y
/// falla si aparece un RenderFlex overflow.
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        publishableKey: 'placeholder',
      );
    } catch (_) {
      // Ya inicializado por otro test.
    }
  });

  Future<void> pumpAtScale(
    WidgetTester tester,
    Widget screen,
    double scale,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.toString();
      if (msg.contains('NetworkImageLoadException') ||
          msg.contains('HTTP request failed') ||
          msg.contains('semantics') ||
          msg.contains('parentData')) {
        return;
      }
      errors.add(details);
    };

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(360, 800),
              textScaler: TextScaler.linear(scale),
            ),
            child: Scaffold(body: screen),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    FlutterError.onError = original;

    final overflows = errors
        .where((e) => e.toString().contains('overflowed'))
        .toList();
    expect(
      overflows,
      isEmpty,
      reason: 'Overflow con textScaler $scale: '
          '${overflows.map((e) => e.exceptionAsString()).join(' | ')}',
    );
  }

  group('textScaler 1.5', () {
    testWidgets('WelcomeScreen', (tester) async {
      await pumpAtScale(tester, const WelcomeScreen(), 1.5);
    });

    testWidgets('DashboardScreen', (tester) async {
      await pumpAtScale(tester, const DashboardScreen(), 1.5);
    });

    testWidgets('DungeonGuardianScreen', (tester) async {
      await pumpAtScale(tester, const DungeonGuardianScreen(), 1.5);
    });
  });

  group('textScaler 2.0', () {
    testWidgets('WelcomeScreen', (tester) async {
      await pumpAtScale(tester, const WelcomeScreen(), 2.0);
    });

    testWidgets('DungeonGuardianScreen', (tester) async {
      await pumpAtScale(tester, const DungeonGuardianScreen(), 2.0);
    });
  });
}
