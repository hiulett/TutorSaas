import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/help_phrase.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/help_phrases_sheet.dart';

/// P-34b (#119): "Necesito ayuda" con frases tocables y estado vacío honesto.
void main() {
  Widget wrap({
    List<HelpPhrase> phrases = const [],
    bool loading = false,
    ValueChanged<HelpPhrase>? onUse,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HelpPhrasesSheet(
          title: 'Necesito ayuda',
          hint: 'Toca una frase para enviarla.',
          emptyMessage: 'Este escenario no tiene frases de ayuda.',
          phrases: phrases,
          loading: loading,
          onUsePhrase: onUse ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('pinta hasta tres frases y devuelve la tocada', (tester) async {
    HelpPhrase? used;
    const phrases = [
      HelpPhrase(id: 'p1', text: 'Hello!', translation: '¡Hola!'),
      HelpPhrase(id: 'p2', text: 'My name is...', translation: 'Me llamo...'),
      HelpPhrase(
        id: 'p3',
        text: 'Nice to meet you.',
        translation: 'Encantado.',
      ),
    ];

    await tester.pumpWidget(wrap(phrases: phrases, onUse: (p) => used = p));

    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text('My name is...'), findsOneWidget);
    expect(find.text('Nice to meet you.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('help-phrase-p2')));
    await tester.pump();
    expect(used?.id, 'p2');
  });

  testWidgets('sin datos muestra el estado vacío', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.byKey(const Key('help-phrases-empty')), findsOneWidget);
    expect(
      find.text('Este escenario no tiene frases de ayuda.'),
      findsOneWidget,
    );
  });

  testWidgets('mientras carga muestra el indicador', (tester) async {
    await tester.pumpWidget(wrap(loading: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('help-phrases-empty')), findsNothing);
  });
}
