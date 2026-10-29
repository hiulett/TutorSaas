import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/tutor_personalization.dart';

/// P-40 (#125) — Lectura del perfil que personaliza al tutor.
///
/// Antes de este issue el onboarding escribía `user_ai_profiles` y los ajustes
/// guardaban `interests`/`tutor_personality`/`correction_level`, pero el prompt
/// del tutor solo usaba el nivel del catálogo y los errores recurrentes. Aquí se
/// leen **una vez por sesión** (sin llamadas al modelo) y se devuelve un objeto
/// inmutable que el builder del prompt consume.
///
/// Todo es best-effort: cualquier fallo devuelve el valor por defecto y la
/// conversación continúa. Los invitados no tienen filas en ninguna tabla.
class TutorPersonalizationRepository {
  TutorPersonalizationRepository(this._client);

  final SupabaseClient _client;

  /// Cada cuántas lecciones superadas se activa el repaso acumulativo.
  static const int reviewEveryNLessons = 3;

  Future<TutorPersonalization> load(
    String? userId, {
    String? currentScenarioId,
  }) async {
    if (userId == null || userId.isEmpty) return TutorPersonalization.empty;

    final settings = await _loadSettings(userId);
    final aiProfile = await _loadAiProfile(userId);
    final cefrLevel = await _loadCefrLevel(userId);
    final completedLessons = await _countCompletedLessons(userId);
    final isReviewSession =
        completedLessons > 0 && completedLessons % reviewEveryNLessons == 0;
    final reviewPhrases = isReviewSession
        ? await _loadReviewPhrases(userId, currentScenarioId: currentScenarioId)
        : const <String>[];

    return TutorPersonalization(
      interests: _stringList(settings?['interests']),
      motivation: (settings?['motivation'] as String?)?.trim() ?? '',
      correctionLevel:
          (settings?['correction_level'] as String?)?.trim() ?? 'short',
      correctionStyle:
          (settings?['correction_style'] as String?)?.trim() ?? 'balanced',
      tutorPersonality:
          (settings?['tutor_personality'] as String?)?.trim() ?? 'friendly',
      focusAreas: _stringList(aiProfile?['focus_areas']),
      tutorPromptInstructions:
          (aiProfile?['tutor_prompt_instructions'] as String?)?.trim() ?? '',
      pedagogicalSummary:
          (aiProfile?['pedagogical_summary'] as String?)?.trim() ?? '',
      cefrLevel: cefrLevel,
      completedLessons: completedLessons,
      reviewPhrases: reviewPhrases,
      isReviewSession: isReviewSession,
    );
  }

  Future<Map<String, dynamic>?> _loadSettings(String userId) async {
    try {
      final row = await _client
          .from('user_settings')
          .select(
            'interests, motivation, correction_level, correction_style, '
            'tutor_personality',
          )
          .eq('user_id', userId)
          .maybeSingle();
      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (e) {
      debugPrint('No se pudo leer user_settings para el tutor: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadAiProfile(String userId) async {
    try {
      final row = await _client
          .from('user_ai_profiles')
          .select('focus_areas, tutor_prompt_instructions, pedagogical_summary')
          .eq('user_id', userId)
          .maybeSingle();
      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (e) {
      debugPrint('No se pudo leer user_ai_profiles: $e');
      return null;
    }
  }

  Future<String> _loadCefrLevel(String userId) async {
    try {
      final row = await _client
          .from('user_language_profiles')
          .select('cefr_levels(code)')
          .eq('user_id', userId)
          .maybeSingle();
      final cefr = row?['cefr_levels'];
      if (cefr is Map) return (cefr['code'] as String?)?.trim() ?? '';
      return '';
    } catch (e) {
      debugPrint('No se pudo leer el nivel CEFR del perfil: $e');
      return '';
    }
  }

  Future<int> _countCompletedLessons(String userId) async {
    try {
      final rows = await _client
          .from('lesson_progress')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'passed');
      return (rows as List).length;
    } catch (e) {
      debugPrint('No se pudieron contar las lecciones superadas: $e');
      return 0;
    }
  }

  /// Frases ya completadas en lecciones anteriores (práctica acumulativa).
  Future<List<String>> _loadReviewPhrases(
    String userId, {
    String? currentScenarioId,
  }) async {
    try {
      var query = _client
          .from('user_scenario_phrases')
          .select('phrase_text, scenario_id')
          .eq('user_id', userId)
          .eq('is_completed', true);
      if (currentScenarioId != null && currentScenarioId.isNotEmpty) {
        query = query.neq('scenario_id', currentScenarioId);
      }
      final rows = await query.order('completed_at', ascending: false).limit(6);
      final phrases = <String>[];
      for (final row in rows as List) {
        final text = (row['phrase_text'] as String?)?.trim() ?? '';
        if (text.isEmpty || phrases.contains(text)) continue;
        phrases.add(text);
      }
      return phrases;
    } catch (e) {
      debugPrint('No se pudieron cargar las frases de repaso: $e');
      return const [];
    }
  }

  List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}
