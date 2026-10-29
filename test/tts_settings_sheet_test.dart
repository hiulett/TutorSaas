import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/tts_settings_sheet.dart';

/// P-34c (#119): velocidad (0.75x/1x/1.25x) y voz del tutor.
void main() {
  Widget wrap({
    double speed = 1.0,
    String? voiceId,
    List<Map<String, String>> voices = const [],
    ValueChanged<double>? onSpeed,
    ValueChanged<String?>? onVoice,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TtsSettingsSheet(
          speed: speed,
          voiceId: voiceId,
          voices: voices,
          title: 'Voz del tutor',
          speedLabel: 'Velocidad',
          voiceLabel: 'Voz',
          defaultVoiceLabel: 'Voz del sistema',
          noVoicesMessage: 'No hay voces en inglés instaladas.',
          onSpeedChanged: onSpeed ?? (_) {},
          onVoiceChanged: onVoice ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('ofrece las tres velocidades y emite la elegida', (tester) async {
    double? selected;
    await tester.pumpWidget(wrap(onSpeed: (value) => selected = value));

    expect(find.byKey(const Key('tts-speed-0.75×')), findsOneWidget);
    expect(find.byKey(const Key('tts-speed-1×')), findsOneWidget);
    expect(find.byKey(const Key('tts-speed-1.25×')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tts-speed-1.25×')));
    await tester.pump();
    expect(selected, 1.25);
  });

  testWidgets('lista las voces y permite volver a la del sistema', (
    tester,
  ) async {
    String? selected = 'en-us-x-iol';
    await tester.pumpWidget(
      wrap(
        voiceId: 'en-us-x-iol',
        voices: const [
          {'name': 'en-us-x-iol', 'locale': 'en-US'},
          {'name': 'en-gb-x-gba', 'locale': 'en-GB'},
        ],
        onVoice: (value) => selected = value,
      ),
    );

    expect(find.text('en-us-x-iol'), findsOneWidget);
    expect(find.text('en-gb-x-gba'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tts-voice-default')));
    await tester.pump();
    expect(selected, isNull);
  });

  testWidgets('sin voces muestra un mensaje accionable', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.byKey(const Key('tts-no-voices')), findsOneWidget);
    expect(find.text('No hay voces en inglés instaladas.'), findsOneWidget);
  });
}
