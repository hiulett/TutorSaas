/// Desglose del saldo por origen (#374).
///
/// El saldo que ve el usuario es **uno**; este desglose es informativo y sale de
/// `currency_ledger`: lo ganado jugando y lo que llegó de la canasta del plan.
class WalletOrigin {
  const WalletOrigin({
    this.earned = 0,
    this.fromPlan = 0,
    this.spent = 0,
  });

  /// Ganado jugando (sesiones, misiones, niveles…).
  final int earned;

  /// Acreditado por la canasta mensual del plan (`reason = plan_allowance`).
  final int fromPlan;

  /// Gastado (valor absoluto de los deltas negativos).
  final int spent;

  int get totalEarned => earned + fromPlan;

  /// Agrega las filas de `currency_ledger` de una sola moneda.
  static WalletOrigin fromRows(
    List<Map<String, dynamic>> rows,
    String currency,
  ) {
    var earned = 0;
    var fromPlan = 0;
    var spent = 0;
    for (final row in rows) {
      if (row['currency'] != currency) continue;
      final delta = (row['delta'] as num?)?.toInt() ?? 0;
      if (delta < 0) {
        spent += -delta;
        continue;
      }
      if (row['reason'] == 'plan_allowance') {
        fromPlan += delta;
      } else {
        earned += delta;
      }
    }
    return WalletOrigin(earned: earned, fromPlan: fromPlan, spent: spent);
  }
}
