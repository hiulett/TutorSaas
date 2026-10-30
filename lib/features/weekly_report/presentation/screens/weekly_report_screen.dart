import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/weekly_report_service.dart';
import '../../domain/models/weekly_report.dart';

/// P-43 (#128) — informe semanal de progreso.
///
/// Todo lo que se ve viene de `get_weekly_report` (servidor): palabras nuevas,
/// errores corregidos, minutos, lecciones y nivel estimado. Si la semana no
/// tiene actividad se dice explícitamente; no se pintan ceros como progreso.
class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(weeklyReportProvider(_weekOffset));

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.medievalText,
                        size: 18,
                      ),
                      tooltip: l10n?.back ?? 'Back',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n?.weekly_title ?? 'WEEKLY REPORT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.medievalText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  l10n?.weekly_subtitle ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.medievalTextDim,
                  ),
                ),
              ),
              Expanded(
                child: async.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.manaCyan,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (error, _) => _ErrorState(
                    message:
                        l10n?.weekly_error ??
                        'We could not load your weekly report.',
                    retryLabel: l10n?.weekly_retry ?? 'RETRY',
                    onRetry: () =>
                        ref.invalidate(weeklyReportProvider(_weekOffset)),
                  ),
                  data: (report) {
                    if (report == null) {
                      return _ErrorState(
                        message:
                            l10n?.weekly_error ??
                            'We could not load your weekly report.',
                        retryLabel: l10n?.weekly_retry ?? 'RETRY',
                        onRetry: () =>
                            ref.invalidate(weeklyReportProvider(_weekOffset)),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      children: [
                        _WeekSelector(
                          report: report,
                          weekOffset: _weekOffset,
                          // P-44 (#129): el plan limita el historial. El botón
                          // se desactiva en el último offset permitido en vez
                          // de pedir semanas que el servidor va a bloquear.
                          canGoPrevious: _weekOffset < report.maxWeekOffset,
                          onPrevious: () => setState(() {
                            if (_weekOffset < report.maxWeekOffset) {
                              _weekOffset += 1;
                            }
                          }),
                          onNext: _weekOffset == 0
                              ? null
                              : () => setState(() {
                                  if (_weekOffset > 0) _weekOffset -= 1;
                                }),
                        ),
                        const SizedBox(height: 16),
                        if (report.locked)
                          _LockedWeekCard(report: report)
                        else if (!report.hasData)
                          _EmptyWeekCard(report: report)
                        else
                          _ReportBody(report: report),
                        if (_weekOffset >= report.maxWeekOffset &&
                            report.historyWeeks < 52)
                          _HistoryLimitNote(weeks: report.historyWeeks),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector({
    required this.report,
    required this.weekOffset,
    required this.onPrevious,
    required this.onNext,
    this.canGoPrevious = true,
  });

  final WeeklyReport report;
  final int weekOffset;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final bool canGoPrevious;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = weekOffset == 0
        ? (l10n?.weekly_this_week ?? 'This week')
        : (l10n?.weekly_previous_week ?? 'Previous week');
    final start = report.startDate;
    final end = report.endDate;
    final range = (start != null && end != null)
        ? (l10n?.weekly_range(_shortDate(start), _shortDate(end)) ??
              '${_shortDate(start)} - ${_shortDate(end)}')
        : '';

    return Row(
      children: [
        IconButton(
          onPressed: canGoPrevious ? onPrevious : null,
          icon: Icon(
            Icons.chevron_left_rounded,
            color: canGoPrevious
                ? AppColors.manaCyan
                : AppColors.medievalTextDim.withValues(alpha: 0.4),
          ),
          tooltip: l10n?.weekly_previous_week ?? 'Previous week',
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.medievalText,
                ),
              ),
              if (range.isNotEmpty)
                Text(
                  range,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppColors.medievalTextDim,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: onNext == null
                ? AppColors.medievalTextDim.withValues(alpha: 0.3)
                : AppColors.manaCyan,
          ),
          tooltip: l10n?.weekly_next_week ?? 'Next week',
        ),
      ],
    );
  }
}

class _EmptyWeekCard extends StatelessWidget {
  const _EmptyWeekCard({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          blur: 20,
          opacity: AppColors.glassOpacity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                color: AppColors.manaCyan,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                l10n?.weekly_empty ?? 'No recorded activity this week.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.medievalText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.weekly_empty_hint ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  height: 1.4,
                  color: AppColors.medievalTextDim,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _LevelCard(report: report),
      ],
    );
  }
}

