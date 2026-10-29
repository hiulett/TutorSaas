import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/conversation_status_bar.dart';

/// P-34a/c/g (#119): la barra solo aparece con actividad y expone stop,
/// velocidad y ajustes de voz.
void main() {
  Widget wrap({
    required bool isRecording,
    required bool isProcessing,
    required bool isPlaying,
    double ttsSpeed = 1.0,
    VoidCallback? onStop,
    VoidCallback? onVoiceSettings,
    ValueChanged<double>? onSpeed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ConversationStatusBar(
          isRecording: isRecording,
          isProcessing: isProcessing,
          isPlaying: isPlaying,
          ttsSpeed: ttsSpeed,
          listeningLabel: 'Escuchando…',
          thinkingLabel: 'Pensando…',
          speakingLabel: 'El tutor está hablando',
          stopLabel: 'Detener',
          voiceSettingsTooltip: 'Voz del tutor',
          onStopTts: onStop ?? () {},
          onOpenVoiceSettings: onVoiceSettings ?? () {},
          onSpeedChanged: onSpeed ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('sin actividad no pinta nada', (tester) async {
    await tester.pumpWidget(
      wrap(isRecording: false, isProcessing: false, isPlaying: false),
    );

    expect(find.byKey(const Key('conversation-status-bar')), findsNothing);
  });

  testWidgets('grabando muestra Escuchando', (tester) async {
    await tester.pumpWidget(
      wrap(isRecording: true, isProcessing: false, isPlaying: false),
    );

    expect(find.text('Escuchando…'), findsOneWidget);
    expect(find.byKey(const Key('conversation-stop-tts')), findsNothing);
  });

  testWidgets('pensando muestra el tiempo transcurrido', (tester) async {
    await tester.pumpWidget(
      wrap(isRecording: false, isProcessing: true, isPlaying: false),
    );

    expect(find.text('Pensando…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Pensando… 2s'), findsOneWidget);

    await tester.pumpWidget(
      wrap(isRecording: false, isProcessing: false, isPlaying: false),
    );
    expect(find.byKey(const Key('conversation-status-bar')), findsNothing);
  });

  testWidgets('hablando permite detener y cambiar velocidad', (tester) async {
    var stops = 0;
    double? newSpeed;
    var openedSettings = 0;

    await tester.pumpWidget(
      wrap(
        isRecording: false,
        isProcessing: false,
        isPlaying: true,
        ttsSpeed: 1.0,
        onStop: () => stops++,
        onSpeed: (value) => newSpeed = value,
        onVoiceSettings: () => openedSettings++,
      ),
    );

    expect(find.text('El tutor está hablando'), findsOneWidget);

    await tester.tap(find.byKey(const Key('conversation-stop-tts')));
    await tester.pump();
    expect(stops, 1);

    await tester.tap(find.byKey(const Key('conversation-speed-1.25×')));
    await tester.pump();
    expect(newSpeed, 1.25);

    await tester.tap(find.byKey(const Key('conversation-voice-settings')));
    await tester.pump();
    expect(openedSettings, 1);
  });
}
