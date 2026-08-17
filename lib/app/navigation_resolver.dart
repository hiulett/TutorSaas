import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Caché por usuario de "¿tiene perfil?" para no consultar la DB en cada
  /// redirección (go_router ejecuta el redirect en cada navegación).
  static final Map<String, bool> _profileCache = {};

  /// Timeout para la consulta de perfil: si la red está caída o Supabase no
  /// responde, el redirect decide con la última decisión persistida en lugar
  /// de quedarse esperando (el spinner post-login NO puede colgar la app).
  static const Duration _profileTimeout = Duration(seconds: 6);

  static String _cacheKey(String userId) => 'nav_has_profile_$userId';

  /// Invalida la caché (p. ej. tras completar el onboarding).
  static void invalidateProfile(String userId) {
    _profileCache.remove(userId);
    unawaited(_clearPersistedProfile(userId));
  }

  /// Marca que el usuario ya tiene perfil (se llama al completar el onboarding)
  /// para que el redirect no vuelva a consultar la DB en ese momento.
  static Future<void> markProfileExists(String userId) async {
    _profileCache[userId] = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cacheKey(userId), true);
    } catch (_) {}
  }

  static Future<void> _clearPersistedProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey(userId));
    } catch (_) {}
  }

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
    bool hasProfile;
    if (_profileCache.containsKey(user.id)) {
      hasProfile = _profileCache[user.id]!;
    } else {
      hasProfile = await _hasProfile(user.id);
      _profileCache[user.id] = hasProfile;
    }

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
          .maybeSingle()
          .timeout(_profileTimeout);
      final has = res != null;
      // Persiste la decisión para cold starts sin red (fail-fast del redirect).
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_cacheKey(userId), has);
      } catch (_) {}
      return has;
    } catch (e) {
      debugPrint('[Nav] Error/timeout verificando perfil ($e) → decisión persistida.');
      // Nunca bloquea: sin caché persistida se va a onboarding (seguro para
      // usuarios nuevos). Un usuario recurrente ya tiene su flag guardado.
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool(_cacheKey(userId)) ?? false;
      } catch (_) {
        return false;
      }
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
