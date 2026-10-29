import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/listening/data/listening_repository.dart';
import 'package:tutorsaas/features/listening/data/listening_tts.dart';
import 'package:tutorsaas/features/listening/domain/models/listening_exercise.dart';
import 'package:tutorsaas/features/listening/presentation/providers/listening_providers.dart';
import 'package:tutorsaas/features/listening/presentation/screens/listening_quiz_screen.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// P-30 (#115) — pantalla del ejercicio de comprensión auditiva.
class _FakeRepository implements ListeningRepository {
  _FakeRepository({
    required this.exercise,
    required this.result,
    this.error,
    this.retryResult,
  });

  final ListeningExercise? exercise;
  final ListeningAttemptResult result;
  final Object? error;
  final ListeningAttemptResult? retryResult;

  Map<String, String>? submittedAnswers;
  int submitCalls = 0;

  @override
  Future<List<ListeningExercise>> loadExercises({required String level}) async {
    final current = exercise;
    return current == null ? const [] : [current];
  }

  @override
  Future<ListeningExercise?> loadBySlug(String slug) async => exercise;

  @override
  Future<ListeningProgress> loadProgress() async => const ListeningProgress();

  @override
  Future<ListeningAttemptResult> submit({
    required String exerciseId,
    required Map<String, String> answers,
    required int minutes,
    int tzOffsetMinutes = 0,
  }) async {
    submittedAnswers = answers;
    submitCalls++;
    if (submitCalls > 1 && retryResult != null) return retryResult!;
    final failure = error;
    if (failure != null) throw failure;
    return result;
  }
}

class _FakeAudio implements ListeningAudio {
  int plays = 0;
  int stops = 0;
  List<ListeningLine>? lastLines;

  @override
  Future<void> play(List<ListeningLine> lines) async {
    plays++;
    lastLines = lines;
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

ListeningExercise _exercise() {
  return ListeningExercise.fromMap({
    'id': 'ex-1',
    'slug': 'a1_coffee_to_go',
    'level': 'A1',
    'title': 'Coffee to go',
    'context': 'You are at a busy coffee shop.',
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

const _passed = ListeningAttemptResult(
  ok: true,
  score: 2,
  total: 2,
  passed: true,
  missionsAdvanced: 2,
  minutesAdded: 1,
  results: [
    ListeningQuestionResult(id: 'q1', isCorrect: true, correctOptionId: 'b'),
    ListeningQuestionResult(id: 'q2', isCorrect: true, correctOptionId: 'b'),
  ],
);

Widget _wrap({required _FakeRepository repository, required _FakeAudio audio}) {
  return ProviderScope(
    overrides: [
      listeningRepositoryProvider.overrideWithValue(repository),
      listeningAudioProvider.overrideWithValue(audio),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: ListeningQuizScreen(exerciseId: 'a1_coffee_to_go'),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  // El fondo animado y GlassCard repiten animaciones: pumpAndSettle no termina.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('muestra el diálogo, responde y presenta el resultado', (
    tester,
  ) async {
    final repository = _FakeRepository(exercise: _exercise(), result: _passed);
    final audio = _FakeAudio();
    await tester.pumpWidget(_wrap(repository: repository, audio: audio));
    await _settle(tester);

    expect(find.text('Coffee to go'), findsOneWidget);
    expect(find.text('PREGUNTA 1 DE 2'), findsOneWidget);

    await tester.tap(find.text('ESCUCHAR DIÁLOGO'));
    await _settle(tester);
    expect(audio.plays, 1);
    expect(audio.lastLines?.length, 2);

    await tester.tap(find.text('A flat white'));
    await _settle(tester);
    await tester.tap(find.text('SIGUIENTE'));
    await _settle(tester);

    expect(find.text('PREGUNTA 2 DE 2'), findsOneWidget);
    await tester.tap(find.text('Large'));
    await _settle(tester);

    await tester.ensureVisible(find.text('COMPROBAR RESPUESTAS'));
    await tester.tap(find.text('COMPROBAR RESPUESTAS'));
    await _settle(tester);
    await _settle(tester);

    expect(repository.submittedAnswers, {'q1': 'b', 'q2': 'b'});
    expect(find.text('EJERCICIO SUPERADO'), findsOneWidget);
    expect(find.text('2 de 2 correctas'), findsOneWidget);
    expect(find.text('+2 de progreso en misiones'), findsOneWidget);
    expect(find.text('REPETIR'), findsOneWidget);
  });

  testWidgets('un fallo de red ofrece reintentar el envío', (tester) async {
    final repository = _FakeRepository(
      exercise: _exercise(),
      result: _passed,
      error: const ListeningException('sin red'),
      retryResult: _passed,
    );
    await tester.pumpWidget(_wrap(repository: repository, audio: _FakeAudio()));
    await _settle(tester);

    await tester.tap(find.text('A flat white'));
    await _settle(tester);
    await tester.tap(find.text('SIGUIENTE'));
    await _settle(tester);
    await tester.tap(find.text('Large'));
    await _settle(tester);
    await tester.ensureVisible(find.text('COMPROBAR RESPUESTAS'));
    await tester.tap(find.text('COMPROBAR RESPUESTAS'));
    await _settle(tester);
    await _settle(tester);

    expect(find.text('sin red'), findsOneWidget);
    expect(find.text('REINTENTAR ENVÍO'), findsOneWidget);

    await tester.tap(find.text('REINTENTAR ENVÍO'));
    await _settle(tester);
    await _settle(tester);

    expect(repository.submitCalls, 2);
    expect(find.text('EJERCICIO SUPERADO'), findsOneWidget);
  });

  testWidgets('un rechazo del servidor no se pinta como superado', (
    tester,
  ) async {
    final repository = _FakeRepository(
      exercise: _exercise(),
      result: const ListeningAttemptResult(ok: false, reason: 'exercise_empty'),
    );
    await tester.pumpWidget(_wrap(repository: repository, audio: _FakeAudio()));
    await _settle(tester);

    await tester.tap(find.text('A flat white'));
    await _settle(tester);
    await tester.tap(find.text('SIGUIENTE'));
    await _settle(tester);
    await tester.tap(find.text('Large'));
    await _settle(tester);
    await tester.ensureVisible(find.text('COMPROBAR RESPUESTAS'));
    await tester.tap(find.text('COMPROBAR RESPUESTAS'));
    await _settle(tester);
    await _settle(tester);

    expect(find.text('EJERCICIO SUPERADO'), findsNothing);
    expect(find.textContaining('contenido'), findsOneWidget);
  });

  testWidgets('si el slug no existe muestra error con reintento', (
    tester,
  ) async {
    final repository = _FakeRepository(exercise: null, result: _passed);
    await tester.pumpWidget(_wrap(repository: repository, audio: _FakeAudio()));
    await _settle(tester);

    expect(
      find.text(
        'No pudimos cargar este ejercicio. Revisa tu conexión e inténtalo de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.text('REINTENTAR'), findsOneWidget);
  });
}
