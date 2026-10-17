import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../missions/domain/models/mission_models.dart';
import '../../../missions/presentation/providers/mission_providers.dart';

/// Misiones Diarias (conectadas a `mission_instances` reales).
///
/// Muestra las misiones activas del usuario con su progreso real y, al
/// reclamar, aplica la recompensa XP vía `claimReward` (RPC add_xp).
class DailyQuestsWidget extends ConsumerWidget {
  final int streakDays;

  const DailyQuestsWidget({super.key, required this.streakDays});

  /// Icono por tipo de objetivo.
  String _iconFor(String objectiveType) {
    switch (objectiveType) {
      case 'speak_minutes':
        return '🎙️';
      case 'vocab_words':
        return '📚';
      case 'sessions':
        return '🗣️';
      case 'conversation_turns':
        return '💬';
      case 'practice_session':
        return '🎯';
      default:
        return '⚔️';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final missionsAsync = ref.watch(dailyMissionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.manaCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.quest_daily_title ?? 'Misiones Diarias',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.royalGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: AppColors.royalGold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$streakDays ${l10n?.days ?? 'Días'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalGold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        missionsAsync.when(
          data: (missions) {
            if (missions.isEmpty) {
              return GlassCard(
                blur: 20,
                opacity: AppColors.glassOpacity,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    l10n?.quest_empty ?? 'No hay misiones diarias activas por ahora.',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              );
            }
            return Column(
              children: missions.map((m) => _buildQuestCard(context, ref, user?.id, m)).toList(),
            );
          },
          loading: () => const GlassCard(
            blur: 20,
            opacity: AppColors.glassOpacity,
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator(color: AppColors.runeViolet, strokeWidth: 2)),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildQuestCard(
    BuildContext context,
    WidgetRef ref,
    String? userId,
    MissionInstance m,
  ) {
    final l10n = AppLocalizations.of(context);
    final isCompleted = m.isCompleted || m.progress >= 1.0;
    final isClaimed = m.isRewardClaimed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GlassCard(
        blur: 20,
        opacity: AppColors.glassOpacity,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Text(_iconFor(m.objectiveType), style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: m.progress,
                      minHeight: 4,
                      backgroundColor: AppColors.onSurface.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppColors.accentGreen : AppColors.runeViolet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isClaimed)
              const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 22)
            else if (isCompleted)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                child: ElevatedButton(
                  onPressed: () async {
                    if (userId == null) return;
                    final ok = await ref
                        .read(missionRepositoryProvider)
                        .claimReward(m.id, userId);
                    if (ok && context.mounted) {
                      ref.invalidate(dailyMissionsProvider);
                      ref.invalidate(userProgressProvider);
                      if (m.xpReward > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.quest_claimed(m.xpReward) ??
                                  '¡Recompensa canjeada! +${m.xpReward} XP',
                            ),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                  child: Text(
                    '+${m.xpReward} XP',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Text(
                '${m.currentValue}/${m.targetValue}',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
