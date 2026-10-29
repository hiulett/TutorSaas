import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../core/analytics/analytics_taxonomy.dart';
import '../core/i18n/language_settings.dart';
import '../core/services/retention_analytics.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/home_widget/presentation/providers/home_widget_providers.dart';
import '../features/notifications/presentation/providers/notification_providers.dart';
import '../features/presence/presentation/providers/presence_providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class TutorSaaSApp extends ConsumerWidget {
  const TutorSaaSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiLanguage = ref.watch(effectiveUiLanguageProvider);
    ref.watch(languageSyncProvider);
    final router = ref.watch(routerProvider);

    // Issue #106: mantiene el recordatorio diario local alineado con
    // `user_settings` (arranque + cada cambio de hora/dias/interruptor).
    // Solo con sesión: sin usuario no hay ajustes ni nada que programar.
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      ref.watch(reminderStartupSyncProvider);
    }

    // P-36 (#121): mantiene el widget de inicio al día. Se engancha siempre:
    // sin sesión publica el estado vacío honesto en vez de números viejos.
    ref.watch(homeWidgetSyncProvider);
    ref.watch(homeWidgetTapSyncProvider);
    ref.listen<String?>(homeWidgetTapRouteProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      ref.read(homeWidgetTapRouteProvider.notifier).state = null;
      _openFromWidget(router, next);
    });

    // Abre el destino cuando el usuario toca la notificacion.
    ref.listen<String?>(notificationTapRouteProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      trackNotificationEvent(
        ref.read(currentUserProvider)?.id ?? '',
        AnalyticsEvent.notificationOpened,
        properties: <String, dynamic>{'route': next},
      );
      ref.read(notificationTapRouteProvider.notifier).state = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => router.go(next));
    });

    // Reporta presencia (sección actual + heartbeat) solo con sesión activa.
    // Condicional para no tocar Supabase en arranque sin usuario (y en tests).
    if (user != null) {
      ref.watch(presenceControllerProvider);
      // Issue #35: `app_open` una sola vez por proceso.
      unawaited(RetentionAnalytics.instance.trackAppOpenOnce(user.id));
    }

    return MaterialApp.router(
      title: 'Dungeon of English',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to premium dark mode
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: uiLanguage == 'es' || uiLanguage == 'en' || uiLanguage == 'pt'
          ? Locale(uiLanguage)
          : const Locale('es'),
    );
  }
}

/// P-36 (#121): abre la ruta que pidió el widget.
///
/// En un arranque en frío desde el widget el `SplashScreen` sigue pendiente y
/// su `go('/')` posterior pisaría el destino, así que se espera a que el router
/// salga de `/splash` (tope ~4 s; el splash navega como máximo a los 3 s).
void _openFromWidget(GoRouter router, String route, [int attempt = 0]) {
  final path = router.routerDelegate.currentConfiguration.uri.path;
  if (path == '/splash' && attempt < 12) {
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 350),
        () => _openFromWidget(router, route, attempt + 1),
      ),
    );
    return;
  }
  router.go(route);
}
