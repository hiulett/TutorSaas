import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/listening/domain/models/listening_exercise.dart';
import 'package:tutorsaas/features/listening/domain/models/listening_session.dart';

/// P-30 (#115) — máquina de estados del ejercicio de comprensión auditiva.
ListeningExercise _exercise() {
  return ListeningExercise.fromMap({
    'id': 'ex-1',
    'slug': 'a1_coffee_to_go',
    'level': 'A1',
    'title': 'Coffee to go',
    'lines': [
      {'speaker': 'Barista', 'text': 'Good morning!'},
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
      },
      {
        'id': 'q2',
        'prompt': 'What size?',
        'options': [
          {'id': 'a', 'text': 'Small'},
          {'id': 'b', 'text': 'Large'},
        ],
        'correct': 'b',
      },
    ],
  });
}

void main() {
  group('ListeningSession', () {
    test('arranca en la primera pregunta sin respuestas', () {
      final session = ListeningSession(exercise: _exercise());

      expect(session.phase, ListeningSessionPhase.answering);
      expect(session.index, 0);
      expect(session.current?.id, 'q1');
      expect(session.answeredCount, 0);
      expect(session.isComplete, isFalse);
      expect(session.canSubmit, isFalse);
      expect(session.isFirst, isTrue);
      expect(session.isLast, isFalse);
    });

    test('seleccionar una opción no avanza ni envía', () {
      final session = ListeningSession(exercise: _exercise()).select('b');

      expect(session.answerFor('q1'), 'b');
      expect(session.index, 0);
      expect(session.phase, ListeningSessionPhase.answering);
      expect(session.canSubmit, isFalse);
    });

    test('no avanza sin responder la pregunta actual', () {
      final session = ListeningSession(exercise: _exercise()).next();

      expect(session.index, 0);
    });

    test('avanza, retrocede y solo permite enviar con todo respondido', () {
      final first = ListeningSession(exercise: _exercise()).select('b');
      final second = first.next().select('a');

      expect(second.index, 1);
      expect(second.isLast, isTrue);
      expect(second.isComplete, isTrue);
      expect(second.canSubmit, isTrue);
      expect(second.localGrade.score, 1);
      expect(second.localGrade.isCorrect('q1'), isTrue);

      final back = second.previous();
      expect(back.index, 0);
      expect(back.answerFor('q1'), 'b');
      expect(back.answerFor('q2'), 'a');
    });

    test('no pasa de la última pregunta', () {
      final last = ListeningSession(
        exercise: _exercise(),
      ).select('b').next().select('b');
      expect(last.next().index, 1);
    });

    test('startSubmitting exige el intento completo', () {
      final incomplete = ListeningSession(
        exercise: _exercise(),
      ).startSubmitting();
      expect(incomplete.phase, ListeningSessionPhase.answering);

      final complete = ListeningSession(
        exercise: _exercise(),
      ).select('b').next().select('b').startSubmitting();
      expect(complete.phase, ListeningSessionPhase.submitting);
    });

    test('resolve con ok deja el resultado del servidor', () {
      final submitting = ListeningSession(
        exercise: _exercise(),
      ).select('b').next().select('b').startSubmitting();

      const result = ListeningAttemptResult(
        ok: true,
        score: 2,
        total: 2,
        passed: true,
        missionsAdvanced: 2,
        minutesAdded: 1,
      );
      final graded = submitting.resolve(result);

      expect(graded.phase, ListeningSessionPhase.graded);
      expect(graded.result?.score, 2);
      expect(graded.error, isNull);
    });

    test('resolve con rechazo del servidor deja motivo accionable', () {
      const rejected = ListeningAttemptResult(
        ok: false,
        reason: 'exercise_not_found',
      );
      final failed = ListeningSession(exercise: _exercise()).resolve(rejected);

      expect(failed.phase, ListeningSessionPhase.failed);
      expect(failed.error, contains('ya no está disponible'));
    });

    test('fail conserva las respuestas para reintentar el envío', () {
      final submitting = ListeningSession(
        exercise: _exercise(),
      ).select('b').next().select('a').startSubmitting();

      final failed = submitting.fail('sin red');
      expect(failed.phase, ListeningSessionPhase.failed);
      expect(failed.error, 'sin red');

      final ready = failed.retry();
      expect(ready.phase, ListeningSessionPhase.answering);
      expect(ready.answers, {'q1': 'b', 'q2': 'a'});
      expect(ready.isComplete, isTrue);
    });

    test('retry sin keepAnswers limpia respuestas e índice', () {
      final graded = ListeningSession(exercise: _exercise())
          .select('b')
          .next()
          .select('b')
          .startSubmitting()
          .resolve(const ListeningAttemptResult(ok: true, score: 2, total: 2));

      final retried = graded.retry(keepAnswers: false);
      expect(retried.index, 0);
      expect(retried.answers, isEmpty);
      expect(retried.phase, ListeningSessionPhase.answering);
      expect(retried.result, isNull);
    });

    test('seleccionar en fase enviando no cambia la respuesta', () {
      final submitting = ListeningSession(
        exercise: _exercise(),
      ).select('b').next().select('b').startSubmitting();

      final ignored = submitting.select('a');
      expect(ignored.answerFor('q2'), 'b');
    });
  });
}
