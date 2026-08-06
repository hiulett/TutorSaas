import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';

/// Resultado de la decisión de navegación inicial.
enum NavDestination { welcome, onboarding, home }

/// Navigation Decision Engine (Navigation-Audit · F2).
///
/// Centraliza TODA la lógica de redirección inicial en un solo lugar.
/// Reglas en orden de prioridad (obligatorio):
///   1. Sin sesión activa → / (WelcomeScreen: login/registro). Esto aplica
///      SIEMPRE, incluso con devAlwaysShowOnboarding: sin JWT de Supabase el
///      pipeline de voz (llm-proxy) no puede autenticarse.
///   2. Con sesión y SIN perfil → /onboarding. El modo desarrollador NO fuerza
///      el onboarding si el usuario ya completó su perfil: con perfil, siempre
///      se accede a /home (toda la aplicación).
///   3. Con sesión y CON perfil → /home (dashboard).
class NavigationDecisionEngine {
  NavigationDecisionEngine._();

  static Future<NavDestination> resolve({
    required User? user,
    required bool devMode,
  }) async {
    // 1. Sin sesión → siempre Welcome/login (dev mode NO lo salta).
    if (user == null) {
      debugPrint('[Nav] Sin sesión → Welcome');
      return NavDestination.welcome;
    }

    // 2/3. Con sesión: si no hay perfil → onboarding; si hay perfil → dashboard.
    // El modo desarrollador solo afecta al onboarding cuando NO hay perfil aún
    // (permite probarlo), pero NUNCA bloquea el acceso al resto de la app.
    final hasProfile = await _hasProfile(user.id);
    if (!hasProfile) {
      debugPrint('[Nav] Sesión sin perfil → Onboarding${devMode ? ' (dev)' : ''}');
      return NavDestination.onboarding;
    }

    debugPrint('[Nav] Sesión con perfil → Dashboard${devMode ? ' (dev mode activo)' : ''}');
    return NavDestination.home;
  }

  static Future<bool> _hasProfile(String userId) async {
    try {
      final res = await Supabase.instance.client
          .from('user_language_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      debugPrint('[Nav] Error verificando perfil: $e');
      return false;
    }
  }
}

/// Provider que re-expone el estado de navegación y el modo dev.
final devModeProvider = devAlwaysShowOnboardingProvider;

/// Convierte [NavDestination] en la ruta correspondiente.
String navDestinationToPath(NavDestination dest) {
  switch (dest) {
    case NavDestination.welcome:
      return '/';
    case NavDestination.onboarding:
      return '/onboarding';
    case NavDestination.home:
      return '/home';
  }
}
