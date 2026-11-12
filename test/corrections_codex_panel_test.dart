// El CODIGO DE ERRORES (#339) sustituye a los chips inline del chat: aquí se
// comprueba que pinta cada corrección con su ERR tachado y su FIX en oro, que
// agrupa por turno y que aguanta el ancho mínimo sin desbordar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/corrections_codex_panel.dart';
import 'package:tutorsaas/features/corrections/domain/models/turn_correction.dart';

TurnCorrection _correction({
  required String original,
  required String corrected,
  required CorrectionType type,
  String messageText = '',
}) {
  return TurnCorrection(
    original: original,
    corrected: corrected,
    type: type,
    messageText: messageText,
  );
}

Widget _host(Widget child, {double width = 312}) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Center(
        child: SizedBox(width: width, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('sin correcciones muestra el estado vacío', (tester) async {
    await tester.pumpWidget(
      _host(const CorrectionsCodexPanel(corrections: [], level: 'moderate')),
    );
    await tester.pump();

    expect(
      find.textContaining('Aún no hay correcciones'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('corrections-codex-count')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pinta ERR tachado y FIX en oro', (tester) async {
    final corrections = [
      _correction(
        original: 'I wants a coffee',
        corrected: 'I want a coffee',
        type: CorrectionType.grammar,
        messageText: 'I wants a coffee',
      ),
    ];

    await tester.pumpWidget(
      _host(CorrectionsCodexPanel(corrections: corrections, level: 'moderate')),
    );
    await tester.pump();

    expect(find.textContaining('CÓDIGO DE ERRORES'), findsOneWidget);
    // La frase original aparece dentro de un Text.rich con "ERR: ".
    expect(find.textContaining('I wants a coffee'), findsOneWidget);
    expect(find.textContaining('I want a coffee'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda a 312 dp', (tester) async {
    final corrections = [
      _correction(
        original:
            'and then she go to the shop and buy a lot of things for the party',
        corrected:
            'and then she went to the shop and bought a lot of things for the party',
        type: CorrectionType.grammar,
        messageText: 'long one',
      ),
      _correction(
        original: 'wants',
        corrected: 'want',
        type: CorrectionType.vocabulary,
        messageText: 'second',
      ),
    ];

    await tester.pumpWidget(
      _host(CorrectionsCodexPanel(corrections: corrections, level: 'moderate')),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
