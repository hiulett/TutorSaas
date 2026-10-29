import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/listening/domain/models/listening_exercise.dart';

/// P-30 (#115) — normalización del banco de ítems y del progreso.
Map<String, dynamic> _row({
  String id = 'ex-1',
  String slug = 'a1_coffee_to_go',
  String level = 'A1',
}) {
  return {
    'id': id,
    'slug': slug,
    'level': level,
    'title': 'Coffee to go',
    'context': 'At a coffee shop.',
    'lines': [
      {'speaker': 'Barista', 'text': 'Good morning!'},
      {'speaker': 'Customer', 'text': 'A flat white, please.'},
    ],
    'questions': [
      {
        'id': 'q1',
        'prompt': 'What does the customer order?',
        'options': [
          {'id': 'a', 'text': 'A latte'},
          {'id': 'b', 'text': 'A flat white'},
        ],
        'correct': 'b',
        'explanation': 'Can I have a flat white.',
      },
    ],
    'sort_order': 10,
  };
}

void main() {
  group('ListeningExercise.fromMap', () {
    test('normaliza el nivel a mayúsculas y conserva el orden', () {
      final exercise = ListeningExercise.fromMap(_row(level: 'a1'));

      expect(exercise.level, 'A1');
      expect(exercise.slug, 'a1_coffee_to_go');
      expect(exercise.sortOrder, 10);
      expect(exercise.isPlayable, isTrue);
      expect(exercise.lessonId, 'listening:a1_coffee_to_go');
    });

    test('el texto hablado incluye el nombre del hablante', () {
      final exercise = ListeningExercise.fromMap(_row());

      expect(exercise.lines.first.spoken, 'Barista says: Good morning!');
      expect(exercise.transcript, contains('A flat white'));
    });

    test('descarta líneas vacías', () {
      final exercise = ListeningExercise.fromMap({
        ..._row(),
        'lines': [
          {'speaker': 'Barista', 'text': 'Hello'},
          {'speaker': 'Barista', 'text': '   '},
        ],
      });

      expect(exercise.lines.length, 1);
    });

    test('un ejercicio sin preguntas no es jugable', () {
      final exercise = ListeningExercise.fromMap({..._row(), 'questions': []});

      expect(exercise.isPlayable, isFalse);
    });

    test(
      'una pregunta cuya respuesta no está entre las opciones es inválida',
      () {
        final exercise = ListeningExercise.fromMap({
          ..._row(),
          'questions': [
            {
              'id': 'q1',
              'prompt': 'Broken?',
              'options': [
                {'id': 'a', 'text': 'A'},
                {'id': 'b', 'text': 'B'},
              ],
              'correct': 'z',
            },
          ],
        });

        expect(exercise.isPlayable, isFalse);
      },
    );

    test('tolera mapas sin datos (fila corrupta) sin lanzar', () {
      final exercise = ListeningExercise.fromMap(null);

      expect(exercise.id, isEmpty);
      expect(exercise.questions, isEmpty);
      expect(exercise.isPlayable, isFalse);
    });
  });

  group('ListeningAttemptResult.fromMap', () {
    test('lee el resultado y el detalle por pregunta', () {
      final result = ListeningAttemptResult.fromMap({
        'ok': true,
        'score': 2,
        'total': 3,
        'passed': true,
        'missions_advanced': 2,
        'results': [
          {'id': 'q1', 'correct': true, 'answer': 'b', 'explanation': 'ok'},
          {'id': 'q2', 'correct': false, 'answer': 'a', 'explanation': 'no'},
        ],
        'practice': {'minutes_added': 3, 'already_registered': false},
      });

      expect(result.ok, isTrue);
      expect(result.passed, isTrue);
      expect(result.score, 2);
      expect(result.missionsAdvanced, 2);
      expect(result.minutesAdded, 3);
      expect(result.practiceAlreadyRegistered, isFalse);
      expect(result.results.length, 2);
      expect(result.results.first.isCorrect, isTrue);
      expect(result.results[1].correctOptionId, 'a');
    });

    test('traduce los motivos del servidor a mensajes accionables', () {
      expect(
        const ListeningAttemptResult(
          ok: false,
          reason: 'unauthorized',
        ).reasonMessage,
        contains('sesión'),
      );
      expect(
        const ListeningAttemptResult(
          ok: false,
          reason: 'exercise_empty',
        ).reasonMessage,
        contains('contenido'),
      );
      expect(
        const ListeningAttemptResult(ok: false).reasonMessage,
        contains('Inténtalo de nuevo'),
      );
    });

    test('una respuesta vacía del servidor no se toma como éxito', () {
      final result = ListeningAttemptResult.fromMap(null);

      expect(result.ok, isFalse);
      expect(result.score, 0);
      expect(result.passed, isFalse);
    });
  });

  group('ListeningProgress', () {
    test('agrupa intentos y se queda con la mejor marca', () {
      final progress = ListeningProgress.fromAttempts([
        {'exercise_id': 'ex-1', 'score': 1, 'total': 3, 'passed': false},
        {'exercise_id': 'ex-1', 'score': 2, 'total': 3, 'passed': true},
        {'exercise_id': 'ex-2', 'score': 0, 'total': 4, 'passed': false},
      ]);

      final first = progress.forExercise('ex-1');
      expect(first?.bestScore, 2);
      expect(first?.attempts, 2);
      expect(first?.passed, isTrue);
      expect(progress.isPassed('ex-1'), isTrue);
      expect(progress.isPassed('ex-2'), isFalse);
    });

    test('ignora filas sin exercise_id', () {
      final progress = ListeningProgress.fromAttempts([
        {'score': 3, 'total': 3, 'passed': true},
      ]);

      expect(progress.byExerciseId, isEmpty);
    });

    test('cuenta superados del nivel y elige el siguiente pendiente', () {
      final exercises = [
        ListeningExercise.fromMap(_row(id: 'ex-1', slug: 'a')),
        ListeningExercise.fromMap(_row(id: 'ex-2', slug: 'b')),
        ListeningExercise.fromMap(_row(id: 'ex-3', slug: 'c')),
      ];
      final progress = ListeningProgress.fromAttempts([
        {'exercise_id': 'ex-1', 'score': 3, 'total': 3, 'passed': true},
        {'exercise_id': 'ex-2', 'score': 1, 'total': 3, 'passed': false},
      ]);

      expect(progress.passedCount(exercises), 1);
      expect(progress.nextOf(exercises)?.id, 'ex-2');
    });

    test('si todo está superado recomienda el primero para repaso', () {
      final exercises = [
        ListeningExercise.fromMap(_row(id: 'ex-1', slug: 'a')),
        ListeningExercise.fromMap(_row(id: 'ex-2', slug: 'b')),
      ];
      final progress = ListeningProgress.fromAttempts([
        {'exercise_id': 'ex-1', 'score': 3, 'total': 3, 'passed': true},
        {'exercise_id': 'ex-2', 'score': 3, 'total': 3, 'passed': true},
      ]);

      expect(progress.nextOf(exercises)?.id, 'ex-1');
    });

    test('sin ejercicios no hay siguiente', () {
      expect(const ListeningProgress().nextOf(const []), isNull);
    });
  });
}
