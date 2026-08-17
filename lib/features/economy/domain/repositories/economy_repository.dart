abstract class EconomyRepository {
  /// Get or create today's daily state for the user
  Future<Map<String, dynamic>> getDailyState(String userId);

  /// Increment invocation count for today
  Future<Map<String, dynamic>> useInvocation(String userId);

  /// Get or create streak record
  Future<Map<String, dynamic>> getStreak(String userId);

  /// Update streak when user is active
  Future<Map<String, dynamic>> updateStreak(String userId);

  /// Claim daily reward
  Future<bool> claimDailyReward(String userId);

  /// Check if user has enough invocations
  Future<bool> canInvoke(String userId);

  /// Get user's inventory
  Future<List<Map<String, dynamic>>> getInventory(String userId);

  /// Purchase an item from the cosmetic catalog
  Future<bool> purchaseItem(String userId, String itemCode);

  /// Compra un cosmético con ORO (Tienda de Oro). Usa cosmetic_catalog.price_gold
  /// e inserta en el inventario con el tipo correcto (category).
  Future<bool> purchaseCosmeticWithGold(String userId, String itemCode);

  /// Equip/desequip a cosmetic item
  Future<void> toggleEquip(String userId, String itemCode);

  /// Add gems to user balance
  Future<void> addGems(String userId, int amount);

  /// Spend gems
  Future<bool> spendGems(String userId, int amount);

  /// Get gem balance
  Future<int> getGems(String userId);

  /// Purchase a streak freeze (consumable) for 30 gems
  Future<bool> purchaseStreakFreeze(String userId);

  /// Get the number of available streak freezes
  Future<int> getStreakFreezes(String userId);

  /// Generate daily pergaminos (batch content)
  Future<void> generateDailyPergaminos(String userId);

  /// Get or create the user's battle pass for the current season
  Future<Map<String, dynamic>> getBattlePass(String userId);

  /// Get gold balance
  Future<int> getGold(String userId);

  /// Spend gold; returns false if insufficient balance
  Future<bool> spendGold(String userId, int amount);

  /// Get fragment balance
  Future<int> getFragments(String userId);

  /// Add fragments (loot drops)
  Future<void> addFragments(String userId, int amount);

  /// Maná del Oráculo otorgado por el plan contratado, en función de los
  /// minutos de audio IA mensuales (30 → +0, 300 → +20, 1200 → +40).
  Future<int> getPlanManaBonus(String userId);

  // ── FASE B: Maná monetizado + Aura sin tope ──────────────────────────────

  /// Debita el costo configurable (ai_action_costs) de una acción IA.
  /// Devuelve `{success, cost, remaining}` o `{success:false, reason}`.
  Future<Map<String, dynamic>> consumeMana(String userId, String actionCode);

  /// Saldo de maná: `{allowance, purchased, used, remaining, expires_at, plan, class}`.
  Future<Map<String, dynamic>> getManaState(String userId);

  /// Suma Aura XP por sesión (idempotente por session_id, factor_radar server-side).
  Future<Map<String, dynamic>> addAuraXp(
    String userId,
    String sessionId,
    Map<String, double> radar,
    int metas,
    int bonusNivel,
  );

  /// Recompensa de oro (moneda cosmética). NUNCA otorga maná.
  Future<void> addGold(String userId, int amount);

  /// Título de prestigio actual: `{tier_code, name}`.
  Future<Map<String, dynamic>> getPrestigeTitle(String userId);

  /// Crea una sesión de Checkout de Stripe para maná (type: 'potion'|'gem_pack').
  /// Devuelve la URL de Checkout o null en error.
  Future<String?> createManaCheckout(String userId, String productId, String type);
}
