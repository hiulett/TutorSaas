import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserLanguageSettings {
  final String uiLanguage;
  final String learningLanguage;
  final bool aiExplanationsInNative;
  final bool followDeviceLanguage;

  const UserLanguageSettings({
    this.uiLanguage = 'es',
    this.learningLanguage = 'en',
    this.aiExplanationsInNative = true,
    this.followDeviceLanguage = true,
  });

  UserLanguageSettings copyWith({
    String? uiLanguage,
    String? learningLanguage,
    bool? aiExplanationsInNative,
    bool? followDeviceLanguage,
  }) => UserLanguageSettings(
    uiLanguage: uiLanguage ?? this.uiLanguage,
    learningLanguage: learningLanguage ?? this.learningLanguage,
    aiExplanationsInNative: aiExplanationsInNative ?? this.aiExplanationsInNative,
    followDeviceLanguage: followDeviceLanguage ?? this.followDeviceLanguage,
  );

  Map<String, dynamic> toJson() => {
    'ui_language': uiLanguage,
    'learning_language': learningLanguage,
    'ai_explanations_native': aiExplanationsInNative,
    'follow_device_language': followDeviceLanguage,
  };
}

class UserLanguageNotifier extends StateNotifier<UserLanguageSettings> {
  UserLanguageNotifier() : super(const UserLanguageSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserLanguageSettings(
      uiLanguage: prefs.getString('ui_language') ?? 'es',
      learningLanguage: prefs.getString('learning_language') ?? 'en',
      aiExplanationsInNative: prefs.getBool('ai_explanations_native') ?? true,
      followDeviceLanguage: prefs.getBool('follow_device_language') ?? true,
    );
  }

  Future<void> setUiLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ui_language', code);
    state = state.copyWith(uiLanguage: code);
    _persistToSupabase();
  }

  Future<void> setLearningLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learning_language', code);
    state = state.copyWith(learningLanguage: code);
    _persistToSupabase();
  }

  Future<void> setAiExplanationsInNative(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_explanations_native', value);
    state = state.copyWith(aiExplanationsInNative: value);
  }

  Future<void> setFollowDeviceLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('follow_device_language', value);
    state = state.copyWith(followDeviceLanguage: value);
    _persistToSupabase();
  }

  /// Sincroniza desde Supabase al arrancar (solo si no hay preferencia local).
  Future<void> syncFromSupabase(Map<String, dynamic>? remote) async {
    if (remote == null) return;
    final prefs = await SharedPreferences.getInstance();
    final hasLocal = prefs.containsKey('ui_language');
    if (hasLocal) return;

    final ui = (remote['ui_language'] as String?) ?? 'es';
    final learning = (remote['learning_language'] as String?) ?? 'en';
    final aiNative = (remote['ai_explanations_native'] as bool?) ?? true;
    final follow = (remote['follow_device_language'] as bool?) ?? true;

    await prefs.setString('ui_language', ui);
    await prefs.setString('learning_language', learning);
    await prefs.setBool('ai_explanations_native', aiNative);
    await prefs.setBool('follow_device_language', follow);
    state = UserLanguageSettings(
      uiLanguage: ui,
      learningLanguage: learning,
      aiExplanationsInNative: aiNative,
      followDeviceLanguage: follow,
    );
  }

  Future<void> _persistToSupabase() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('user_settings').upsert({
          'user_id': user.id,
          ...state.toJson(),
        });
      }
    } catch (_) {}
  }
}

final userLanguageProvider = StateNotifierProvider<UserLanguageNotifier, UserLanguageSettings>((ref) {
  return UserLanguageNotifier();
});

/// Idioma del dispositivo (detección automática). El dispositivo manda si
/// `followDeviceLanguage` está activo.
final deviceLocaleProvider = Provider<String>((ref) {
  final locale = PlatformDispatcher.instance.locale;
  return locale.languageCode;
});

/// Idiomas soportados por la interfaz (extensible: añadir a esta lista + ARB).
const supportedUiLanguages = ['en', 'es', 'pt'];

/// Idioma efectivo de la interfaz: dispositivo si follow, si no uiLanguage.
final effectiveUiLanguageProvider = Provider<String>((ref) {
  final settings = ref.watch(userLanguageProvider);
  if (settings.followDeviceLanguage) {
    final device = ref.watch(deviceLocaleProvider);
    return supportedUiLanguages.contains(device) ? device : 'es';
  }
  return settings.uiLanguage;
});

/// Sincroniza las preferencias de idioma desde Supabase cuando hay sesión
/// y no existen preferencias locales aún (primer inicio / otro dispositivo).
/// Tolerante a entornos sin Supabase inicializado (tests).
final languageSyncProvider = Provider<UserLanguageNotifier>((ref) {
  final notifier = ref.watch(userLanguageProvider.notifier);
  try {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user != null) {
      Future(() async {
        try {
          final remote = await client
              .from('user_settings')
              .select('ui_language, learning_language, ai_explanations_native, follow_device_language')
              .eq('user_id', user.id)
              .maybeSingle();
          await notifier.syncFromSupabase(remote);
        } catch (_) {}
      });
    }
  } catch (_) {}
  return notifier;
});
