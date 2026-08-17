import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../conversation/presentation/providers/conversation_providers.dart';
import '../providers/dashboard_providers.dart';

/// Resumen post-sesión de conversación.
///
/// Diseño bento-grid compacto (MV-2026): un hero con el anillo principal,
/// una cuadrícula 2×2 de métricas pequeñas, barras segmentadas de habilidad
/// (HUD) y acciones discretas — todo con tokens de DS y radio estándar 4px.
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // ── Métricas dinámicas desde el estado de la conversación ────────────────
    final convState = ref.watch(conversationStateProvider);
    final messages = convState.messages;
    final userMsgs = messages.where((m) => m.sender == 'user').toList();
    final wordCount = userMsgs.fold(0, (sum, m) =>
        sum + m.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length);

    final double fluencyVal = userMsgs.isEmpty
        ? 0.85
        : math.min(0.98, math.max(0.70, 0.78 + (wordCount > 20 ? 0.15 : wordCount * 0.005)));
    final int fluencyPct = (fluencyVal * 100).round();

    final double pronVal = userMsgs.isEmpty
        ? 0.80
        : math.min(0.96, math.max(0.72, 0.75 + (userMsgs.length * 0.03)));
    final int pronPct = (pronVal * 100).round();

    final corrections = userMsgs
        .where((m) => m.originalText != null && m.originalText!.isNotEmpty)
        .toList();

    final int sessionSeconds =
        userMsgs.isEmpty ? 0 : math.max(60, userMsgs.length * 45);
    final int sessionMin = sessionSeconds ~/ 60;
    final int sessionSec = sessionSeconds % 60;
    final String durationLabel = sessionMin > 0
        ? '${sessionMin}m ${sessionSec.toString().padLeft(2, '0')}s'
        : '${sessionSec}s';

    final bool hasData = userMsgs.isNotEmpty;

    void goHome() {
      ref.read(dashboardRefreshProvider.notifier).state++;
      ref.invalidate(userProgressProvider);
      ref.invalidate(skillsRadarProvider);
      ref.invalidate(practiceHeatmapProvider);
      ref.invalidate(fluencyTrendsProvider);
      ref.invalidate(weeklyPracticeProvider);
      ref.invalidate(learnedVocabularyProvider);
      context.go('/home');
    }

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -160,
            left: -160,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            right: -160,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Cabecera compacta ──────────────────────────────────────
                  Row(
                    children: [
                      _RoundIconButton(icon: Icons.arrow_back_rounded, onTap: goHome),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.session_title,
                          style: AppTypography.title(context),
                        ),
                      ),
                      _StatusPill(label: l10n.session_completed, color: AppColors.runeViolet),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Hero: anillo principal + titular ──────────────────────
                  GlassCard(
                    blur: 16,
                    opacity: AppColors.glassOpacity,
                    borderColor: AppColors.manaCyan.withValues(alpha: 0.25),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _CompactRing(
                          value: fluencyVal,
                          color: AppColors.manaCyan,
                          size: 76,
                          label: '$fluencyPct%',
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.session_good_job,
                                style: AppTypography.subtitle(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasData
                                    ? l10n.session_words_spoken(wordCount)
                                    : l10n.session_ready,
                                style: AppTypography.bodyMuted(context),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _MiniTag(
                                    icon: Icons.record_voice_over_rounded,
                                    color: AppColors.runeViolet,
                                    text: '${userMsgs.length} turnos',
                                  ),
                                  _MiniTag(
                                    icon: Icons.check_circle_rounded,
                                    color: AppColors.emeraldGreen,
                                    text: '$pronPct% precisión',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Cuadrícula 2×2 de métricas compactas ──────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCell(
                          icon: Icons.timer_outlined,
                          color: AppColors.manaCyan,
                          value: durationLabel,
                          label: l10n.session_duration,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCell(
                          icon: Icons.abc_rounded,
                          color: AppColors.runeViolet,
                          value: '$wordCount',
                          label: l10n.session_words,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCell(
                          icon: Icons.gps_fixed_rounded,
                          color: AppColors.emeraldGreen,
                          value: '$pronPct%',
                          label: l10n.session_accuracy,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: _MetricCell(
                          icon: Icons.bolt_rounded,
                          color: AppColors.royalGold,
                          value: '+80',
                          label: 'XP',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Habilidades: barras segmentadas compactas ─────────────
                  GlassCard(
                    blur: 16,
                    opacity: AppColors.glassOpacity,
                    borderColor: AppColors.runeViolet.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _SkillBarRow(
                          icon: Icons.waves_rounded,
                          color: AppColors.manaCyan,
                          label: l10n.session_fluency,
                          value: fluencyVal,
                          percent: fluencyPct,
                        ),
                        const SizedBox(height: 14),
                        _SkillBarRow(
                          icon: Icons.record_voice_over_rounded,
                          color: AppColors.runeViolet,
                          label: l10n.session_pronunciation,
                          value: pronVal,
                          percent: pronPct,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Retroalimentación y correcciones ──────────────────────
                  Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.errorRed, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.session_feedback,
                        style: AppTypography.title(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (corrections.isEmpty)
                    _buildSummaryCorrectionCard(
                      context,
                      originalText: hasData
                          ? l10n.session_excellent_performance
                          : l10n.session_ready_first,
                      correctedText: hasData
                          ? l10n.session_no_errors
                          : l10n.session_talk_tutor,
                      category: l10n.session_performance,
                      tag: l10n.session_excellent,
                      accentColor: AppColors.manaCyan,
                    )
                  else
                    ...corrections.take(3).map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildSummaryCorrectionCard(
                            context,
                            originalText: c.originalText ?? c.text,
                            correctedText: c.text,
                            category: l10n.session_correction,
                            tag: c.correctionExplanation ?? l10n.session_grammar,
                            accentColor: AppColors.runeViolet,
                          ),
                        )),
                  const SizedBox(height: 24),

                  // ── Recompensas + acciones ─────────────────────────────────
                  GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    borderColor: AppColors.royalGold.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _RewardChip(
                              icon: Icons.star_rounded,
                              color: AppColors.runeViolet,
                              value: '+80 XP',
                              label: l10n.session_bonus,
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.onSurface.withValues(alpha: 0.10),
                            ),
                            _RewardChip(
                              icon: Icons.local_fire_department_rounded,
                              color: AppColors.guildAmber,
                              value: '+1 Racha',
                              label: l10n.session_maintained,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: AppColors.onSurface.withValues(alpha: 0.08),
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.menu_book_rounded, size: 16),
                                label: Text(l10n.summary_view_vocab),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.summary_vocab_saved)),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.runeViolet,
                                  side: BorderSide(
                                    color: AppColors.runeViolet.withValues(alpha: 0.35),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: Text(l10n.summary_done),
                                onPressed: goHome,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.runeViolet,
                                  foregroundColor: AppColors.onSurface,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCorrectionCard(
    BuildContext context, {
    required String originalText,
    required String correctedText,
    required String category,
    required String tag,
    required Color accentColor,
  }) {
    return GlassCard(
      blur: 14,
      opacity: AppColors.glassOpacity,
      borderColor: accentColor.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _RoundIconButton(icon: Icons.close_rounded, color: AppColors.errorRed, size: 24, iconSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  originalText,
                  style: AppTypography.bodyMuted(context).copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _RoundIconButton(icon: Icons.arrow_forward_rounded, color: AppColors.manaCyan, size: 24, iconSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  correctedText,
                  style: AppTypography.body(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  category,
                  style: AppTypography.tiny(context).copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  tag,
                  style: AppTypography.tiny(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets compactos ─────────────────────────────────────────────────────

/// Botón redondo compacto para cabeceras y chips.
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;

  const _RoundIconButton({
    required this.icon,
    this.onTap,
    this.size = 40,
    this.iconSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: AppColors.onSurface.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: color ?? AppColors.onSurface, size: iconSize),
          ),
        ),
      ),
    );
  }
}

/// Pill compacto de estado (p.ej. "SESIÓN COMPLETADA").
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.tiny(context).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Anillo compacto de progreso (hero).
class _CompactRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final String label;

  const _CompactRing({
    required this.value,
    required this.color,
    required this.size,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: NeonProgressPainter(progress: value, color: color),
        child: Center(
          child: Text(
            label,
            style: AppTypography.stat(context).copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Celda de métrica compacta (icono pequeño + valor + etiqueta).
class _MetricCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _MetricCell({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppRadius.sm,
      borderColor: color.withValues(alpha: 0.22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(context).copyWith(
                    color: AppColors.onSurface,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.tiny(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de habilidad con barra segmentada (HUD).
class _SkillBarRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double value;
  final int percent;

  const _SkillBarRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTypography.bodyMuted(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SegmentedBar(
            value: value,
            segments: 10,
            color: color,
            height: 5,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 38,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: AppTypography.stat(context).copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Chip compacto de recompensa.
class _RewardChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _RewardChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.subtitle(context).copyWith(fontSize: 15),
            ),
            Text(
              label,
              style: AppTypography.tiny(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// Mini etiqueta con icono (hero).
class _MiniTag extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _MiniTag({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.tiny(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Neon Glow Progress Arc
class NeonProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  NeonProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final basePaint = Paint()
      ..color = AppColors.onSurface.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
