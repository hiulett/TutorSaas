import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'srs_flashcard_modal.dart';

/// Issue #24: tarjeta de repaso espaciado (SM-2).
///
/// `srs_flashcard_modal.dart` existía con 274 líneas y **cero importadores**:
/// el algoritmo se ejecutaba pero el usuario nunca podía repasar. Esta tarjeta
/// aparece en la pestaña de mazmorras solo cuando hay palabras vencidas.
class SrsReviewCard extends ConsumerWidget {
  const SrsReviewCard({super.key, this.maxItems = 10});

  final int maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueVocabularyProvider).value ?? const <Map<String, dynamic>>[];
    if (due.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => _open(context, ref, due),
        borderColor: AppColors.manaCyan.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.style_rounded, color: AppColors.manaCyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.srs_review_title ?? 'REPASO DEL DÍA',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.manaCyan,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n?.srs_review_due(due.length) ?? '${due.length} palabras esperan repaso',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n?.srs_review_cta ?? 'REPASAR',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> due,
  ) async {
    await SrsFlashcardModal.show(context, due.take(maxItems).toList());
    // Al cerrar, las palabras repasadas ya tienen nueva fecha: recargar.
    ref.invalidate(dueVocabularyProvider);
  }
}
