import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/lesson_catalog.dart';

class AIPickHeroCard extends StatelessWidget {
  final LessonData lesson;
  final int matchPercentage;
  final String matchReason;
  final VoidCallback onTapPreview;

  const AIPickHeroCard({
    super.key,
    required this.lesson,
    required this.matchPercentage,
    required this.matchReason,
    required this.onTapPreview,
  });

  IconData _getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'handshake':
        return Icons.handshake_rounded;
      case 'people':
        return Icons.people_alt_rounded;
      case 'schedule':
        return Icons.access_time_filled_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'explore':
        return Icons.explore_rounded;
      case 'devices':
        return Icons.devices_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      blur: 30,
      opacity: 0.14,
      border: Border.all(
        color: AppColors.manaCyan.withValues(alpha: 0.5),
        width: 1.5,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.runeViolet.withValues(alpha: 0.3),
                      AppColors.manaCyan.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.manaCyan.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.manaCyan,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI PICK DEL DÍA',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.manaCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '⚡ $matchPercentage% Match IA',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Lesson Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.runeViolet.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.runeViolet.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  _getIconData(lesson.iconKey),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
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

          const SizedBox(height: 14),

          // Match Reason Tag
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.manaCyan,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    matchReason,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Preview & Start Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTapPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.runeViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_red_eye_rounded, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Ver Vista Previa y Objetivos',
                      style: GoogleFonts.hankenGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
