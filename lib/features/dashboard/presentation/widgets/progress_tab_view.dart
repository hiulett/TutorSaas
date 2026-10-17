import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../providers/dashboard_providers.dart';
import '../screens/dashboard_screen.dart';
import 'daily_quests_widget.dart';
import 'league_leaderboard_widget.dart';
import 'charts/skills_radar_chart.dart';

class ProgressTabView extends ConsumerWidget {
  final Map<String, dynamic> profile;
  final Map<String, dynamic> progress;

  const ProgressTabView({super.key, required this.profile, required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final weeklyPracticeAsync = ref.watch(weeklyPracticeProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(currentUserProvider);
    final String avatarUrl = profile['avatar_url'] as String? ?? 'warrior';
    final String displayName = profile['display_name'] as String? ?? 'Estudiante TutorSaaS';
    final String cefrCode = progress['level_code'] as String? ?? 'B1';
    // Rango del juego (F→SSS) con fallback desde el nivel CEFR.
    final String gameRank = (progress['game_rank'] as String?)?.isNotEmpty == true
        ? (progress['game_rank'] as String)!
        : CefrRank.gameRankFromCefr(cefrCode);
    final String langEmoji = progress['language_emoji'] as String? ?? '🇺🇸';
    final String langName = progress['language'] as String? ?? 'Inglés';
    final int xp = progress['xp'] as int? ?? 0;
    final int streak = progress['streak'] as int? ?? 0;

    // LIVE-02: streak at risk — invocations_used del player_daily_state de hoy
    // (misma convención que HunterHudHeader) indica si ya se practicó hoy.
    final dailyStateAsync = ref.watch(dailyStateProvider);
    final int invocationsUsed = (dailyStateAsync.value?['invocations_used'] as num?)?.toInt() ?? 0;
    final bool streakAtRisk = dailyStateAsync.hasValue && invocationsUsed <= 0;

    // Refresca el estado diario al volver de una sesión de práctica (endSession
    // incrementa dashboardRefreshProvider) para que el banner desaparezca.
    ref.listen(dashboardRefreshProvider, (prev, next) {
      if (next != prev) {
        Future.microtask(() {
          ref.invalidate(dailyStateProvider);
        });
      }
    });

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Profile Header Card
            GlassCard(
              blur: 20,
              opacity: AppColors.glassOpacity,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  RpgAvatar(
                    avatarUrl: avatarUrl,
                    initials: displayName.isNotEmpty ? displayName.substring(0, displayName.length > 1 ? 2 : 1) : 'H',
                    size: 64,
                    hunterClass: avatarUrl,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$langEmoji Aprendiendo $langName • Rango $gameRank',
                          style: const TextStyle(
                            color: AppColors.manaCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.runeViolet, size: 20),
                        onPressed: () => context.push('/profile-edit'),
                        tooltip: AppLocalizations.of(context)?.progress_edit_profile ?? 'Editar Perfil',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 LIVE-02: Banner de Racha en Riesgo (streak at risk)
            if (streakAtRisk) ...[
              GlassCard(
                borderColor: AppColors.crimsonRed.withValues(alpha: 0.6),
                showRunicCorners: true,
                runicColor: AppColors.crimsonRed,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.crimsonRed.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.crimsonRed),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.crimsonRed,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.progress_streak_at_risk ?? '¡RACHA EN RIESGO!',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.crimsonRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)?.progress_streak_hint(
                                  streak,
                                  streak == 1 ? (AppLocalizations.of(context)?.days ?? 'día') : (AppLocalizations.of(context)?.days ?? 'días'),
                                ) ??
                                'Practica hoy para mantener tu racha de $streak ${streak == 1 ? 'día' : 'días'}.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                           SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () => ref.read(dashboardTabProvider.notifier).state = 0,
                              icon: const Icon(Icons.mic_rounded, size: 16),
                              label: Text(
                                AppLocalizations.of(context)?.progress_practice ?? 'PRACTICAR',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.crimsonRed,
                                foregroundColor: AppColors.onSurface,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 20),

            // Key Real DB Stats Grid
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.royalGold, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          '$xp XP',
                          style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          l10n.progress_xp_points,
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: AppColors.royalGold, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          '$streak Días',
                          style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          l10n.progress_active_streak,
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(Icons.psychology_rounded, color: AppColors.manaCyan, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          'Rango $gameRank',
                          style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          l10n.progress_active_rank,
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Radar Holográfico de Habilidades (6 ejes, datos reales del Oráculo)
            const SkillsRadarChart(),

            const SizedBox(height: 24),

            // Weekly Practice Chart Title & Card
            Text(
              AppLocalizations.of(context)?.progress_weekly_voice ?? 'Práctica Semanal (Minutos de Voz)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            weeklyPracticeAsync.when(
              data: (practiceList) => GlassCard(
                blur: 20,
                opacity: AppColors.glassOpacity,
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: practiceList.map((data) {
                      final height = 90.0 * (data['heightFactor'] as double);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${data['minutes']}m',
                            style: TextStyle(
                              color: AppColors.onSurface.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 16,
                            height: height > 6 ? height : 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.runeViolet, AppColors.manaCyan],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['day'] as String,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              loading: () => const GlassCard(
                blur: 20,
                opacity: AppColors.glassOpacity,
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.runeViolet)),
              ),
              error: (e, s) => GlassCard(
                blur: 20,
                opacity: AppColors.glassOpacity,
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Error al cargar datos de práctica',
                    style: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Quests Gamification Widget (conectado a misiones reales)
            DailyQuestsWidget(streakDays: streak),

            const SizedBox(height: 24),

            // League Leaderboard (datos reales desde get_leaderboard)
            LeaderboardSection(
              entries: leaderboardAsync.value ?? const [],
              currentUserId: currentUser?.id,
              currentDisplayName: displayName,
              currentXp: xp,
              currentLevel: gameRank,
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

/// Sección de clasificación con datos reales de `get_leaderboard`.
/// Convierte las filas (user_id, xp_points) al formato de LeagueLeaderboardWidget.
class LeaderboardSection extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final String? currentUserId;
  final String currentDisplayName;
  final int currentXp;
  final String currentLevel;

  const LeaderboardSection({
    super.key,
    required this.entries,
    this.currentUserId,
    required this.currentDisplayName,
    required this.currentXp,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Map<String, dynamic>>[];
    final ranked = [...entries];
    if (ranked.isEmpty) {
      // Sin datos de BD → solo el usuario (vista mínima real).
      rows.add({'rank': 1, 'name': currentDisplayName, 'xp': currentXp, 'stars': 0, 'avatar': null, 'isUser': true});
    } else {
      for (var i = 0; i < ranked.length; i++) {
        final e = ranked[i];
        final isUser = e['user_id']?.toString() == currentUserId;
        rows.add({
          'rank': i + 1,
          'name': isUser ? currentDisplayName : 'Cazador ${e['user_id'].toString().substring(0, 4).toUpperCase()}',
          'xp': (e['xp_points'] as num?)?.toInt() ?? 0,
          'stars': 0,
          'avatar': isUser ? null : null,
          'isUser': isUser,
        });
      }
    }
    return LeagueLeaderboardWidget(
      activeLeague: AppLocalizations.of(context)?.progress_xp_rank ?? 'Rango de XP',
      userRank: rows.indexWhere((r) => r['isUser'] == true) + 1,
      userXp: currentXp,
      userLevelCode: currentLevel,
      entries: rows,
    );
  }
}
