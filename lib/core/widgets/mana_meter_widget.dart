import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class ManaMeterWidget extends StatelessWidget {
  final int currentMana;
  final int maxMana;
  final int usedInSession;

  const ManaMeterWidget({
    super.key,
    required this.currentMana,
    this.maxMana = 500,
    this.usedInSession = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (currentMana / maxMana).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.deepSlate.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.runeViolet.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.runeViolet.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔮', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '$currentMana Maná',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (usedInSession > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(-$usedInSession)',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.crimsonRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 80,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: AppColors.onSurface.withValues(alpha: 0.10),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.runeViolet),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
