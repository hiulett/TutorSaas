import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';

/// Coste de la siguiente ampliación (espeja `sanctuary_upgrade_cost` en SQL).
const List<int> _upgradeCosts = [150, 250, 400, 600];

/// Etapa del jardín según la racha (#380). Función pura para poder testearla.
/// Devuelve una de: `seed`, `sprout`, `plant`, `tree`.
String gardenStage(int days) {
  if (days >= 30) return 'tree';
  if (days >= 7) return 'plant';
  if (days >= 3) return 'sprout';
  return 'seed';
}

/// Santuario del cazador (#379): base persistente que crece pagando oro.
class SanctuaryScreen extends ConsumerStatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  ConsumerState<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends ConsumerState<SanctuaryScreen> {
  bool _busy = false;

  int? _costFor(int level) {
    if (level >= 5) return null;
    return _upgradeCosts[level - 1];
  }

  Future<void> _upgrade(int level) async {
    if (_busy) return;
    setState(() => _busy = true);
    final repo = ref.read(economyRepositoryProvider);
    final result = await repo.upgradeSanctuary('sanctuary:${level + 1}');
    if (!mounted) return;
    setState(() => _busy = false);

    final l10n = AppLocalizations.of(context)!;
    final ok = result != null && result['success'] == true;
    final reason = result?['reason']?.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (l10n.sanctuary_upgraded)
              : (reason == 'insufficient'
                    ? l10n.sanctuary_insufficient
                    : l10n.sanctuary_failed),
        ),
        backgroundColor: ok ? AppColors.emeraldGreen : AppColors.runeViolet,
      ),
    );
    if (ok) {
      ref.invalidate(sanctuaryProvider);
      ref.invalidate(economyWalletProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sanctuaryProvider);
    final data = state.value ?? const {'level': 1, 'slots': 3};
    final level = (data['level'] as num?)?.toInt() ?? 1;
    final slots = (data['slots'] as num?)?.toInt() ?? 3;
    final cost = _costFor(level);
    // #380: jardín (racha) y vitrina (reliquias ganadas, no compradas).
    final streak = ref.watch(streakProvider).value ?? const {};
    final streakDays = (streak['current_streak'] as num?)?.toInt() ?? 0;
    final inventory = ref.watch(inventoryProvider).value ?? const [];
    final relics = inventory
        .where((item) => (item['item_type'] ?? '') == 'relic')
        .toList();

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.onSurface,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        l10n.sanctuary_title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.voidBg.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.royalGold.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _stat(
                              l10n.sanctuary_level_label,
                              '$level',
                              AppColors.manaCyan,
                            ),
                            const SizedBox(height: 8),
                            _stat(
                              l10n.sanctuary_slots_label,
                              '$slots',
                              AppColors.emeraldGreen,
                            ),
                            if (cost != null) ...[
                              const SizedBox(height: 8),
                              _stat(
                                l10n.sanctuary_cost_label,
                                '$cost',
                                AppColors.royalGold,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _gardenCard(l10n, streakDays),
                      const SizedBox(height: 12),
                      _vitrineCard(l10n, relics),
                      const Spacer(),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.royalGold,
                            foregroundColor: AppColors.voidBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: cost == null || _busy
                              ? null
                              : () => _upgrade(level),
                          child: Text(
                            cost == null
                                ? l10n.sanctuary_max
                                : l10n.sanctuary_upgrade,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// #380: el jardín crece con la racha; no se compra, se gana.
  Widget _gardenCard(AppLocalizations l10n, int days) {
    final stage = gardenStage(days);
    final stageLabel = switch (stage) {
      'tree' => l10n.sanctuary_stage_tree,
      'plant' => l10n.sanctuary_stage_plant,
      'sprout' => l10n.sanctuary_stage_sprout,
      _ => l10n.sanctuary_stage_seed,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.voidBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.sanctuary_garden,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            '$stageLabel · $days',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.emeraldGreen,
            ),
          ),
        ],
      ),
    );
  }

  /// #380: la vitrina solo muestra reliquias ganadas, nunca compradas.
  Widget _vitrineCard(AppLocalizations l10n, List<Map<String, dynamic>> relics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.voidBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sanctuary_vitrine,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            relics.isEmpty
                ? l10n.sanctuary_vitrine_empty
                : relics.map((r) => r['item_code']).join(' · '),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: AppColors.manaCyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
