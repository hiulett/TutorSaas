import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/boss_exam_service.dart';
import '../../domain/models/boss_exam_status.dart';

/// P-31 (#116) — Tarjeta del "Jefe de mazmorra" en la Ruta/Estado.
///
/// Muestra el estado real del examen de promoción: requisitos pendientes,
/// listo para retar, o cooldown tras un intento fallido. Cuando la RPC no
/// responde (offline, error), cae al cálculo local heredado del 80% de
/// lecciones para no cerrar la entrada al examen.
class BossExamCard extends ConsumerWidget {
  const BossExamCard({
    super.key,
    required this.level,
    required this.completedLessons,
    required this.totalLessons,
  });

  final String level;
  final int completedLessons;
  final int totalLessons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Null-safe: hay pantallas de test que montan la ruta sin delegates de
    // localización (igual que hacía la tarjeta anterior).
    final l10n = AppLocalizations.of(context);
    final asyncStatus = ref.watch(bossExamStatusProvider);
    final status = asyncStatus.value;
    final fallbackRatio = totalLessons > 0
        ? completedLessons / totalLessons
        : 0.0;

    final ready = status?.isReady ?? (fallbackRatio >= 0.80);
    final cooldown = status?.isOnCooldown ?? false;
    final accent = cooldown
        ? AppColors.runeViolet
        : (ready ? AppColors.royalGold : AppColors.onSurfaceVariant);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      border: Border.all(
        color: ready
            ? AppColors.royalGold
            : AppColors.onSurface.withValues(alpha: 0.1),
        width: ready ? 1.5 : 1,
      ),
      padding: const EdgeInsets.all(14),
      // GlassCard gana la arena de gestos: el tap va en su propio onTap.
      onTap: ready ? () => _openExam(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.2),
                  border: Border.all(color: accent),
                ),
                child: Icon(
                  cooldown
                      ? Icons.hourglass_top_rounded
                      : Icons.local_fire_department_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.boss_exam_title ?? 'JEFE DE MAZMORRA: EL ORÁCULO',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stateLine(l10n, status, ready, cooldown, fallbackRatio),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (ready)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.royalGold,
                  ),
                  onPressed: () => _openExam(context),
                )
              else
                Icon(
                  cooldown
                      ? Icons.hourglass_bottom_rounded
                      : Icons.lock_rounded,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 18,
                ),
            ],
          ),
          if (status != null && status.requirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...status.requirements.map(
              (requirement) => _RequirementRow(
                label: _requirementLabel(l10n, requirement.id),
                met: requirement.met,
                progress: requirement.progress,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openExam(BuildContext context) {
    context.push('/oracle-test?mode=promotion&level=$level');
  }

  String _stateLine(
    AppLocalizations? l10n,
    BossExamStatus? status,
    bool ready,
    bool cooldown,
    double fallbackRatio,
  ) {
    if (cooldown) {
      final until = status?.cooldownUntil;
      if (until != null) {
        final time = _formatDate(until);
        return l10n?.boss_exam_state_cooldown(time) ??
            'El jefe descansa hasta $time.';
      }
      return l10n?.boss_exam_state_locked ??
          'Cumple los requisitos para retar al jefe.';
    }
    if (ready) {
      return l10n?.boss_exam_state_ready ??
          'El jefe te espera. ¡Reto disponible!';
    }
    final pct = (fallbackRatio * 100).round();
    if (status == null) {
      return l10n?.boss_exam_state_locked_progress(pct) ??
          'Completa el 80% de las lecciones del nivel ($pct%)';
    }
    return l10n?.boss_exam_state_locked ??
        'Cumple los requisitos para retar al jefe.';
  }

  String _requirementLabel(AppLocalizations? l10n, String id) {
    switch (id) {
      case 'level':
        return l10n?.boss_req_level ?? 'Nivel asignado';
      case 'practice':
        return l10n?.boss_req_practice ?? 'Práctica: metas, racha o minutos';
      case 'cooldown':
        return l10n?.boss_req_cooldown ?? 'Espera entre intentos';
      default:
        return id;
    }
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)} ${two(date.hour)}:${two(date.minute)}';
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.label,
    required this.met,
    required this.progress,
  });

  final String label;
  final bool met;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.emeraldGreen : AppColors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: color),
            ),
          ),
          if (!met)
            SizedBox(
              width: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.onSurface.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.manaCyan,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
