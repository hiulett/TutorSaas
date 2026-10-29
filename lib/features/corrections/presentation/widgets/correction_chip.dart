import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/session_correction.dart';

/// Chip discreto bajo la burbuja del usuario (P-29).
///
/// No interrumpe la conversación: por defecto solo muestra «FIX n» y se
/// despliega al tocar. El nivel de corrección (`correction_level`) decide
/// cuántas se ven y si se muestra la explicación.
class CorrectionChip extends StatefulWidget {
  const CorrectionChip({
    super.key,
    required this.corrections,
    required this.level,
  });

  final List<TurnCorrection> corrections;
  final String level;

  @override
  State<CorrectionChip> createState() => _CorrectionChipState();
}

class _CorrectionChipState extends State<CorrectionChip> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = correctionsForLevel(widget.corrections, widget.level);
    if (visible.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final showExplanation = showsCorrectionExplanation(widget.level);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: l10n?.corrections_chip_label(visible.length) ?? 'FIX',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                constraints: const BoxConstraints(minHeight: 28),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.runeViolet.withValues(alpha: 0.12),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.runeViolet.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.spellcheck_rounded,
                      size: 13,
                      color: AppColors.runeVioletText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n?.corrections_chip_label(visible.length) ??
                          'FIX ${visible.length}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: AppColors.runeVioletText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 14,
                      color: AppColors.runeVioletText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final correction in visible)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${l10n?.corrections_you_wrote ?? 'You wrote'}: ',
                                        style: const TextStyle(
                                          color: AppColors.medievalTextDim,
                                        ),
                                      ),
                                      TextSpan(
                                        text: correction.original,
                                        style: const TextStyle(
                                          color: AppColors.medievalTextDim,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${l10n?.corrections_suggested ?? 'Better'}: ',
                                        style: const TextStyle(
                                          color: AppColors.royalGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: correction.corrected,
                                        style: const TextStyle(
                                          color: AppColors.emeraldGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                                if (showExplanation &&
                                    correction.explanation.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      correction.explanation,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        height: 1.35,
                                        color: AppColors.medievalText,
                                      ),
                                    ),
                                  ),
                              ],
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
