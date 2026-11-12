// Recorre todas las rutas registradas en `lib/app/router.dart` sobre un
// dispositivo real y reporta, por ruta, si monta sin excepción.
//
// Uso:
//   flutter test integration_test/all_routes_test.dart -d <device>
//
// No sustituye a los tests de widget: comprueba que cada pantalla se construye
// con el estado real (sesión, providers, Supabase) y no lanza excepciones.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tutorsaas/app/app.dart';
import 'package:tutorsaas/app/router.dart';
import 'package:tutorsaas/core/constants/api_constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Rutas declaradas en `lib/app/router.dart`.
  const routes = <String>[
    '/',
    '/splash',
    '/onboarding',
    '/mini-conversation',
    '/oracle-test',
    '/home',
    '/voice-room',
    '/conversation',
    '/summary',
    '/paywall',
    '/profile-edit',
    '/chat-rooms',
    '/shop',
    '/inventory',
    '/dungeon-guardian',
    '/boss-result',
    '/my-errors',
    '/weekly-report',
    '/listening',
    '/missions',
  ];

  testWidgets('todas las rutas montan sin excepcion', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    try {
      await Supabase.initialize(
        url: ApiConstants.supabaseUrl,
        publishableKey: ApiConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('INIT Supabase ya inicializado o falló: $e');
    }

    await tester.pumpWidget(const ProviderScope(child: TutorSaaSApp()));
    // Deja arrancar el splash (navega como máximo a los ~3 s).
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TutorSaaSApp)),
    );
    final router = container.read(routerProvider);

    final failures = <String>[];
    for (final route in routes) {
      Object? failure;
      String landed = '';
      try {
        router.go(route);
        // Sin pumpAndSettle: las pantallas tienen animaciones infinitas.
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 400));
        }
        landed = router.routerDelegate.currentConfiguration.uri.path;
        failure = tester.takeException();
      } catch (e) {
        failure = e;
      }
      if (failure != null) {
        failures.add(route);
      }
      debugPrint(
        'ROUTE $route -> landed=$landed exception=${failure ?? "none"}',
      );
    }

    debugPrint('RESUMEN rutas=${routes.length} fallos=${failures.length}');
    expect(failures, isEmpty, reason: 'Rutas con excepción: $failures');
  });
}
