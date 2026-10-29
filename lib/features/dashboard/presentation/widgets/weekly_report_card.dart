import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../boss_exam/data/boss_exam_service.dart';
import '../../../weekly_report/data/weekly_report_service.dart';
import '../../../boss_exam/domain/services/level_checkpoint.dart';
import '../../../weekly_report/domain/models/weekly_report.dart';
import '../providers/dashboard_providers.dart';

/// P-43 (#128) — tarjeta del informe semanal en la pestaña de progreso.
///
/// Los números vienen de `get_weekly_report` (servidor). Si la semana no tiene
/// actividad se dice; si la RPC falla se avisa y se puede reintentar. No hay
/// ceros de relleno en ninguno de los dos casos.
class WeeklyReportCard extends ConsumerWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se refresca al terminar una sesión (endSession sube este contador).
    ref.listen(dashboardRefreshProvider, (previous, next) {
      if (next != previous) {
        Future.microtask(() => ref.invalidate(weeklyReportProvider));
      }
    });
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(weeklyReportProvider(0));
    final bossStatus = ref.watch(bossExamStatusProvider).value;

    final muted = GoogleFonts.inter(
      fontSize: 10,
      color: AppColors.onSurfaceVariant,
    );

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/weekly-report'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.royalGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.weekly_title ?? 'WEEKLY REPORT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                l10n?.weekly_open ?? 'VIEW REPORT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          async.when(
            loading: () =>
                Text(l10n?.weekly_this_week ?? 'This week', style: muted),
            error: (error, _) => Text(
              l10n?.weekly_error ?? 'We could not load your weekly report.',
              style: muted,
            ),
            data: (report) {
              if (report == null) {
                return Text(
                  l10n?.weekly_error ?? 'We could not load your weekly report.',
                  style: muted,
                );
              }
              if (!report.hasData) {
                return Text(
                  l10n?.weekly_empty ?? 'No recorded activity this week.',
                  style: muted,
                );
              }
              return _ReportSummary(report: report);
            },
          ),
          if (bossStatus != null && !bossStatus.checkDue) ...[
            const SizedBox(height: 8),
            Text(
              l10n?.checkpoint_remaining(
                    LevelCheckpoint.remaining(bossStatus.lessonsSinceLastCheck),
                  ) ??
                  '${LevelCheckpoint.remaining(bossStatus.lessonsSinceLastCheck)} lessons to the next level check',
              style: muted,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _Metric(
          value: '${report.newWords}',
          label: l10n?.weekly_new_words ?? 'New words',
          color: AppColors.manaCyan,
        ),
        _Metric(
          value: '${report.corrections}',
          label: l10n?.weekly_corrections ?? 'Errors corrected',
          color: AppColors.royalGold,
        ),
        _Metric(
          value: '${report.minutes}',
          label: l10n?.weekly_minutes ?? 'Minutes',
          color: AppColors.emeraldGreen,
        ),
        _Metric(
          value: report.level ?? '—',
          label: l10n?.weekly_level ?? 'Estimated level',
          color: AppColors.runeViolet,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              height: 1.2,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
