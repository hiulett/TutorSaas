/// P-40 (#125) — Construcción del system prompt del tutor.
///
/// Función pura: recibe lo que el alumno declaró y lo que el sistema ya sabe de
/// él y devuelve el prompt exacto que viaja en el turno de chat. Al ser pura se
/// puede comparar en tests (perfil A1 sin intereses vs. B2 con intereses vs.
/// racha de fallos) sin red, sin Supabase y sin llamar al modelo.
///
/// Reglas de coste:
/// * No genera ninguna petición al modelo: el prompt va dentro del turno que ya
///   se paga (`llm-proxy` recibe `messages`).
/// * Todo el texto viene de campos que ya existen en la BD. Los campos de texto
///   libre (instrucciones del perfil de IA, objetivos y frases del escenario,
///   que edita `web_admin`) se recortan y se normalizan para que un valor raro
///   no infle el prompt ni inyecte saltos de línea.
library;

import '../../../corrections/domain/models/turn_correction.dart';
import '../models/tutor_adaptation.dart';

/// Tope de caracteres para textos libres que llegan de la BD.
const int _maxFreeTextChars = 320;
const int _maxListItems = 5;

class TutorPromptInput {
  const TutorPromptInput({
    required this.correctionLevel,
    this.cefrLevel = '',
    this.tutorPersonality = 'friendly',
    this.correctionStyle = 'balanced',
    this.interests = const [],
    this.motivation = '',
    this.tutorPromptInstructions = '',
    this.pedagogicalSummary = '',
    this.assistantRole,
    this.userRole,
    this.scenarioContext,
    this.mainObjective,
    this.pendingGoals = const [],
    this.usefulPhrases = const [],
    this.recurringErrors = const [],
    this.reviewPhrases = const [],
    this.adaptation = TutorDifficultyAdjustment.steady,
    this.struggleStreak = 0,
    this.successStreak = 0,
  });

  final String correctionLevel;
  final String cefrLevel;
  final String tutorPersonality;
  final String correctionStyle;
  final List<String> interests;
  final String motivation;
  final String tutorPromptInstructions;
  final String pedagogicalSummary;

  /// Rol del NPC cuando la sesión es una lección del catálogo.
  final String? assistantRole;
  final String? userRole;
  final String? scenarioContext;

  /// `scenarios.main_objective` — el objetivo de la escena, que hoy no llegaba
  /// al prompt (solo rol y contexto).
  final String? mainObjective;

  /// Metas del escenario todavía sin cumplir.
  final List<String> pendingGoals;

  /// `scenarios.useful_phrases[].phrase` de la lección en curso.
  final List<String> usefulPhrases;

  /// Errores recurrentes (`user_recurring_errors`, P-29).
  final List<CorrectionGroup> recurringErrors;

  /// Frases de lecciones anteriores para la práctica acumulativa.
  final List<String> reviewPhrases;

  final TutorDifficultyAdjustment adaptation;
  final int struggleStreak;
  final int successStreak;
}

class TutorPromptBuilder {
  const TutorPromptBuilder._();

  /// Devuelve el system prompt completo del turno.
  static String build(TutorPromptInput input) {
    final sections = <String>[
      _roleSection(input),
      if (_clean(input.mainObjective).isNotEmpty)
        'YOUR OBJECTIVE IN THIS SCENE: ${_clean(input.mainObjective)}',
      if (_usable(input.usefulPhrases).isNotEmpty)
        'USEFUL PHRASES THE STUDENT SHOULD TRY TO USE: '
            '${_quoteList(_usable(input.usefulPhrases))}',
      _studentProfileSection(input),
      _styleSection(input),
      if (_studentInstructions(input).isNotEmpty)
        'STUDENT-SPECIFIC TUTOR INSTRUCTIONS: '
            '${_studentInstructions(input)} (from the student onboarding; '
            'follow it even if it is written in their native language).',
      _correctionSection(input),
      if (_pendingErrors(input).isNotEmpty)
        'RECURRING MISTAKES from the student history: ${_recurringHint(input)}',
      if (_usable(input.pendingGoals).isNotEmpty)
        'PENDING GOALS for this scene (never declare a goal complete; the '
            'system verifies them separately): '
            '${_quoteList(_usable(input.pendingGoals))}',
      if (_usable(input.reviewPhrases).isNotEmpty)
        'CUMULATIVE REVIEW: earlier lessons used these phrases. Work one or '
            'two of them back into the conversation naturally, without saying '
            'this is a review: ${_quoteList(_usable(input.reviewPhrases))}',
      _adaptationSection(input),
      'Analyze the user message and point out mistakes according to the '
          'correction mode above. If the user writes in Spanish, gently remind '
          'them to use English and help them translate. '
          'Ask a natural follow-up question to continue the conversation.',
      'IMPORTANT: You MUST ALWAYS respond in English. Never use Spanish or any '
          'other language.',
    ];

    return sections.join('\n\n');
  }

