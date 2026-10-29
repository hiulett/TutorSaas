import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/models/mission_claim_result.dart';
import '../../domain/models/mission_models.dart';
import '../../domain/models/mission_visibility.dart';
import '../providers/mission_providers.dart';

/// Tarjeta de misión (issue #109).
///
/// - Muestra progreso real (`current_value/target_value`) y recompensa.
/// - El reclamo va por la RPC `claim_mission_reward`; el botón se bloquea
///   mientras la petición está en vuelo y la RPC es idempotente, así que un
///   doble toque no cobra dos veces.
/// - Las misiones no alcanzables se muestran atenuadas con la etiqueta
///   "no disponible" y sin botón.
class MissionCard extends ConsumerStatefulWidget {
  final MissionInstance mission;

  /// Variante destacada (misión principal del día).
  final bool featured;

  /// Variante compacta (secundarias del bloque de Home).
  final bool compact;

  const MissionCard({
    super.key,
    required this.mission,
    this.featured = false,
    this.compact = false,
  });

  @override
  ConsumerState<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends ConsumerState<MissionCard> {
  bool _claiming = false;
  bool _justClaimed = false;

  String _unit(AppLocalizations? l10n, String objectiveType) {
    switch (objectiveType) {
      case 'speak_minutes':
        return l10n?.missions_unit_minutes ?? 'min';
      case 'conversation_turns':
        return l10n?.missions_unit_turns ?? 'turns';
      case 'vocab_words':
        return l10n?.missions_unit_words ?? 'words';
      case 'sessions':
      case 'practice_session':
        return l10n?.missions_unit_sessions ?? 'sessions';
      default:
        return '';
    }
  }

  String _iconFor(String objectiveType) {
    switch (objectiveType) {
      case 'speak_minutes':
        return '🎙️';
      case 'vocab_words':
        return '📚';
      case 'sessions':
      case 'practice_session':
        return '🗣️';
      case 'conversation_turns':
        return '💬';
      default:
        return '⚔️';
    }
  }

  bool get _isDone =>
      widget.mission.isCompleted || widget.mission.progress >= 1.0;

  Future<void> _claim() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _claiming) return;
    setState(() => _claiming = true);

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    MissionClaimResult result;
    try {
      result = await ref
          .read(missionRepositoryProvider)
          .claimReward(widget.mission.id, user.id);
    } finally {
      if (mounted) setState(() => _claiming = false);
    }

    if (!mounted) return;

