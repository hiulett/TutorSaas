import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Contrato de rutas: toda pantalla nueva debe estar registrada en
/// `lib/app/router.dart` (AGENTS.md). No existía este test; P-29 lo añade para
/// cubrir `/my-errors`.
void main() {
  final router = File('lib/app/router.dart').readAsStringSync();

  test('/my-errors está registrada y apunta a MyErrorsScreen', () {
    expect(router.contains("path: '/my-errors'"), isTrue);
    expect(router.contains('MyErrorsScreen()'), isTrue);
    expect(router.contains('my_errors_screen.dart'), isTrue);
  });

  test('las rutas documentadas siguen presentes', () {
    for (final path in [
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
    ]) {
      expect(
        router.contains("path: '$path'"),
        isTrue,
        reason: 'falta la ruta $path',
      );
    }
  });
}
