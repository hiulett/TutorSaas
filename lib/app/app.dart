import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/i18n/language_settings.dart';
import '../core/services/retention_analytics.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
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

    // Reporta presencia (sección actual + heartbeat) solo con sesión activa.
    // Condicional para no tocar Supabase en arranque sin usuario (y en tests).
    final user = ref.watch(currentUserProvider);
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
