import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/listening_exercise.dart';
import '../providers/listening_providers.dart';

/// P-30 (#115) — Tarjeta de comprensión auditiva dentro de la Ruta.
///
/// Solo aparece cuando el nivel tiene ejercicios sembrados. Muestra el
/// siguiente ejercicio pendiente y el progreso real (`listening_attempts`,
/// escrito por el servidor).
class ListeningPathCard extends ConsumerWidget {
  const ListeningPathCard({super.key, required this.level});

  /// Código CEFR de la etapa seleccionada en la Ruta (A1, A2, B1...).
  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final exercisesAsync = ref.watch(listeningExercisesProvider(level));
    // `AsyncValue.value` relanza el error: aquí basta con ocultar la tarjeta si
    // el banco no se pudo leer (el provider ya dejó el registro del fallo).
    final exercises =
        exercisesAsync.asData?.value ?? const <ListeningExercise>[];
    if (exercises.isEmpty) return const SizedBox.shrink();

    final progress =
        ref.watch(listeningProgressProvider).asData?.value ??
        const ListeningProgress();
    final next = progress.nextOf(exercises);
    final passed = progress.passedCount(exercises);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.35)),
        // GlassCard gana la arena de gestos: el tap va en su propio onTap.
        onTap: next == null
            ? null
            : () => context.push('/listening?exerciseId=${next.slug}'),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.manaCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.headphones_rounded,
                size: 18,
                color: AppColors.manaCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n?.listening_path_title ?? 'LISTENING',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: AppColors.manaCyan,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        l10n?.listening_path_progress(
                              passed,
                              exercises.length,
                            ) ??
                            '$passed/${exercises.length} passed',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.medievalTextDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    next == null
                        ? (l10n?.listening_empty ??
                              'No listening exercises for this level yet.')
                        : (l10n?.listening_path_next(next.title) ??
                              'Next: ${next.title}'),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.manaCyan,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
