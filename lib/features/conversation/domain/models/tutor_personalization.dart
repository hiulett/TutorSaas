/// P-40 (#125) — Perfil de personalización que se inyecta en el turno de chat.
///
/// Reúne lo que el alumno ya declaró (onboarding y ajustes) y lo que el sistema
/// ya aprendió de él (nivel real, errores recurrentes, frases usadas). Se lee
/// **una vez por sesión** y no añade ninguna llamada al modelo: el prompt del
/// tutor viaja en el turno de chat que ya se pagaba.
class TutorPersonalization {
  const TutorPersonalization({
    this.interests = const [],
    this.focusAreas = const [],
    this.motivation = '',
    this.cefrLevel = '',
    this.correctionLevel = 'short',
    this.correctionStyle = 'balanced',
    this.tutorPersonality = 'friendly',
    this.tutorPromptInstructions = '',
    this.pedagogicalSummary = '',
    this.completedLessons = 0,
    this.reviewPhrases = const [],
    this.isReviewSession = false,
  });

  /// `user_settings.interests` (elegidos en el onboarding).
  final List<String> interests;

  /// `user_ai_profiles.focus_areas` (mismo origen, guardado por el onboarding
  /// como perfil pedagógico duradero).
  final List<String> focusAreas;

  /// `user_settings.motivation` (`career`, `travel`, `general`...).
  final String motivation;

  /// Código CEFR real del perfil de idioma (`A1`, `B2`...).
  final String cefrLevel;

  final String correctionLevel;
  final String correctionStyle;
  final String tutorPersonality;

  /// `user_ai_profiles.tutor_prompt_instructions`: instrucciones que el
  /// onboarding generó para el tutor y que hasta P-40 solo se guardaban.
  final String tutorPromptInstructions;

  /// `user_ai_profiles.pedagogical_summary`: resumen legible del perfil.
  final String pedagogicalSummary;

  /// Lecciones superadas (`lesson_progress.status = 'passed'`).
  final int completedLessons;

  /// Frases de lecciones anteriores, para la práctica acumulativa.
  final List<String> reviewPhrases;

  /// Verdadero cada N lecciones superadas: esta sesión incluye repaso.
  final bool isReviewSession;

  /// Intereses sin duplicados, primero los de `user_settings`.
  List<String> get allInterests {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in [...interests, ...focusAreas]) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      if (!seen.add(value.toLowerCase())) continue;
      result.add(value);
    }
    return result;
  }

  /// `true` si hay algo declarado por el alumno que merezca ir al prompt.
  bool get hasDeclaredProfile =>
      allInterests.isNotEmpty ||
      motivation.trim().isNotEmpty ||
      tutorPromptInstructions.trim().isNotEmpty;

  static const TutorPersonalization empty = TutorPersonalization();
}
