/// Cartera del cazador tal como la devuelve `get_economy_wallet` (P-32).
///
/// Es la fuente única que lee la tienda: oro, gemas, fragmentos, nivel de
/// cazador y cuánto se ha ganado/gastado. El nivel sale de `economy_level`
/// (XP / 1000 + 1), la misma curva que [HunterLevel].
class EconomyWallet {
  const EconomyWallet({
    this.gold = 0,
    this.gems = 0,
    this.fragments = 0,
    this.level = 1,
    this.xp = 0,
    this.xpPerLevel = 1000,
    this.xpIntoLevel = 0,
    this.streakFreezes = 0,
    this.unclaimedLevelRewards = 0,
    this.earned = const {},
    this.spent = const {},
  });

  factory EconomyWallet.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return const EconomyWallet();
    final xp = _int(map['xp']);
    final perLevel = _int(map['xp_per_level'], fallback: 1000);
    return EconomyWallet(
      gold: _int(map['gold']),
      gems: _int(map['gems']),
      fragments: _int(map['fragments']),
      level: _int(map['level'], fallback: 1).clamp(1, 999),
      xp: xp,
      xpPerLevel: perLevel <= 0 ? 1000 : perLevel,
      xpIntoLevel: map.containsKey('xp_into_level')
          ? _int(map['xp_into_level'])
          : (xp <= 0 ? 0 : xp % (perLevel <= 0 ? 1000 : perLevel)),
      streakFreezes: _int(map['streak_freezes']),
      unclaimedLevelRewards: _int(map['unclaimed_level_rewards']),
      earned: _intMap(map['earned']),
      spent: _intMap(map['spent']),
    );
  }

  final int gold;
  final int gems;
  final int fragments;
  final int level;
  final int xp;
  final int xpPerLevel;

  /// XP acumulados dentro del nivel actual.
  final int xpIntoLevel;

  final int streakFreezes;

  /// Recompensas de nivel ya desbloqueadas y sin reclamar.
  final int unclaimedLevelRewards;

  /// Total ganado por moneda (`gold`, `gems`, `fragments`).
  final Map<String, int> earned;

  /// Total gastado por moneda (valor positivo).
  final Map<String, int> spent;

  /// Progreso 0..1 hacia el siguiente nivel.
  double get levelProgress {
    if (xpPerLevel <= 0) return 0;
    final p = xpIntoLevel / xpPerLevel;
    if (p.isNaN || p.isInfinite) return 0;
    return p.clamp(0.0, 1.0);
  }

  /// XP que faltan para el siguiente nivel.
  int get xpToNextLevel =>
      xpPerLevel <= 0 ? 0 : (xpPerLevel - xpIntoLevel).clamp(0, xpPerLevel);

  bool hasUnclaimedRewards() => unclaimedLevelRewards > 0;

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? fallback;
  }

  static Map<String, int> _intMap(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries) '${entry.key}': _int(entry.value),
    };
  }
}
