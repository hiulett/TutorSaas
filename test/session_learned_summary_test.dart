import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/session_learned_summary.dart';

/// P-28 (#113): el resumen «Qué aprendiste» no debe inventar cifras. Estos
/// tests cubren el parseo tolerante de la RPC y la composición de la vista con
/// datos reales (BD + recompensa + estado en memoria de la sesión).
void main() {
  group('LearnedSummaryData.fromRpc', () {
    test('parsea palabras, correcciones, metas, foco y métricas reales', () {
      final data = LearnedSummaryData.fromRpc({
        'words': [
          {
            'vocabulary_id': 'v-1',
            'word': 'booking',
            'translation': 'reserva',
            'is_new': true,
            'mastered': false,
            'interval_days': 1,
          },
          {
            'word': 'upgrade',
            'translation': 'mejora',
            'is_new': false,
            'interval_days': 6,
          },
        ],
        'new_words': 5,
        'reviewed_words': 2,
        'corrections': [
          {
            'original': 'I want a room',
            'corrected': 'I would like a room',
            'explanation': 'I would like es más educado',
            'error_type': 'politeness',
          },
        ],
        'goals': ['Provide your name for reservation', 'Confirm room type'],
        'goals_completed': 2,
        'goals_total': 4,
        'focus': {'text': 'past tenses', 'source': 'error_type'},
        'metrics': {'phonetic_clarity': 82, 'wpm': 96},
      });

      expect(data.words, hasLength(2));
      expect(data.words.first.word, 'booking');
      expect(data.words.first.translation, 'reserva');
      expect(data.words.first.vocabularyId, 'v-1');
      expect(data.words.first.isNew, isTrue);
      expect(data.words.first.intervalDays, 1);
      expect(data.words[1].isNew, isFalse);
      expect(data.words[1].vocabularyId, isNull);

      expect(data.corrections, hasLength(1));
      final correction = data.corrections.single;
      expect(correction.original, 'I want a room');
      expect(correction.corrected, 'I would like a room');
      expect(correction.explanation, 'I would like es más educado');
      expect(correction.errorType, 'politeness');

      expect(data.completedGoals, hasLength(2));
      expect(data.goalsCompletedInDb, 2);
      expect(data.goalsTotalInDb, 4);
      expect(data.newWords, 5);
      expect(data.reviewedWords, 2);
      expect(data.focus, 'past tenses');
      expect(data.focusSource, 'error_type');
      expect(data.phoneticClarity, 82);
      expect(data.wpm, 96);
      expect(data.hasWords, isTrue);
      expect(data.hasCorrections, isTrue);
      expect(data.hasFocus, isTrue);
    });

    test('sin datos devuelve vacío explícito (nunca cifras inventadas)', () {
      for (final raw in <Object?>[null, 'nope', 42, <String, dynamic>{}]) {
        final data = LearnedSummaryData.fromRpc(raw);
        expect(data.words, isEmpty);
        expect(data.corrections, isEmpty);
        expect(data.completedGoals, isEmpty);
        expect(data.goalsCompletedInDb, 0);
        expect(data.goalsTotalInDb, isNull);
        expect(data.focus, isNull);
        expect(data.hasWords, isFalse);
        expect(data.hasCorrections, isFalse);
        expect(data.hasFocus, isFalse);
        expect(data.phoneticClarity, isNull);
      }
    });

    test('descarta filas incompletas y usa el word como traducción', () {
      final data = LearnedSummaryData.fromRpc({
        'words': [
          {'word': '   ', 'translation': 'vacía'},
          {'word': 'hello'},
          {'translation': 'sin palabra'},
        ],
        'corrections': [
          {'original': 'solo original'},
          {'original': '', 'corrected': 'algo'},
          {'original': 'a', 'corrected': 'b'},
        ],
        'goals': ['', '  ', 'Meta real'],
      });

      expect(data.words, hasLength(1));
      expect(data.words.single.word, 'hello');
      expect(data.words.single.translation, 'hello');

      expect(data.corrections, hasLength(1));
      expect(data.corrections.single.original, 'a');

      expect(data.completedGoals, ['Meta real']);
    });

    test('acepta foco como texto plano y goals_completed ausente', () {
      final data = LearnedSummaryData.fromRpc({
        'focus': 'pronunciación de /θ/',
        'goals': ['Meta 1', 'Meta 2'],
      });

      expect(data.focus, 'pronunciación de /θ/');
      expect(data.focusSource, isNull);
      // Sin contador explícito se usa el tamaño de la lista de metas.
      expect(data.goalsCompletedInDb, 2);
    });
  });

  group('SessionSummaryView.from', () {
    test('usa la recompensa real del servidor', () {
      final view = SessionSummaryView.from(
        sessionResult: {
          'xp': 120,
          'gold': 45,
          'fragments': 30,
          'reward_applied': true,
          'objectives': 3,
          'goals_total': 4,
          'minutes': 8,
          'turns': 12,
        },
        inMemoryWords: 74,
      );

      expect(view.xp, 120);
      expect(view.gold, 45);
      expect(view.fragments, 30);
      expect(view.rewardApplied, isTrue);
      expect(view.xpLabel, '+120');
      expect(view.goldLabel, '+45');
      expect(view.fragmentsLabel, '+30');
      expect(view.goalsCompleted, 3);
      expect(view.goalsTotal, 4);
      expect(view.goalsLabel, '3/4');
      expect(view.minutes, 8);
      expect(view.turns, 12);
      expect(view.words, 74);
      expect(view.hasSessionData, isTrue);
      expect(view.goalsRatio, closeTo(0.75, 0.0001));
    });

    test('sin recompensa confirmada muestra «—» en lugar de ceros', () {
      final view = SessionSummaryView.from(
        sessionResult: {'minutes': 2, 'reward_applied': false},
      );

      expect(view.rewardApplied, isFalse);
      expect(view.xpLabel, '—');
      expect(view.goldLabel, '—');
      expect(view.fragmentsLabel, '—');
    });

    test('sin sesión no declara datos (todo «—» o vacío)', () {
      const view = SessionSummaryView.empty;

      expect(view.hasSessionData, isFalse);
      expect(view.goalsRatio, 0);
      expect(view.goalsLabel, '0');
      expect(view.xpLabel, '—');
      expect(view.learned.hasWords, isFalse);
      expect(view.metricRows, hasLength(4));
      for (final row in view.metricRows) {
        expect(row.value, '—');
      }
    });

    test('las metas en memoria nunca quedan por debajo de lo logrado', () {
      final view = SessionSummaryView.from(
        // La BD puede ir un paso por detrás: las metas se escriben sin await.
        sessionResult: {'objectives': 1, 'goals_total': 4, 'minutes': 5},
        learned: const LearnedSummaryData(goalsCompletedInDb: 2),
        inMemoryGoalsCompleted: 3,
        catalogGoalsTotal: 4,
      );

      expect(view.goalsCompleted, 3);
      expect(view.goalsTotal, 4);
      expect(view.goalsLabel, '3/4');
    });

    test('el total nunca es menor que las completadas', () {
      final view = SessionSummaryView.from(
        sessionResult: {'objectives': 3},
        learned: const LearnedSummaryData(goalsTotalInDb: 2),
      );

      expect(view.goalsCompleted, 3);
      expect(view.goalsTotal, 3);
      expect(view.goalsRatio, 1);
      expect(view.goalsLabel, '3/3');
    });

    test('sin metas declara el total desconocido en lugar de inventarlo', () {
      final view = SessionSummaryView.from(sessionResult: {'objectives': 2});

      expect(view.goalsCompleted, 2);
      expect(view.goalsTotal, 2);
      // La celda de metas sigue mostrando el dato real disponible.
      expect(
        view.metricRows
            .firstWhere((m) => m.kind == SummaryMetricKind.goals)
            .value,
        '2/2',
      );
    });

    test('filas de métricas con datos reales y sin datos', () {
      final withData = SessionSummaryView.from(
        sessionResult: {'minutes': 7, 'turns': 5},
        inMemoryWords: 40,
        inMemoryGoalsCompleted: 1,
        catalogGoalsTotal: 3,
      );
      final values = {
        for (final row in withData.metricRows) row.kind: row.value,
      };
      expect(values[SummaryMetricKind.duration], '7');
      expect(values[SummaryMetricKind.words], '40');
      expect(values[SummaryMetricKind.goals], '1/3');
      expect(values[SummaryMetricKind.turns], '5');
    });

    test('expone las palabras listas para el repaso SRS', () {
      final view = SessionSummaryView.from(
        learned: const LearnedSummaryData(
          words: [
            LearnedWord(
              vocabularyId: 'v-9',
              word: 'booking',
              translation: 'reserva',
              isNew: true,
              intervalDays: 3,
            ),
          ],
        ),
      );

      expect(view.srsItems, hasLength(1));
      expect(view.srsItems.single['word'], 'booking');
      expect(view.srsItems.single['translation'], 'reserva');
      expect(view.srsItems.single['vocabulary_id'], 'v-9');
      expect(view.srsItems.single['interval_days'], 3);
    });
  });
}
