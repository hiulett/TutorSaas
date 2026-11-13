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
  Future<void> syncEntitlement() async {
    try {
      await _supabaseClient.functions
          .invoke('sync-entitlement')
          .timeout(const Duration(seconds: 12));
      // #373: acredita la canasta mensual del plan. El servidor la entrega una
      // sola vez por mes natural (idempotente por ref_key) y no hace nada si el
      // plan no tiene canasta. Si falla, no debe tumbar el entitlement.
      try {
        await _supabaseClient
            .rpc('grant_plan_allowance')
            .timeout(const Duration(seconds: 8));
      } catch (allowanceError) {
        debugPrint('grant_plan_allowance failed: $allowanceError');
      }
    } on FunctionException catch (e) {
      // #310: 401/403 significa que RevenueCat rechaza la credencial del
      // servidor. No es una caída de red: no se reintenta ni se pinta como
      // error, y se registra una sola línea accionable.
      if (e.status == 401 || e.status == 403) {
        debugPrint(
          'sync-entitlement: RevenueCat no autorizado (${e.status}). '
          'Revisar el secreto REVENUECAT_API_KEY del proyecto.',
        );
        return;
      }
      debugPrint('sync-entitlement failed: $e');
    } catch (e) {
      // Si la función no está configurada o no hay red, se sigue con el estado
      // que ya tenga la base de datos.
      debugPrint('sync-entitlement failed: $e');
    }
  }
}
