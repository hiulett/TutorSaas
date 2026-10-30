import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/conversation_mic_button.dart';

/// P-34f (#198): gesto del botón del micrófono (tap-to-toggle y hold-to-talk).
void main() {
  const buttonKey = ValueKey('conversation-mic-button');

  /// Reloj controlado: el widget recibe `clock`, así el test decide cuánto duró
  /// la pulsación sin depender del tiempo real de la máquina.
  late DateTime now;

  setUp(() {
    now = DateTime.utc(2026, 10, 29, 12);
  });

  void advance(int milliseconds) {
    now = now.add(Duration(milliseconds: milliseconds));
  }

  Widget wrap({
    required bool holdToTalk,
    bool isRecording = false,
    bool isProcessing = false,
    VoidCallback? onTap,
    VoidCallback? onHoldStart,
    ValueChanged<Duration>? onHoldEnd,
    ValueChanged<Duration>? onHoldTooShort,
    VoidCallback? onHoldCancel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ConversationMicButton(
            holdToTalk: holdToTalk,
            isRecording: isRecording,
            isProcessing: isProcessing,
            isPlaying: false,
            clock: () => now,
            onTap: onTap ?? () {},
            onHoldStart: onHoldStart ?? () {},
            onHoldEnd: onHoldEnd ?? (_) {},
            onHoldTooShort: onHoldTooShort ?? (_) {},
            onHoldCancel: onHoldCancel ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('tap-to-toggle: un toque alterna (no usa el gesto mantenido)', (
    tester,
  ) async {
    var taps = 0;
    var holds = 0;
    await tester.pumpWidget(
      wrap(holdToTalk: false, onTap: () => taps++, onHoldStart: () => holds++),
    );

    await tester.tap(find.byKey(buttonKey));
    await tester.pump();

    expect(taps, 1);
    expect(holds, 0);
  });

  testWidgets('hold-to-talk: pulsar y soltar por encima del umbral envía', (
    tester,
  ) async {
    var holds = 0;
    var cancels = 0;
    Duration? sent;
    await tester.pumpWidget(
      wrap(
        holdToTalk: true,
        onHoldStart: () => holds++,
        onHoldEnd: (heldFor) => sent = heldFor,
        onHoldCancel: () => cancels++,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(buttonKey)),
    );
    await tester.pump();
    expect(holds, 1);

    advance(800);
    await gesture.up();
    await tester.pump();

    expect(sent, const Duration(milliseconds: 800));
    expect(cancels, 0);
  });

  testWidgets('hold-to-talk: soltar antes de 300 ms descarta el clip', (
    tester,
  ) async {
    Duration? tooShort;
    Duration? sent;
    await tester.pumpWidget(
      wrap(
        holdToTalk: true,
        onHoldEnd: (heldFor) => sent = heldFor,
        onHoldTooShort: (heldFor) => tooShort = heldFor,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(buttonKey)),
    );
    advance(120);
    await gesture.up();
    await tester.pump();

    expect(tooShort, const Duration(milliseconds: 120));
    expect(sent, isNull);
  });

  testWidgets('hold-to-talk: arrastrar fuera cancela y avisa en el botón', (
    tester,
  ) async {
    var cancels = 0;
    Duration? sent;
    await tester.pumpWidget(
      wrap(
        holdToTalk: true,
        onHoldEnd: (heldFor) => sent = heldFor,
        onHoldCancel: () => cancels++,
      ),
    );

    final center = tester.getCenter(find.byKey(buttonKey));
    final gesture = await tester.startGesture(center);
    advance(600);
    await gesture.moveTo(center + const Offset(0, -200));
    await tester.pump();

    // Feedback visual: el icono pasa a "cancelar".
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await gesture.up();
    await tester.pump();

    expect(cancels, 1);
    expect(sent, isNull);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
  });

  testWidgets('hold-to-talk: cancelación del puntero descarta sin enviar', (
    tester,
  ) async {
    var cancels = 0;
    Duration? sent;
    await tester.pumpWidget(
      wrap(
        holdToTalk: true,
        onHoldEnd: (heldFor) => sent = heldFor,
        onHoldCancel: () => cancels++,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(buttonKey)),
    );
    advance(700);
    await gesture.cancel();
    await tester.pump();

    expect(cancels, 1);
    expect(sent, isNull);
  });

  testWidgets('hold-to-talk: durante el turno del tutor no se graba', (
    tester,
  ) async {
    var holds = 0;
    await tester.pumpWidget(
      wrap(holdToTalk: true, isProcessing: true, onHoldStart: () => holds++),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(buttonKey)),
    );
    await tester.pump();
    advance(900);
    await gesture.up();
    await tester.pump();

    expect(holds, 0);
  });

  testWidgets('mientras graba muestra el icono de detener', (tester) async {
    await tester.pumpWidget(wrap(holdToTalk: true, isRecording: true));

    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsNothing);
  });
}
