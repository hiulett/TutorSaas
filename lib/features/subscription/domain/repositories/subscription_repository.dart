abstract class SubscriptionRepository {
  Future<bool> isUserPremium(String userId);

  /// Issue #69: reconcilia `user_subscriptions` con el estado real de
  /// RevenueCat. La app la invoca al iniciar sesión y tras volver de una compra,
  /// para que un webhook perdido no deje al usuario sin su plan.
  Future<void> syncEntitlement();
}