    if (!result.ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.missions_claim_error ??
                'No pudimos reclamar la recompensa. Revisa tu conexión e inténtalo de nuevo.',
          ),
          backgroundColor: AppColors.errorContainer,
        ),
      );
      return;
    }

    if (result.alreadyClaimed) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.missions_claim_already ?? 'Ya reclamaste esta recompensa.',
          ),
        ),
      );
      ref.invalidate(activeMissionsProvider);
      ref.invalidate(dashboardRefreshProvider);
      return;
    }

    // Animación breve del check antes de refrescar la lista (la tarjeta
    // reclamada desaparece al invalidar el provider).
    setState(() => _justClaimed = true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n?.missions_claim_success(result.xp, result.gems) ??
              'Recompensa reclamada: +${result.xp} XP · +${result.gems} gemas',
        ),
        backgroundColor: AppColors.accentGreen,
      ),
    );
    Future.delayed(AppMotion.of(context, AppMotion.standard), () {
      if (!mounted) return;
      ref.invalidate(activeMissionsProvider);
      ref.invalidate(dashboardRefreshProvider);
      ref.invalidate(userProgressProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mission = widget.mission;
    final unavailable = !MissionVisibility.isReachableInstance(mission);
    final claimed = mission.isRewardClaimed;
    final unit = _unit(l10n, mission.objectiveType);
    final accent = mission.isCompleted
        ? AppColors.accentGreen
        : unavailable
        ? AppColors.outline
        : AppColors.runeViolet;

    if (widget.compact) {
      return _buildCompact(
        context,
        mission,
        unavailable,
        claimed,
        unit,
        accent,
      );
    }
    return _buildFull(context, mission, unavailable, claimed, unit, accent);
  }

  Widget _buildCompact(
    BuildContext context,
    MissionInstance mission,
    bool unavailable,
    bool claimed,
    String unit,
    Color accent,
  ) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      blur: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: accent,
      child: Row(
        children: [
          Text(
            _iconFor(mission.objectiveType),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unavailable
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                _ProgressLine(
                  progress: mission.progress,
                  color: accent,
                  current: mission.currentValue,
                  target: mission.targetValue,
                  unit: unit,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (claimed)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.accentGreen,
              size: 20,
            )
          else if (unavailable)
            Text(
              l10n?.missions_unavailable ?? 'No disponible',
              style: const TextStyle(color: AppColors.outline, fontSize: 9),
            )
          else
            _RewardChip(mission: mission),
        ],
      ),
    );
  }

  Widget _buildFull(
    BuildContext context,
    MissionInstance mission,
    bool unavailable,
    bool claimed,
    String unit,
    Color accent,
  ) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: EdgeInsets.all(widget.featured ? 16 : 14),
      borderColor: accent,
      showRunicCorners: widget.featured,
      runicColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _iconFor(mission.objectiveType),
                style: TextStyle(fontSize: widget.featured ? 26 : 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        color: unavailable
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.featured ? 16 : 13,
                      ),
                    ),
                    if (mission.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        mission.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                claimed: claimed,
                justClaimed: _justClaimed,
                unavailable: unavailable,
                completed: mission.isCompleted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProgressLine(
            progress: mission.progress,
            color: accent,
            current: mission.currentValue,
            target: mission.targetValue,
            unit: unit,
            height: widget.featured ? 8 : 5,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _RewardChip(mission: mission),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: unavailable
                      ? Text(
                          l10n?.missions_unavailable_hint ??
                              'Esta misión no se puede completar con el seguimiento actual.',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: AppColors.outline,
                            fontSize: 9,
                          ),
                        )
                      : (!claimed && _isDone
                            ? _ClaimButton(
                                xp: mission.xpReward,
                                busy: _claiming,
                                onPressed: _claim,
                              )
                            : const SizedBox.shrink()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final double progress;
  final Color color;
  final int current;
  final int target;
  final String unit;
  final double height;

  const _ProgressLine({
    required this.progress,
    required this.color,
    required this.current,
    required this.target,
    required this.unit,
    this.height = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: height,
              backgroundColor: AppColors.onSurface.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          unit.isEmpty ? '$current/$target' : '$current/$target $unit',
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  final MissionInstance mission;

  const _RewardChip({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mission.xpReward > 0) ...[
          const Icon(Icons.bolt_rounded, color: AppColors.royalGold, size: 13),
          const SizedBox(width: 2),
          Text(
            '+${mission.xpReward}',
            style: const TextStyle(
              color: AppColors.royalGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        if (mission.gemReward > 0) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.diamond_rounded,
            color: AppColors.gemPurple,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '+${mission.gemReward}',
            style: const TextStyle(
              color: AppColors.gemPurple,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final int xp;
  final bool busy;
  final VoidCallback onPressed;

  const _ClaimButton({
    required this.xp,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: AppColors.voidBg,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: busy
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                l10n?.missions_claim_xp(xp) ?? 'Reclamar +$xp XP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool claimed;
  final bool justClaimed;
  final bool unavailable;
  final bool completed;

  const _StatusBadge({
    required this.claimed,
    required this.justClaimed,
    required this.unavailable,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    if (justClaimed || claimed) {
      return AnimatedScale(
        scale: justClaimed ? 1.2 : 1.0,
        duration: AppMotion.of(context, AppMotion.standard),
        curve: AppMotion.curveSpring,
        child: const Icon(
          Icons.verified_rounded,
          color: AppColors.accentGreen,
          size: 22,
        ),
      );
    }
    if (unavailable) {
      return const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.outline,
        size: 18,
      );
    }
    if (completed) {
      return const Icon(
        Icons.flag_rounded,
        color: AppColors.accentGreen,
        size: 20,
      );
    }
    return const SizedBox.shrink();
  }
}
