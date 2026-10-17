import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../widgets/learning_path_roadmap.dart';
import '../widgets/hunter_hud_header.dart';
import '../widgets/progress_tab_view.dart';
import '../../../economy/presentation/widgets/daily_reward_modal.dart';
import 'settings_screen.dart';
import 'package:tutorsaas/features/chat_rooms/presentation/screens/chat_rooms_screen.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../../l10n/app_localizations.dart';





final dashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Null-safe: algunos tests montan DashboardScreen sin Localizations.
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value ?? {};
    final cosmetics = ref.watch(equippedCosmeticsProvider);

    final isPremium = ref.watch(isPremiumProvider);
    final gemsAsync = ref.watch(gemBalanceProvider);
    final gems = gemsAsync.value ?? 0;
    final dailyStateAsync = ref.watch(dailyStateProvider);
    final dailyClaimed = (dailyStateAsync.value?['daily_reward_claimed'] as bool?) ?? false;
    final progressAsync = ref.watch(userProgressProvider);
    final currentTab = ref.watch(dashboardTabProvider);
    // Issue #32: mientras carga no se inventan cifras (antes: 2450 XP, racha 7).
    final progress = progressAsync.value ?? {
      'xp': 0,
      'streak': 0,
      'level_code': 'A1',
      'level': 'Principiante',
      'language': 'Inglés',
      'language_emoji': '🇺🇸',
    };
    final int streak = progress['streak'] as int;
    final String cefrCode = progress['level_code'] as String;

    final completedLessonsAsync = ref.watch(completedLessonsProvider);
    final completedLessons = completedLessonsAsync.value ?? [];

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: currentTab == 2 ? CyberBgMode.hunterStatus : CyberBgMode.dashboardGate,
        child: Stack(
        children: [
          // 1. Decorative Glow Orbs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.08),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar — identidad del cazador (avatar + nombre + nivel)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            RpgAvatar(
                              avatarUrl: profile['avatar_url'] as String? ?? 'warrior',
                              hunterClass: profile['avatar_url'] as String? ?? 'warrior',
                              initials: _displayInitials(profile),
                              size: 32,
                              borderColor: cosmetics.frameCode != null
                                  ? frameCosmeticColor(cosmetics.frameCode)
                                  : AppColors.manaCyan,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (profile['display_name'] as String? ?? 'Hunter').toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    l10n?.cefr_level(cefrCode) ?? 'CEFR $cefrCode',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: AppColors.manaCyan.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: AppColors.onSurfaceVariant),
                        onPressed: () => _confirmLogout(context, ref),
                      ),
                    ],
                  ),
                ),
                // Body with 4 Tabs (0: Dungeons, 1: Guild→/chat-rooms, 2: Status, 3: Config)
                Expanded(
                  child: currentTab == 1
                      ? const ChatRoomsScreen(isTab: true)
                      : currentTab == 2
                          ? ProgressTabView(profile: profile, progress: progress)
                          : currentTab == 3
                              ? const SettingsScreen()
                              : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 12),

                                    // HUD Central del Cazador (paridad hunter_control_center_dashboard)
                                    const HunterHudHeader(),

                                    const SizedBox(height: 12),

                                    // Accesos rápidos: gemas, racha, premium
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Gems badge (taps to open shop)
                                        SizedBox(
                                          height: 48,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => context.push('/shop'),
                                            child: Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.manaCyan.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                                  border: Border.all(
                                                    color: AppColors.manaCyan.withValues(alpha: 0.4),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.diamond_rounded,
                                                      color: AppColors.manaCyan,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '$gems',
                                                      style: GoogleFonts.jetBrainsMono(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                        color: AppColors.onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Streak badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.onSurface.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(AppRadius.lg),
                                            border: Border.all(
                                              color: AppColors.onSurface.withValues(alpha: 0.1),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.local_fire_department_rounded,
                                                color: AppColors.royalGold,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$streak ${streak == 1 ? "DÍA" : "DÍAS"}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  letterSpacing: 1.0,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Premium status badge / Upgrade button
                                        SizedBox(
                                          height: 48,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              if (!isPremium) {
                                                context.push('/paywall');
                                              }
                                            },
                                            child: Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: isPremium
                                                      ? AppColors.manaCyan.withValues(alpha: 0.15)
                                                      : AppColors.runeViolet.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                                  border: Border.all(
                                                    color: isPremium ? AppColors.manaCyan : AppColors.runeViolet,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isPremium ? Icons.workspace_premium_rounded : Icons.star_border_rounded,
                                                      color: isPremium ? AppColors.manaCyan : AppColors.runeViolet,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      isPremium
                                                          ? (l10n?.pro_badge ?? 'PRO')
                                                          : (l10n?.go_pro ?? 'IR PRO'),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                        color: isPremium ? AppColors.manaCyan : AppColors.runeViolet,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Accesos rápidos del sistema
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildQuickAccess(
                                          icon: Icons.diamond_rounded,
                                          label: l10n?.shop ?? 'TIENDA',
                                          color: AppColors.runeViolet,
                                          onTap: () => context.push('/shop'),
                                        ),
                                        _buildQuickAccess(
                                          icon: Icons.auto_awesome_rounded,
                                          label: l10n?.oracle ?? 'ORÁCULO',
                                          color: AppColors.royalGold,
                                          onTap: () => context.push('/oracle-test'),
                                        ),
                                        _buildQuickAccess(
                                          icon: dailyClaimed ? Icons.check_circle_rounded : Icons.card_giftcard_rounded,
                                          label: dailyClaimed
                                              ? (l10n?.claimed ?? 'RECLAMADO')
                                              : (l10n?.daily ?? 'DAILY'),
                                          color: dailyClaimed ? AppColors.emeraldGreen : AppColors.royalGold,
                                          onTap: () => DailyRewardModal.show(context),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // 2. Ruta de Aprendizaje por Etapas (Roadmap Interactivo A1-C2)
                                    LearningPathRoadmap(
                                      activeUserLevel: cefrCode,
                                      completedLessonsHistory: completedLessons,
                                    ),

                                    const SizedBox(height: 28),


                                    const SizedBox(height: 100), // Spacing for bottom navigation
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),

          // Floating Bottom Navigation Bar (4 Items: Dungeons, Guild→/chat-rooms, Status, Config)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: GlassCard(
                blur: 30.0,
                opacity: AppColors.glassOpacity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.gps_fixed_rounded,
                      label: l10n?.dungeons ?? 'MAZMORRAS',
                      isActive: currentTab == 0,
                      onTap: () => ref.read(dashboardTabProvider.notifier).state = 0,
                    ),
                    _buildNavItem(
                      icon: Icons.shield_rounded,
                      label: l10n?.guild ?? 'GUILD',
                      isActive: currentTab == 1,
                      onTap: () => ref.read(dashboardTabProvider.notifier).state = 1,
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: l10n?.status ?? 'ESTADO',
                      isActive: currentTab == 2,
                      onTap: () => ref.read(dashboardTabProvider.notifier).state = 2,
                    ),
                    _buildNavItem(
                      icon: Icons.settings_rounded,
                      label: l10n?.config ?? 'CONFIG',
                      isActive: currentTab == 3,
                      onTap: () => ref.read(dashboardTabProvider.notifier).state = 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: isActive ? AppColors.manaCyan.withValues(alpha: 0.12) : Colors.transparent,
            border: Border(
              top: BorderSide(
                color: isActive ? AppColors.manaCyan : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.manaCyan : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.manaCyan : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDeep,
        title: Text(
          l10n?.logout_confirm_title ?? '¿CERRAR SESIÓN?',
          style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n?.logout_confirm_desc ??
              'Tu progreso queda guardado. Necesitarás volver a iniciar sesión para continuar.',
          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              (l10n?.cancel ?? 'Cancel').toUpperCase(),
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              (l10n?.logout ?? 'Log Out').toUpperCase(),
              style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go('/');
    }
  }

  String _displayInitials(Map<String, dynamic> profile) {
    final name = profile['display_name'] as String? ?? '';
    if (name.trim().isNotEmpty) return name.trim().substring(0, 1).toUpperCase();
    return 'H';
  }

  Widget _buildQuickAccess({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
