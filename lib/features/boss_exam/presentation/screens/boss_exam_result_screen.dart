import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/boss_exam_outcome.dart';
import '../../domain/models/boss_exam_rubric.dart';

/// P-31 (#116) — Pantalla de resultado del "Jefe de mazmorra".
///
/// El veredicto y el motivo vienen del servidor (`evaluate-placement`). Aquí
/// solo se explica: puntuación por dimensión, qué reforzar y cuándo se puede
/// reintentar.
class BossExamResultScreen extends StatelessWidget {
  const BossExamResultScreen({super.key, this.outcome});

  final BossExamOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = outcome;

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.voidBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.boss_result_missing,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/home'),
                    child: Text(l10n.boss_result_home),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final accent = result.promoted
        ? AppColors.emeraldGreen
        : (result.isInitial ? AppColors.manaCyan : AppColors.runeViolet);

    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Icon(
              result.promoted
                  ? Icons.emoji_events_rounded
                  : (result.isInitial
                        ? Icons.auto_awesome_rounded
                        : Icons.shield_rounded),
              color: accent,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              result.promoted
                  ? l10n.boss_result_victory
                  : (result.isInitial
                        ? l10n.boss_result_initial
                        : l10n.boss_result_defeat),
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _levelLine(l10n, result),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (result.forced) ...[
              const SizedBox(height: 8),
              Text(
                l10n.boss_result_forced,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _RubricCard(outcome: result),
            if (result.hasReason) ...[
              const SizedBox(height: 12),
              _ReasonCard(outcome: result),
            ],
            if (result.recommendedFocus.isNotEmpty ||
                result.weaknesses.isNotEmpty) ...[
              const SizedBox(height: 12),
              _FocusCard(outcome: result),
            ],
            const SizedBox(height: 20),
            if (!result.promoted && !result.isInitial) ...[
              OutlinedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: Text(l10n.boss_result_reinforce),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.manaCyan,
                  side: const BorderSide(color: AppColors.manaCyan),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: () => context.go('/home'),
              style: FilledButton.styleFrom(
                backgroundColor: result.promoted
                    ? AppColors.emeraldGreen
                    : AppColors.royalGold,
                foregroundColor: AppColors.voidBg,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.boss_result_home),
            ),
          ],
        ),
      ),
    );
  }

  String _levelLine(AppLocalizations l10n, BossExamOutcome result) {
    if (result.level.isEmpty) return l10n.boss_result_missing;
    if (result.promoted && result.previousLevel.isNotEmpty) {
      return l10n.boss_result_level_up(result.previousLevel, result.level);
    }
    if (result.isInitial) {
      return l10n.boss_result_level_assigned(result.level);
    }
    return l10n.boss_result_level_kept(result.level);
  }
}

class _RubricCard extends StatelessWidget {
  const _RubricCard({required this.outcome});

  final BossExamOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rubric = outcome.rubric;

    return GlassCard(
      blur: 16,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.boss_result_rubric,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              if (rubric.dimensions.isNotEmpty)
                Text(
                  l10n.boss_result_average(
                    rubric.average,
                    BossExamRubric.passAverage,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: rubric.passed
                        ? AppColors.emeraldGreen
                        : AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (rubric.dimensions.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.boss_result_no_scores,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            ...BossExamRubric.dimensionKeys.map((key) {
              final score = rubric.dimensions[key];
              if (score == null) return const SizedBox.shrink();
              return _DimensionBar(
                label: _dimensionLabel(l10n, key),
                score: score,
                pass: score >= BossExamRubric.minDimension,
              );
            }),
          ],
        ],
      ),
    );
  }

  static String _dimensionLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'listening':
        return l10n.boss_dim_listening;
      case 'fluency':
        return l10n.boss_dim_fluency;
      case 'grammar':
        return l10n.boss_dim_grammar;
      case 'vocabulary':
        return l10n.boss_dim_vocabulary;
      case 'pronunciation':
        return l10n.boss_dim_pronunciation;
      case 'naturalness':
        return l10n.boss_dim_naturalness;
      default:
        return key;
    }
  }
}

class _DimensionBar extends StatelessWidget {
  const _DimensionBar({
    required this.label,
    required this.score,
    required this.pass,
  });

  final String label;
  final int score;
  final bool pass;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (score / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.onSurface.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  pass ? AppColors.emeraldGreen : AppColors.hpBarRed,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: pass ? AppColors.onSurface : AppColors.hpBarRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({required this.outcome});

  final BossExamOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final until = outcome.nextAttemptAt;

    return GlassCard(
      blur: 16,
      opacity: AppColors.glassOpacity,
      border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.boss_result_reason_title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.runeViolet,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _reasonText(l10n, outcome.reasonCode),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          if (until != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.boss_result_retry_at(_formatDate(until)),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          if (outcome.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              outcome.explanation,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _reasonText(AppLocalizations l10n, String reasonCode) {
    switch (reasonCode) {
      case 'rubric_below_threshold':
        return l10n.boss_result_reason_rubric;
      case 'no_improvement':
        return l10n.boss_result_reason_no_improvement;
      case 'rubric_unavailable':
        return l10n.boss_result_reason_unavailable;
      default:
        return l10n.boss_result_reason_no_improvement;
    }
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)} ${two(date.hour)}:${two(date.minute)}';
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.outcome});

  final BossExamOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      blur: 16,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.boss_result_focus_title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.royalGold,
            ),
          ),
          if (outcome.recommendedFocus.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              outcome.recommendedFocus,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurface,
              ),
            ),
          ],
          if (outcome.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...outcome.weaknesses.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: AppColors.manaCyan,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
