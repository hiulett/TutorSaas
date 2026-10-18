abstract class SubscriptionRepository {
  Future<bool> isUserPremium(String userId);
  Future<List<Map<String, dynamic>>> getSubscriptionPlans();

  /// Issue #69: reconcilia `user_subscriptions` con el estado real de
  /// RevenueCat. La app la invoca al iniciar sesión y tras volver de una compra,
  /// para que un webhook perdido no deje al usuario sin su plan.
  Future<void> syncEntitlement();

  /// Crea la sesión de Checkout de Stripe para el plan (suscripción).
  /// `billingCycle`: 'monthly' | 'annual' (el ciclo se elige al comprar).
  /// Devuelve la URL de Checkout o null en error. El alta real la hace el
  /// webhook (stripe-webhook → renew_mana_cycle).
  Future<String?> purchasePackage(String packageId, String billingCycle);

  Future<void> restorePurchases();
}
