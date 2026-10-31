import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/conversation_mic_button.dart';
import 'package:tutorsaas/features/dashboard/presentation/widgets/dashboard_dock_item.dart';
import 'package:tutorsaas/features/dashboard/presentation/widgets/league_leaderboard_widget.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// #252 (UX-13) y #259 (UX-23, UX-22): lo que TalkBack obtiene del micrófono,
/// del dock del dashboard y de las cifras que solo se distinguen por su icono.
void main() {
  Widget app(Widget child, {Locale locale = const Locale('es')}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }

  group('UX-13 (#252): el micrófono expone la acción real', () {
    late DateTime now;
    late int taps;
    late int holds;
    late int cancels;

    setUp(() {
      now = DateTime.utc(2026, 10, 30, 12);
      taps = 0;
      holds = 0;
      cancels = 0;
    });

    Widget mic({required bool holdToTalk, bool isProcessing = false}) {
      return app(
        Center(
          child: ConversationMicButton(
            holdToTalk: holdToTalk,
            isRecording: false,
            isProcessing: isProcessing,
            isPlaying: false,
            clock: () => now,
            semanticsLabel: 'Micrófono',
            onTap: () => taps++,
            onHoldStart: () => holds++,
            onHoldEnd: (_) {},
            onHoldTooShort: (_) {},
            onHoldCancel: () => cancels++,
          ),
        ),
      );
    }

    testWidgets('tap-to-toggle: nodo con rol de botón, etiqueta y acción', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(mic(holdToTalk: false));

      final data = tester
          .getSemantics(find.bySemanticsLabel('Micrófono'))
          .getSemanticsData();

      expect(data.label, 'Micrófono');
      expect(data.hint, contains('detener la grabación'));
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      // En modo toggle no hay gesto mantenido que ofrecer.
      expect(data.hasAction(SemanticsAction.longPress), isFalse);

      handle.dispose();
    });

    testWidgets('mantener para hablar: expone tap y long press', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(mic(holdToTalk: true));

      final node = tester.getSemantics(find.bySemanticsLabel('Micrófono'));
      final data = node.getSemanticsData();

      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.hasAction(SemanticsAction.longPress), isTrue);
      expect(data.hint, contains('Mantén pulsado'));

      handle.dispose();
    });

    testWidgets('las acciones semánticas disparan el mismo callback que el '
        'gesto físico', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(mic(holdToTalk: true));

      tester.semantics.performAction(
        find.semantics.byLabel(RegExp('Micrófono')),
        SemanticsAction.longPress,
      );
      await tester.pump();
      expect(holds, 1);

      tester.semantics.performAction(
        find.semantics.byLabel(RegExp('Micrófono')),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(taps, 1);

      handle.dispose();
    });

    testWidgets('durante el turno del tutor no ofrece long press', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(mic(holdToTalk: true, isProcessing: true));

      final data = tester
          .getSemantics(find.bySemanticsLabel('Micrófono'))
          .getSemanticsData();

      expect(data.hasAction(SemanticsAction.longPress), isFalse);

      handle.dispose();
    });
  });

  group('UX-23 (#259): el dock anuncia pestaña y cuál está seleccionada', () {
    const labels = ['MAZMORRAS', 'GUILD', 'ESTADO', 'CONFIG'];
    const icons = [
      Icons.gps_fixed_rounded,
      Icons.shield_rounded,
      Icons.person_rounded,
      Icons.settings_rounded,
    ];

    late List<int> tapped;

    Widget dock({int active = 0}) {
      return app(
        Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              DashboardDockItem(
                icon: icons[i],
                label: labels[i],
                isActive: active == i,
                onTap: () => tapped.add(i),
              ),
          ],
        ),
      );
    }

    setUp(() {
      tapped = <int>[];
    });

    testWidgets('los 4 destinos son pestañas con estado seleccionado', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(dock(active: 1));

      for (var i = 0; i < labels.length; i++) {
        final data = tester
            .getSemantics(find.bySemanticsLabel(labels[i]))
            .getSemanticsData();

        expect(data.label, labels[i]);
        expect(data.role, SemanticsRole.tab, reason: 'rol de ${labels[i]}');
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        expect(
          data.flagsCollection.isSelected,
          i == 1 ? Tristate.isTrue : Tristate.isFalse,
          reason: 'selección de ${labels[i]}',
        );
      }

      handle.dispose();
    });

    testWidgets('tocar un destino avisa a quien lo escucha', (tester) async {
      await tester.pumpWidget(dock());
      await tester.tap(find.text('ESTADO'));
      await tester.pump();

      expect(tapped, [2]);
    });
  });

  group('UX-22 (#259): las cifras con icono dicen qué son', () {
    testWidgets('la estrella del leaderboard se anuncia como estrellas', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          const LeagueLeaderboardWidget(
            activeLeague: 'bronce',
            userRank: 1,
            userXp: 120,
            userLevelCode: 'A1',
            entries: [
              {
                'name': 'Cazador',
                'rank': 1,
                'stars': 3,
                'xp': 120,
                'isUser': false,
              },
            ],
          ),
        ),
      );

      final data = tester
          .getSemantics(find.bySemanticsLabel(RegExp('Estrellas')))
          .getSemanticsData();

      expect(data.label, contains('Estrellas'));

      handle.dispose();
    });
  });
}
