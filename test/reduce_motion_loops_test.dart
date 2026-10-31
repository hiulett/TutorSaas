import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/theme/app_motion.dart';
import 'package:tutorsaas/core/widgets/cyber_manhwa_background.dart';
import 'package:tutorsaas/core/widgets/draggable_monster_widget.dart';
import 'package:tutorsaas/core/widgets/glass_card.dart';
import 'package:tutorsaas/features/conversation/presentation/widgets/voice_waveform_visualizer.dart';
import 'package:tutorsaas/features/dashboard/data/models/hunter_catalog.dart';

/// Issue #243 (UX-04) — animaciones infinitas (`repeat()`) que ignoraban
/// `MediaQuery.disableAnimationsOf`.
///
/// Con `disableAnimations: true` ningún bucle debe dejar un `Ticker` vivo:
/// `transientCallbackCount == 0` tras `pump()`. Con reduce-motion desactivado
/// el mismo widget sí anima (no se rompe el aspecto normal).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Monta [child] bajo un `MediaQuery` con [reduceMotion] sin perder el
  /// tamaño de la vista (`MediaQueryData()` a pelo dejaría `size == 0`).
  Widget host(Widget child, {required bool reduceMotion}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: Scaffold(
          body: Center(child: SizedBox(width: 400, height: 700, child: child)),
        ),
      ),
    ),
  );

  Future<int> tickersWith(
    WidgetTester tester,
    Widget child, {
    required bool reduceMotion,
  }) async {
    await tester.pumpWidget(host(child, reduceMotion: reduceMotion));
    await tester.pump();
    return tester.binding.transientCallbackCount;
  }

  group('reduce-motion detiene los bucles infinitos', () {
    testWidgets('GlassCard (esquinas rúnicas)', (tester) async {
      Widget card() => const GlassCard(
        showRunicCorners: true,
        child: SizedBox(width: 120, height: 40),
      );

      expect(
        await tickersWith(tester, card(), reduceMotion: false),
        greaterThan(0),
        reason: 'sin reduce-motion el brillo rúnico debe seguir animando',
      );

      expect(
        await tickersWith(tester, card(), reduceMotion: true),
        0,
        reason: 'con reduce-motion no puede quedar ningún Ticker activo',
      );

      // Cambiar el ajuste en caliente también debe detener el bucle.
      await tester.pumpWidget(host(card(), reduceMotion: false));
      await tester.pump();
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester.pumpWidget(host(card(), reduceMotion: true));
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('CyberManhwaBackground (4 bucles ambientales)', (tester) async {
      const bg = CyberManhwaBackground(child: SizedBox.expand());

      final active = await tickersWith(tester, bg, reduceMotion: false);
      expect(active, greaterThan(0));

      expect(await tickersWith(tester, bg, reduceMotion: true), 0);
    });

    testWidgets('VoiceWaveformVisualizer', (tester) async {
      const wave = VoiceWaveformVisualizer(
        isAiSpeaking: true,
        isUserSpeaking: false,
      );

      expect(
        await tickersWith(tester, wave, reduceMotion: false),
        greaterThan(0),
      );

      expect(await tickersWith(tester, wave, reduceMotion: true), 0);
    });

    testWidgets('DraggableMonsterWidget (flotación, respiración, runa)', (
      tester,
    ) async {
      const monster = DungeonMonsterItem(
        id: 'm-ux243',
        name: 'Oráculo',
        level: 'A1',
        avatarUrl: '',
        description: 'Monstruo instructor de prueba',
      );

      Widget pill() => const Stack(
        children: [
          DraggableMonsterWidget(
            monster: monster,
            avatarAsset: 'assets/images/avatars/oracle_01.png',
          ),
        ],
      );

      expect(
        await tickersWith(tester, pill(), reduceMotion: false),
        greaterThan(0),
      );

      expect(await tickersWith(tester, pill(), reduceMotion: true), 0);
    });

    testWidgets('AppMotion.loopsAllowed refleja el ajuste del sistema', (
      tester,
    ) async {
      late bool allowed;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              allowed = AppMotion.loopsAllowed(context);
              return const SizedBox.shrink();
            },
          ),
          reduceMotion: false,
        ),
      );
      expect(allowed, isTrue);

      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              allowed = AppMotion.loopsAllowed(context);
              return const SizedBox.shrink();
            },
          ),
          reduceMotion: true,
        ),
      );
      expect(allowed, isFalse);
    });
  });
}
