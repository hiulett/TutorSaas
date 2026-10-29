import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/listening/domain/models/listening_exercise.dart';
import 'package:tutorsaas/features/listening/presentation/providers/listening_providers.dart';
import 'package:tutorsaas/features/listening/presentation/widgets/listening_path_card.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// P-30 (#115) — tarjeta de comprensión auditiva en la Ruta.
ListeningExercise _exercise({String id = 'ex-1', String slug = 'a1_coffee'}) {
  return ListeningExercise.fromMap({
    'id': id,
    'slug': slug,
    'level': 'A1',
    'title': 'Coffee to go',
    'lines': [
      {'speaker': 'Barista', 'text': 'Good morning!'},
    ],
    'questions': [
      {
        'id': 'q1',
        'prompt': 'What?',
        'options': [
          {'id': 'a', 'text': 'A'},
          {'id': 'b', 'text': 'B'},
        ],
        'correct': 'a',
      },
    ],
  });
}

Widget _wrap(List<ListeningExercise> exercises, ListeningProgress progress) {
  return ProviderScope(
    overrides: [
      listeningExercisesProvider('A1').overrideWith((ref) async => exercises),
      listeningProgressProvider.overrideWith((ref) async => progress),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: Scaffold(body: ListeningPathCard(level: 'A1')),
    ),
  );
}

void main() {
  testWidgets('muestra el siguiente ejercicio y el progreso', (tester) async {
    final exercises = [
      _exercise(id: 'ex-1', slug: 'a1_coffee'),
      _exercise(id: 'ex-2', slug: 'a1_train'),
    ];
    final progress = ListeningProgress.fromAttempts([
      {'exercise_id': 'ex-1', 'score': 3, 'total': 3, 'passed': true},
    ]);

    await tester.pumpWidget(_wrap(exercises, progress));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('COMPRENSIÓN AUDITIVA'), findsOneWidget);
    expect(find.text('Siguiente: Coffee to go'), findsOneWidget);
    expect(find.text('1/2 superados'), findsOneWidget);
  });

  testWidgets('sin ejercicios del nivel no ocupa espacio', (tester) async {
    await tester.pumpWidget(_wrap(const [], const ListeningProgress()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('COMPRENSIÓN AUDITIVA'), findsNothing);
    expect(find.textContaining('Siguiente:'), findsNothing);
  });

  testWidgets('con todos superados sigue ofreciendo repaso', (tester) async {
    final exercises = [_exercise()];
    final progress = ListeningProgress.fromAttempts([
      {'exercise_id': 'ex-1', 'score': 3, 'total': 3, 'passed': true},
    ]);

    await tester.pumpWidget(_wrap(exercises, progress));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('1/1 superados'), findsOneWidget);
    expect(find.text('Siguiente: Coffee to go'), findsOneWidget);
  });
}
