import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/services/sensory_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/daily_goal_progress.dart';
import '../providers/dashboard_providers.dart';

/// P-23 (#108): anillo de la meta diaria en Home.
///
/// - Minutos reales de hoy desde el servidor (`practice_sessions`).
/// - La meta sale de `user_settings.daily_goal_minutes`, así que editarla en
///   Ajustes se refleja al instante.
/// - Al cumplirla, el servidor concede la celebración una sola vez al día:
///   animación + háptica (el `claim` es idempotente).
class DailyGoalRingCard extends ConsumerStatefulWidget {
  const DailyGoalRingCard({super.key});

  @override
  ConsumerState<DailyGoalRingCard> createState() => _DailyGoalRingCardState();
}

class _DailyGoalRingCardState extends ConsumerState<DailyGoalRingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebration;
  late final Animation<double> _scale;

  bool _claiming = false;
  bool _celebratedNow = false;

  @override
  void initState() {
    super.initState();
    // Se crea en initState (no con `late` perezoso): si el widget se destruye
    // sin haber celebrado, `dispose()` no debe crear un Ticker.
    _celebration = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _celebration, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _celebration.dispose();
    super.dispose();
  }

  Future<void> _maybeCelebrate(DailyGoalProgress progress) async {
    if (!mounted || _claiming || !progress.canCelebrate) return;
    _claiming = true;
    final claimed = await ref.read(dailyGoalCelebrationProvider)();
    _claiming = false;
    if (!mounted) return;
    if (!claimed) {
      // Ya se celebró hoy (otro dispositivo o una visita anterior).
      ref.invalidate(dailyGoalProgressProvider);
      return;
    }
    setState(() => _celebratedNow = true);
    await ref.read(sensoryFeedbackProvider).fire(SensoryEvent.goalCompleted);
    _celebration.forward(from: 0);
    ref.invalidate(dailyGoalProgressProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(dailyGoalProgressProvider).value;
    if (progress == null) return const SizedBox.shrink();

    if (progress.canCelebrate) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeCelebrate(progress),
      );
    }

    final done = progress.goalCompleted;
    final accent = done ? AppColors.emeraldGreen : AppColors.manaCyan;
    final percent = (progress.ratio * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: accent.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Semantics(
                  label:
                      '${l10n?.daily_goal_title ?? 'META DIARIA'}: $percent%',
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: CircularProgressIndicator(
                            value: progress.ratio,
                            strokeWidth: 6,
                            backgroundColor: AppColors.onSurfaceVariant
                                .withValues(alpha: 0.18),
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                        Text(
                          '${progress.minutesToday}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.daily_goal_title ?? 'META DIARIA',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n?.daily_goal_minutes(
                              progress.minutesToday,
                              progress.goalMinutes,
                            ) ??
                            '${progress.minutesToday} / ${progress.goalMinutes} min',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        done
                            ? (l10n?.daily_goal_done ?? 'Meta cumplida')
                            : (l10n?.daily_goal_remaining(
                                    progress.remainingMinutes,
                                  ) ??
                                  'Faltan ${progress.remainingMinutes} min'),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress.streak > 0)
                  Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.royalGold,
                        size: 20,
                      ),
                      Text(
                        l10n?.daily_goal_streak(progress.streak) ??
                            '${progress.streak}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalGold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (_celebratedNow) ...[
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _scale,
                builder: (context, child) {
                  return Opacity(
                    opacity: _celebration.value.clamp(0, 1),
                    child: Transform.scale(scale: _scale.value, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.emeraldGreen),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.emeraldGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n?.daily_goal_celebrate ?? '¡META CUMPLIDA!',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: AppColors.emeraldGreen,
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
      ),
    );
  }
}
