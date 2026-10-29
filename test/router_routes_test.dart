import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorsaas/app/router.dart';

/// Contrato de navegacion (P-18 / #103).
void main() {
  test('las rutas esperadas estan registradas y no hay duplicados', () {
    final paths = appRoutes.whereType<GoRoute>().map((r) => r.path).toList();

    expect(paths.toSet().length, paths.length, reason: 'sin rutas duplicadas');
    expect(
      paths,
      containsAll([
        '/splash',
        '/',
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
      ]),
    );
    expect(paths, isNot(contains('/disruption')));
  });

  test('cada ruta tiene un builder', () {
    for (final route in appRoutes.whereType<GoRoute>()) {
      expect(route.builder, isNotNull, reason: route.path);
    }
  });
}
