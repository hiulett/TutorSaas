import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/cache/cached_future_controller.dart';
import 'package:tutorsaas/core/widgets/hud_icon_button.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutorsaas/features/boss_exam/domain/models/boss_exam_outcome.dart';
import 'package:tutorsaas/features/boss_exam/presentation/screens/boss_exam_result_screen.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:tutorsaas/features/dashboard/domain/models/session_learned_summary.dart';
import 'package:tutorsaas/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:tutorsaas/features/dashboard/presentation/screens/profile_edit_screen.dart';
import 'package:tutorsaas/features/dashboard/presentation/screens/session_summary_screen.dart';
import 'package:tutorsaas/features/economy/domain/models/economy_wallet.dart';
import 'package:tutorsaas/features/economy/domain/models/shop_offer.dart';
import 'package:tutorsaas/features/economy/presentation/providers/economy_providers.dart';
import 'package:tutorsaas/features/economy/presentation/screens/dungeon_guardian_screen.dart';
import 'package:tutorsaas/features/economy/presentation/screens/shop_screen.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// UX-03 (#242): ningún control icon-only puede quedar por debajo de 48 dp de
/// área táctil efectiva. Estos tests miden el `RenderBox` real de cada control
/// (incluido su padding) y fallan si encoge.
///
/// Sitios cubiertos (evidencia del issue):
/// 1. `session_summary_screen.dart` — volver + marcadores de corrección.
/// 2. `dungeon_guardian_screen.dart` — volver del guardián.
/// 3. `profile_edit_screen.dart` — volver del registro de licencia.
/// 4. `boss_exam_result_screen.dart` — CTAs de refuerzo y volver al gremio.
/// 5. `shop_screen.dart` — botón de reclamar recompensas de nivel.
void main() {
  const minTapTarget = kHudMinTapTarget;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        publishableKey: 'placeholder',
      );
    } catch (_) {
      // Ya inicializado por otro test.
    }
  });

  /// Falla si el control mide menos de 48 dp en cualquier eje.
  void expectTapTarget(WidgetTester tester, Finder finder, String label) {
    expect(finder, findsOneWidget, reason: '$label no está en el árbol');
    final size = tester.getSize(finder);
    expect(
      size.width,
      greaterThanOrEqualTo(minTapTarget),
      reason: '$label mide ${size.width}dp de ancho (< $minTapTarget)',
    );
    expect(
      size.height,
      greaterThanOrEqualTo(minTapTarget),
      reason: '$label mide ${size.height}dp de alto (< $minTapTarget)',
    );
  }

  /// Mide la superficie pintada del botón.
  ///
  /// Los botones de Material añaden un `_InputPadding` que estira el área
  /// táctil hasta 48 dp aunque el fondo visible siga en 40, así que el
  /// `RenderBox` exterior no basta para detectar la regresión: se mide el
  /// `Material` interior, que es el alto real de la superficie táctil.
  void expectButtonSurface(WidgetTester tester, Finder button, String label) {
    final surface = find
        .descendant(of: button, matching: find.byType(Material))
        .first;
    expect(surface, findsOneWidget, reason: '$label no tiene superficie');
    final size = tester.getSize(surface);
    expect(
      size.height,
      greaterThanOrEqualTo(minTapTarget),
      reason: '$label pinta ${size.height}dp de alto (< $minTapTarget)',
    );
  }

  Widget app(Widget home) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: home,
  );

  group('HudIconButton', () {
    testWidgets('el área táctil no baja de 48 aunque el icono sea diminuto', (
      tester,
    ) async {
      for (final visual in <double>[24, 40, 44]) {
        await tester.pumpWidget(
          app(
            Scaffold(
              body: Center(
                child: HudIconButton(
                  icon: Icons.close_rounded,
                  visualSize: visual,
                  iconSize: 14,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );
        expectTapTarget(
          tester,
          find.byType(HudIconButton),
          'HudIconButton visualSize=$visual',
        );
      }
    });
  });

  testWidgets('resumen de sesión: volver y marcadores de corrección', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    const sessionId = '11111111-1111-4111-8111-111111111111';
    final since = DateTime.utc(2026, 1, 1, 12);
    final learnedKey = (conversationId: sessionId, since: since);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeConversationIdProvider.overrideWith((ref) => sessionId),
          sessionResultProvider.overrideWith((ref) {
            final notifier = SessionRewardNotifier(ref);
            notifier.confirm({
              'session_id': sessionId,
              'started_at': since.toIso8601String(),
            });
            return notifier;
          }),
          sessionLearnedSummaryProvider(learnedKey).overrideWith(
            (ref) async => const LearnedSummaryData(
              corrections: [
                SessionCorrection(
                  original: 'I go to the guild yesterday',
                  corrected: 'I went to the guild yesterday',
                  explanation: 'Pasado simple para acciones terminadas.',
                ),
              ],
            ),
          ),
        ],
        child: app(const SessionSummaryScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final buttons = find.byType(HudIconButton);
    expect(
      buttons,
      findsNWidgets(3),
      reason: 'volver + los dos marcadores de la tarjeta de corrección',
    );
    for (var i = 0; i < 3; i++) {
      expectTapTarget(tester, buttons.at(i), 'resumen de sesión · control $i');
    }
  });

  testWidgets('guardián de la mazmorra: botón de volver', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manaStateProvider.overrideWith(
            (ref) => CachedFutureController<Map<String, dynamic>>(
              userIdGetter: () => 'test',
              fetcher: () async => {'remaining': 0},
            ),
          ),
        ],
        child: app(const DungeonGuardianScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // El HUD tiene animaciones en bucle: no se usa `pumpAndSettle`.
    expectTapTarget(
      tester,
      find.byType(HudIconButton).first,
      'guardián · volver',
    );
  });

  testWidgets('editar perfil: botón de volver', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          userProgressProvider.overrideWith(
            (ref) async => <String, dynamic>{'level_code': 'B1'},
          ),
        ],
        child: app(const ProfileEditScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expectTapTarget(
      tester,
      find.byType(HudIconButton).first,
      'perfil · volver',
    );
  });

  testWidgets('resultado de jefe: CTAs de 48 dp de alto', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        const BossExamResultScreen(
          outcome: BossExamOutcome(
            level: 'B1',
            rank: 'B',
            previousLevel: 'B1',
            verdict: BossExamVerdict.maintained,
            reasonCode: 'no_improvement',
            explanation: 'Sin mejora suficiente.',
          ),
        ),
      ),
    );
    await tester.pump();

    expectTapTarget(tester, find.byType(OutlinedButton), 'jefe · reforzar');
    expectButtonSurface(tester, find.byType(OutlinedButton), 'jefe · reforzar');
    expectTapTarget(tester, find.byType(FilledButton), 'jefe · volver');
    expectButtonSurface(tester, find.byType(FilledButton), 'jefe · volver');
  });

  testWidgets('tienda: reclamar recompensas de nivel', (tester) async {
    tester.view.physicalSize = const Size(312 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopCatalogProvider.overrideWith(
            (ref) async => const <ShopOffer>[
              ShopOffer(
                id: 'emote_saludo_gremio',
                name: 'Saludo del Gremio',
                category: 'emote',
                priceGold: 60,
              ),
            ],
          ),
          economyWalletProvider.overrideWith(
            (ref) async => const EconomyWallet(
              gold: 100,
              gems: 57,
              fragments: 398,
              level: 1,
              xp: 255,
              xpIntoLevel: 255,
            ),
          ),
          levelRewardsProvider.overrideWith(
            (ref) async => [
              const LevelReward(level: 2, gold: 100, unlocked: true),
            ],
          ),
          inventoryProvider.overrideWith((ref) async => const []),
          manaStateProvider.overrideWith(
            (ref) => CachedFutureController<Map<String, dynamic>>(
              userIdGetter: () => 'test',
              fetcher: () async => {'remaining': 1800},
            ),
          ),
        ],
        child: app(const ShopScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final claim = find.ancestor(
      of: find.textContaining('RECLAMAR'),
      matching: find.byType(ElevatedButton),
    );
    expectTapTarget(tester, claim.first, 'tienda · reclamar nivel');
    expectButtonSurface(tester, claim.first, 'tienda · reclamar nivel');
  });
}
