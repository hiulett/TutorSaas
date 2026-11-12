import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../corrections/domain/models/turn_correction.dart';

/// Fila plegada de correcciones del turno, justo debajo de la burbuja del
/// cazador (opción B del análisis de UX del chat).
///
/// Antes las correcciones solo vivían tras el icono del códex: el alumno tenía
/// que adivinar que había algo y abrirlo después, descontextualizado. Aquí se
/// ven en el mismo turno, pero colapsadas a una línea para no ensuciar el flujo.
class ConversationCorrectionsRow extends StatefulWidget {
  const ConversationCorrectionsRow({super.key, required this.corrections});

  final List<TurnCorrection> corrections;

  @override
  State<ConversationCorrectionsRow> createState() =>
      _ConversationCorrectionsRowState();
}

class _ConversationCorrectionsRowState extends State<ConversationCorrectionsRow> {
  bool _expanded = false;

  String _typeLabel(AppLocalizations? l10n, CorrectionType type) {
    switch (type) {
      case CorrectionType.grammar:
        return l10n?.corr_type_grammar ?? 'GRAMMAR';
      case CorrectionType.vocabulary:
        return l10n?.corr_type_vocabulary ?? 'VOCAB';
      case CorrectionType.wordChoice:
        return l10n?.corr_type_word_choice ?? 'WORD CHOICE';
      case CorrectionType.pronunciationHint:
        return l10n?.corr_type_pronunciation ?? 'PRONUNCIATION';
      case CorrectionType.typoStt:
        return l10n?.corr_type_stt ?? 'STT';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = widget.corrections.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.royalGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.fact_check_outlined,
                    color: AppColors.royalGold,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n?.convo_corrections_title ?? 'CORRECTIONS'} · $count',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.royalGold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.end,
                      children: [
                        for (final correction
                            in widget.corrections.take(_expanded ? 0 : 3))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: AppColors.royalGold.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                            child: Text(
                              _typeLabel(l10n, correction.type),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 7.5,
                                letterSpacing: 0.8,
                                color: AppColors.royalGold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.royalGold,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final correction in widget.corrections)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabel(l10n, correction.type),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 7.5,
                              letterSpacing: 0.8,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: correction.original,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const TextSpan(text: '  →  '),
                                TextSpan(
                                  text: correction.corrected,
                                  style: const TextStyle(
                                    color: AppColors.emeraldGreen,
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(fontSize: 13, height: 1.35),
                          ),
                          if (correction.explanation.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              correction.explanation,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
