/// Resultado de `claim_mission_reward` (RPC `SECURITY DEFINER`).
///
/// El servidor valida estado, usuario y multiplicador; el cliente solo muestra
/// los importes devueltos. No se calculan recompensas en el cliente.
class MissionClaimResult {
  final bool ok;
  final bool alreadyClaimed;
  final int xp;
  final int gems;

  /// #372: las misiones pagan oro (la gema queda reservada al plan).
  final int gold;

  /// Motivo del servidor cuando `ok == false`: `not_found`, `not_completed`,
  /// `exception` (fallo de red o de RPC).
  final String? reason;

  const MissionClaimResult({
    required this.ok,
    this.alreadyClaimed = false,
    this.xp = 0,
    this.gems = 0,
    this.gold = 0,
    this.reason,
  });

  const MissionClaimResult.failure(String reason)
    : ok = false,
      alreadyClaimed = false,
      xp = 0,
      gems = 0,
      gold = 0,
      reason = reason;

  /// `true` cuando no hay nada que cobrar porque ya se cobró antes.
  bool get nothingToClaim => ok && alreadyClaimed;

  /// Hay recompensa nueva que mostrar en la animación.
  bool get hasReward => ok && !alreadyClaimed && (xp > 0 || gems > 0 || gold > 0);

  factory MissionClaimResult.fromRpc(Object? response) {
    if (response is! Map) {
      return const MissionClaimResult.failure('invalid_response');
    }
    // `success` es la clave canónica; `ok` se acepta como alias legacy.
    final ok = response['success'] == true || response['ok'] == true;
    if (!ok) {
      final reason = response['reason'];
      return MissionClaimResult.failure(
        reason is String && reason.isNotEmpty ? reason : 'unknown',
      );
    }
    return MissionClaimResult(
      ok: true,
      alreadyClaimed: response['already_claimed'] == true,
      xp: (response['xp'] as num?)?.toInt() ?? 0,
      gems: (response['gems'] as num?)?.toInt() ?? 0,
      gold: (response['gold'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'MissionClaimResult(ok: $ok, alreadyClaimed: $alreadyClaimed, '
      'xp: $xp, gems: $gems, gold: $gold, reason: $reason)';
}
