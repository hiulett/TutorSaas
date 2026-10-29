import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/listening/domain/models/listening_exercise.dart';
import 'package:tutorsaas/features/listening/domain/services/listening_grading.dart';

/// P-30 (#115) — corrección y puntuación de comprensión auditiva.
///
/// La regla de superación es la canónica de P-38 (`LessonCompletion.isPassed`,
/// la misma que aplica `lesson_completion_passed` en servidor).
ListeningExercise _exercise({int questions = 3}) {
  return ListeningExercise.fromMap({
    'id': 'ex-1',
    'slug': 'a1_coffee_to_go',
    'level': 'a1',
    'title': 'Coffee to go',
    'context': 'At a coffee shop.',
    'lines': [
      {'speaker': 'Barista', 'text': 'Good morning!'},
      {'speaker': 'Customer', 'text': 'A flat white, please.'},
    ],
    'questions': List.generate(
      questions,
      (i) => {
        'id': 'q${i + 1}',
        'prompt': 'Question ${i + 1}?',
        'options': [
          {'id': 'a', 'text': 'A'},
          {'id': 'b', 'text': 'B'},
          {'id': 'c', 'text': 'C'},
        ],
        'correct': 'a',
        'explanation': 'Because A.',
      },
    ),
  });
}

void main() {
  group('ListeningGrading.evaluate', () {
    test('todo correcto: 3 de 3, superado y 3 estrellas', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(),
        answers: {'q1': 'a', 'q2': 'a', 'q3': 'a'},
      );

      expect(grade.score, 3);
      expect(grade.total, 3);
      expect(grade.passed, isTrue);
      expect(grade.stars, 3);
      expect(grade.ratio, 1.0);
      expect(grade.isCorrect('q2'), isTrue);
    });

    test('2 de 3 supera por la tolerancia de una meta (P-38)', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(),
        answers: {'q1': 'a', 'q2': 'b', 'q3': 'a'},
      );

      expect(grade.score, 2);
      expect(grade.passed, isTrue);
      expect(grade.isCorrect('q2'), isFalse);
      // 2/3 = 66.6 % < 75 %: superada pero 1 estrella.
      expect(grade.stars, 1);
    });

    test('sin respuestas: 0 de 3, no superado, 0 estrellas', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(),
        answers: const {},
      );

      expect(grade.score, 0);
      expect(grade.passed, isFalse);
      expect(grade.stars, 0);
      expect(grade.correctness.values.every((v) => v == false), isTrue);
    });

    test('una pregunta sin responder cuenta como fallada', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(),
        answers: {'q1': 'a', 'q3': 'a'},
      );

      expect(grade.score, 2);
      expect(grade.correctness['q2'], isFalse);
    });

    test('respuestas de preguntas inexistentes se ignoran', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(),
        answers: {'q1': 'a', 'q2': 'a', 'q3': 'a', 'q99': 'a'},
      );

      expect(grade.score, 3);
      expect(grade.correctness.containsKey('q99'), isFalse);
    });

    test('opción no válida no acierta', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(),
        answers: {'q1': 'z', 'q2': 'a', 'q3': 'a'},
      );

      expect(grade.score, 2);
      expect(grade.isCorrect('q1'), isFalse);
    });

    test('4 preguntas con 3 aciertos (75 %) supera con 2 estrellas', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(questions: 4),
        answers: {'q1': 'a', 'q2': 'a', 'q3': 'a', 'q4': 'b'},
      );

      expect(grade.score, 3);
      expect(grade.total, 4);
      expect(grade.passed, isTrue);
      expect(grade.stars, 2);
    });

    test('4 preguntas con 2 aciertos (50 %) no supera', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(questions: 4),
        answers: {'q1': 'a', 'q2': 'a', 'q3': 'b', 'q4': 'b'},
      );

      expect(grade.score, 2);
      expect(grade.passed, isFalse);
      expect(grade.stars, 0);
    });

    test('respuestas con espacios se normalizan', () {
      final grade = ListeningGrading.evaluate(
        exercise: _exercise(questions: 1),
        answers: {'q1': ' a '},
      );

      expect(grade.score, 1);
    });
  });
}
