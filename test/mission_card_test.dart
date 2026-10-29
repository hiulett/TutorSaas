import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/missions/domain/models/mission_models.dart';
import 'package:tutorsaas/features/missions/presentation/widgets/mission_card.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// Issue #109 · P-24: la tarjeta muestra progreso real, recompensa y estado.
void main() {
  MissionInstance mission({
    String type = 'daily',
    String objective = 'speak_minutes',
    int target = 5,
    int current = 2,
    String status = 'active',
    bool claimed = false,
  }) => MissionInstance(
    id: 'm1',
    userId: 'u1',
    missionType: type,
    title: 'La Hora del Almuerzo',
    description: 'Habla con el mesero',
    objectiveType: objective,
    targetValue: target,
    currentValue: current,
    xpReward: 50,
    gemReward: 5,
    status: status,
    isRewardClaimed: claimed,
    startedAt: DateTime(2026, 1, 1),
  );

  Widget wrap(Widget child) => ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );

  testWidgets('muestra progreso real y recompensa visible', (tester) async {
    await tester.pumpWidget(wrap(MissionCard(mission: mission())));
    await tester.pump();

    expect(find.text('2/5 min'), findsOneWidget);
    expect(find.text('+50'), findsOneWidget);
    expect(find.text('+5'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 0.4);
  });

  testWidgets('misión completada sin reclamar muestra el botón de reclamo', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(MissionCard(mission: mission(current: 5, status: 'completed'))),
    );
    await tester.pump();

    expect(find.text('Reclamar +50 XP'), findsOneWidget);
  });

  testWidgets('misión ya reclamada no ofrece botón', (tester) async {
    await tester.pumpWidget(
      wrap(
        MissionCard(
          mission: mission(current: 5, status: 'completed', claimed: true),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Reclamar +50 XP'), findsNothing);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('misión fuera de techo se marca como no disponible', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(MissionCard(mission: mission(type: 'weekly', target: 25))),
    );
    await tester.pump();

    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(
      find.text('Esta misión no se puede completar con el seguimiento actual.'),
      findsOneWidget,
    );
    expect(find.text('Reclamar +50 XP'), findsNothing);
  });
}
