import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/subscription_plan.dart';
import '../../domain/repositories/subscription_plan_repository.dart';

class SubscriptionPlanRepositoryImpl implements SubscriptionPlanRepository {
  SubscriptionPlanRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const List<String> _columns = [
    'id',
    'name',
    'price',
    'price_annual',
    'billing_cycle',
    'description',
    'badge_tag',
    'features',
    'trial_days',
    'weekly_report_weeks',
    'mana_allowance',
    'order_index',
  ];

  @override
  Future<PlanCatalog> loadCatalog() async {
    try {
      final rows = await _client
          .from('subscription_plans')
          .select(_columns.join(', '))
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final plans = (rows as List)
          .whereType<Map>()
          .map(
            (row) => SubscriptionPlan.fromMap(Map<String, dynamic>.from(row)),
          )
          .where((plan) => plan.id.isNotEmpty)
          .toList();

      return PlanCatalog(
        plans: plans,
        exclusiveByPlan: await _loadExclusiveCounts(),
      );
    } catch (e) {
      // Sin catálogo el paywall sigue funcionando con el CTA nativo: mejor no
      // prometer nada que inventar planes.
      debugPrint('No se pudo leer subscription_plans: $e');
      return const PlanCatalog();
    }
  }

  /// Cosmético → plan mínimo que lo desbloquea (`min_plan`).
  Future<Map<String, int>> _loadExclusiveCounts() async {
    final counts = <String, int>{};
    try {
      final rows = await _client
          .from('cosmetic_catalog')
          .select('min_plan')
          .not('min_plan', 'is', null);
      for (final row in rows as List) {
        final minPlan = row is Map ? row['min_plan'] as String? : null;
        if (minPlan == null || minPlan.isEmpty) continue;
        counts[minPlan] = (counts[minPlan] ?? 0) + 1;
      }
    } catch (e) {
      debugPrint('No se pudo contar cosmetic_catalog.min_plan: $e');
    }
    return counts;
  }
}