  // ── Secciones ─────────────────────────────────────────────────────────────

  static String _roleSection(TutorPromptInput input) {
    final level = _clean(input.cefrLevel);
    final levelRule = _levelRule(level);
    final role = _clean(input.assistantRole);
    final scenario = _clean(input.scenarioContext);
    final userRole = _clean(input.userRole);

    if (role.isEmpty) {
      return 'You are an AI Language Tutor. Converse naturally in English.'
          '${level.isEmpty ? '' : ' The student level is $level. $levelRule'}';
    }
    final buffer = StringBuffer(
      'You are an AI Language Tutor roleplaying as $role',
    );
    if (scenario.isNotEmpty) buffer.write(' in a $scenario');
    buffer.write('.');
    if (userRole.isNotEmpty) {
      buffer.write(' The user is playing the role of $userRole.');
    }
    if (level.isNotEmpty) {
      buffer.write(' Target CEFR Level: $level. $levelRule');
    }
    return buffer.toString().trim();
  }

  static String _levelRule(String level) {
    final upper = level.toUpperCase();
    if (upper.isEmpty) {
      return 'Keep your language appropriate for the student level.';
    }
    if (upper == 'PRE-A1' || upper == 'A1' || upper == 'A2') {
      return 'Keep your response appropriate for CEFR level $level: short, '
          'high-frequency sentences.';
    }
    if (upper == 'B1' || upper == 'B2') {
      return 'Keep your response appropriate for CEFR level $level: '
          'intermediate language and connected ideas.';
    }
    return 'Keep your response appropriate for CEFR level $level: advanced, '
        'native-level fluency and complex discourse.';
  }

  static String _studentProfileSection(TutorPromptInput input) {
    final parts = <String>[];
    final level = _clean(input.cefrLevel);
    if (level.isNotEmpty) parts.add('CEFR level: $level');
    final interests = _usable(input.interests);
    if (interests.isNotEmpty) {
      parts.add('interests: ${interests.join(', ')}');
    }
    final motivation = _clean(input.motivation);
    if (motivation.isNotEmpty) parts.add('motivation: $motivation');
    if (parts.isEmpty) return '';
    return 'STUDENT PROFILE (use it to pick examples and follow-up questions): '
        '${parts.join(' · ')}.';
  }

  static String _styleSection(TutorPromptInput input) {
    final personality = _clean(input.tutorPersonality).toLowerCase();
    final String line;
    switch (personality) {
      case 'professional':
        line =
            'Tone: professional and direct. No roleplay flourishes; stay '
            'focused on the task and the language.';
        break;
      case 'challenging':
        line =
            'Tone: challenging. Push for a little more than the student '
            'offers, but stay respectful and never mock an answer.';
        break;
      case 'friendly':
      default:
        line =
            'Tone: warm and encouraging. Celebrate small wins without '
            'padding the answer.';
    }
    final style = _clean(input.correctionStyle).toLowerCase();
    final styleLine = switch (style) {
      'strict' =>
        'Correction style: strict. Flag every real error, including small ones.',
      'conversational' =>
        'Correction style: conversational. Correct inside the flow of the '
            'conversation, as a natural recast.',
      _ =>
        'Correction style: balanced. Correct what matters without derailing '
            'the conversation.',
    };
    return '$line $styleLine';
  }