class _LockedWeekCard extends StatelessWidget {
  const _LockedWeekCard({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      borderColor: AppColors.runeViolet.withValues(alpha: 0.45),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.runeViolet,
            size: 26,
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.weekly_history_locked(report.historyWeeks) ??
                'Your plan keeps ${report.historyWeeks} week of history.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.medievalText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.weekly_history_upgrade ??
                'Upgrade your plan to open previous weeks.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.4,
              color: AppColors.medievalTextDim,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso al llegar al final del historial que permite el plan.
class _HistoryLimitNote extends StatelessWidget {
  const _HistoryLimitNote({required this.weeks});

  final int weeks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppColors.medievalTextDim,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n?.weekly_history_locked(weeks) ??
                  'Your plan keeps $weeks week of history.',
              style: GoogleFonts.inter(
                fontSize: 10,
                height: 1.4,
                color: AppColors.medievalTextDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final perDay = report.minutesPerPracticeDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.auto_stories_rounded,
                color: AppColors.manaCyan,
                value: '${report.newWords}',
                label: l10n?.weekly_new_words ?? 'New words',
                delta: report.newWordsDelta,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.spellcheck_rounded,
                color: AppColors.royalGold,
                value: '${report.corrections}',
                label: l10n?.weekly_corrections ?? 'Errors corrected',
                delta: report.correctionsDelta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.timer_rounded,
                color: AppColors.emeraldGreen,
                value: '${report.minutes}',
                label: l10n?.weekly_minutes ?? 'Minutes',
                delta: report.minutesDelta,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.school_rounded,
                color: AppColors.runeViolet,
                value: '${report.lessonsCompleted}',
                label: l10n?.weekly_lessons ?? 'Lessons passed',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          blur: 20,
          opacity: AppColors.glassOpacity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: l10n?.weekly_words_reviewed ?? 'Words reviewed',
                value: '${report.wordsReviewed}',
              ),
              const SizedBox(height: 8),
              _DetailRow(
                label: l10n?.weekly_words_mastered ?? 'Words mastered',
                value: '${report.wordsMastered}',
              ),
              const SizedBox(height: 8),
              _DetailRow(
                label: l10n?.weekly_practice_days ?? 'Days practised',
                value: '${report.practiceDays}',
              ),
              if (perDay != null) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  label: l10n?.weekly_per_day ?? 'Average per practice day',
                  value: '${perDay.round()} min',
                ),
              ],
              if (report.topErrorType != null) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  label: l10n?.weekly_top_error ?? 'Most frequent error',
                  value: report.topErrorType!,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _LevelCard(report: report),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = report.levelLabel;
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.4)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.royalGold,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.weekly_level ?? 'Estimated level',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.medievalTextDim,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label ?? (l10n?.weekly_level_unknown ?? 'Not assessed yet'),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.medievalText,
                  ),
                ),
              ],
            ),
          ),
          if (report.gameRank != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.royalGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.royalGold),
              ),
              child: Text(
                report.gameRank!,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalGold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.delta,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final int? delta;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.medievalText,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.medievalTextDim,
            ),
          ),
          if (delta != null && delta != 0) ...[
            const SizedBox(height: 4),
            Text(
              '${delta! > 0 ? '+' : ''}$delta',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: delta! > 0
                    ? AppColors.emeraldGreen
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.medievalTextDim,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.medievalText,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.medievalTextDim,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(
                retryLabel,
                style: GoogleFonts.jetBrainsMono(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _shortDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}';
}
