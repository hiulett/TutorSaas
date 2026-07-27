import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SupabaseClient _supabaseClient;

  SubscriptionRepositoryImpl(this._supabaseClient);

  @override
  Future<bool> isUserPremium(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_subscriptions')
          .select('plan_id, status')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final planId = response['plan_id'] as String?;
        return planId != null && planId != 'free';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final response = await _supabaseClient
          .from('subscription_plans')
          .select('id, name, price, billing_cycle, monthly_audio_minutes_limit, order_index, description, badge_tag, features')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      if (response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response).map((p) {
          final String id = p['id'] as String? ?? 'free';
          final String billingCycle = p['billing_cycle'] as String? ?? 'monthly';
          String billingText = 'Facturado cada mes';
          if (billingCycle == 'annual') {
            billingText = 'Facturado cada año';
          } else if (billingCycle == 'lifetime') {
            billingText = 'Pago único para siempre';
          }

          return {
            'id': id,
            'title': p['name'] as String? ?? 'Plan $id',
            'price': p['price'] as String? ?? '\$9.99',
            'billing': billingText,
            'tag': p['badge_tag'] as String?,
            'minutesLimit': p['monthly_audio_minutes_limit'] as int? ?? 300,
            'features': List<String>.from(p['features'] ?? []),
          };
        }).toList();
      }
    } catch (_) {}

    // Fallback if DB table is initializing
    return [
      {
        'id': 'monthly',
        'title': 'Plan Mensual',
        'price': '\$9.99',
        'billing': 'Facturado cada mes',
        'tag': null,
        'minutesLimit': 300,
        'features': [
          '300 min/mes de conversación IA',
          'Tutor IA disponible 24/7',
          'Corrección gramatical avanzada',
        ],
      },
      {
        'id': 'annual',
        'title': 'Plan Anual',
        'price': '\$79.99',
        'billing': 'Facturado cada año (\$6.66/mes)',
        'tag': 'AHORRA 33%',
        'minutesLimit': 1200,
        'features': [
          '1,200 min/mes de audio IA (20 hrs)',
          'Voces HD ultra realistas',
          'Speech DNA y biometría fonética completa',
        ],
      },
      {
        'id': 'lifetime',
        'title': 'Acceso Vitalicio',
        'price': '\$149.99',
        'billing': 'Pago único para siempre',
        'tag': 'MEJOR VALOR',
        'minutesLimit': 3600,
        'features': [
          '3,600 min/mes de audio IA (60 hrs)',
          'Acceso ilimitado a lecciones futuras',
          'Prioridad máxima en servidores de voz',
        ],
      },
    ];
  }

  @override
  Future<bool> purchasePackage(String packageId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabaseClient.from('user_subscriptions').upsert({
          'user_id': userId,
          'plan_id': packageId,
          'status': 'active',
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}
