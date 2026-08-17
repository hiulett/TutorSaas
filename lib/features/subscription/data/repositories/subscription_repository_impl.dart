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
        return planId != null && planId != 'plebeyo';
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
          .select('id, name, price, price_annual, billing_cycle, monthly_audio_minutes_limit, order_index, description, badge_tag, features, class_name, mana_allowance, stripe_price_id, stripe_price_annual_id')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      if (response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response).map((p) {
          final String id = p['id'] as String? ?? 'plebeyo';
          final int mana = (p['mana_allowance'] as num?)?.toInt() ?? 1800;

          return {
            'id': id,
            'title': p['name'] as String? ?? 'Plan $id',
            'price': p['price'] as String? ?? '\$9.99',
            'priceAnnual': p['price_annual'] as String?,
            'billing': 'Mensual o Anual',
            'tag': p['badge_tag'] as String?,
            'class': p['class_name'] as String? ?? 'plebeyo',
            'mana': mana,
            'minutesLimit': p['monthly_audio_minutes_limit'] as int? ?? 300,
            'stripePriceId': p['stripe_price_id'] as String?,
            'stripePriceAnnualId': p['stripe_price_annual_id'] as String?,
            'features': List<String>.from(p['features'] ?? []),
          };
        }).toList();
      }
    } catch (_) {}

    // Fallback si la tabla no está disponible: estamentos del diseño D2.
    return [
      {
        'id': 'noble',
        'title': 'NOBLE',
        'price': '\$4.99',
        'priceAnnual': '\$49.99',
        'billing': 'Mensual o Anual',
        'tag': 'PREMIUM 1',
        'class': 'noble',
        'mana': 18000,
        'minutesLimit': 300,
        'stripePriceId': null,
        'stripePriceAnnualId': null,
        'features': [
          '18,000 maná/mes (300 min de IA)',
          'Techo de prestigio: Gran Duque',
          'Corrección gramatical avanzada',
        ],
      },
      {
        'id': 'realeza',
        'title': 'REALEZA',
        'price': '\$14.99',
        'priceAnnual': '\$149.99',
        'billing': 'Mensual o Anual',
        'tag': 'PREMIUM 2',
        'class': 'realeza',
        'mana': 72000,
        'minutesLimit': 1200,
        'stripePriceId': null,
        'stripePriceAnnualId': null,
        'features': [
          '72,000 maná/mes (1,200 min de IA)',
          'Techo de prestigio: Emperador + Legendario',
          'Voces HD y prioridad en servidores de voz',
        ],
      },
    ];
  }

  @override
  Future<String?> purchasePackage(String packageId, String billingCycle) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final res = await _supabaseClient.functions.invoke(
        'stripe-checkout',
        body: {
          'type': 'subscription',
          'plan_id': packageId,
          'billing_cycle': billingCycle,
        },
      );
      final data = (res.data as Map?) ?? const {};
      return data['url'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}
