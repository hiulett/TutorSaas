import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/boss_exam/data/boss_exam_service.dart';
import 'package:tutorsaas/features/boss_exam/domain/models/boss_exam_status.dart';
import 'package:tutorsaas/features/boss_exam/presentation/widgets/boss_exam_card.dart';
import 'package:tutorsaas/features/boss_exam/presentation/widgets/boss_exam_health_bar.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// P-31 (#116): estados de la entrada visible del jefe en la Ruta/Estado.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Widget wrap(Widget child, {BossExamStatus? status}) {
    return ProviderScope(
      overrides: [bossExamStatusProvider.overrideWith((ref) async => status)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    );
  }

  BossExamStatus buildStatus({
    required BossExamState state,
    List<BossExamRequirement> requirements = const [],
    DateTime? cooldownUntil,
  }) => BossExamStatus(
    currentLevel: 'B1',
    currentRank: 'C',
    state: state,
    requirements: requirements,
    cooldownUntil: cooldownUntil,
  );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('listo: muestra el estado de reto disponible', (tester) async {
    await tester.pumpWidget(
      wrap(
        const BossExamCard(level: 'B1', completedLessons: 0, totalLessons: 20),
        status: buildStatus(
          state: BossExamState.ready,
          requirements: const [
            BossExamRequirement(id: 'level', met: true, current: 1, target: 1),
            BossExamRequirement(
              id: 'practice',
              met: true,
              current: 6,
              target: 6,
            ),
          ],
        ),
      ),
    );
    await settle(tester);

    expect(find.text(l10n.boss_exam_title), findsOneWidget);
    expect(find.text(l10n.boss_exam_state_ready), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
  });

  testWidgets('bloqueado: muestra requisitos pendientes y candado', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const BossExamCard(level: 'B1', completedLessons: 0, totalLessons: 20),
        status: buildStatus(
          state: BossExamState.locked,
          requirements: const [
            BossExamRequirement(id: 'level', met: true, current: 1, target: 1),
            BossExamRequirement(
              id: 'practice',
              met: false,
              current: 2,
              target: 6,
            ),
          ],
        ),
      ),
    );
    await settle(tester);

    expect(find.text(l10n.boss_exam_state_locked), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.text(l10n.boss_req_practice), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('cooldown: muestra el reloj y la hora del reintento', (
    tester,
  ) async {
    final until = DateTime(2026, 10, 30, 18, 30);
    await tester.pumpWidget(
      wrap(
        const BossExamCard(level: 'B1', completedLessons: 0, totalLessons: 20),
        status: buildStatus(
          state: BossExamState.cooldown,
          cooldownUntil: until,
        ),
      ),
    );
    await settle(tester);

    expect(
      find.text(l10n.boss_exam_state_cooldown('30/10 18:30')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.hourglass_bottom_rounded), findsOneWidget);
  });

  testWidgets('sin RPC (null) cae al calculo local del 80 por ciento', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const BossExamCard(level: 'B1', completedLessons: 10, totalLessons: 20),
      ),
    );
    await settle(tester);

    expect(find.text(l10n.boss_exam_state_locked_progress(50)), findsOneWidget);
  });

  testWidgets('la barra de vida del jefe baja con cada respuesta', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [BossExamHealthBar(turns: 0), BossExamHealthBar(turns: 4)],
        ),
      ),
    );

    final bars = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .toList();
    expect(bars, hasLength(2));
    expect(bars[0].value, 1.0);
    expect(bars[1].value, closeTo(0.5, 0.001));
    expect(find.text(l10n.boss_hud_turns(0, 8)), findsOneWidget);
  });
}
