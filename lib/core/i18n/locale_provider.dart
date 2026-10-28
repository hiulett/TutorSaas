import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';

/// Legacy locale provider — maintains backward compatibility with existing code
class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('es') {
    _loadFromStorage();
  }

  String get languageCode => state;

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('interface_language') ?? 'es';
    if (state != saved) state = saved;
  }

  Future<void> setLanguage(String code) async {
    final supported = ['es', 'en', 'pt'];
    final lang = supported.contains(code) ? code : 'es';
    state = lang;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('interface_language', lang);

    // Sync with UserLanguageSettings
    try {

    } catch (e, st) {
      ErrorTracker.logSilent('lib/core/i18n/locale_provider.dart:29', e, stackTrace: st);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(localeProvider);
});

/// Convenience t() function that reads from ARB files via AppLocalizations
/// Falls back to the legacy AppTranslations if ARB not available.
String t(String key, {WidgetRef? ref, String? languageCode}) {
  // For now, return the key itself so existing calls don't break
  // The actual translation will be done via AppLocalizations.of(context)!
  return key;
}
