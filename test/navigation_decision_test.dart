import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/app/navigation_resolver.dart';

/// Contrato del `redirect` del router (P-18 / #103).
///
/// Los cuatro casos del hallazgo H-18: sin sesión, sin perfil, con perfil y
/// sin red. Se prueba el Navigation Decision Engine (la lógica que consume
/// `GoRouter.redirect`) sin levantar Supabase ni la UI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  User user(String id) => User.fromJson({
    'id': id,
    'aud': 'authenticated',
    'created_at': '2026-01-01T00:00:00Z',
  })!;

  tearDown(() {
    NavigationDecisionEngine.profileProbe = null;
  });

  group('NavigationDecisionEngine.resolve', () {
    test('sin sesión → welcome aunque el modo dev esté activo', () async {
      NavigationDecisionEngine.profileProbe = (_) async =>
          fail('sin sesión no se consulta el perfil');

      final dest = await NavigationDecisionEngine.resolve(
        user: null,
        devMode: true,
      );

      expect(dest, NavDestination.welcome);
      expect(navDestinationToPath(dest), '/');
    });

    test('con sesión y sin perfil → onboarding', () async {
      SharedPreferences.setMockInitialValues({});
      NavigationDecisionEngine.profileProbe = (_) async => false;

      final dest = await NavigationDecisionEngine.resolve(
        user: user('u-sin-perfil'),
        devMode: false,
      );

      expect(dest, NavDestination.onboarding);
      expect(navDestinationToPath(dest), '/onboarding');
    });

    test('con sesión y con perfil → dashboard', () async {
      SharedPreferences.setMockInitialValues({});
      NavigationDecisionEngine.profileProbe = (_) async => true;

      final dest = await NavigationDecisionEngine.resolve(
        user: user('u-con-perfil'),
        devMode: false,
      );

      expect(dest, NavDestination.home);
      expect(navDestinationToPath(dest), '/home');
    });

    test('sin red y decisión persistida → dashboard', () async {
      SharedPreferences.setMockInitialValues({
        'nav_has_profile_u-offline': true,
      });
      NavigationDecisionEngine.profileProbe = (_) async =>
          throw Exception('SocketException: network is unreachable');

      final dest = await NavigationDecisionEngine.resolve(
        user: user('u-offline'),
        devMode: false,
      );

      expect(dest, NavDestination.home);
    });

    test(
      'sin red y sin caché → onboarding (seguro para usuarios nuevos)',
      () async {
        SharedPreferences.setMockInitialValues({});
        NavigationDecisionEngine.profileProbe = (_) async =>
            throw Exception('TimeoutException after 0:00:06');

        final dest = await NavigationDecisionEngine.resolve(
          user: user('u-offline-nuevo'),
          devMode: false,
        );

        expect(dest, NavDestination.onboarding);
      },
    );

    test(
      'la decisión correcta se persiste para el siguiente arranque',
      () async {
        SharedPreferences.setMockInitialValues({});
        NavigationDecisionEngine.profileProbe = (_) async => true;
        await NavigationDecisionEngine.resolve(
          user: user('u-persistido'),
          devMode: false,
        );

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('nav_has_profile_u-persistido'), isTrue);
      },
    );
  });
}
