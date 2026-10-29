import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/goal_evaluation_parser.dart';
import 'package:tutorsaas/features/corrections/domain/models/session_correction.dart';

/// P-29 — Tests de la lógica pura de correcciones:
/// validación de tipos, dedupe, política por nivel y agrupación/recurrencia.
void main() {
  group('parseCorrections (validación de tipos)', () {
    test('acepta el esquema válido y normaliza la explicación', () {
      final result = parseCorrections([
        {
          'original': '  I go yesterday ',
          'corrected': 'I went yesterday',
          'type': 'grammar',
          'explanation': ' Use the past simple. ',
        },
      ], messageText: 'I go yesterday to the market');

      expect(result.corrections, hasLength(1));
      expect(result.discarded, 0);
      final correction = result.corrections.single;
      expect(correction.original, 'I go yesterday');
      expect(correction.corrected, 'I went yesterday');
      expect(correction.type, CorrectionType.grammar);
      expect(correction.explanation, 'Use the past simple.');
      expect(correction.messageText, 'I go yesterday to the market');
    });

    test('descarta tipos fuera del conjunto acotado', () {
      final result = parseCorrections([
        {'original': 'a', 'corrected': 'b', 'type': 'spelling'},
        {'original': 'a', 'corrected': 'b', 'type': 'STYLE'},
        {'original': 'a', 'corrected': 'b'},
        {'original': 'a', 'corrected': 'b', 'type': 42},
      ]);

      expect(result.corrections, isEmpty);
      expect(result.discarded, 4);
    });

    test('descarta correcciones sin cambio real o sin texto', () {
      final result = parseCorrections([
        {'original': 'hello', 'corrected': ' Hello. ', 'type': 'grammar'},
        {'original': '   ', 'corrected': 'x', 'type': 'grammar'},
        {'original': 'x', 'corrected': '', 'type': 'grammar'},
      ]);

      expect(result.corrections, isEmpty);
      expect(result.discarded, 3);
    });

    test('deduplica dentro del mismo turno', () {
      final result = parseCorrections([
        {'original': 'I go', 'corrected': 'I went', 'type': 'grammar'},
        {'original': 'i go.', 'corrected': 'I went', 'type': 'grammar'},
      ]);

      expect(result.corrections, hasLength(1));
      expect(result.discarded, 1);
    });

    test('recorta a 3 correcciones por turno', () {
      final result = parseCorrections([
        for (var i = 0; i < 6; i++)
          {'original': 'bad $i', 'corrected': 'good $i', 'type': 'grammar'},
      ]);

      expect(result.corrections, hasLength(maxCorrectionsPerTurn));
      expect(result.discarded, 3);
    });

    test('un valor que no es lista no rompe el turno', () {
      expect(parseCorrections('nope').corrections, isEmpty);
      expect(parseCorrections({'a': 1}).discarded, 1);
      expect(parseCorrections(null).corrections, isEmpty);
      expect(parseCorrections(null).discarded, 0);
    });

    test('recorta textos desmesurados', () {
      final result = parseCorrections([
        {'original': 'x' * 500, 'corrected': 'y' * 500, 'type': 'vocabulary'},
      ]);

      expect(
        result.corrections.single.original.length,
        maxCorrectionTextLength,
      );
      expect(
        result.corrections.single.corrected.length,
        maxCorrectionTextLength,
      );
    });
  });

  group('parseGoalEvaluation (una sola llamada)', () {
    test('lee metas y correcciones del formato nuevo', () {
      final result = parseGoalEvaluation(
        '{"goals": {"g1": true, "g2": false}, '
        '"corrections": [{"original": "I go", "corrected": "I went", "type": "grammar"}]}',
      );

      expect(result.goals, {'g1': true, 'g2': false});
      expect(result.corrections, hasLength(1));
      expect(result.discardedCorrections, 0);
    });

    test('mantiene compatibilidad con el formato plano antiguo', () {
      final result = parseGoalEvaluation('{"g1": true, "g2": false}');

      expect(result.goals, {'g1': true, 'g2': false});
      expect(result.corrections, isEmpty);
    });

    test('acepta la clave "errors" como alias y bloques ```json', () {
      final result = parseGoalEvaluation(
        '```json\n{"goals": {"g1": true}, '
        '"errors": [{"original": "definately", "corrected": "definitely", "type": "typo_stt"}]}\n```',
      );

      expect(result.goals, {'g1': true});
      expect(result.corrections.single.type, CorrectionType.typoStt);
    });

    test('ignora valores de meta que no son booleanos', () {
      final result = parseGoalEvaluation(
        '{"g1": "true", "g2": 1, "g3": false}',
      );

      expect(result.goals, {'g3': false});
    });

    test('JSON inválido devuelve resultado vacío sin lanzar', () {
      final result = parseGoalEvaluation('{"goals": ');

      expect(result.isEmpty, isTrue);
      expect(parseGoalEvaluation('').isEmpty, isTrue);
      expect(parseGoalEvaluation('[]').isEmpty, isTrue);
    });
  });

  group('correctionsForLevel (correction_level)', () {
    final corrections = [
      const SessionCorrection(
        original: 'I go',
        corrected: 'I went',
        type: CorrectionType.grammar,
      ),
      const SessionCorrection(
        original: 'big house',
        corrected: 'large house',
        type: CorrectionType.wordChoice,
      ),
      const SessionCorrection(
        original: 'definately',
        corrected: 'definitely',
        type: CorrectionType.typoStt,
      ),
    ];

    test('normaliza niveles desconocidos a short', () {
      expect(normalizeCorrectionLevel('Loud'), 'short');
      expect(normalizeCorrectionLevel(null), 'short');
      expect(normalizeCorrectionLevel('TEACHER'), 'teacher');
    });

    test('important_only solo muestra gramática', () {
      final visible = correctionsForLevel(corrections, 'important_only');
      expect(visible, hasLength(1));
      expect(visible.single.type, CorrectionType.grammar);
    });

    test('short y moderate recortan la cantidad', () {
      expect(correctionsForLevel(corrections, 'short'), hasLength(1));
      expect(correctionsForLevel(corrections, 'moderate'), hasLength(2));
      expect(correctionsForLevel(corrections, 'detailed'), hasLength(3));
      expect(correctionsForLevel(corrections, 'teacher'), hasLength(3));
    });

    test('la explicación solo se muestra desde moderate', () {
      expect(showsCorrectionExplanation('important_only'), isFalse);
      expect(showsCorrectionExplanation('short'), isFalse);
      expect(showsCorrectionExplanation('moderate'), isTrue);
      expect(showsCorrectionExplanation('detailed'), isTrue);
      expect(showsCorrectionExplanation('teacher'), isTrue);
    });
  });

  group('groupCorrections (pantalla Mis errores)', () {
    test('agrupa por tipo y forma corregida contando recurrencia', () {
      final groups = groupCorrections([
        const CorrectionRecord(
          type: CorrectionType.grammar,
          original: 'I go',
          corrected: 'I went',
          createdAt: null,
        ),
        CorrectionRecord(
          type: CorrectionType.grammar,
          original: 'i go.',
          corrected: 'I Went',
          explanation: 'past simple',
          createdAt: DateTime.utc(2026, 10, 29),
        ),
        const CorrectionRecord(
          type: CorrectionType.wordChoice,
          original: 'big house',
          corrected: 'large house',
        ),
      ]);

      expect(groups, hasLength(2));
      final grammar = groups.first;
      expect(grammar.type, CorrectionType.grammar);
      expect(grammar.occurrences, 2);
      expect(grammar.isRecurring, isTrue);
      // La versión más reciente manda en original/explicación.
      expect(grammar.original, 'i go.');
      expect(grammar.explanation, 'past simple');
      expect(groups.last.occurrences, 1);
      expect(groups.last.isRecurring, isFalse);
    });

    test('ordena por recurrencia descendente y luego alfabéticamente', () {
      final groups = groupCorrections([
        const CorrectionRecord(
          type: CorrectionType.vocabulary,
          original: 'a',
          corrected: 'b',
        ),
        const CorrectionRecord(
          type: CorrectionType.vocabulary,
          original: 'z',
          corrected: 'zebra',
        ),
        const CorrectionRecord(
          type: CorrectionType.grammar,
          original: 'x',
          corrected: 'y',
        ),
      ]);

      expect(groups.map((g) => g.corrected), ['b', 'y', 'zebra']);
    });

    test('separa las secciones por tipo en orden del enum', () {
      final groups = groupCorrections([
        const CorrectionRecord(
          type: CorrectionType.typoStt,
          original: 'definately',
          corrected: 'definitely',
        ),
        const CorrectionRecord(
          type: CorrectionType.grammar,
          original: 'I go',
          corrected: 'I went',
        ),
        const CorrectionRecord(
          type: CorrectionType.grammar,
          original: 'he go',
          corrected: 'he goes',
        ),
      ]);

      final sections = groupCorrectionsByType(groups);
      expect(sections.keys.toList(), [
        CorrectionType.grammar,
        CorrectionType.typoStt,
      ]);
      expect(sections[CorrectionType.grammar], hasLength(2));
    });
  });

  group('contexto para misiones y prompt del tutor', () {
    final groups = groupCorrections([
      for (var i = 0; i < 3; i++)
        const CorrectionRecord(
          type: CorrectionType.grammar,
          original: 'I go yesterday',
          corrected: 'I went yesterday',
        ),
    ]);

    test('genera el hint del tutor con los errores recurrentes', () {
      final hint = buildTutorRecurringErrorsHint(groups);
      expect(hint, contains('I went yesterday'));
      expect(hint, contains('3x'));
      expect(hint, contains('student'));
    });

    test('el hint del tutor queda vacío sin recurrencia', () {
      final single = groupCorrections([
        const CorrectionRecord(
          type: CorrectionType.grammar,
          original: 'a',
          corrected: 'b',
        ),
      ]);
      expect(buildTutorRecurringErrorsHint(single), isEmpty);
    });

    test('el foco de la misión de refuerzo usa el mismo registro', () {
      final focus = buildMissionFocusFromErrors(groups);
      expect(focus, contains('grammar'));
      expect(focus, contains('I went yesterday'));
      expect(buildMissionFocusFromErrors(const []), isEmpty);
    });
  });
}
