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

  /// Generate daily pergaminos (batch content)
  Future<void> generateDailyPergaminos(String userId);
}
