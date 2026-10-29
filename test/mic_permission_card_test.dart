import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/mic_permission_card.dart';

/// P-34e (#119): permiso denegado con flujo "ir a ajustes".
void main() {
  testWidgets('muestra el mensaje y ambas acciones', (tester) async {
    var openSettings = 0;
    var retry = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MicPermissionCard(
            title: 'Micrófono bloqueado',
            body: 'Actívalo en los ajustes de Android y vuelve a intentarlo.',
            openSettingsLabel: 'Abrir ajustes',
            retryLabel: 'Reintentar',
            onOpenSettings: () => openSettings++,
            onRetry: () => retry++,
          ),
        ),
      ),
    );

    expect(find.text('Micrófono bloqueado'), findsOneWidget);
    expect(
      find.text('Actívalo en los ajustes de Android y vuelve a intentarlo.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('mic-open-settings')));
    await tester.pump();
    expect(openSettings, 1);

    await tester.tap(find.byKey(const Key('mic-retry')));
    await tester.pump();
    expect(retry, 1);
  });
}
