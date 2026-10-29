/// Resultado de `claim_session_drop` (drop de fin de sesión).
///
/// Contrato normalizado: `{success, ok (legacy), already_claimed, rarity, xp,
/// gold, reason}`. El parser acepta la forma antigua (solo `ok`) por
/// compatibilidad con builds anteriores.
class SessionDropResult {
  const SessionDropResult({
    required this.success,
    required this.alreadyClaimed,
    required this.xp,
    required this.gold,
    this.rarity,
    this.reason,
  });

  factory SessionDropResult.fromMap(Map<String, dynamic> map) {
    return SessionDropResult(
      success: map['success'] == true || map['ok'] == true,
      alreadyClaimed: map['already_claimed'] == true,
      xp: _int(map['xp']),
      gold: _int(map['gold']),
      rarity: map['rarity'] is String && (map['rarity'] as String).isNotEmpty
          ? map['rarity'] as String
          : null,
      reason: map['reason'] is String && (map['reason'] as String).isNotEmpty
          ? map['reason'] as String
          : null,
    );
  }

  final bool success;
  final bool alreadyClaimed;
  final int xp;
  final int gold;
  final String? rarity;
  final String? reason;

  /// Nada que celebrar: el drop de esa sesión ya se reclamó.
  bool get isNoop => success && alreadyClaimed;

  /// Hay drop nuevo que mostrar.
  bool get hasDrop => success && !alreadyClaimed && (xp > 0 || gold > 0);

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? 0;
  }
}
