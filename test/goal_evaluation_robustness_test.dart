import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/goal_evaluation_parser.dart';
import 'package:tutorsaas/features/conversation/domain/models/goal_evaluation_result.dart';

/// P-39 — Robustez del parseo de `goal_eval`.
///
/// Regla de oro: una meta solo se marca si el modelo devolvió `true` y el id
/// pertenece al catálogo de la lección. Este archivo cubre JSON parcial,
/// ids desconocidos, booleanos como string, respuestas vacías y tipos basura.
void main() {
  group('parseGoalEvaluation tolera respuestas parciales', () {
    test('recorta prosa alrededor del objeto JSON', () {
      final result = parseGoalEvaluation(
        'Here is the result: {"goals": {"g1": true}, "corrections": []} done.',
      );

      expect(result.succeeded, isTrue);
      expect(result.goals, {'g1': true});
    });

    test('rescata pares completos de un JSON truncado', () {
      final result = parseGoalEvaluation(
        '{"goals": {"g1": true, "g2": "false", "g3": fal',
      );

      expect(result.succeeded, isTrue);
      expect(result.goals, {'g1': true, 'g2': false});
    });

    test('no adivina un valor cortado ni un booleano ausente', () {
      final result = parseGoalEvaluation('{"goals": {"g1": tru');

      expect(result.isEmpty, isTrue);
      expect(result.succeeded, isFalse);
    });

    test('arregla comas finales antes de cerrar', () {
      final result = parseGoalEvaluation(
        '{"goals": {"g1": true, "g2": false,}, "corrections": [],}',
      );

      expect(result.goals, {'g1': true, 'g2': false});
    });

    test('el formato plano con corrections no pierde las metas', () {
      final result = parseGoalEvaluation(
        '{"g1": true, "g2": false, '
        '"corrections": [{"original": "I go", "corrected": "I went", "type": "grammar"}]}',
      );

      expect(result.goals, {'g1': true, 'g2': false});
      expect(result.corrections, hasLength(1));
    });
  });

  group('booleanos y tipos', () {
    test('acepta "true"/"false" como texto sin distinguir mayúsculas', () {
      final result = parseGoalEvaluation(
        '{"goals": {"g1": "true", "g2": "FALSE", "g3": " True "}}',
      );

      expect(result.goals, {'g1': true, 'g2': false, 'g3': true});
    });

    test('1, 0, null, listas y objetos no son evidencia', () {
      final result = parseGoalEvaluation(
        '{"goals": {"g1": 1, "g2": 0, "g3": null, "g4": [], "g5": {}}}',
      );

      expect(result.goals, isEmpty);
      expect(result.succeeded, isTrue);
    });

    test('un "goals" que no es mapa no rompe el parseo', () {
      final asString = parseGoalEvaluation('{"goals": "true"}');
      expect(asString.goals, isEmpty);
      expect(asString.succeeded, isFalse);

      final asList = parseGoalEvaluation('{"goals": [true, false]}');
      expect(asList.goals, isEmpty);
      expect(asList.succeeded, isFalse);
    });
  });

  group('respuestas vacías o basura', () {
    test('string vacío, espacios y null literal no evalúan', () {
      expect(parseGoalEvaluation('').succeeded, isFalse);
      expect(parseGoalEvaluation('   ').succeeded, isFalse);
      expect(parseGoalEvaluation('null').succeeded, isFalse);
      expect(parseGoalEvaluation('[]').succeeded, isFalse);
      expect(parseGoalEvaluation('not json at all').succeeded, isFalse);
    });

    test('un JSON válido sin metas sí cuenta como evaluación hecha', () {
      final result = parseGoalEvaluation('{"goals": {}, "corrections": []}');

      expect(result.goals, isEmpty);
      expect(result.succeeded, isTrue);
    });
  });

  group('catálogo de la lección (sin falsos positivos)', () {
    test('descarta ids inventados y deja false los no devueltos', () {
      final result = parseGoalEvaluation(
        '{"goals": {"g1": true, "g99": true, "g2": false}}',
      );

      expect(result.goalsForCatalog(['g1', 'g2', 'g3']), {
        'g1': true,
        'g2': false,
        'g3': false,
      });
    });

    test('un id desconocido en true nunca se marca', () {
      final result = parseGoalEvaluation('{"goals": {"g99": true}}');

      expect(result.goalsForCatalog(['g1']), {'g1': false});
      expect(result.goalsForCatalog([]), isEmpty);
    });

    test('los ids del catálogo se normalizan y los vacíos se ignoran', () {
      final result = parseGoalEvaluation('{"goals": {"g1": true}}');

      expect(result.goalsForCatalog([' g1 ', '', '   ']), {'g1': true});
    });

    test('un resultado vacío no inventa metas del catálogo en true', () {
      final result = GoalEvaluationResult.empty;

      expect(result.goalsForCatalog(['g1', 'g2']), {'g1': false, 'g2': false});
      expect(result.succeeded, isFalse);
    });
  });
}
