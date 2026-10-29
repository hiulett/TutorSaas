import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/onboarding/domain/models/placement_outcome.dart';

/// #73: el cliente ya no clasifica el nivel. Estos tests cubren el contrato con
/// `evaluate-placement`: el nivel y el rango llegan validados del servidor y el
/// cliente no inventa valores si faltan.
void main() {
  test('lee el resultado completo del servidor', () {
    final outcome = PlacementOutcome.fromMap(const {
      'cefr_level': 'b2',
      'game_rank': 'b',
      'scores': {'grammar': 70, 'fluency': 68},
      'strengths': ['good connectors', '  '],
      'weaknesses': ['tense agreement'],
      'explanation': 'Structured answers with minor errors.',
      'recommended_focus': 'Past perfect',
      'previous_cefr_level': 'B1',
      'promoted': true,
      'source': 'ai',
    });

    expect(outcome.cefrLevel, 'B2');
    expect(outcome.gameRank, 'B');
    expect(outcome.scores['grammar'], 70);
    expect(outcome.strengths, ['good connectors']);
    expect(outcome.weaknesses, ['tense agreement']);
    expect(outcome.recommendedFocus, 'Past perfect');
    expect(outcome.previousCefrLevel, 'B1');
    expect(outcome.promoted, isTrue);
    expect(outcome.fromHeuristic, isFalse);
  });

  test('sin evaluacion previa no hay promocion', () {
    final outcome = PlacementOutcome.fromMap(const {
      'cefr_level': 'A1',
      'game_rank': 'E',
      'previous_cefr_level': null,
      'promoted': false,
    });

    expect(outcome.previousCefrLevel, isEmpty);
    expect(outcome.promoted, isFalse);
  });

  test('marca el respaldo heuristico del servidor', () {
    final outcome = PlacementOutcome.fromMap(const {
      'cefr_level': 'C1',
      'game_rank': 'A',
      'source': 'heuristic',
    });

    expect(outcome.fromHeuristic, isTrue);
  });

  test('un mapa vacio no inventa nivel', () {
    final outcome = PlacementOutcome.fromMap(const {});

    expect(outcome.cefrLevel, isEmpty);
    expect(outcome.gameRank, isEmpty);
    expect(outcome.scores, isEmpty);
    expect(outcome.strengths, isEmpty);
  });

  test('scores y listas con tipos inesperados no rompen', () {
    final outcome = PlacementOutcome.fromMap(const {
      'cefr_level': 'B1',
      'game_rank': 'C',
      'scores': 'not-a-map',
      'strengths': [1, 2, 3],
    });

    expect(outcome.scores, isEmpty);
    expect(outcome.strengths, isEmpty);
    expect(outcome.cefrLevel, 'B1');
  });
}
