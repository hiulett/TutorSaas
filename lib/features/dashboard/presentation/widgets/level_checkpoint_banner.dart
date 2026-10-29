import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../boss_exam/data/boss_exam_service.dart';
import '../../../boss_exam/domain/models/boss_exam_status.dart';
import '../../../boss_exam/domain/services/level_checkpoint.dart';

/// P-43 (#128) — mini-chequeo periódico del nivel.
///
/// Cada ~10 lecciones superadas desde el último reto, el servidor marca
/// `check_due` y aquí se propone volver al examen del jefe. No es automático y
/// no gasta IA: reutiliza el `oracle_eval` que ya existe. Si el jefe no está
/// disponible (cooldown o requisitos), se explica en vez de abrir el examen.
class LevelCheckpointBanner extends ConsumerWidget {
  const LevelCheckpointBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(bossExamStatusProvider).value;
    if (status == null) return const SizedBox.shrink();

    final lessons = status.lessonsSinceLastCheck;
    final due = status.checkDue || LevelCheckpoint.isDue(lessons);
    if (!due) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    // Mismo criterio que la tarjeta del jefe (P-31): el examen solo se abre si
    // el servidor lo permite. Si está bloqueado o en cooldown, solo se explica.
    final canChallenge = status.isReady;

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      borderColor: AppColors.runeViolet.withValues(alpha: 0.6),
      showRunicCorners: true,
      runicColor: AppColors.runeViolet,
      padding: const EdgeInsets.all(16),
      onTap: canChallenge ? () => _openExam(context, status) : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.runeViolet.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.runeViolet),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.runeViolet,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.checkpoint_title ?? 'LEVEL CHECK',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.checkpoint_body(lessons) ??
                      'You completed $lessons lessons since your last challenge with the Oracle.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (canChallenge) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n?.checkpoint_action ?? 'CHALLENGE THE ORACLE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.runeViolet,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canChallenge)
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.runeViolet,
              size: 18,
            )
          else
            Icon(
              Icons.lock_rounded,
              size: 16,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }

  void _openExam(BuildContext context, BossExamStatus status) {
    final level = status.currentLevel.isEmpty ? 'A1' : status.currentLevel;
    context.push('/oracle-test?mode=promotion&level=$level');
  }
}