  /// Instrucciones de corrección por nivel declarado por el alumno en ajustes.
  ///
  /// Los textos de `important_only`, `short`, `moderate` y `detailed` son los
  /// mismos que ya usaba el prompt antes de P-40 (no se cambia el
  /// comportamiento por defecto); `teacher` se añade porque la pantalla de
  /// ajustes lo ofrece y antes caía en `detailed`.
  static String _correctionSection(TutorPromptInput input) {
    final level = normalizeCorrectionLevel(input.correctionLevel);
    const instructions = {
      'important_only':
          'Only correct mistakes that prevent understanding or represent '
          'severe grammar errors. Keep corrections minimal and very brief.',
      'short':
          'Provide a very short correction (one line max) then immediately '
          'continue the conversation. Do not explain grammar rules.',
      'moderate':
          'Provide the correction and a brief explanation of 1 to 2 lines, '
          'then continue the conversation.',
      'detailed':
          'Provide detailed corrections with full grammar explanations. '
          'Suggest alternative phrasing and explain why the error occurred. '
          'Then ask a follow-up question to continue.',
      'teacher':
          'Act as a demanding teacher: correct every error, explain the rule in '
          'one line, add a better alternative and a micro-exercise.',
    };
    return 'CORRECTION MODE (${level.replaceAll('_', ' ')}): '
        '${instructions[level] ?? instructions['short']}';
  }

  static List<CorrectionGroup> _pendingErrors(TutorPromptInput input) {
    return input.recurringErrors.where((g) => g.isRecurring).take(3).toList();
  }

  /// Instrucciones del perfil de IA. Se prefiere `tutor_prompt_instructions`;
  /// si el onboarding solo guardó el resumen pedagógico, se usa ese.
  static String _studentInstructions(TutorPromptInput input) {
    final instructions = _clean(input.tutorPromptInstructions);
    if (instructions.isNotEmpty) return instructions;
    return _clean(input.pedagogicalSummary);
  }

  static String _recurringHint(TutorPromptInput input) {
    return buildTutorRecurringErrorsHint(
      input.recurringErrors,
    ).replaceFirst('The student keeps making these mistakes: ', '');
  }

  static String _adaptationSection(TutorPromptInput input) {
    switch (input.adaptation) {
      case TutorDifficultyAdjustment.simplify:
        return 'ADAPTATION: the student has failed the last '
            '${input.struggleStreak} turns in a row. SIMPLIFY now: use short '
            'sentences with one idea each, present tense and high-frequency '
            'words. Before your question, give ONE concrete hint (a model '
            'answer or a choice between two options) so the student can answer.';
      case TutorDifficultyAdjustment.stretch:
        return 'ADAPTATION: the student has answered cleanly '
            '${input.successStreak} turns in a row. RAISE THE BAR: use slightly '
            'richer vocabulary and one structure above their level, and ask a '
            'question that requires a reason or an opinion instead of yes/no.';
      case TutorDifficultyAdjustment.steady:
        return 'ADAPTATION: keep the scene difficulty steady; no change needed.';
    }
  }

  // ── Utilidades ────────────────────────────────────────────────────────────

  /// Normaliza texto libre de la BD: sin saltos de línea, sin espacios dobles
  /// y con tope de longitud.
  static String _clean(String? raw) {
    if (raw == null) return '';
    final singleLine = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (singleLine.length <= _maxFreeTextChars) return singleLine;
    return '${singleLine.substring(0, _maxFreeTextChars).trimRight()}…';
  }

  static List<String> _usable(List<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in values) {
      final value = _clean(raw);
      if (value.isEmpty) continue;
      if (!seen.add(value.toLowerCase())) continue;
      result.add(value);
      if (result.length >= _maxListItems) break;
    }
    return result;
  }

  static String _quoteList(List<String> values) {
    return values.map((v) => '"${v.replaceAll('"', "'")}"').join('; ');
  }
}
