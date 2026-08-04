import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../providers/economy_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Battle Pass del Gremio (T-502).
/// Muestra nivel, progreso XP, recompensas por tier (reclamables) y estado
/// premium/free.
class BattlePassScreen extends ConsumerStatefulWidget {
  const BattlePassScreen({super.key});

  @override
  ConsumerState<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends ConsumerState<BattlePassScreen> {
  static const int _maxTiers = 10;
  static const int _xpPerLevel = 1000;

  Future<void> _claim(int tier) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final ok = await ref.read(economyRepositoryProvider).claimBattlePassReward(user.id, tier);
    ref.invalidate(battlePassProvider);
    if (mounted) {
      SystemSnack.show(
        context,
        ok ? 'RECOMPENSA TIER $tier RECLAMADA' : 'NO DISPONIBLE',
        type: ok ? SystemSnackType.reward : SystemSnackType.error,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bpAsync = ref.watch(battlePassProvider);
    final bp = bpAsync.value ?? {};

    final level = (bp['level'] as num?)?.toInt() ?? 1;
    final progress = (bp['xp_progress'] as num?)?.toInt() ?? 0;
    final isPremium = bp['is_premium'] as bool? ?? false;
    final claimed = List<String>.from((bp['claimed_rewards'] as List? ?? const <String>[]));

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.dashboardGate,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                      tooltip: 'Volver',
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'BATTLE PASS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isPremium ? AppColors.royalGold : AppColors.manaCyan).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isPremium ? AppColors.royalGold : AppColors.manaCyan),
                      ),
                      child: Text(
                        isPremium ? 'PREMIUM' : 'GRATUITO',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isPremium ? AppColors.royalGold : AppColors.manaCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: bpAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.royalGold)),
                  error: (_, __) => Center(child: Text(l10n.battlepass_load_error, style: TextStyle(color: AppColors.onSurfaceVariant))),
                  data: (_) => ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Nivel y progreso
                      GlassCard(
                        borderColor: AppColors.royalGold.withValues(alpha: 0.5),
                        showRunicCorners: true,
                        runicColor: AppColors.royalGold,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Text(
                              'NIVEL $level',
                              style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                            ),
                            const SizedBox(height: 10),
                            Semantics(
                              label: 'Progreso del Pase de Batalla: '
                                  '${((progress / _xpPerLevel) * 100).round()} por ciento',
                              child: SegmentedBar(
                                value: (progress / _xpPerLevel).clamp(0.0, 1.0),
                                segments: 10,
                                height: 8,
                                color: AppColors.royalGold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$progress / $_xpPerLevel XP',
                              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.royalGold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tiers de recompensas
                      Text(
                        'RECOMPENSAS',
                        style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface, letterSpacing: 1),
                      ),
                      const SizedBox(height: 10),
                      for (int tier = 1; tier <= _maxTiers; tier++)
                        _buildTierRow(tier, level, claimed),
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

  Widget _buildTierRow(int tier, int level, List<String> claimed) {
    final l10n = AppLocalizations.of(context)!;
    final unlocked = tier <= level;
    final isClaimed = claimed.contains('tier_$tier');
    final color = tier % 3 == 0 ? AppColors.royalGold : (tier % 2 == 0 ? AppColors.manaCyan : AppColors.runeViolet);

    return Semantics(
      label: isClaimed
          ? 'Recompensa nivel $tier reclamada'
          : unlocked
              ? 'Recompensa nivel $tier desbloqueada'
              : 'Recompensa nivel $tier bloqueada, desbloquea en nivel $tier',
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          border: Border.all(color: (unlocked ? color : AppColors.onSurface.withValues(alpha: 0.12)).withValues(alpha: unlocked ? 0.5 : 0.2)),
          opacity: unlocked ? 0.1 : 0.03,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: unlocked ? 0.15 : 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: unlocked ? 0.6 : 0.2)),
                  ),
                  child: Icon(
                    isClaimed ? Icons.check_rounded : (unlocked ? Icons.card_giftcard_rounded : Icons.lock_rounded),
                    color: isClaimed ? AppColors.emeraldGreen : (unlocked ? color : AppColors.onSurface.withValues(alpha: 0.6)),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIER $tier',
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    Text(
                      unlocked ? 'Recompensa desbloqueada' : 'Desbloquea en nivel $tier',
                      style: GoogleFonts.jetBrainsMono(fontSize: 9, color: unlocked ? AppColors.onSurfaceVariant : AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              if (unlocked && !isClaimed)
                Semantics(
                  button: true,
                  label: 'Reclamar recompensa nivel $tier',
                  child: ElevatedButton(
                    onPressed: () => _claim(tier),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: AppColors.voidBg,
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(l10n.mission_claim, style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
