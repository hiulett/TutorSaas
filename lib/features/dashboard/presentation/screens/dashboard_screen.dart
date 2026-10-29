import 'package:flutter/material.dart';
import 'package:tutorsaas/core/utils/player_identity.dart';
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
import '../widgets/daily_goal_ring_card.dart';
import '../widgets/welcome_back_card.dart';
import '../../data/models/lesson_catalog.dart';
import '../../domain/models/lesson_unlock_service.dart';
import '../widgets/progress_tab_view.dart';
import '../../../economy/presentation/widgets/daily_reward_modal.dart';
import '../../../vocabulary/presentation/widgets/srs_review_card.dart';
import '../../../missions/presentation/widgets/mission_spotlight_widget.dart';
import 'settings_screen.dart';
import 'package:tutorsaas/features/chat_rooms/presentation/screens/chat_rooms_screen.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../../l10n/app_localizations.dart';

final dashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// Issue #22: acción principal del dashboard.
  ///
  /// Antes, el único punto de entrada a la práctica era un nodo dentro del
  /// roadmap, por debajo de insignias y accesos rápidos. Ahora hay una CTA
  /// explícita que inicia la siguiente lección pendiente del nivel del usuario.
  Widget _buildPrimaryCta(
    BuildContext context,
    WidgetRef ref,
    String cefrCode,
  ) {
    final goalRows =
        ref.watch(completedGoalsProvider).value ??
        const <Map<String, dynamic>>[];
    final lesson = _nextLesson(cefrCode, goalRows);
    if (lesson == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        borderColor: AppColors.manaCyan.withValues(alpha: 0.35),
        showRunicCorners: true,
        runicColor: AppColors.manaCyan,
        onTap: () => context.push(
          '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}',
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.manaCyan.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: AppColors.manaCyan,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTINUAR AVENTURA',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.manaCyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lesson.level} · ${lesson.goals.length} objetivos',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.manaCyan,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Primera lección disponible del nivel; si ya están todas superadas,
  /// devuelve la primera como repaso.
  LessonData? _nextLesson(String level, List<Map<String, dynamic>> goalRows) {
    final normalized = level.toUpperCase();
    final lessons = LessonCatalog.catalog
        .where((l) => l.level.toUpperCase() == normalized)
        .toList();
    if (lessons.isEmpty) return null;

    for (final lesson in lessons) {
      final state = LessonUnlockService.classify(
        lesson: lesson,
        userCefr: normalized,
        goalRows: goalRows,
        catalog: LessonCatalog.catalog,
      );
      if (state == LessonUnlockState.nextAvailable) return lesson;
    }
    return lessons.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Null-safe: algunos tests montan DashboardScreen sin Localizations.
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value ?? {};
    final cosmetics = ref.watch(equippedCosmeticsProvider);

    final isPremium = ref.watch(isPremiumProvider);
    final dailyStateAsync = ref.watch(dailyStateProvider);
    final dailyClaimed =
        (dailyStateAsync.value?['daily_reward_claimed'] as bool?) ?? false;
    final progressAsync = ref.watch(userProgressProvider);
    final offlineProgress = ref.watch(progressOfflineProvider);
    final progressCachedAt = ref.watch(progressCachedAtProvider);
    final currentTab = ref.watch(dashboardTabProvider);
    // Issue #32: mientras carga no se inventan cifras (antes: 2450 XP, racha 7).
    final progress =
        progressAsync.value ??
        {
          'xp': 0,
          'streak': 0,
          'level_code': 'A1',
          'level': 'Principiante',
          'language': 'Inglés',
          'language_emoji': '🇺🇸',
        };
    final String cefrCode = progress['level_code'] as String;

    // Issue #63: al abrirse el teclado el Scaffold encoge el body y el dock
    // flotante subía con él, superponiéndose al contenido. Se oculta desplazándolo
    // fuera del área visible (el Stack recorta con Clip.hardEdge).
    final bool isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    final completedLessonsAsync = ref.watch(completedLessonsProvider);
    final completedLessons = completedLessonsAsync.value ?? [];

    // P-19: sin cache y sin red no se pinta un dashboard con ceros.
    if (progressAsync.hasError && !progressAsync.hasValue) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.dashboard_offline ??
                        'Sin conexion. Mostrando el ultimo progreso guardado.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(userProgressProvider),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(l10n?.retry ?? 'REINTENTAR'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: currentTab == 2
            ? CyberBgMode.hunterStatus
            : CyberBgMode.dashboardGate,
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
                  if (offlineProgress)
                    Container(
                      width: double.infinity,
                      color: AppColors.royalGold.withValues(alpha: 0.14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: AppColors.royalGold,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _offlineProgressLabel(l10n, progressCachedAt),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.royalGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Top App Bar — identidad del cazador (avatar + nombre + nivel)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
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
                                  avatarUrl: playerAvatarUrlOf(profile),
                                  hunterClass: playerClassOf(profile),
                                  initials: _displayInitials(profile),
                                  size: 32,
                                  borderColor: cosmetics.frameCode != null
                                      ? frameCosmeticColor(cosmetics.frameCode)
                                      : AppColors.manaCyan,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        (profile['display_name'] as String? ??
                                                'Hunter')
                                            .toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.onSurface,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Text(
                                        l10n?.cefr_level(cefrCode) ??
                                            'CEFR $cefrCode',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                          color: AppColors.manaCyan.withValues(
                                            alpha: 0.8,
                                          ),
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
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.onSurfaceVariant,
                          ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 12),

                                  // HUD Central del Cazador (paridad hunter_control_center_dashboard)
                                  const HunterHudHeader(),

                                  const SizedBox(height: 12),

                                  // P-23 (#108): anillo de la meta diaria.
                                  // P-27 (#112): retorno tras inactividad.
                                  const WelcomeBackCard(),

                                  const DailyGoalRingCard(),

                                  // Issue #24: repaso espaciado (solo si hay palabras vencidas).
                                  const SrsReviewCard(),

                                  // Issue #109: mision del dia (1 principal + 2 secundarias).
                                  const MissionSpotlightWidget(),

                                  // Acceso a suscripción (la racha vive en Estado, #80)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isPremium
                                                    ? AppColors.manaCyan
                                                          .withValues(
                                                            alpha: 0.15,
                                                          )
                                                    : AppColors.runeViolet
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                border: Border.all(
                                                  color: isPremium
                                                      ? AppColors.manaCyan
                                                      : AppColors.runeViolet,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isPremium
                                                        ? Icons
                                                              .workspace_premium_rounded
                                                        : Icons
                                                              .star_border_rounded,
                                                    color: isPremium
                                                        ? AppColors.manaCyan
                                                        : AppColors.runeViolet,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isPremium
                                                        ? (l10n?.pro_badge ??
                                                              'PRO')
                                                        : (l10n?.go_pro ??
                                                              'IR PRO'),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11,
                                                      color: isPremium
                                                          ? AppColors.manaCyan
                                                          : AppColors
                                                                .runeViolet,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
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
                                        onTap: () =>
                                            context.push('/oracle-test'),
                                      ),
                                      _buildQuickAccess(
                                        icon: dailyClaimed
                                            ? Icons.check_circle_rounded
                                            : Icons.card_giftcard_rounded,
                                        label: dailyClaimed
                                            ? (l10n?.claimed ?? 'RECLAMADO')
                                            : (l10n?.daily ?? 'DAILY'),
                                        color: dailyClaimed
                                            ? AppColors.emeraldGreen
                                            : AppColors.royalGold,
                                        onTap: () =>
                                            DailyRewardModal.show(context),
                                      ),
                                      // P-29: historial de errores propios.
                                      _buildQuickAccess(
                                        icon: Icons.spellcheck_rounded,
                                        label:
                                            l10n?.my_errors_short ?? 'ERRORES',
                                        color: AppColors.emeraldGreen,
                                        onTap: () =>
                                            context.push('/my-errors'),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Issue #22: CTA principal de práctica.
                                  _buildPrimaryCta(context, ref, cefrCode),

                                  // 2. Ruta de Aprendizaje por Etapas (Roadmap Interactivo A1-C2)
                                  LearningPathRoadmap(
                                    activeUserLevel: cefrCode,
                                    completedLessonsHistory: completedLessons,
                                  ),

                                  const SizedBox(height: 28),

                                  const SizedBox(
                                    height: 100,
                                  ), // Spacing for bottom navigation
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
              bottom: isKeyboardOpen ? -160 : 24,
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
                        onTap: () =>
                            ref.read(dashboardTabProvider.notifier).state = 0,
                      ),
                      _buildNavItem(
                        icon: Icons.shield_rounded,
                        label: l10n?.guild ?? 'GUILD',
                        isActive: currentTab == 1,
                        onTap: () =>
                            ref.read(dashboardTabProvider.notifier).state = 1,
                      ),
                      _buildNavItem(
                        icon: Icons.person_rounded,
                        label: l10n?.status ?? 'ESTADO',
                        isActive: currentTab == 2,
                        onTap: () =>
                            ref.read(dashboardTabProvider.notifier).state = 2,
                      ),
                      _buildNavItem(
                        icon: Icons.settings_rounded,
                        label: l10n?.config ?? 'CONFIG',
                        isActive: currentTab == 3,
                        onTap: () =>
                            ref.read(dashboardTabProvider.notifier).state = 3,
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
            color: isActive
                ? AppColors.manaCyan.withValues(alpha: 0.12)
                : Colors.transparent,
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
                color: isActive
                    ? AppColors.manaCyan
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
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
                  color: isActive
                      ? AppColors.manaCyan
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
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
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n?.logout_confirm_desc ??
              'Tu progreso queda guardado. Necesitarás volver a iniciar sesión para continuar.',
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
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
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
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
    if (name.trim().isNotEmpty)
      return name.trim().substring(0, 1).toUpperCase();
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

/// P-19: texto del banner de sin conexion, con la antiguedad de la cache.
String _offlineProgressLabel(AppLocalizations? l10n, DateTime? cachedAt) {
  final fallback =
      l10n?.dashboard_offline ??
      'Sin conexion. Mostrando el ultimo progreso guardado.';
  if (cachedAt == null) return fallback;
  final minutes = DateTime.now().difference(cachedAt).inMinutes;
  if (minutes < 1) return fallback;
  return l10n?.dashboard_offline_age(minutes) ??
      'Sin conexion. Ultimo progreso hace $minutes min.';
}
