import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/floating_reward.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../data/models/hunter_catalog.dart';

/// HUD central del dashboard (paridad con PlantillaHtml/hunter_control_center_dashboard).
/// Muestra: avatar + nombre + título, mana gem, barra XP segmentada (CEFR) y
/// notificaciones de misiones/racha. Reutiliza widgets core (GlassCard,
/// SegmentedBar, AnimatedCounter, RpgAvatar) y tipografía estándar.
class HunterHudHeader extends ConsumerStatefulWidget {
  const HunterHudHeader({super.key});

  @override
  ConsumerState<HunterHudHeader> createState() => _HunterHudHeaderState();
}

class _HunterHudHeaderState extends ConsumerState<HunterHudHeader> {
  static const int _xpPerLevel = 1000;
  int _lastLevel = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider).value ?? {};
    final progress = ref.watch(userProgressProvider).value ?? {};

    final String displayName = profile['display_name'] as String? ??
        user?.userMetadata?['full_name'] ??
        user?.email?.split('@').first ??
        'Hunter';
    final String avatarUrl = profile['avatar_url'] as String? ?? 'warrior';
    final String cefrCode = progress['level_code'] as String? ?? 'A1';
    final int xp = progress['xp'] as int? ?? 0;
    final int streak = progress['streak'] as int? ?? 0;
    final String languageEmoji = progress['language_emoji'] as String? ?? '🇺🇸';

    // Núcleo Arcano: métrica única de energía (UX-05).
    final dailyState = ref.watch(dailyStateProvider).value ?? {};
    final int energyUsed = (dailyState['invocations_used'] as num?)?.toInt() ?? 0;
    final int energyMax = (dailyState['invocations_max'] as num?)?.toInt() ?? 20;
    final int energyLeft = (energyMax - energyUsed).clamp(0, energyMax);

    final String equippedTitleCode =
        progress['equipped_title_code'] as String? ?? 'oido_halcon_abismo_c';
    final activeTitle = HunterCatalog.titles.firstWhere(
      (t) => t.code == equippedTitleCode,
      orElse: () => HunterCatalog.titles.first,
    );

    // Mana gem: energía de práctica diaria (invocaciones restantes).
    final double levelProgress = (xp % _xpPerLevel) / _xpPerLevel;

    // Detección de subida de nivel (AN-E): muestra recompensa flotante.
    final currentLevel = xp ~/ _xpPerLevel;
    if (currentLevel > _lastLevel && _lastLevel >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FloatingReward.show(
            context,
            '¡SUBIDA DE NIVEL! $currentLevel',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.royalGold,
          );
        }
      });
    }
    _lastLevel = currentLevel;

    return GlassCard(
      borderColor: AppColors.manaCyan.withValues(alpha: 0.35),
      showRunicCorners: true,
      runicColor: AppColors.manaCyan,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RpgAvatar(
                avatarUrl: avatarUrl,
                initials: displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'H',
                size: 52,
                hunterClass: avatarUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${activeTitle.name.toUpperCase()} · $languageEmoji',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.royalGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Núcleo Arcano (energía — UX-05, métrica única)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.runeViolet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.runeViolet, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'NÚCLEO $energyLeft/$energyMax',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barra XP segmentada + contador
          Row(
            children: [
              Expanded(
                child: SegmentedBar(
                  value: levelProgress.clamp(0.0, 1.0),
                  segments: 10,
                  height: 6,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedCounter(
                target: xp,
                duration: const Duration(milliseconds: 600),
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.manaCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.royalGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'CEFR $cefrCode',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalGold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🔥 RACHA $streak DÍAS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: streak > 0 ? AppColors.royalGold : AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Notificaciones → acceso a misiones/estado
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onSurfaceVariant, size: 20),
                tooltip: 'Notificaciones',
                onPressed: () => context.push('/hunter-status'),
              ),
              IconButton(
                icon: const Icon(Icons.flag_rounded, color: AppColors.emeraldGreen, size: 20),
                tooltip: 'Misiones',
                onPressed: () => context.push('/hunter-status'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'SISTEMA DE CAZADOR — CONECTADO',
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              letterSpacing: 2,
              color: AppColors.manaCyan.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
