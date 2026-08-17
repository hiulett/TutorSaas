abstract class SubscriptionRepository {
  Future<bool> isUserPremium(String userId);
  Future<List<Map<String, dynamic>>> getSubscriptionPlans();

  /// Crea la sesión de Checkout de Stripe para el plan (suscripción).
  /// `billingCycle`: 'monthly' | 'annual' (el ciclo se elige al comprar).
  /// Devuelve la URL de Checkout o null en error. El alta real la hace el
  /// webhook (stripe-webhook → renew_mana_cycle).
  Future<String?> purchasePackage(String packageId, String billingCycle);

  Future<void> restorePurchases();
}
