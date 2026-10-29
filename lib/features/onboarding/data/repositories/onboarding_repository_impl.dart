import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SupabaseClient _supabaseClient;

  OnboardingRepositoryImpl(this._supabaseClient);

  @override
  Future<void> saveOnboardingData({
    required String userId,
    required String targetLanguageCode,
    required String nativeLanguageCode,
    required String cefrLevelCode,
    required int dailyGoalMinutes,
    required List<String> interests,
    required String motivation,
    required String correctionStyle,
    required String tutorPersonality,
    String? primaryObstacle,
    String? learningStyle,
  }) async {
    final currentUser = _supabaseClient.auth.currentUser;
    final String userEmail = currentUser?.email ?? '';
    final String defaultDisplayName =
        (currentUser?.userMetadata?['full_name'] as String?) ??
        (userEmail.isNotEmpty ? userEmail.split('@').first : 'Estudiante');

    // 0. Ensure user profile record exists in public.users table
    try {
      await _supabaseClient.from('users').upsert({
        'id': userId,
        'email': userEmail,
        'display_name': defaultDisplayName,
        'native_language': nativeLanguageCode,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error upserting public.users: $e');
    }

    // 1. Get or create language ID
    int langId = 1;
    try {
      final langResponse = await _supabaseClient
          .from('languages')
          .select('id')
          .eq('code', targetLanguageCode)
          .maybeSingle();

      if (langResponse == null) {
        final insertLang = await _supabaseClient
            .from('languages')
            .insert({
              'code': targetLanguageCode,
              'name': _getLanguageName(targetLanguageCode),
              'native_name': _getNativeLanguageName(targetLanguageCode),
              'flag_emoji': _getLanguageEmoji(targetLanguageCode),
            })
            .select('id')
            .single();
        langId = insertLang['id'] as int;
      } else {
        langId = langResponse['id'] as int;
      }
    } catch (e) {
      debugPrint('Error getting language ID: $e');
    }

    // 2. Perfil de idioma con el nivel autodeclarado (#73).
    //
    // El cliente ya no escribe `cefr_level_id`: el trigger
    // `guard_language_profile` fuerza el nivel inicial en el INSERT y esta RPC
    // (SECURITY DEFINER) guarda la elección del onboarding marcada como
    // `self_declared`. Una vez que el Oráculo evalúa, se rechaza cualquier
    // autodeclaración posterior.
    try {
      await _supabaseClient.rpc(
        'apply_self_declared_level',
        params: {'p_cefr_code': cefrLevelCode, 'p_language_id': langId},
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/onboarding/data/repositories/onboarding_repository_impl.dart:self_declared',
        e,
        stackTrace: st,
      );
    }

    // 4. Upsert user settings
    try {
      await _supabaseClient.from('user_settings').upsert({
        'user_id': userId,
        'daily_goal_minutes': dailyGoalMinutes,
        'correction_style': correctionStyle,
        'tutor_personality': tutorPersonality,
        'interests': interests,
        'motivation': motivation,
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('Error upserting user_settings: $e');
    }

    // 5. Upsert user AI profile for adaptive learning
    try {
      final pedagogicalSummary =
          "Estudiante de nivel $cefrLevelCode enfocado en ${interests.join(', ')} con meta de $dailyGoalMinutes min/día.";
      final tutorInstructions =
          "Tutor de IA personalizado para $targetLanguageCode (Nivel $cefrLevelCode). Estilo de corrección: $correctionStyle. Exige precisión fonética >90% en vocabulario clave y evalúa las 10 metas conversacionales.";

      await _supabaseClient.from('user_ai_profiles').upsert({
        'user_id': userId,
        'pedagogical_summary': pedagogicalSummary,
        'learning_style': 'auditory_interactive',
        'focus_areas': interests,
        'tutor_prompt_instructions': tutorInstructions,
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('Error upserting user_ai_profiles: $e');
    }
  }

  /// Issue #23: actualiza solo idioma objetivo y nivel CEFR. No toca XP, racha
  /// ni el perfil de `users`, a diferencia de [saveOnboardingData].
  @override
  Future<void> updateLanguagePreferences({
    required String userId,
    String? targetLanguageCode,
    String? cefrLevelCode,
  }) async {
    final patch = <String, dynamic>{};
    if (targetLanguageCode != null && targetLanguageCode.isNotEmpty) {
      patch['language_id'] = await _resolveLanguageId(targetLanguageCode);
    }
    if (cefrLevelCode != null && cefrLevelCode.isNotEmpty) {
      patch['cefr_level_id'] = await _resolveCefrId(cefrLevelCode);
    }
    if (patch.isEmpty) return;

    await _supabaseClient
        .from('user_language_profiles')
        .update(patch)
        .eq('user_id', userId);
  }

  Future<int> _resolveLanguageId(String code) async {
    final existing = await _supabaseClient
        .from('languages')
        .select('id')
        .eq('code', code)
        .maybeSingle();
    if (existing != null) return existing['id'] as int;
    final inserted = await _supabaseClient
        .from('languages')
        .insert({
          'code': code,
          'name': _getLanguageName(code),
          'native_name': _getNativeLanguageName(code),
          'flag_emoji': _getLanguageEmoji(code),
        })
        .select('id')
        .single();
    return inserted['id'] as int;
  }

  Future<int> _resolveCefrId(String code) async {
    final existing = await _supabaseClient
        .from('cefr_levels')
        .select('id')
        .eq('code', code)
        .maybeSingle();
    if (existing != null) return existing['id'] as int;
    final inserted = await _supabaseClient
        .from('cefr_levels')
        .insert({
          'code': code,
          'name': _getCefrName(code),
          'description': 'Nivel CEFR $code',
          'order_index': _getCefrOrder(code),
        })
        .select('id')
        .single();
    return inserted['id'] as int;
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Francés';
      case 'de':
        return 'Alemán';
      case 'it':
        return 'Italiano';
      default:
        return 'Inglés';
    }
  }

  String _getNativeLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      default:
        return 'English';
    }
  }

  String _getLanguageEmoji(String code) {
    switch (code) {
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      default:
        return '🇺🇸';
    }
  }

  String _getCefrName(String code) {
    switch (code) {
      case 'A2':
        return 'Elemental';
      case 'B1':
        return 'Intermedio';
      case 'B2':
        return 'Intermedio Alto';
      case 'C1':
        return 'Avanzado';
      case 'C2':
        return 'Maestría';
      default:
        return 'Principiante';
    }
  }

  int _getCefrOrder(String code) {
    switch (code) {
      case 'A2':
        return 2;
      case 'B1':
        return 3;
      case 'B2':
        return 4;
      case 'C1':
        return 5;
      case 'C2':
        return 6;
      default:
        return 1;
    }
  }
}
