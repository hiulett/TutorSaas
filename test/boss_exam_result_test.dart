import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/boss_exam/domain/models/boss_exam_outcome.dart';
import 'package:tutorsaas/features/boss_exam/domain/models/boss_exam_rubric.dart';
import 'package:tutorsaas/features/boss_exam/presentation/screens/boss_exam_result_screen.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// P-31 (#116): pantalla de resultado del jefe (asciende / se mantiene + motivo).
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: child,
  );

  BossExamRubric buildRubric({int grammar = 78}) => BossExamRubric.fromScores({
    'listening': 80,
    'fluency': 78,
    'grammar': grammar,
    'vocabulary': 80,
    'pronunciation': 78,
    'naturalness': 78,
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('ascenso: victoria, nivel anterior a nuevo y 6 dimensiones', (
    tester,
  ) async {
    final outcome = BossExamOutcome(
      level: 'B2',
      rank: 'B',
      previousLevel: 'B1',
      verdict: BossExamVerdict.promoted,
      rubric: buildRubric(),
      turns: 6,
    );

    await tester.pumpWidget(wrap(BossExamResultScreen(outcome: outcome)));
    await settle(tester);

    expect(find.text(l10n.boss_result_victory), findsOneWidget);
    expect(find.text(l10n.boss_result_level_up('B1', 'B2')), findsOneWidget);
    expect(find.text(l10n.boss_result_rubric), findsOneWidget);
    expect(find.text(l10n.boss_dim_grammar), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(6));
    // Sin motivo ni refuerzo cuando asciende.
    expect(find.text(l10n.boss_result_reason_title), findsNothing);
    expect(find.text(l10n.boss_result_reinforce), findsNothing);
  });

  testWidgets('mantiene: motivo de rubrica, refuerzo y reintento', (
    tester,
  ) async {
    final outcome = BossExamOutcome(
      level: 'B1',
      rank: 'C',
      previousLevel: 'B1',
      verdict: BossExamVerdict.maintained,
      reasonCode: 'rubric_below_threshold',
      recommendedFocus: 'Past tenses and longer answers',
      weaknesses: const ['grammar 40/45'],
      rubric: buildRubric(grammar: 40),
      nextAttemptAt: DateTime(2026, 10, 30, 18, 30),
      forced: true,
      turns: 8,
    );

    await tester.pumpWidget(wrap(BossExamResultScreen(outcome: outcome)));
    await settle(tester);

    expect(find.text(l10n.boss_result_defeat), findsOneWidget);
    expect(find.text(l10n.boss_result_level_kept('B1')), findsOneWidget);
    expect(find.text(l10n.boss_result_reason_title), findsOneWidget);
    expect(find.text(l10n.boss_result_reason_rubric), findsOneWidget);
    expect(find.text(l10n.boss_result_forced), findsOneWidget);

    // El resto vive más abajo en la lista: hay que desplazarse.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    expect(find.text(l10n.boss_result_retry_at('30/10 18:30')), findsOneWidget);
    expect(find.text(l10n.boss_result_reinforce), findsOneWidget);
    expect(find.text('grammar 40/45'), findsOneWidget);
  });

  testWidgets('placement inicial: nivel asignado sin motivo ni refuerzo', (
    tester,
  ) async {
    const outcome = BossExamOutcome(
      level: 'A2',
      rank: 'D',
      verdict: BossExamVerdict.initial,
    );

    await tester.pumpWidget(wrap(const BossExamResultScreen(outcome: outcome)));
    await settle(tester);

    expect(find.text(l10n.boss_result_initial), findsOneWidget);
    expect(find.text(l10n.boss_result_level_assigned('A2')), findsOneWidget);
    expect(find.text(l10n.boss_result_no_scores), findsOneWidget);
    expect(find.text(l10n.boss_result_reason_title), findsNothing);
  });

  testWidgets('sin resultado no inventa veredicto', (tester) async {
    await tester.pumpWidget(wrap(const BossExamResultScreen()));
    await settle(tester);

    expect(find.text(l10n.boss_result_missing), findsOneWidget);
    expect(find.text(l10n.boss_result_home), findsOneWidget);
  });
}
