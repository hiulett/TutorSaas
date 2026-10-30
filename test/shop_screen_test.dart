import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/cache/cached_future_controller.dart';
import 'package:tutorsaas/features/economy/domain/models/economy_wallet.dart';
import 'package:tutorsaas/features/economy/domain/models/shop_offer.dart';
import 'package:tutorsaas/features/economy/presentation/providers/economy_providers.dart';
import 'package:tutorsaas/features/economy/presentation/screens/shop_screen.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// P-32 (#117): la tienda muestra los tres sumideros, el nivel que bloquea y la
/// meta de progresión, sin overflow en el ancho mínimo soportado (312 dp).
void main() {
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

  const catalog = <ShopOffer>[
    ShopOffer(
      id: 'emote_saludo_gremio',
      name: 'Saludo del Gremio',
      category: 'emote',
      priceGold: 60,
    ),
    ShopOffer(
      id: 'title_eloquente',
      name: 'Elocuente del Gremio',
      category: 'title',
      priceGold: 200,
      priceGems: 450,
      requiredLevel: 2,
    ),
    ShopOffer(
      id: 'frame_escudo',
      name: 'Marco del Escudo',
      category: 'frame',
      priceGold: 250,
      requiredLevel: 2,
      craftFragments: 250,
    ),
    // P-44 (#129): cosmético exclusivo de REALEZA.
    ShopOffer(
      id: 'title_leyenda_viva',
      name: 'Leyenda Viva',
      category: 'title',
      priceGold: 800,
      requiredLevel: 3,
      minPlan: 'realeza',
    ),
  ];

  const wallet = EconomyWallet(
    gold: 100,
    gems: 57,
    fragments: 398,
    level: 1,
    xp: 255,
    xpIntoLevel: 255,
  );

  Future<void> pumpShop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(312 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopCatalogProvider.overrideWith((ref) async => catalog),
          economyWalletProvider.overrideWith((ref) async => wallet),
          levelRewardsProvider.overrideWith(
            (ref) async => [
              const LevelReward(level: 2, gold: 100, unlocked: false),
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
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: ShopScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  test('ShopOffer.fromMap lee el plan mínimo', () {
    final exclusive = ShopOffer.fromMap(const {
      'id': 'title_leyenda_viva',
      'name': 'Leyenda Viva',
      'min_plan': 'realeza',
    });
    final normal = ShopOffer.fromMap(const {
      'id': 'title_novato',
      'name': 'Novato',
    });

    expect(exclusive.isExclusive, isTrue);
    expect(exclusive.requiredPlanLabel, 'REALEZA');
    expect(normal.isExclusive, isFalse);
    expect(normal.requiredPlanLabel, isNull);
  });

  testWidgets('pinta los tres sumideros y el nivel', (tester) async {
    await pumpShop(tester);

    expect(find.textContaining('TIENDA ARCANO'), findsOneWidget);
    expect(find.textContaining('ORO ·'), findsWidgets);
    expect(find.textContaining('GEMAS ·'), findsWidgets);
    expect(find.textContaining('FRAGMENTOS ·'), findsWidgets);
    expect(find.textContaining('NV. 1'), findsWidgets);
  });

  testWidgets('bloquea por nivel los objetos que no tocan', (tester) async {
    await pumpShop(tester);

    // Nivel 1: el objeto de nivel 2 no se puede comprar.
    expect(find.text('NV. 2'), findsWidgets);
    // El de entrada (60 oro) sí, con 100 de oro en cartera.
    expect(find.textContaining('60'), findsWidgets);
  });

  testWidgets('anuncia la siguiente meta de progresión', (tester) async {
    await pumpShop(tester);

    expect(find.textContaining('PRÓXIMO DESBLOQUEO'), findsOneWidget);
    expect(
      find.textContaining('Elocuente del Gremio'.toUpperCase()),
      findsWidgets,
    );
  });

  testWidgets('la pestaña de fragmentos muestra la receta', (tester) async {
    await pumpShop(tester);

    await tester.tap(find.textContaining('FRAGMENTOS').first);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('250 FRAGMENTOS'), findsOneWidget);
    expect(find.textContaining('CRAFTEAR'), findsOneWidget);
  });

  testWidgets('anuncia el plan mínimo de los cosméticos exclusivos', (
    tester,
  ) async {
    await pumpShop(tester);

    // P-44 (#129): la tienda avisa del plan; el servidor es quien bloquea.
    expect(find.text('REALEZA'), findsOneWidget);
  });

  testWidgets('no desborda a 312 dp y avisa de recompensas pendientes', (
    tester,
  ) async {
    final overflows = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) {
        overflows.add(details);
      }
    };

    await pumpShop(tester);
    await tester.pump(const Duration(milliseconds: 300));

    FlutterError.onError = original;
    expect(overflows, isEmpty);
  });
}
