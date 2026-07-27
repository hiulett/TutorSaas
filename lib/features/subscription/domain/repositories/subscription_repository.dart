abstract class SubscriptionRepository {
  Future<bool> isUserPremium(String userId);
  Future<List<Map<String, dynamic>>> getSubscriptionPlans();
  Future<bool> purchasePackage(String packageId);
  Future<void> restorePurchases();
}
