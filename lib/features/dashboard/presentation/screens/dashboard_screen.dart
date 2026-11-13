import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:tutorsaas/core/utils/player_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/analytics/analytics_taxonomy.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../widgets/learning_path_roadmap.dart';
import '../widgets/continue_adventure_card.dart';
import '../widgets/dashboard_dock_item.dart';
import '../widgets/hunter_hud_header.dart';
import '../widgets/welcome_back_card.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Null-safe: algunos tests montan DashboardScreen sin Localizations.
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value ?? {};
    final cosmetics = ref.watch(equippedCosmeticsProvider);

    final isPremium = ref.watch(isPremiumProvider);
    // #417: disparador contextual de compra. Se muestra solo si hay margen
    // real de fricciÃƒÂ³n: plan gratuito y menos del 30 % del manÃƒÂ¡ diario.
    final manaState = ref.watch(manaStateProvider).value ?? const {};
    // El plan gratuito consume el cupo DIARIO (`daily_remaining`); `remaining`
    // es el saldo del ciclo y en free puede mostrar un valor alto que nunca se
    // gasta. Usar el campo correcto decide si la oferta aparece o no (#417).
    final manaRemaining = (manaState['daily_remaining'] as int?) ??
        (manaState['remaining'] as int?) ??
        0;
    final manaDailyLimit = (manaState['daily_limit'] as int?) ?? 200;
    final showManaUpsell =
        !isPremium &&
        manaDailyLimit > 0 &&
        manaRemaining < manaDailyLimit * 0.3;
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
          'language': 'InglÃƒÂ©s',
          'language_emoji': 'Ã°Å¸â€¡ÂºÃ°Å¸â€¡Â¸',
        };
    final String cefrCode = progress['level_code'] as String;

    // Issue #63: al abrirse el teclado el Scaffold encoge el body y el dock
    // flotante subÃƒÂ­a con ÃƒÂ©l, superponiÃƒÂ©ndose al contenido. Se oculta desplazÃƒÂ¡ndolo
    // fuera del ÃƒÂ¡rea visible (el Stack recorta con Clip.hardEdge).
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
                  // Top App Bar Ã¢â‚¬â€ identidad del cazador (avatar + nombre + nivel)
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
                  // Body with 4 Tabs (0: Dungeons, 1: GuildÃ¢â€ â€™/chat-rooms, 2: Status, 3: Config)
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

                                  // #312: la prÃƒÂ¡ctica es la acciÃƒÂ³n primaria, justo
                                  // debajo de la identidad y antes de cualquier
                                  // tarjeta secundaria.
                                  ContinueAdventureCard(
                                    levelCode:
                                        (progress['level_code'] as String?) ??
                                        '',
                                  ),

                                  const SizedBox(height: 12),

                                  // P-23 (#108): anillo de la meta diaria.
                                  // P-27 (#112): retorno tras inactividad.
                                  const WelcomeBackCard(),

                                  // #312: la meta diaria se moviÃƒÂ³ dentro de la
                                  // licencia del HUD (anillo compacto).

                                  // Issue #24: repaso espaciado (solo si hay palabras vencidas).
                                  const SrsReviewCard(),

                                  // Issue #109: mision del dia (1 principal + 2 secundarias).
                                  const MissionSpotlightWidget(),

                                  // Acceso a suscripciÃƒÂ³n (la racha vive en Estado, #80)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Premium status badge / Upgrade button
                                      SizedBox(
                                        height: 48,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            // #417: medir el embudo por origen.
                                            _trackUpgrade(ref, 'header');
                                            // Siempre navega: la pantalla de
                                            // suscripciÃƒÂ³n ya distingue premium
                                            // (gestionar) de no premium (comprar).
                                            context.push('/paywall');
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
                                                    : AppColors.royalGold,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                border: Border.all(
                                                  color: isPremium
                                                      ? AppColors.manaCyan
                                                      : AppColors.royalGold,
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
                                                        : AppColors.voidBg,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isPremium
                                                        ? '${l10n?.pro_badge ?? 'PRO'} Ã‚Â· ${l10n?.paywall_manage_subscription ?? 'GESTIONAR'}'
                                                        : (l10n?.go_pro ??
                                                              'PROBAR GRATIS'),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12,
                                                      letterSpacing: 0.4,
                                                      color: isPremium
                                                          ? AppColors.manaCyan
                                                          : AppColors.voidBg,
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

                                  // Accesos rÃƒÂ¡pidos del sistema
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
                                        label: l10n?.oracle ?? 'ORÃƒÂCULO',
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
                                        onTap: () => context.push('/my-errors'),
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

                                  // #417: oferta contextual en el momento de
                                  // fricciÃƒÂ³n (manÃƒÂ¡ bajo y plan gratuito).
                                  if (showManaUpsell) ...[
                                    _buildManaUpsellCard(context, l10n, ref),
                                    const SizedBox(height: 16),
                                  ],

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

            // Floating Bottom Navigation Bar (4 Items: Dungeons, GuildÃ¢â€ â€™/chat-rooms, Status, Config)
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
                  child: Semantics(
                    role: SemanticsRole.tabBar,
                    container: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DashboardDockItem(
                          icon: Icons.gps_fixed_rounded,
                          label: l10n?.dungeons ?? 'MAZMORRAS',
                          isActive: currentTab == 0,
                          onTap: () =>
                              ref.read(dashboardTabProvider.notifier).state = 0,
                        ),
                        DashboardDockItem(
                          icon: Icons.shield_rounded,
                          label: l10n?.guild ?? 'GUILD',
                          isActive: currentTab == 1,
                          onTap: () =>
                              ref.read(dashboardTabProvider.notifier).state = 1,
                        ),
                        DashboardDockItem(
                          icon: Icons.person_rounded,
                          label: l10n?.status ?? 'ESTADO',
                          isActive: currentTab == 2,
                          onTap: () =>
                              ref.read(dashboardTabProvider.notifier).state = 2,
                        ),
                        DashboardDockItem(
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
            ),
          ],
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
          l10n?.logout_confirm_title ?? 'Ã‚Â¿CERRAR SESIÃƒâ€œN?',
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n?.logout_confirm_desc ??
              'Tu progreso queda guardado. NecesitarÃƒÂ¡s volver a iniciar sesiÃƒÂ³n para continuar.',
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

  /// #417: medir el embudo de mejora de plan por origen.
  void _trackUpgrade(WidgetRef ref, String source) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    RetentionAnalytics.instance.track(
      user.id,
      AnalyticsEvent.upgradeCtaTapped,
      properties: {'source': source},
    );
  }

  /// #417: oferta contextual en el momento de fricciÃƒÂ³n (manÃƒÂ¡ bajo).
  /// El manÃƒÂ¡ ya estÃƒÂ¡ en el header; esto no lo repite, lo convierte en decisiÃƒÂ³n.
  Widget _buildManaUpsellCard(BuildContext context, AppLocalizations? l10n, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _trackUpgrade(ref, 'mana_card');
        context.push('/paywall');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.royalGold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.royalGold.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: AppColors.royalGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.mana_upsell_title ?? 'Te queda poco manÃƒÂ¡',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n?.mana_upsell_body ??
                        'Con un plan tendrÃƒÂ­as mucho mÃƒÂ¡s cada mes.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n?.mana_upsell_cta ?? 'VER PLANES',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.royalGold,
              ),
            ),
          ],
        ),
      ),
    );
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
