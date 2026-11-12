import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/conversation_corrections_row.dart';
import 'package:tutorsaas/features/corrections/domain/models/turn_correction.dart';

/// Opción B+C: las correcciones se pliegan bajo la burbuja del turno.
///
/// El widget nace colapsado (una línea con el contador y los tipos) y al
/// tocarlo muestra el detalle `original → corregido`. Sin delegados de
/// localización cae a los literales en inglés, que es lo que se comprueba.
void main() {
  const corrections = [
    TurnCorrection(
      original: 'an extra shot coffee',
      corrected: 'an extra espresso shot',
      type: CorrectionType.grammar,
      explanation: 'Use espresso shot when customizing drinks.',
      messageText: 'I want an extra shot coffee',
    ),
    TurnCorrection(
      original: 'with',
      corrected: 'with',
      type: CorrectionType.pronunciationHint,
      messageText: 'I want an extra shot coffee',
    ),
  ];

  testWidgets('colapsado muestra contador y tipos, sin el detalle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ConversationCorrectionsRow(corrections: corrections),
        ),
      ),
    );

    expect(find.text('CORRECTIONS · 2'), findsOneWidget);
    expect(find.text('GRAMMAR'), findsOneWidget);
    expect(find.text('PRONUNCIATION'), findsOneWidget);
    // Colapsado: la explicación no está en el árbol.
    expect(
      find.text('Use espresso shot when customizing drinks.'),
      findsNothing,
    );
  });

  testWidgets('al tocar se expande y muestra original -> corregido', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ConversationCorrectionsRow(corrections: corrections),
        ),
      ),
    );

    await tester.tap(find.text('CORRECTIONS · 2'));
    await tester.pumpAndSettle();

    expect(
      find.text('Use espresso shot when customizing drinks.'),
      findsOneWidget,
    );
    // El detalle usa un TextSpan con el original y la corrección.
    final rich = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && w.textSpan != null &&
            w.textSpan!.toPlainText().contains('an extra espresso shot'),
      ),
    );
    expect(rich.textSpan!.toPlainText(), contains('an extra shot coffee'));
  });
}
