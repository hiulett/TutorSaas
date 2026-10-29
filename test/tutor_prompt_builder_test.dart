import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/tutor_adaptation.dart';
import 'package:tutorsaas/features/conversation/domain/services/tutor_prompt_builder.dart';
import 'package:tutorsaas/features/corrections/domain/models/turn_correction.dart';

/// P-40 (#125) — El prompt del tutor cambia de verdad con cada perfil.
///
/// Estos tests son la evidencia medible del issue: con el mismo turno de chat,
/// dos alumnos distintos generan prompts distintos (intereses, nivel, estilo,
/// errores recurrentes, metas y ajuste de dificultad), y el prompt por defecto
/// sigue siendo válido cuando el alumno no ha declarado nada.
void main() {
  const freeChatInput = TutorPromptInput(correctionLevel: 'short');

  group('TutorPromptBuilder — perfil vacío', () {
    test('sin perfil: solo rol, modo de corrección y ajuste neutro', () {
      final prompt = TutorPromptBuilder.build(freeChatInput);

      expect(prompt, contains('You are an AI Language Tutor'));
      expect(prompt, contains('CORRECTION MODE (short)'));
      expect(prompt, contains('ADAPTATION: keep the scene difficulty steady'));
      expect(prompt, contains('You MUST ALWAYS respond in English'));
      // Nada inventado cuando no hay datos.
      expect(prompt, isNot(contains('STUDENT PROFILE')));
      expect(prompt, isNot(contains('RECURRING MISTAKES')));
      expect(prompt, isNot(contains('CUMULATIVE REVIEW')));
      expect(prompt, isNot(contains('USEFUL PHRASES')));
      expect(prompt, isNot(contains('PENDING GOALS')));
      expect(prompt, isNot(contains('STUDENT-SPECIFIC TUTOR INSTRUCTIONS')));
    });

    test('el nivel CEFR sin lección adapta la regla de lenguaje', () {
      final a1 = TutorPromptBuilder.build(
        const TutorPromptInput(correctionLevel: 'short', cefrLevel: 'A1'),
      );
      final c1 = TutorPromptBuilder.build(
        const TutorPromptInput(correctionLevel: 'short', cefrLevel: 'C1'),
      );

      expect(a1, contains('CEFR level A1: short, high-frequency sentences'));
      expect(c1, contains('CEFR level C1: advanced'));
      expect(a1, isNot(equals(c1)));
    });
  });

  group('TutorPromptBuilder — perfil declarado', () {
    test('intereses, motivación e instrucciones del perfil de IA entran', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'moderate',
          cefrLevel: 'B2',
          interests: ['travel', 'technology'],
          motivation: 'career',
          tutorPromptInstructions:
              'Insiste en el past simple y corrige la pronunciación de the.',
          tutorPersonality: 'professional',
          correctionStyle: 'strict',
        ),
      );

      expect(
        prompt,
        contains('interests: travel, technology · motivation: career'),
      );
      expect(
        prompt,
        contains('STUDENT-SPECIFIC TUTOR INSTRUCTIONS: Insiste en el past'),
      );
      expect(prompt, contains('Tone: professional'));
      expect(prompt, contains('Correction style: strict'));
      expect(prompt, contains('CORRECTION MODE (moderate)'));
      expect(prompt, contains('CEFR level B2'));
    });

    test('sin tutor_prompt_instructions usa el resumen pedagógico', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          pedagogicalSummary: 'Estudiante de nivel A1 enfocado en viajes.',
        ),
      );

      expect(
        prompt,
        contains('STUDENT-SPECIFIC TUTOR INSTRUCTIONS: Estudiante de nivel A1'),
      );
    });

    test('deduplica intereses y recorta textos libres de la BD', () {
      final longInstructions = 'x' * 900;
      final prompt = TutorPromptBuilder.build(
        TutorPromptInput(
          correctionLevel: 'short',
          interests: const ['travel', ' Travel ', 'travel', 'music'],
          tutorPromptInstructions: 'linea uno\nlinea dos   con   espacios',
          mainObjective: longInstructions,
        ),
      );

      expect('interests: travel, music'.allMatches(prompt), hasLength(1));
      expect(prompt, contains('linea uno linea dos con espacios'));
      expect(prompt, isNot(contains('linea dos   con')));
      // El objetivo largo se recorta: no infla el prompt.
      expect(prompt.length, lessThan(2200));
      expect(prompt, contains('…'));
    });
  });

  group('TutorPromptBuilder — escenario', () {
    test('inyecta objetivo, frases útiles y metas pendientes', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          cefrLevel: 'A2',
          assistantRole: 'a hotel receptionist',
          userRole: 'a guest checking in',
          scenarioContext: 'hotel lobby',
          mainObjective: 'Check in and ask for a late checkout.',
          usefulPhrases: [
            "I'd like to check in",
            'Could I have a late checkout?',
          ],
          pendingGoals: ['State the number of nights'],
        ),
      );

      expect(prompt, contains('roleplaying as a hotel receptionist'));
      expect(prompt, contains('The user is playing the role of a guest'));
      expect(
        prompt,
        contains(
          'YOUR OBJECTIVE IN THIS SCENE: Check in and ask for a late checkout.',
        ),
      );
      expect(prompt, contains('"I\'d like to check in"'));
      expect(prompt, contains('PENDING GOALS for this scene'));
      expect(prompt, contains('"State the number of nights"'));
    });
  });

  group('TutorPromptBuilder — errores recurrentes y repaso', () {
    test('los errores recurrentes aparecen una sola vez y sin duplicar', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          recurringErrors: [
            CorrectionGroup(
              type: CorrectionType.grammar,
              original: 'I go yesterday',
              corrected: 'I went yesterday',
              occurrences: 4,
            ),
            // Una sola vez no es recurrente: no debe entrar.
            CorrectionGroup(
              type: CorrectionType.vocabulary,
              original: 'big house',
              corrected: 'large house',
              occurrences: 1,
            ),
          ],
        ),
      );

      expect(prompt, contains('RECURRING MISTAKES from the student history'));
      expect(prompt, contains('"I go yesterday" → "I went yesterday"'));
      expect(prompt, isNot(contains('large house')));
    });

    test('el repaso acumulativo inyecta frases de lecciones anteriores', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          reviewPhrases: ['Could I have the bill, please?'],
        ),
      );

      expect(prompt, contains('CUMULATIVE REVIEW'));
      expect(prompt, contains('"Could I have the bill, please?"'));
    });
  });

  group('TutorPromptBuilder — adaptación dentro del nivel', () {
    test('racha de fallos pide simplificar y dar pistas', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          adaptation: TutorDifficultyAdjustment.simplify,
          struggleStreak: 2,
        ),
      );

      expect(prompt, contains('SIMPLIFY now'));
      expect(prompt, contains('failed the last 2 turns'));
      expect(prompt, contains('ONE concrete hint'));
      expect(prompt, isNot(contains('RAISE THE BAR')));
    });

    test('racha de aciertos sube el listón', () {
      final prompt = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'short',
          adaptation: TutorDifficultyAdjustment.stretch,
          successStreak: 3,
        ),
      );

      expect(prompt, contains('RAISE THE BAR'));
      expect(prompt, contains('answered cleanly 3 turns in a row'));
      expect(prompt, isNot(contains('SIMPLIFY now')));
    });

    test('el mismo turno con alumnos distintos produce prompts distintos', () {
      final beginner = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'important_only',
          cefrLevel: 'A1',
          interests: ['music'],
          tutorPersonality: 'friendly',
        ),
      );
      final advanced = TutorPromptBuilder.build(
        const TutorPromptInput(
          correctionLevel: 'detailed',
          cefrLevel: 'C1',
          interests: ['economics'],
          tutorPersonality: 'challenging',
          adaptation: TutorDifficultyAdjustment.stretch,
          successStreak: 4,
        ),
      );

      expect(beginner, isNot(equals(advanced)));
      expect(advanced.length, greaterThan(beginner.length));
    });
  });
}
