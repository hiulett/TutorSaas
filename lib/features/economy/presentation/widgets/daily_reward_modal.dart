import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/system_window.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/economy_providers.dart';

/// Modal de Recompensa Diaria (T-503).
/// Muestra la racha actual, la recompensa escalonada y permite reclamarla.
class DailyRewardModal extends ConsumerStatefulWidget {
  const DailyRewardModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DailyRewardModal(),
    );
  }

  @override
  ConsumerState<DailyRewardModal> createState() => _DailyRewardModalState();
}

class _DailyRewardModalState extends ConsumerState<DailyRewardModal> {
  bool _isClaiming = false;
  bool _claimed = false;

  Future<void> _claim() async {
    setState(() => _isClaiming = true);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final ok = await ref.read(economyRepositoryProvider).claimDailyReward(user.id);
      if (ok) {
        ref.invalidate(dailyStateProvider);
        ref.invalidate(streakProvider);
        ref.invalidate(gemBalanceProvider);
        if (mounted) setState(() => _claimed = true);
      }
    }
    if (mounted) setState(() => _isClaiming = false);
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(streakProvider);
    final dailyAsync = ref.watch(dailyStateProvider);
    final streak = streakAsync.value?['current_streak'] as int? ?? 0;
    final alreadyClaimed = (dailyAsync.value?['daily_reward_claimed'] as bool?) ?? false;

    final (int gems, int pergaminos) = switch (streak) {
      >= 30 => (300, 15),
      >= 14 => (100, 8),
      >= 7 => (50, 5),
      _ => (5, 2),
    };

    final effectiveClaimed = _claimed || alreadyClaimed;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SystemWindow(
        title: 'RECOMPENSA DIARIA',
        subtitle: 'RACHA ACTUAL: $streak DÍAS',
        icon: Icons.card_giftcard_rounded,
        accentColor: AppColors.royalGold,
        showCloseButton: true,
        onClose: () => Navigator.pop(context),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Streak indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.royalGold, size: 28),
                const SizedBox(width: 8),
                Text(
                  '$streak',
                  style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                ),
                const SizedBox(width: 4),
                Text(
                  'DÍAS',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.onSurfaceVariant, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reward preview
            Row(
              children: [
                Expanded(
                  child: _RewardTile(icon: Icons.diamond_rounded, color: AppColors.manaCyan, value: '$gems GEMAS', label: 'POR RACHA'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RewardTile(icon: Icons.menu_book_rounded, color: AppColors.runeViolet, value: '+$pergaminos PERGAMINOS', label: 'TETO DIARIO'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Next tier hint
            Text(
              streak < 7
                  ? 'MANTÉN TU RACHA: A LOS 7 DÍAS GANAS 50 GEMAS Y 5 PERGAMINOS'
                  : streak < 14
                      ? 'A LOS 14 DÍAS: 100 GEMAS Y 8 PERGAMINOS'
                      : streak < 30
                          ? 'A LOS 30 DÍAS: 300 GEMAS Y 15 PERGAMINOS'
                          : '¡RACHA MÁXIMA ALCANZADA!',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 0.5,
                color: AppColors.royalGold.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: (effectiveClaimed || _isClaiming) ? null : _claim,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveClaimed ? AppColors.onSurface.withValues(alpha: 0.12) : AppColors.royalGold,
                foregroundColor: effectiveClaimed ? AppColors.onSurface.withValues(alpha: 0.54) : AppColors.voidBg,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                _isClaiming
                    ? 'RECLAMANDO…'
                    : effectiveClaimed
                        ? 'RECOMPENSA RECLAMADA HOY'
                        : 'RECLAMAR RECOMPENSA',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _RewardTile({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
