import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/ai/placement_ai.dart';

/// QA — clasificación CEFR de respaldo del Oráculo.
///
/// Issue #44: este test antes replicaba los umbrales en vez de importar el
/// código real. Ahora ejercita `PlacementAiEvaluator.classifyCefrByWordCount`.
///
/// Umbrales: A1 < 6, A2 6-11, B1 12-19, B2 20-31, C1 >= 32 (media de palabras).
String answerOf(int n) => List.filled(n, 'word').join(' ');

String classify(List<String> answers) =>
    PlacementAiEvaluator.classifyCefrByWordCount(answers);

void main() {
  group('respuesta única (avg = palabras)', () {
    test('A1 por debajo de 6 (avg 5)', () {
      expect(classify([answerOf(5)]), 'A1');
    });

    test('A2 en el límite inferior (avg 6)', () {
      expect(classify([answerOf(6)]), 'A2');
    });

    test('A2 en el límite superior del rango (avg 11)', () {
      expect(classify([answerOf(11)]), 'A2');
    });

    test('B1 en el límite inferior (avg 12)', () {
      expect(classify([answerOf(12)]), 'B1');
    });

    test('B1 en el límite superior del rango (avg 19)', () {
      expect(classify([answerOf(19)]), 'B1');
    });

    test('B2 en el límite inferior (avg 20)', () {
      expect(classify([answerOf(20)]), 'B2');
    });

    test('B2 en el límite superior del rango (avg 31)', () {
      expect(classify([answerOf(31)]), 'B2');
    });

    test('C1 en el límite inferior (avg 32)', () {
      expect(classify([answerOf(32)]), 'C1');
    });

    test('C1 para respuestas largas (avg 40)', () {
      expect(classify([answerOf(40)]), 'C1');
    });
  });

  group('media sobre varias respuestas', () {
    test('lista vacía devuelve A1', () {
      expect(classify(const []), 'A1');
    });

    test('avg (6+6)/2 = 6 → A2', () {
      expect(classify([answerOf(6), answerOf(6)]), 'A2');
    });

    test('avg (8+4)/2 = 6 compensa respuestas cortas → A2', () {
      expect(classify([answerOf(8), answerOf(4)]), 'A2');
    });

    test('avg (4+4)/2 = 4 → A1', () {
      expect(classify([answerOf(4), answerOf(4)]), 'A1');
    });

    test('avg (20+44)/2 = 32 → C1', () {
      expect(classify([answerOf(20), answerOf(44)]), 'C1');
    });
  });

  group('robustez del conteo', () {
    test('espacios múltiples no inflan el conteo', () {
      expect(classify(['  hello    brave new   world  ']), 'A1');
    });

    test('texto vacío cuenta como 0 palabras', () {
      expect(classify(['', '   ']), 'A1');
    });

    test('la heurística nunca produce PRE-A1 ni C2', () {
      for (var n = 0; n <= 60; n++) {
        final level = classify([answerOf(n)]);
        expect(level, isNot('PRE-A1'));
        expect(level, isNot('C2'));
      }
    });
  });
}
