import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../domain/models/aura_system.dart';
import '../providers/dashboard_providers.dart';

/// Widget compacto de estado del Aura para el HUD y la Status Window.
///
/// - Estado [AuraState.locked]: muestra el candado y el progreso de la
///   Etapa Básica (A1 + A2) hasta despertar.
/// - Estado [AuraState.awakened]: muestra el tier de poder y el medidor.
///
/// Los textos usan i18n cuando hay [AppLocalizations] disponible y caen a
/// literales cuando no (p. ej. en tests que montan el dashboard sin
/// localización, consistente con el resto del HUD).
class AuraHud extends ConsumerWidget {
  const AuraHud({super.key});

  /// Color del tier de poder del Aura (paleta actual del tema).
  static Color tierColor(AuraTier tier) {
    switch (tier) {
      case AuraTier.latente:
        return AppColors.manaCyan.withValues(alpha: 0.7);
      case AuraTier.revelada:
        return AppColors.manaCyan;
      case AuraTier.abierta:
        return AppColors.runeViolet;
      case AuraTier.dominante:
        return AppColors.royalGold;
      case AuraTier.abisal:
        return AppColors.emeraldGreen;
    }
  }

  /// Etiqueta i18n del tier de poder (fallback literal si no hay l10n).
  static String tierLabel(AppLocalizations? l10n, AuraTier tier) {
    switch (tier) {
      case AuraTier.latente:
        return l10n?.aura_tier_latente ?? 'LATENTE';
      case AuraTier.revelada:
        return l10n?.aura_tier_revelada ?? 'REVELADA';
      case AuraTier.abierta:
        return l10n?.aura_tier_abierta ?? 'ABIERTA';
      case AuraTier.dominante:
        return l10n?.aura_tier_dominante ?? 'DOMINANTE';
      case AuraTier.abisal:
        return l10n?.aura_tier_abisal ?? 'ABISAL';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final aura = ref.watch(auraStateProvider).value;
    if (aura == null) return const SizedBox.shrink();

    // El aura cosmética equipada (si existe) define el color del glow;
    // si no, se usa el color del tier de poder del Aura.
    final equippedAura = ref.watch(equippedCosmeticsProvider).auraCode;
    final Color? equippedAuraColor =
        equippedAura != null ? auraCosmeticColor(equippedAura) : null;

    return aura.isAwakened
        ? _buildAwakenedCard(ref, l10n, aura, equippedAuraColor: equippedAuraColor)
        : _buildLockedCard(l10n, aura);
  }

  Widget _buildLockedCard(AppLocalizations? l10n, AuraSnapshot aura) {
    return GlassCard(
      blur: 12,
      opacity: AppColors.glassOpacity,
      borderColor: AppColors.onSurface.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.onSurface.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.25)),
            ),
            child: Icon(Icons.lock_rounded, size: 18, color: AppColors.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        l10n?.aura_locked ?? 'AURA BLOQUEADA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n?.aura_basic_stage ?? 'ETAPA BÁSICA'} ${aura.basicObjectivesDone}/${aura.basicObjectivesTotal}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.manaCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Tooltip(
                  message: l10n?.aura_locked_tooltip ??
                      'ETAPA BÁSICA: completa los objetivos de las misiones PRE-A1, A1 y A2 para despertar tu Aura.',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: aura.basicStageProgress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: AppColors.onSurface.withValues(alpha: 0.10),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.manaCyan),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.aura_locked_desc ?? 'Supera la Etapa Básica (PRE-A1 + A1 + A2) para despertar tu poder.',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
                if (aura.hasRankMismatch) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n?.aura_rank_mismatch ?? '⚠ RANGO INCONSISTENTE CON CEFR',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalGold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwakenedCard(
    WidgetRef ref,
    AppLocalizations? l10n,
    AuraSnapshot aura, {
    Color? equippedAuraColor,
  }) {
    // Aura XP SIN tope (FASE B): mérito acumulado. El radar queda en su propio
    // widget (SkillsRadarChart); aquí solo se muestra la progresión de prestigio.
    final ladder = ref.watch(prestigeLadderProvider).value ?? const <Map<String, dynamic>>[];
    double progress = 0.0;
    if (ladder.isNotEmpty) {
      int cur = 0;
      int next = 0;
      for (final row in ladder) {
        final t = (row['aura_xp_threshold'] as num?)?.toInt() ?? 0;
        if (t <= aura.auraXp) {
          cur = t;
        } else {
          next = t;
          break;
        }
      }
      if (next > cur) {
        progress = ((aura.auraXp - cur) / (next - cur)).clamp(0.0, 1.0);
      }
    }

    // El aura cosmética equipada gana al color del tier (coherencia RPG).
    final color = equippedAuraColor ?? tierColor(aura.tier);
    final title = (aura.prestigeTitleName != null && aura.prestigeTitleName!.isNotEmpty)
        ? aura.prestigeTitleName!.toUpperCase()
        : (l10n?.aura_awakened ?? 'USUARIO DEL AURA');

    return GlassCard(
      blur: 14,
      opacity: AppColors.glassOpacity,
      borderColor: color.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
              ],
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.aura_xp(aura.auraXp) ?? 'AURA XP ${aura.auraXp}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Tooltip(
                  message: l10n?.aura_awakened_tooltip ??
                      'AURA: mérito sin tope. Sigue acumulando con cada sesión evaluada.',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: AppColors.onSurface.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.aura_next_rank((progress * 100).round()) ??
                      '${(progress * 100).round()}% al siguiente rango',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
                if (aura.hasRankMismatch) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n?.aura_rank_mismatch ?? '⚠ RANGO INCONSISTENTE CON CEFR',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalGold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
