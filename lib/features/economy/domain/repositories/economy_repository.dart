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

  /// Add XP progress to the battle pass and advance levels
  Future<Map<String, dynamic>?> addBattlePassXp(String userId, int amount);

  /// Mark a battle pass reward tier as claimed
  Future<bool> claimBattlePassReward(String userId, int tier);

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
}
