import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/premium_status.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SupabaseClient _supabaseClient;

  SubscriptionRepositoryImpl(this._supabaseClient);

  @override
  Future<bool> isUserPremium(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_subscriptions')
          .select('plan_id, status, period_end')
          .eq('user_id', userId)
          .maybeSingle();

      // Issue #65: plan + estado + fecha, no solo el plan_id.
      return isPremiumSubscription(response);
    } catch (_) {
      return false;
    }
  }

  @override
  @override
  Future<void> syncEntitlement() async {
    try {
      await _supabaseClient.functions
          .invoke('sync-entitlement')
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      // Si la función no está configurada (falta el secreto de RevenueCat) o no
      // hay red, se sigue con el estado que ya tenga la base de datos.
      debugPrint('sync-entitlement failed: $e');
    }
  }
}
