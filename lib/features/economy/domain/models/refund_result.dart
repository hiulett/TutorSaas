/// Resultado de una compensación de maná (reembolso de un turno fallido).
///
/// Contrato normalizado de `refund_failed_turn` y `refund_mana`:
/// `{success, refunded, already_refunded, reason}`.
///
/// El parser acepta también la forma antigua (`ok`) por si una build anterior
/// recibe la respuesta de un servidor sin migrar.
class RefundResult {
  const RefundResult({
    required this.success,
    required this.refunded,
    required this.alreadyRefunded,
    this.reason,
  });

  factory RefundResult.fromMap(Map<String, dynamic> map) {
    return RefundResult(
      success: map['success'] == true || map['ok'] == true,
      refunded: _int(map['refunded']),
      alreadyRefunded: map['already_refunded'] == true,
      reason: map['reason'] is String && (map['reason'] as String).isNotEmpty
          ? map['reason'] as String
          : null,
    );
  }

  /// Error de red o excepción al llamar al servicio.
  factory RefundResult.requestFailed() => const RefundResult(
    success: false,
    refunded: 0,
    alreadyRefunded: false,
    reason: 'request_failed',
  );

  final bool success;
  final int refunded;
  final bool alreadyRefunded;
  final String? reason;

  /// Nada que hacer, pero no es un error: el turno ya se había compensado.
  bool get isNoop => success && alreadyRefunded && refunded == 0;

  bool get failed => !success;

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? 0;
  }
}
