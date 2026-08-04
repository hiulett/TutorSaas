import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/i18n/language_settings.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class TutorSaaSApp extends ConsumerWidget {
  const TutorSaaSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiLanguage = ref.watch(effectiveUiLanguageProvider);
    ref.watch(languageSyncProvider);
    final router = ref.watch(routerProvider);

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
