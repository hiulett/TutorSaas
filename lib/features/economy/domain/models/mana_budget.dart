/// Presupuesto de maná para la UI (P-26 / #111).
///
/// Traduce el JSON de `get_mana_state` a algo que la interfaz pueda mostrar
/// sin repetir reglas: cuántos turnos quedan al coste actual, si está bajo y
/// cuándo se recarga.
///
/// Reglas del servidor que refleja:
/// - Plan gratuito: la barra es el tope **diario** (`daily_limit`), que el
///   servidor reinicia con `current_date` (medianoche UTC).
/// - Plan de pago: la barra es el saldo del ciclo y recarga en `expires_at`.
class ManaBudget {
  const ManaBudget({
    required this.available,
    required this.capacity,
    required this.isFree,
    required this.costPerTurn,
    this.expiresAt,
    this.lowTurnThreshold = 3,
  });

  factory ManaBudget.fromState(
    Map<String, dynamic> mana, {
    int costPerTurn = defaultCostPerTurn,
    int lowTurnThreshold = 3,
  }) {
    final isFree = mana['is_free'] as bool? ?? true;
    final dailyRemaining = _int(mana['daily_remaining']);
    final remaining = _int(mana['remaining']);
    final dailyLimit = _int(mana['daily_limit'], fallback: 200);
    final allowance = _int(mana['allowance']);
    final purchased = _int(mana['purchased']);
    final expires = mana['expires_at'];

    return ManaBudget(
      available: isFree ? dailyRemaining : remaining,
      capacity: isFree ? dailyLimit : (allowance + purchased),
      isFree: isFree,
      costPerTurn: costPerTurn > 0 ? costPerTurn : defaultCostPerTurn,
      expiresAt: expires is String ? DateTime.tryParse(expires) : null,
      lowTurnThreshold: lowTurnThreshold,
    );
  }

  static const int defaultCostPerTurn = 12;

  /// Maná disponible (del día en free, del ciclo en pago).
  final int available;

  /// Capacidad que representa la barra.
  final int capacity;

  final bool isFree;
  final int costPerTurn;
  final DateTime? expiresAt;

  /// A partir de cuántos turnos se avisa.
  final int lowTurnThreshold;

  /// Turnos que aún se pueden pagar. 0 si no alcanza ni para uno.
  int get turnsLeft => available <= 0 ? 0 : available ~/ costPerTurn;

  /// No alcanza para el próximo turno.
  bool get isEmpty => available < costPerTurn;

  /// Aviso: quedan pocos turnos pero aún se puede jugar.
  bool get isLow => !isEmpty && turnsLeft <= lowTurnThreshold;

  double get ratio =>
      capacity <= 0 ? 0 : (available / capacity).clamp(0, 1).toDouble();

  /// Próxima recarga. Gratuito: medianoche UTC (así reinicia el servidor).
  DateTime? refillAt(DateTime now) {
    if (isFree) {
      final utc = now.toUtc();
      return DateTime.utc(
        utc.year,
        utc.month,
        utc.day,
      ).add(const Duration(days: 1));
    }
    return expiresAt;
  }

  /// Tiempo hasta la recarga. `null` si el plan no tiene fecha conocida.
  Duration? refillIn(DateTime now) {
    final at = refillAt(now);
    if (at == null) return null;
    final diff = at.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? fallback;
  }
}
