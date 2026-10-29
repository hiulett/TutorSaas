import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/corrections_repository.dart';
import '../../domain/models/session_correction.dart';
import '../providers/corrections_providers.dart';

/// P-29 — Pantalla «Mis errores».
///
/// Agrupa las correcciones guardadas por tipo y recurrencia. Los errores
/// recurrentes son la misma señal que consumen las misiones de refuerzo y el
/// prompt del tutor (vista `user_recurring_errors`).
class MyErrorsScreen extends ConsumerWidget {
  const MyErrorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final correctionsAsync = ref.watch(myCorrectionsProvider);

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 8),
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
                        l10n?.my_errors_title ?? 'MY ERRORS',
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
                  l10n?.my_errors_subtitle ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.medievalTextDim,
                  ),
                ),
              ),
              Expanded(
                child: correctionsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.manaCyan,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (error, _) => _ErrorState(
                    message: error is CorrectionsException
                        ? error.message
                        : (l10n?.my_errors_error ??
                              'We could not load your errors.'),
                    retryLabel: l10n?.my_errors_retry ?? 'RETRY',
                    onRetry: () => ref.invalidate(myCorrectionsProvider),
                  ),
                  data: (records) {
                    final groups = groupCorrections(records);
                    if (groups.isEmpty) {
                      return _EmptyState(message: l10n?.my_errors_empty ?? '');
                    }
                    return _ErrorsList(
                      groups: groups,
                      l10n: l10n,
                      onRefresh: () async =>
                          ref.invalidate(myCorrectionsProvider),
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

class _ErrorsList extends StatelessWidget {
  const _ErrorsList({
    required this.groups,
    required this.l10n,
    required this.onRefresh,
  });

  final List<CorrectionGroup> groups;
  final AppLocalizations? l10n;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final sections = groupCorrectionsByType(groups);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.manaCyan,
      backgroundColor: AppColors.surfaceDeep,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          for (final entry in sections.entries) ...[
            _SectionHeader(type: entry.key, l10n: l10n),
            const SizedBox(height: 8),
            for (final group in entry.value) ...[
              _ErrorCard(group: group, l10n: l10n),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.type, required this.l10n});

  final CorrectionType type;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_iconFor(type), size: 16, color: _colorFor(type)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _labelFor(type, l10n),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: _colorFor(type),
            ),
          ),
        ),
        Container(
          height: 1,
          width: 40,
          color: _colorFor(type).withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.group, required this.l10n});

  final CorrectionGroup group;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 18,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.original,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.medievalTextDim,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CountBadge(
                occurrences: group.occurrences,
                recurring: group.isRecurring,
                l10n: l10n,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            group.corrected,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: AppColors.emeraldGreen,
            ),
          ),
          if (group.explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              group.explanation,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppColors.medievalText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.occurrences,
    required this.recurring,
    required this.l10n,
  });

  final int occurrences;
  final bool recurring;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final color = recurring ? AppColors.royalGold : AppColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        recurring
            ? '${l10n?.my_errors_recurring_badge ?? 'RECURRING'} '
                  '${l10n?.my_errors_times(occurrences) ?? '${occurrences}x'}'
            : (l10n?.my_errors_times(occurrences) ?? '${occurrences}x'),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spellcheck_rounded,
              size: 40,
              color: AppColors.runeViolet.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.medievalTextDim,
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 36,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.medievalText,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.manaCyan.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
              ),
              child: Text(
                retryLabel,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.manaCyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _labelFor(CorrectionType type, AppLocalizations? l10n) {
  switch (type) {
    case CorrectionType.grammar:
      return l10n?.correction_type_grammar ?? 'Grammar';
    case CorrectionType.vocabulary:
      return l10n?.correction_type_vocabulary ?? 'Vocabulary';
    case CorrectionType.wordChoice:
      return l10n?.correction_type_word_choice ?? 'Word choice';
    case CorrectionType.pronunciationHint:
      return l10n?.correction_type_pronunciation_hint ?? 'Pronunciation';
    case CorrectionType.typoStt:
      return l10n?.correction_type_typo_stt ?? 'Transcription';
  }
}

IconData _iconFor(CorrectionType type) {
  switch (type) {
    case CorrectionType.grammar:
      return Icons.rule_rounded;
    case CorrectionType.vocabulary:
      return Icons.menu_book_rounded;
    case CorrectionType.wordChoice:
      return Icons.swap_horiz_rounded;
    case CorrectionType.pronunciationHint:
      return Icons.record_voice_over_rounded;
    case CorrectionType.typoStt:
      return Icons.mic_none_rounded;
  }
}

Color _colorFor(CorrectionType type) {
  switch (type) {
    case CorrectionType.grammar:
      return AppColors.manaCyan;
    case CorrectionType.vocabulary:
      return AppColors.runeVioletText;
    case CorrectionType.wordChoice:
      return AppColors.royalGold;
    case CorrectionType.pronunciationHint:
      return AppColors.emeraldGreen;
    case CorrectionType.typoStt:
      return AppColors.onSurfaceVariant;
  }
}
