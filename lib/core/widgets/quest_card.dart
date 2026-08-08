import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'segmented_bar.dart';

class QuestCard extends StatelessWidget {
  final String title;
  final String description;
  final String rank; // 'S', 'A', 'B', 'C', 'D'
  final int gemReward;
  final int xpReward;
  final double progress; // Value from 0.0 to 1.0
  final int progressSegments;
  final VoidCallback? onTap;

  const QuestCard({
    super.key,
    required this.title,
    required this.description,
    required this.rank,
    required this.gemReward,
    required this.xpReward,
    this.progress = 0.0,
    this.progressSegments = 5,
    this.onTap,
  });

  Color _getRankColor() {
    switch (rank.toUpperCase()) {
      case 'S':
        return AppColors.royalGold;
      case 'A':
        return AppColors.runeViolet;
      case 'B':
        return AppColors.manaCyan;
      case 'C':
        return AppColors.emeraldGreen;
      default:
        return AppColors.outlineVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();

    return GlassCard(
      showRunicCorners: true,
      runicColor: rankColor,
      borderColor: rankColor.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(16),
      // onTap integrado en el GestureDetector interno del GlassCard para que
      // el tap no quede atrapado por la animación de prensado.
      onTap: onTap,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Rank Badge and Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: rankColor, width: 1.5),
                  ),
                  child: Text(
                    rank.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: rankColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Quest Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Middle Row: Rewards Info
            Row(
              children: [
                // Gems
                if (gemReward > 0) ...[
                  const Icon(Icons.diamond_rounded, color: AppColors.manaCyan, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+$gemReward GEMS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.manaCyan,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                // XP
                if (xpReward > 0) ...[
                  const Icon(Icons.flash_on_rounded, color: AppColors.royalGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+$xpReward XP',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalGold,
                    ),
                  ),
                ],
              ],
            ),

            // Progress bar if progress > 0
            if (progress > 0) ...[
              const SizedBox(height: 12),
              SegmentedBar(
                value: progress,
                segments: progressSegments,
                color: rankColor,
                height: 4,
              ),
            ],
          ],
        ),
    );
  }
}
