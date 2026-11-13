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
