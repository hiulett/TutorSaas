import 'economy_wallet.dart';

/// Moneda con la que se paga una oferta de la tienda.
enum CurrencyKind {
  gold,
  gems,
  fragments;

  String get code => name;

  /// Clave de saldo dentro de [EconomyWallet].
  int balanceIn(EconomyWallet wallet) => switch (this) {
    CurrencyKind.gold => wallet.gold,
    CurrencyKind.gems => wallet.gems,
    CurrencyKind.fragments => wallet.fragments,
  };
}

/// Oferta de la tienda (fila de `cosmetic_catalog`).
///
/// P-32: además del precio, cada cosmético declara `required_level` (nivel de
/// cazador que lo desbloquea) y `craft_cost_fragments` (receta alternativa).
/// La regla de compra vive en el servidor; aquí solo se decide qué pintar.
class ShopOffer {
  const ShopOffer({
    required this.id,
    required this.name,
    this.description = '',
    this.category = 'cosmetic',
    this.rarity = 'common',
    this.priceGold = 0,
    this.priceGems = 0,
    this.craftFragments = 0,
    this.requiredLevel = 1,
    this.imageUrl,
  });

  factory ShopOffer.fromMap(Map<String, dynamic> map) {
    return ShopOffer(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'cosmetic',
      rarity: (map['rarity'] as String?) ?? 'common',
      priceGold: _int(map['price_gold']),
      priceGems: _int(map['price_gems']),
      craftFragments: _int(map['craft_cost_fragments']),
      requiredLevel: _int(map['required_level'], fallback: 1).clamp(1, 999),
      imageUrl: map['image_url'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final String category;
  final String rarity;
  final int priceGold;
  final int priceGems;
  final int craftFragments;
  final int requiredLevel;
  final String? imageUrl;

  bool get purchasableWithGold => priceGold > 0;
  bool get purchasableWithGems => priceGems > 0;
  bool get craftable => craftFragments > 0;

  int priceFor(CurrencyKind currency) => switch (currency) {
    CurrencyKind.gold => priceGold,
    CurrencyKind.gems => priceGems,
    CurrencyKind.fragments => craftFragments,
  };

  /// Precio más bajo al que se puede conseguir (oro, gemas o fragmentos).
  int get cheapestPrice {
    final prices = [
      if (purchasableWithGold) priceGold,
      if (purchasableWithGems) priceGems,
      if (craftable) craftFragments,
    ];
    if (prices.isEmpty) return 0;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  bool isUnlockedAt(int hunterLevel) => hunterLevel >= requiredLevel;

  /// Niveles que faltan para desbloquearlo (0 si ya está desbloqueado).
  int levelsMissingAt(int hunterLevel) {
    final missing = requiredLevel - hunterLevel;
    return missing > 0 ? missing : 0;
  }

  bool canAffordWith(CurrencyKind currency, EconomyWallet wallet) {
    final price = priceFor(currency);
    return price > 0 && currency.balanceIn(wallet) >= price;
  }

  /// Motivo por el que el botón queda deshabilitado, o `null` si se puede.
  ///
  /// El nivel solo bloquea la **compra** (oro/gemas). El crafteo con fragmentos
  /// es la ruta alternativa: cuesta ~12 sesiones de juego y sirve justamente
  /// para conseguir lo que aún no has desbloqueado.
  ShopBlockReason? blockReason(
    CurrencyKind currency,
    EconomyWallet wallet, {
    required bool owned,
  }) {
    if (owned) return ShopBlockReason.owned;
    if (currency != CurrencyKind.fragments && !isUnlockedAt(wallet.level)) {
      return ShopBlockReason.level;
    }
    if (priceFor(currency) <= 0) return ShopBlockReason.notAvailable;
    if (!canAffordWith(currency, wallet)) return ShopBlockReason.balance;
    return null;
  }

  /// Catálogo ordenado para la tienda: primero lo desbloqueado y barato.
  static List<ShopOffer> sortForShop(List<ShopOffer> offers) {
    final sorted = [...offers];
    sorted.sort((a, b) {
      final byLevel = a.requiredLevel.compareTo(b.requiredLevel);
      if (byLevel != 0) return byLevel;
      return a.cheapestPrice.compareTo(b.cheapestPrice);
    });
    return sorted;
  }

  /// Siguiente meta de progresión: el cosmético más barato que aún no está
  /// desbloqueado. Devuelve `null` si el nivel actual ya lo desbloquea todo.
  static ShopOffer? nextUnlock(List<ShopOffer> offers, int hunterLevel) {
    ShopOffer? best;
    for (final offer in offers) {
      if (offer.isUnlockedAt(hunterLevel)) continue;
      if (best == null) {
        best = offer;
        continue;
      }
      if (offer.requiredLevel < best.requiredLevel) {
        best = offer;
      } else if (offer.requiredLevel == best.requiredLevel &&
          offer.cheapestPrice < best.cheapestPrice) {
        best = offer;
      }
    }
    return best;
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? fallback;
  }
}

/// Por qué una oferta no se puede comprar ahora mismo.
enum ShopBlockReason {
  /// Ya está en el inventario.
  owned,

  /// El nivel de cazador no llega a `required_level`.
  level,

  /// Falta saldo de la moneda elegida.
  balance,

  /// La oferta no admite esa moneda / no tiene precio.
  notAvailable,
}

/// Recompensa de nivel (`level_rewards`) con su estado de reclamo.
class LevelReward {
  const LevelReward({
    required this.level,
    this.gold = 0,
    this.itemCode,
    this.itemName,
    this.labelEs = '',
    this.labelEn = '',
    this.labelPt = '',
    this.unlocked = false,
    this.claimed = false,
  });

  factory LevelReward.fromMap(Map<String, dynamic> map) {
    return LevelReward(
      level: ShopOffer._int(map['level'], fallback: 1).clamp(1, 999),
      gold: ShopOffer._int(map['gold']),
      itemCode: map['item_code'] as String?,
      itemName: map['item_name'] as String?,
      labelEs: (map['label_es'] as String?) ?? '',
      labelEn: (map['label_en'] as String?) ?? '',
      labelPt: (map['label_pt'] as String?) ?? '',
      unlocked: map['unlocked'] == true,
      claimed: map['claimed'] == true,
    );
  }

  final int level;
  final int gold;
  final String? itemCode;
  final String? itemName;
  final String labelEs;
  final String labelEn;
  final String labelPt;
  final bool unlocked;
  final bool claimed;

  /// Pendiente de reclamar: nivel alcanzado y sin cobrar.
  bool get claimable => unlocked && !claimed;

  String labelFor(String localeCode) => switch (localeCode) {
    'es' => labelEs,
    'pt' => labelPt,
    _ => labelEn,
  };

  /// Sólo lo pendiente, ordenado por nivel: es lo que anuncia la app.
  static List<LevelReward> claimableOf(List<LevelReward> rewards) {
    final pending = rewards.where((r) => r.claimable).toList();
    pending.sort((a, b) => a.level.compareTo(b.level));
    return pending;
  }
}
