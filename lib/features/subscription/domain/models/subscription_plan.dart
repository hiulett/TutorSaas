/// Plan de suscripción tal y como lo publica el servidor
/// (`subscription_plans`), P-44 (#129) y P-45 (#130).
///
/// La app **no** mantiene una lista de planes en el código: pinta lo que la
/// tabla devuelve con `is_active = true`. DIVINO se retiró en la migración
/// `20261030005704_plans_capabilities_p44_p45` (sigue en la tabla, inactivo),
/// así que aquí no hay ninguna referencia a él.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.price = '',
    this.priceAnnual,
    this.billingCycle = 'monthly',
    this.description = '',
    this.badgeTag,
    this.features = const [],
    this.trialDays = 0,
    this.weeklyReportWeeks = 1,
    this.manaAllowance = 0,
    this.orderIndex = 0,
  });

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      price: (map['price'] as String?) ?? '',
      priceAnnual: map['price_annual'] as String?,
      billingCycle: (map['billing_cycle'] as String?) ?? 'monthly',
      description: (map['description'] as String?) ?? '',
      badgeTag: map['badge_tag'] as String?,
      features: _featureList(map['features']),
      trialDays: _int(map['trial_days']),
      weeklyReportWeeks: _int(map['weekly_report_weeks'], fallback: 1),
      manaAllowance: _int(map['mana_allowance']),
      orderIndex: _int(map['order_index']),
    );
  }

  /// `plebeyo` | `noble` | `realeza` (los activos hoy).
  final String id;
  final String name;
  final String price;
  final String? priceAnnual;
  final String billingCycle;
  final String description;
  final String? badgeTag;
  final List<String> features;

  /// P-45 (#130): días de prueba que la app puede anunciar. `0` = sin trial.
  /// Este valor debe coincidir con la oferta configurada en Play Console.
  final int trialDays;

  /// P-44 (#129): semanas de historial que el servidor devuelve en el informe
  /// semanal (`get_weekly_report`).
  final int weeklyReportWeeks;

  final int manaAllowance;
  final int orderIndex;

  bool get hasTrial => trialDays > 0;
  bool get isMonthly => billingCycle == 'monthly';

  /// Precio de la prueba: "{days} días gratis, luego {price}".
  /// Solo se pinta si [hasTrial]; si Play no ofrece el trial, el valor de BD
  /// debe ser 0 y esta línea no aparece.
  String trialHeadline(String Function(int days, String price) formatter) =>
      formatter(trialDays, price);

  static List<String> _featureList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Object>()
        .map((e) => '$e'.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? fallback;
  }
}

/// Catálogo activo + cosméticos exclusivos por plan.
class PlanCatalog {
  const PlanCatalog({this.plans = const [], this.exclusiveByPlan = const {}});

  /// Solo planes con `is_active = true`, ordenados por `order_index`.
  final List<SubscriptionPlan> plans;

  /// Cuántos cosméticos exige cada plan (`cosmetic_catalog.min_plan`).
  final Map<String, int> exclusiveByPlan;

  bool get isEmpty => plans.isEmpty;

  int exclusivesFor(SubscriptionPlan plan) => exclusiveByPlan[plan.id] ?? 0;
}
