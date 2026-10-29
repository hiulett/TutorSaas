import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/economy/domain/models/economy_wallet.dart';
import 'package:tutorsaas/features/dashboard/domain/models/hunter_level.dart';
import 'package:tutorsaas/features/economy/domain/models/shop_offer.dart';

/// P-32 (#117): reglas puras de la tienda con propósito.
///
/// El servidor es la autoridad (valida saldo, nivel e idempotencia); aquí se
/// fija el contrato que la UI usa para decidir qué enseñar y qué bloquear.
void main() {
  const wallet = EconomyWallet(
    gold: 100,
    gems: 20,
    fragments: 130,
    level: 3,
    xp: 2500,
    xpIntoLevel: 500,
  );

  ShopOffer offer(Map<String, dynamic> overrides) =>
      ShopOffer.fromMap({'id': 'item', 'name': 'Objeto', ...overrides});

  group('ShopOffer: parseo del catálogo', () {
    test('lee precios, nivel y receta', () {
      final o = offer({
        'price_gold': 90,
        'price_gems': 550,
        'craft_cost_fragments': 250,
        'required_level': 4,
        'category': 'frame',
      });
      expect(o.priceGold, 90);
      expect(o.priceGems, 550);
      expect(o.craftFragments, 250);
      expect(o.requiredLevel, 4);
      expect(o.category, 'frame');
      expect(o.purchasableWithGold, isTrue);
      expect(o.purchasableWithGems, isTrue);
      expect(o.craftable, isTrue);
    });

    test('sin columnas nuevas asume nivel 1 y sin receta', () {
      final o = offer({'price_gold': 60});
      expect(o.requiredLevel, 1);
      expect(o.craftFragments, 0);
      expect(o.craftable, isFalse);
      expect(o.requiredLevel, 1);
    });

    test('acepta números como string (PostgREST)', () {
      final o = offer({'price_gold': '120', 'required_level': '2'});
      expect(o.priceGold, 120);
      expect(o.requiredLevel, 2);
    });

    test('precio más barato entre monedas', () {
      final o = offer({
        'price_gold': 450,
        'price_gems': 1100,
        'craft_cost_fragments': 250,
      });
      expect(o.cheapestPrice, 250);
    });
  });

  group('ShopOffer: desbloqueo por nivel', () {
    test('nivel exacto desbloquea', () {
      expect(offer({'required_level': 3}).isUnlockedAt(3), isTrue);
      expect(offer({'required_level': 3}).isUnlockedAt(2), isFalse);
    });

    test('niveles que faltan', () {
      final o = offer({'required_level': 6});
      expect(o.levelsMissingAt(3), 3);
      expect(o.levelsMissingAt(6), 0);
      expect(o.levelsMissingAt(9), 0);
    });

    test('el bloqueo por nivel gana al de saldo', () {
      final o = offer({'price_gold': 1200, 'required_level': 9});
      expect(
        o.blockReason(CurrencyKind.gold, wallet, owned: false),
        ShopBlockReason.level,
      );
    });

    test('owned gana a todo', () {
      final o = offer({'price_gold': 60, 'required_level': 1});
      expect(
        o.blockReason(CurrencyKind.gold, wallet, owned: true),
        ShopBlockReason.owned,
      );
    });

    test('saldo insuficiente', () {
      final o = offer({'price_gold': 120, 'required_level': 1});
      expect(
        o.blockReason(CurrencyKind.gold, wallet, owned: false),
        ShopBlockReason.balance,
      );
    });

    test('comprable cuando hay saldo y nivel', () {
      final o = offer({'price_gold': 60, 'required_level': 2});
      expect(o.blockReason(CurrencyKind.gold, wallet, owned: false), isNull);
    });

    test('moneda sin precio no es comprable', () {
      final o = offer({'price_gold': 60, 'price_gems': 0});
      expect(
        o.blockReason(CurrencyKind.gems, wallet, owned: false),
        ShopBlockReason.notAvailable,
      );
    });

    test('craftear no exige nivel: es la ruta alternativa', () {
      final o = offer({
        'price_gold': 250,
        'craft_cost_fragments': 120,
        'required_level': 9,
      });
      expect(
        o.blockReason(CurrencyKind.fragments, wallet, owned: false),
        isNull,
      );
      expect(
        o.blockReason(CurrencyKind.gold, wallet, owned: false),
        ShopBlockReason.level,
      );
    });
  });

  group('ShopOffer: orden y meta', () {
    final catalog = [
      offer({'id': 'a', 'price_gold': 900, 'required_level': 4}),
      offer({'id': 'b', 'price_gold': 60, 'required_level': 1}),
      offer({'id': 'c', 'price_gold': 250, 'required_level': 2}),
      offer({'id': 'd', 'price_gold': 120, 'required_level': 2}),
    ];

    test('ordena por nivel y luego por precio', () {
      final sorted = ShopOffer.sortForShop(catalog);
      expect(sorted.map((o) => o.id).toList(), ['b', 'd', 'c', 'a']);
    });

    test('la siguiente meta es el desbloqueo más cercano y barato', () {
      expect(ShopOffer.nextUnlock(catalog, 1)?.id, 'd');
      expect(ShopOffer.nextUnlock(catalog, 2)?.id, 'a');
      expect(ShopOffer.nextUnlock(catalog, 4), isNull);
    });
  });

  group('EconomyWallet', () {
    test('parsea la respuesta de get_economy_wallet', () {
      final w = EconomyWallet.fromMap({
        'gold': 148,
        'gems': 57,
        'fragments': 398,
        'level': 2,
        'xp': 1200,
        'xp_per_level': 1000,
        'xp_into_level': 200,
        'streak_freezes': 1,
        'unclaimed_level_rewards': 2,
        'earned': {'gold': 100},
        'spent': {'gold': 60, 'gems': 30},
      });
      expect(w.gold, 148);
      expect(w.gems, 57);
      expect(w.fragments, 398);
      expect(w.level, 2);
      expect(w.xpIntoLevel, 200);
      expect(w.streakFreezes, 1);
      expect(w.hasUnclaimedRewards(), isTrue);
      expect(w.earned['gold'], 100);
      expect(w.spent['gems'], 30);
      expect(w.levelProgress, closeTo(0.2, 0.0001));
      expect(w.xpToNextLevel, 800);
    });

    test('respuesta vacía o rota no rompe la tienda', () {
      expect(EconomyWallet.fromMap(null).level, 1);
      expect(EconomyWallet.fromMap(const {}).gold, 0);
      final w = EconomyWallet.fromMap({'level': 0, 'xp_per_level': 0});
      expect(w.level, 1);
      expect(w.xpPerLevel, 1000);
      expect(w.levelProgress, 0);
    });

    test('calcula xp_into_level si el servidor no lo manda', () {
      final w = EconomyWallet.fromMap({'xp': 1450, 'xp_per_level': 1000});
      expect(w.xpIntoLevel, 450);
      expect(w.xpToNextLevel, 550);
    });

    test('el progreso nunca sale de 0..1', () {
      final w = EconomyWallet.fromMap({'xp_into_level': 5000});
      expect(w.levelProgress, 1.0);
      final negative = EconomyWallet.fromMap({'xp_into_level': -50});
      expect(negative.levelProgress, 0.0);
    });

    test('misma curva de nivel que HunterLevel (1000 XP)', () {
      // economy_level() en SQL y HunterLevel en Dart deben coincidir.
      for (final xp in [0, 999, 1000, 1999, 2000, 9500]) {
        final expected = HunterLevel.levelFor(xp);
        final fromDb = EconomyWallet.fromMap({'xp': xp, 'level': expected});
        expect(fromDb.level, expected, reason: 'xp=$xp');
        expect(HunterLevel.xpPerLevel, 1000);
      }
    });
  });

  group('LevelReward', () {
    test('sólo lo desbloqueado y sin reclamar está pendiente', () {
      final rewards = [
        LevelReward.fromMap({'level': 3, 'gold': 150, 'unlocked': false}),
        LevelReward.fromMap({'level': 2, 'gold': 100, 'unlocked': true}),
        LevelReward.fromMap({
          'level': 1,
          'gold': 50,
          'unlocked': true,
          'claimed': true,
        }),
      ];
      final pending = LevelReward.claimableOf(rewards);
      expect(pending.length, 1);
      expect(pending.first.level, 2);
      expect(pending.first.gold, 100);
    });

    test('ordena por nivel y elige el idioma', () {
      final rewards = [
        LevelReward.fromMap({
          'level': 5,
          'unlocked': true,
          'label_es': 'Cinco',
          'label_en': 'Five',
          'label_pt': 'Cinco',
        }),
        LevelReward.fromMap({
          'level': 2,
          'unlocked': true,
          'label_es': 'Dos',
          'label_en': 'Two',
          'label_pt': 'Dois',
        }),
      ];
      final pending = LevelReward.claimableOf(rewards);
      expect(pending.map((r) => r.level), [2, 5]);
      expect(pending.first.labelFor('es'), 'Dos');
      expect(pending.first.labelFor('pt'), 'Dois');
      expect(pending.first.labelFor('en'), 'Two');
      expect(pending.first.labelFor('fr'), 'Two');
    });
  });
}
