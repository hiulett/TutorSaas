import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/services/boss_exam_rules.dart';

/// P-31 (#116) — Barra de vida del jefe durante el examen de promoción.
///
/// Capa visual: la vida baja con cada respuesta del jugador (tope duro de
/// [BossExamRules.maxTurns]). No interviene en la evaluación, que es del
/// servidor.
class BossExamHealthBar extends StatelessWidget {
  const BossExamHealthBar({super.key, required this.turns});

  /// Respuestas enviadas por el jugador.
  final int turns;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final health = BossExamRules.bossHealthPercent(turns);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              size: 14,
              color: AppColors.hpBarRed,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l10n.boss_hud_title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              l10n.boss_hud_turns(turns, BossExamRules.maxTurns),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: health / 100,
            minHeight: 6,
            backgroundColor: AppColors.onSurface.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
              health > 50
                  ? AppColors.hpBarRed
                  : (health > 20
                        ? AppColors.royalGold
                        : AppColors.emeraldGreen),
            ),
          ),
        ),
      ],
    );
  }
}
