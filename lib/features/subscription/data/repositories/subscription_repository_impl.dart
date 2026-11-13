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
    } on FunctionException catch (e) {
      // #310: 401/403 significa que RevenueCat rechaza la credencial del
      // servidor. No es una caída de red: no se reintenta ni se pinta como
      // error, y se registra una sola línea accionable.
      if (e.status == 401 || e.status == 403) {
        debugPrint(
          'sync-entitlement: RevenueCat no autorizado (${e.status}). '
          'Revisar el secreto REVENUECAT_SECRET_KEY del proyecto.',
        );
        return;
      }
      debugPrint('sync-entitlement failed: $e');
    } catch (e) {
      // Si la función no está configurada o no hay red, se sigue con el estado
      // que ya tenga la base de datos.
      debugPrint('sync-entitlement failed: $e');
    } finally {
      // #373: la canasta del plan NO depende de que el sync funcione. Antes
      // estaba dentro del `try` y un 403 del sync la saltaba en silencio.
      try {
        await _supabaseClient
            .rpc('grant_plan_allowance')
            .timeout(const Duration(seconds: 8));
      } catch (allowanceError) {
        debugPrint('grant_plan_allowance failed: $allowanceError');
      }
    }
  }
}
