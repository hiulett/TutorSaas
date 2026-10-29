import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/learning_evidence_summary.dart';
import '../providers/dashboard_providers.dart';

/// Evidencia de aprendizaje (R3 / #74): retencion, progreso y transferencia.
///
/// Muestra "aun sin datos" o "necesitas 4 semanas" en vez de ceros. La
/// evidencia es un mapa, no una nota.
class LearningEvidenceCard extends ConsumerWidget {
  const LearningEvidenceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(learningEvidenceProvider);
    final summary = LearningEvidenceSummary.fromMap(async.value ?? const {});
    final muted = GoogleFonts.inter(
      fontSize: 10,
      color: AppColors.onSurfaceVariant,
    );

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.manaCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.evidence_title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.evidence_disclaimer, style: muted),
          const SizedBox(height: 12),
          _EvidenceRow(
            icon: Icons.school_rounded,
            label: l10n.evidence_retention,
            value: summary.hasRetention
                ? '${summary.retentionPercent}%'
                : l10n.evidence_no_data,
            available: summary.hasRetention,
          ),
          const SizedBox(height: 8),
          _EvidenceRow(
            icon: Icons.trending_up_rounded,
            label: l10n.evidence_progress,
            value: summary.hasComparableProgress
                ? l10n.evidence_progress_value(
                    summary.firstWeekCompleted!,
                    summary.lastWeekCompleted!,
                  )
                : l10n.evidence_needs_weeks,
            available: summary.hasComparableProgress,
          ),
          const SizedBox(height: 8),
          _EvidenceRow(
            icon: Icons.swap_horiz_rounded,
            label: l10n.evidence_transfer,
            value: summary.hasTransfer
                ? l10n.evidence_transfer_value(summary.transferTypes)
                : l10n.evidence_no_data,
            available: summary.hasTransfer,
          ),
        ],
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.available,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available
        ? AppColors.emeraldGreen
        : AppColors.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
