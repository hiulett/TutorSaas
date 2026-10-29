import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/goal_evaluation_baseline.dart';

/// P-39 — Golden set determinista de evaluación de metas.
///
/// Replica las conversaciones de `test/fixtures/goal_evaluation_golden_set.json`
/// contra [GoalEvaluationBaseline]. No llama a ningún modelo: mide la línea base
/// heurística y documenta el resultado esperado de cada caso. El objetivo de
/// acuerdo es ≥90 % de etiquetas de meta correctas.
void main() {
  final fixtureFile = File('test/fixtures/goal_evaluation_golden_set.json');

  late Map<String, dynamic> fixture;
  late List<dynamic> cases;

  setUpAll(() {
    fixture =
        jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;
    cases = fixture['cases'] as List<dynamic>;
  });

  test('el fixture es versionado y tiene casos suficientes', () {
    expect(fixture['version'], 1);
    expect(cases.length, greaterThanOrEqualTo(8));
  });

  test('cada caso declara metas y expected con los mismos ids', () {
    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      final goalIds = (c['goals'] as List)
          .map((g) => (g as Map<String, dynamic>)['id'] as String)
          .toSet();
      final expectedIds = (c['expected'] as Map<String, dynamic>).keys.toSet();
      expect(
        expectedIds,
        goalIds,
        reason: '${c['id']}: expected debe cubrir exactamente el catálogo',
      );
    }
  });

  test('el evaluador base cumple ≥90 % del golden set', () {
    var total = 0;
    var correct = 0;
    final failures = <String>[];

    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      final goals = (c['goals'] as List)
          .map(
            (g) => GoalBaselineRule(
              id: (g as Map<String, dynamic>)['id'] as String,
              text: g['text'] as String,
              keywords: ((g['keywords'] as List?) ?? const [])
                  .map((k) => k as String)
                  .toList(),
              examplePhrase: (g['examplePhrase'] as String?) ?? '',
            ),
          )
          .toList();
      final turns = (c['turns'] as List)
          .map(
            (t) => GoalBaselineTurn(
              speaker: (t as Map<String, dynamic>)['speaker'] as String,
              text: t['text'] as String,
            ),
          )
          .toList();
      final expected = Map<String, bool>.from(
        c['expected'] as Map<String, dynamic>,
      );

      final actual = GoalEvaluationBaseline.evaluate(
        goals: goals,
        turns: turns,
        level: (c['level'] as String?) ?? 'A1',
      );

      // Determinismo: la misma entrada da exactamente la misma salida.
      final repeated = GoalEvaluationBaseline.evaluate(
        goals: goals,
        turns: turns,
        level: (c['level'] as String?) ?? 'A1',
      );
      expect(repeated, actual, reason: '${c['id']}: no es determinista');

      for (final id in expected.keys) {
        total++;
        if (actual[id] == expected[id]) {
          correct++;
        } else {
          failures.add(
            '${c['id']}.$id: esperado=${expected[id]}, obtenido=${actual[id]}',
          );
        }
      }
    }

    final accuracy = total == 0 ? 0.0 : correct / total;
    expect(
      accuracy,
      greaterThanOrEqualTo(0.9),
      reason:
          'Acuerdo ${(accuracy * 100).toStringAsFixed(1)}% '
          '($correct/$total). Fallos: ${failures.join(' | ')}',
    );
  });

  test('el tutor nunca aporta evidencia de una meta', () {
    const goals = [
      GoalBaselineRule(id: 'g1', text: 'Order a coffee', keywords: ['coffee']),
    ];
    final actual = GoalEvaluationBaseline.evaluate(
      goals: goals,
      turns: const [
        GoalBaselineTurn(
          speaker: 'tutor',
          text: 'I would like to order a coffee for you.',
        ),
      ],
    );
    expect(actual, {'g1': false});
  });

  test('una meta con dos requisitos exige ambos conceptos', () {
    const goals = [
      GoalBaselineRule(
        id: 'g1',
        text: 'Explain weakness with improvement step',
        keywords: ['weakness', 'improvement'],
      ),
    ];
    expect(
      GoalEvaluationBaseline.evaluate(
        goals: goals,
        turns: const [
          GoalBaselineTurn(
            speaker: 'user',
            text: 'My main weakness is delegation.',
          ),
        ],
        level: 'B1',
      ),
      {'g1': false},
    );
    expect(
      GoalEvaluationBaseline.evaluate(
        goals: goals,
        turns: const [
          GoalBaselineTurn(
            speaker: 'user',
            text:
                'My main weakness is delegation and I am taking a course to improve it.',
          ),
        ],
        level: 'B1',
      ),
      {'g1': true},
    );
  });
}
