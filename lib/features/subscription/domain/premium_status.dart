/// Regla única para decidir si una suscripción da acceso premium.
///
/// Issue #65: antes `isUserPremium` solo comparaba `plan_id != 'plebeyo'`, así
/// que una suscripción vencida (o cancelada y ya expirada) conservaba el acceso
/// para siempre porque la fila mantiene el `plan_id` del plan contratado.
///
/// Considera premium cuando:
/// - hay un plan distinto de `plebeyo`,
/// - el estado es `active` o `in_grace` (periodo de gracia de Play),
/// - y `period_end` no ha pasado (si viene informado).
bool isPremiumSubscription(Map<String, dynamic>? subscription) {
  if (subscription == null) return false;

  final planId = subscription['plan_id'] as String?;
  if (planId == null || planId == 'plebeyo') return false;

  final status = (subscription['status'] as String?)?.toLowerCase();
  if (status != null && status != 'active' && status != 'in_grace') {
    return false;
  }

  final rawEnd = subscription['period_end'];
  if (rawEnd == null) return true; // sin fecha: se confía en el estado
  final end = rawEnd is DateTime ? rawEnd : DateTime.tryParse(rawEnd.toString());
  if (end == null) return true;

  return end.isAfter(DateTime.now().toUtc());
}
