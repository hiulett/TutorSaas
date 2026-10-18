import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';

/// Barra única de MANÁ (FASE B).
///
/// Saldo = asignación mensual del plan + maná comprado (porciones/gemas) − usado.
/// Toda acción IA descuenta el costo configurable (ai_action_costs); nada se
/// gana jugando. Se recarga al renovar el ciclo (expira en `expires_at`).
///
/// En el plan GRATUITO la barra refleja el MANÁ DIARIO (daily_limit=200):
/// el consumo de lecciones descuenta `daily_used` y la barra muestra lo que
/// queda del día, reiniciando cada día.
class OracleManaBar extends ConsumerWidget {
  final bool showLabel;
  final bool compact;

  const OracleManaBar({super.key, this.showLabel = true, this.compact = false});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final manaAsync = ref.watch(manaStateProvider);
    final mana = manaAsync.value ?? const {
      'allowance': 1800,
      'purchased': 0,
      'used': 0,
      'remaining': 1800,
      'expires_at': null,
      'plan': 'Plan Gratuito',
      'is_free': true,
      'daily_limit': 200,
      'daily_used': 0,
      'daily_remaining': 200,
    };
    final bool isFree = mana['is_free'] as bool? ?? true;
    final int allowance = mana['allowance'] as int? ?? 1800;
    final int purchased = mana['purchased'] as int? ?? 0;
    final int remaining = mana['remaining'] as int? ?? 0;
    final int available = allowance + purchased;

    // Maná diario (plan free): tope diario y lo que queda hoy.
    final int dailyLimit = mana['daily_limit'] as int? ?? 200;
    final int dailyRemaining = mana['daily_remaining'] as int? ?? 0;

    final DateTime? expiresAt = mana['expires_at'] is String
        ? DateTime.tryParse(mana['expires_at'] as String)
        : null;

    // Qué muestra la barra según el plan:
    //   free  → maná diario (dailyRemaining/dailyLimit), se recarga cada día.
    //   pago  → saldo mensual (remaining/available), se recarga al renovar.
    final int barValue = isFree ? dailyRemaining : remaining;
    final int barMax = isFree ? dailyLimit : available;
    final double progress = barMax > 0 ? (barValue / barMax).clamp(0.0, 1.0) : 0.0;
    final bool exhausted = barValue <= 0;

    final double titleSize = compact ? 9 : 10;
    final double numSize = compact ? 10 : 11;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.runeViolet, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n?.mana_label ?? 'MANÁ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$barValue / $barMax',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: numSize,
                  fontWeight: FontWeight.bold,
                  color: exhausted ? AppColors.crimsonRed : AppColors.runeViolet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Tooltip(
          message: l10n?.mana_tooltip ??
              'MANÁ: energía para toda acción IA (Oráculo, mazmorras, chats). '
                  'Se adquiere con tu plan y porciones/gemas; expira con el ciclo.',
          child: SegmentedBar(
            value: progress,
            segments: compact ? 10 : 20,
            height: compact ? 5 : 7,
            color: exhausted ? AppColors.crimsonRed : AppColors.runeViolet,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              AnimatedCounter(
                target: barValue,
                duration: const Duration(milliseconds: 600),
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: numSize,
                  color: AppColors.manaCyan,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  isFree
                      ? (l10n?.mana_daily_available ?? 'maná disponible hoy')
                      : (l10n?.mana_available ?? 'maná disponible'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: titleSize, color: AppColors.onSurfaceVariant),
                ),
              ),
              if (!isFree && expiresAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  l10n?.mana_expires(_formatDate(expiresAt)) ??
                      'expira ${_formatDate(expiresAt)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
