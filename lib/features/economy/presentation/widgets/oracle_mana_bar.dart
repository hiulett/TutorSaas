import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../providers/economy_providers.dart';

/// Panel de maná del Oráculo. Muestra dos barras:
///  1. MANÁ MENSUAL: minutos de audio IA consumidos del plan (30/300/1200 min).
///  2. USO DIARIO: invocaciones restantes hoy (base 20 + racha + consumibles
///     + bonus del plan).
class OracleManaBar extends ConsumerWidget {
  final bool showLabel;
  final bool compact;

  const OracleManaBar({super.key, this.showLabel = true, this.compact = false});

  String _formatMinutes(int seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Maná mensual (audio del plan)
    final monthlyAsync = ref.watch(monthlyManaProvider);
    final monthly = monthlyAsync.value ?? const {
      'usedSeconds': 0,
      'limitSeconds': 1800,
      'remainingSeconds': 1800,
      'planName': 'free',
    };
    final int usedSec = monthly['usedSeconds'] as int? ?? 0;
    final int limitSec = monthly['limitSeconds'] as int? ?? 1800;
    final int remainingSec = monthly['remainingSeconds'] as int? ?? 0;
    final double monthlyProgress =
        limitSec > 0 ? (remainingSec / limitSec).clamp(0.0, 1.0) : 0.0;
    final bool monthlyExhausted = remainingSec <= 0;

    // Maná diario (invocaciones)
    final manaAsync = ref.watch(oracleManaProvider);
    final mana = manaAsync.value ?? const {
      'manaMax': 20,
      'manaUsed': 0,
      'manaLeft': 20,
      'planBonus': 0,
    };
    final int manaMax = mana['manaMax'] as int? ?? 20;
    final int manaLeft = mana['manaLeft'] as int? ?? 0;
    final int planBonus = mana['planBonus'] as int? ?? 0;
    final double dailyProgress = manaMax > 0 ? (manaLeft / manaMax).clamp(0.0, 1.0) : 0.0;

    final double titleSize = compact ? 9 : 10;
    final double labelSize = compact ? 9 : 10;
    final double numSize = compact ? 10 : 11;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── MANÁ MENSUAL (minutos de audio del plan) ──
        if (showLabel) ...[
          Row(
            children: [
              const Icon(Icons.hourglass_bottom_rounded, color: AppColors.manaCyan, size: 13),
              const SizedBox(width: 6),
              Text(
                'MANÁ MENSUAL · AUDIO',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatMinutes(remainingSec)} / ${_formatMinutes(limitSec)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: numSize,
                  fontWeight: FontWeight.bold,
                  color: monthlyExhausted ? AppColors.crimsonRed : AppColors.manaCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        SegmentedBar(
          value: monthlyProgress,
          segments: compact ? 10 : 20,
          height: compact ? 5 : 7,
          color: monthlyExhausted ? AppColors.crimsonRed : AppColors.manaCyan,
        ),
        SizedBox(height: showLabel ? 10 : 6),

        // ── USO DIARIO (invocaciones del Núcleo Arcano) ──
        if (showLabel) ...[
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.runeViolet, size: 13),
              const SizedBox(width: 6),
              Text(
                'USO DIARIO · INVOCACIONES',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '$manaLeft/$manaMax',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: numSize,
                  fontWeight: FontWeight.bold,
                  color: manaLeft == 0 ? AppColors.crimsonRed : AppColors.runeViolet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        SegmentedBar(
          value: dailyProgress,
          segments: compact ? 10 : 20,
          height: compact ? 5 : 7,
          color: manaLeft == 0 ? AppColors.crimsonRed : AppColors.runeViolet,
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              AnimatedCounter(
                target: manaLeft,
                duration: const Duration(milliseconds: 600),
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: numSize,
                  color: AppColors.manaCyan,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'invocaciones restantes hoy',
                style: TextStyle(fontSize: labelSize, color: AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              if (planBonus > 0)
                Text(
                  '+$planBonus por plan',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: labelSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldGreen,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
