import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserLanguageSettings {
  final String uiLanguage;
  final String learningLanguage;
  final bool aiExplanationsInNative;

  const UserLanguageSettings({
    this.uiLanguage = 'es',
    this.learningLanguage = 'en',
    this.aiExplanationsInNative = true,
  });

  UserLanguageSettings copyWith({
    String? uiLanguage,
    String? learningLanguage,
    bool? aiExplanationsInNative,
  }) => UserLanguageSettings(
    uiLanguage: uiLanguage ?? this.uiLanguage,
    learningLanguage: learningLanguage ?? this.learningLanguage,
    aiExplanationsInNative: aiExplanationsInNative ?? this.aiExplanationsInNative,
  );

  Map<String, dynamic> toJson() => {
    'ui_language': uiLanguage,
    'learning_language': learningLanguage,
    'ai_explanations_native': aiExplanationsInNative,
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
