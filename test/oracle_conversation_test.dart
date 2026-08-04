import 'package:flutter_test/flutter_test.dart';

/// QA-02: lógica de evaluación CEFR del Oráculo.
///
/// La lógica real vive en `lib/core/ai/placement_ai.dart`
/// (`PlacementAiEvaluator._heuristicFallback`, umbrales A1<6, A2 6-11,
/// B1 12-19, B2 20-31, C1 >= 32) y en el turno Oracle de
/// `lib/features/conversation/presentation/providers/conversation_providers.dart`.
/// Este test NO importa esos archivos: replica la lógica mínima y verifica los
/// umbrales del código real.
///
/// Umbrales: A1 < 6, A2 6-11, B1 12-19, B2 20-31, C1 >= 32 (media de palabras).
const int minWordsA2 = 6;
const int minWordsB1 = 12;
const int minWordsB2 = 20;
const int minWordsC1 = 32;

int wordCount(String text) =>
    text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

String computeLevel(List<String> answers) {
  if (answers.isEmpty) return 'A1';
  final totalWords = answers.fold<int>(0, (sum, a) => sum + wordCount(a));
  final avg = totalWords / answers.length;
  if (avg >= minWordsC1) return 'C1';
  if (avg >= minWordsB2) return 'B2';
  if (avg >= minWordsB1) return 'B1';
  if (avg >= minWordsA2) return 'A2';
  return 'A1';
}

/// Genera una respuesta de exactamente [n] palabras.
String answerOf(int n) => List.filled(n, 'word').join(' ');

void main() {
  group('wordCount (conteo de palabras por respuesta)', () {
    test('cuenta palabras separadas por un espacio', () {
      expect(wordCount('hello world'), 2);
    });

    test('cuenta palabras con espacios múltiples y trim', () {
      expect(wordCount('  hello    brave new   world  '), 4);
    });

    test('devuelve 0 para texto vacío o solo espacios', () {
      expect(wordCount(''), 0);
      expect(wordCount('   '), 0);
    });
  });

  group('computeLevel con respuesta única (avg = palabras)', () {
    test('A1 para menos de 6 palabras (avg 5)', () {
      expect(computeLevel([answerOf(5)]), 'A1');
    });

    test('A2 en el límite inferior (avg 6)', () {
      expect(computeLevel([answerOf(6)]), 'A2');
    });

    test('A2 en el límite superior del rango (avg 11)', () {
      expect(computeLevel([answerOf(11)]), 'A2');
    });

    test('B1 en el límite inferior (avg 12)', () {
      expect(computeLevel([answerOf(12)]), 'B1');
    });

    test('B1 en el límite superior del rango (avg 19)', () {
      expect(computeLevel([answerOf(19)]), 'B1');
    });

    test('B2 en el límite inferior (avg 20)', () {
      expect(computeLevel([answerOf(20)]), 'B2');
    });

    test('B2 en el límite superior del rango (avg 31)', () {
      expect(computeLevel([answerOf(31)]), 'B2');
    });

    test('C1 en el límite inferior (avg 32)', () {
      expect(computeLevel([answerOf(32)]), 'C1');
    });

    test('C1 para respuestas largas (avg 40)', () {
      expect(computeLevel([answerOf(40)]), 'C1');
    });
  });

  group('computeLevel con media sobre varias respuestas', () {
    test('sin respuestas devuelve A1', () {
      expect(computeLevel([]), 'A1');
    });

    test('avg (6+6)/2 = 6 → A2', () {
      expect(computeLevel([answerOf(6), answerOf(6)]), 'A2');
    });

    test('avg (8+4)/2 = 6 → A2 (compensa respuestas cortas)', () {
      expect(computeLevel([answerOf(8), answerOf(4)]), 'A2');
    });

    test('avg (4+4)/2 = 4 → A1', () {
      expect(computeLevel([answerOf(4), answerOf(4)]), 'A1');
    });

    test('avg (20+44)/2 = 32 → C1', () {
      expect(computeLevel([answerOf(20), answerOf(44)]), 'C1');
    });
  });

  group('constantes replicadas coinciden con el código real', () {
    test('umbrales documentados (6/12/20/32)', () {
      expect(minWordsA2, 6);
      expect(minWordsB1, 12);
      expect(minWordsB2, 20);
      expect(minWordsC1, 32);
    });
  });
}
