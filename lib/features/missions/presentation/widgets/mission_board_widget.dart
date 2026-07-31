import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../providers/mission_providers.dart';
import '../../domain/models/mission_models.dart';

class MissionBoardWidget extends ConsumerWidget {
  const MissionBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMissions = ref.watch(activeMissionsProvider);
    final emergency = ref.watch(emergencyMissionsProvider);
    final completed = ref.watch(completedMissionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.assignment_rounded, color: AppColors.manaCyan, size: 20),
            const SizedBox(width: 8),
            Text(
              'TABLÓN DE MISIONES',
              style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Emergency banner
        emergency.when(
          data: (list) {
            if (list.isEmpty) return const SizedBox.shrink();
            final em = list.first;
            final remaining = em.expiresAt.difference(DateTime.now());
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                blur: 4, opacity: 0.1,
                border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.5)),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.crimsonRed, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('⚠ EMERGENCIA', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.crimsonRed, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(em.title, style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('${remaining.inMinutes} min restantes', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.crimsonRed)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimsonRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                      child: Text('ACEPTAR', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Active missions
        activeMissions.when(
          data: (missions) {
            if (missions.isEmpty) {
              return GlassCard(
                blur: 4, opacity: 0.94,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text('No hay misiones activas. Revisa el tablón del gremio.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ),
              );
            }
            return Column(
              children: missions.take(3).map((mission) => _MissionCard(mission: mission)).toList(),
            );
          },
          loading: () => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.manaCyan, strokeWidth: 2))),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Completed but unclaimed
        completed.when(
          data: (list) {
            if (list.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassCard(
                blur: 4, opacity: 0.94,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard_rounded, color: AppColors.royalGold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${list.length} recompensa(s) por reclamar', style: GoogleFonts.inter(fontSize: 12, color: Colors.white))),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.royalGold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                      child: Text('RECLAMAR', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final MissionInstance mission;
  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final icon = missionTypeIcon(mission.missionType);
    final color = Color(missionTypeColor(mission.missionType));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        blur: 4, opacity: 0.94,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.4))),
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(mission.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3)),
                        child: Text(mission.missionType.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SegmentedBar(value: mission.progress, color: color, height: 4),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${mission.currentValue}/${mission.targetValue}', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.onSurfaceVariant)),
                      Row(
                        children: [
                          if (mission.xpReward > 0) ...[
                            const Icon(Icons.stars_rounded, size: 12, color: AppColors.royalGold),
                            const SizedBox(width: 2),
                            Text('${mission.xpReward}', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.royalGold)),
                          ],
                          if (mission.gemReward > 0) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.diamond_rounded, size: 12, color: Color(0xFFE0B6FF)),
                            const SizedBox(width: 2),
                            Text('${mission.gemReward}', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: const Color(0xFFE0B6FF))),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
