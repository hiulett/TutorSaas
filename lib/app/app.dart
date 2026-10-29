import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/i18n/language_settings.dart';
import '../core/services/retention_analytics.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
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

    // Abre el destino cuando el usuario toca la notificacion.
    ref.listen<String?>(notificationTapRouteProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      trackNotificationEvent(
        ref.read(currentUserProvider)?.id ?? '',
        'notification_opened',
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
