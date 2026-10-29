import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/corrections/domain/models/session_correction.dart';
import 'package:tutorsaas/features/corrections/presentation/widgets/correction_chip.dart';

/// P-29 — El chip es discreto: solo se despliega al tocarlo y respeta
/// `correction_level`.
void main() {
  const grammar = TurnCorrection(
    original: 'I go yesterday',
    corrected: 'I went yesterday',
    type: CorrectionType.grammar,
    explanation: 'Use the past simple for finished actions.',
  );
  const wordChoice = TurnCorrection(
    original: 'big house',
    corrected: 'large house',
    type: CorrectionType.wordChoice,
  );

  Future<void> pumpChip(
    WidgetTester tester, {
    required List<TurnCorrection> corrections,
    required String level,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CorrectionChip(corrections: corrections, level: level),
        ),
      ),
    );
  }

  testWidgets('empieza colapsado y se despliega al tocar', (tester) async {
    await pumpChip(tester, corrections: const [grammar], level: 'short');

    expect(find.textContaining('FIX'), findsOneWidget);
    expect(
      find.textContaining('I went yesterday', findRichText: true),
      findsNothing,
    );

    await tester.tap(find.textContaining('FIX'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('I went yesterday', findRichText: true),
      findsOneWidget,
    );
    // `short` no muestra la explicación.
    expect(
      find.textContaining('past simple for finished', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('teacher sí muestra la explicación al desplegar', (tester) async {
    await pumpChip(tester, corrections: const [grammar], level: 'teacher');

    await tester.tap(find.textContaining('FIX'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('past simple for finished', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('important_only oculta lo que no es gramática', (tester) async {
    await pumpChip(
      tester,
      corrections: const [wordChoice],
      level: 'important_only',
    );

    expect(find.textContaining('FIX'), findsNothing);
  });

  testWidgets('sin correcciones no pinta nada', (tester) async {
    await pumpChip(tester, corrections: const [], level: 'moderate');

    expect(find.textContaining('FIX'), findsNothing);
  });
}
