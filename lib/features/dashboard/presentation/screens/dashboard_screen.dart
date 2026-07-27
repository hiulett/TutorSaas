import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';
import '../providers/dashboard_providers.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../widgets/next_recommended_lesson_hero.dart';
import '../widgets/learning_path_roadmap.dart';
import '../widgets/completed_lessons_history_list.dart';
import '../widgets/recommended_lessons_hub.dart';
import '../widgets/daily_quests_widget.dart';
import '../widgets/league_leaderboard_widget.dart';
import '../../../vocabulary/presentation/widgets/srs_flashcard_modal.dart';
import 'settings_screen.dart';
import '../widgets/status_window_modal.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';





final dashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value ?? {};
    final String rawName = profile['display_name'] as String? ?? user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? '';
    final String userName = rawName.isNotEmpty
        ? rawName
        : (user != null ? 'Estudiante ${user.id.substring(0, 5)}' : 'Estudiante');
    final userAvatarUrl = profile['avatar_url'] as String? ?? user?.userMetadata?['avatar_url'] as String? ?? 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=$userName';

    final isPremium = ref.watch(isPremiumProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final achievementsAsync = ref.watch(userAchievementsProvider);
    final currentTab = ref.watch(dashboardTabProvider);
    final progress = progressAsync.value ?? {
      'xp': 2450,
      'streak': 7,
      'level_code': 'B1',
      'level': 'Intermedio',
      'language': 'Inglés',
      'language_emoji': '🇺🇸',
    };
    final int xp = progress['xp'] as int;
    final int streak = progress['streak'] as int;
    final String cefrCode = progress['level_code'] as String;
    final String languageEmoji = progress['language_emoji'] as String;

    final recommendedAsync = ref.watch(recommendedLessonsProvider);
    final recommendedList = recommendedAsync.value ?? [];

    final activeRecMap = recommendedList.firstWhere(
      (m) => m['is_completed'] != true,
      orElse: () => recommendedList.isNotEmpty ? recommendedList.first : {},
    );

    final activeRecId = activeRecMap['id'] as String?;
    final heroLesson = LessonCatalog.getLessonById(activeRecId) ??
        LessonCatalog.catalog.firstWhere(
          (l) => l.level.toUpperCase() == cefrCode.toUpperCase(),
          orElse: () => LessonCatalog.catalog.first,
        );

    final double realProgress = (activeRecMap['progress'] as num?)?.toDouble() ?? 0.0;

    final completedHistory = recommendedList
        .where((m) => m['is_completed'] == true)
        .toList();

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
                color: AppColors.primaryPurple.withValues(alpha: 0.12),
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
                color: AppColors.secondaryBlue.withValues(alpha: 0.08),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: AppColors.primaryPurple,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TutorSaaS',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: AppColors.onSurfaceVariant),
                        onPressed: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Body with 4 Tabs (0: Home, 1: Lecciones, 2: Progreso, 3: Ajustes)
                Expanded(
                  child: currentTab == 1
                      ? const RecommendedLessonsHub()
                      : currentTab == 2
                          ? _ProgressTabView(profile: profile, progress: progress)
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

                                    // Profile Header
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              // Cyberpunk User Avatar
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                                    width: 2,
                                                  ),
                                                ),
                                                padding: const EdgeInsets.all(3),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: NetworkImage(userAvatarUrl),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Hola, $userName',
                                                      style: theme.textTheme.titleLarge?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'Nivel $cefrCode • $xp XP',
                                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                              color: AppColors.onSurfaceVariant,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          languageEmoji,
                                                          style: const TextStyle(fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            // Streak badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.05),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.1),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.local_fire_department_rounded,
                                                    color: Colors.orangeAccent,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$streak ${streak == 1 ? "DÍA" : "DÍAS"}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      letterSpacing: 1.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Premium status badge / Upgrade button
                                            GestureDetector(
                                              onTap: () {
                                                if (!isPremium) {
                                                  context.push('/paywall');
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: isPremium
                                                      ? AppColors.tertiaryTeal.withValues(alpha: 0.15)
                                                      : AppColors.primaryPurple.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: isPremium ? AppColors.tertiaryTeal : AppColors.primaryPurple,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isPremium ? Icons.workspace_premium_rounded : Icons.star_border_rounded,
                                                      color: isPremium ? AppColors.tertiaryTeal : AppColors.primaryPurpleDim,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      isPremium ? 'PRO' : 'IR PRO',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                        color: isPremium ? AppColors.tertiaryTeal : AppColors.primaryPurpleDim,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // 1. Hero Card: Siguiente Lección Recomendada en tu Etapa
                                    NextRecommendedLessonHero(
                                      lesson: heroLesson,
                                      stageCompletionPercentage: realProgress,
                                    ),

                                    const SizedBox(height: 20),

                                    // 🎙️ Banner de Salas de Chat de Voz Grupales
                                    GlassCard(
                                      blur: 25,
                                      opacity: 0.1,
                                      border: Border.all(
                                        color: AppColors.tertiaryTeal.withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: InkWell(
                                        onTap: () => context.push('/chat-rooms'),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppColors.tertiaryTeal.withValues(alpha: 0.2),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.tertiaryTeal),
                                              ),
                                              child: const Icon(
                                                Icons.groups_rounded,
                                                color: AppColors.tertiaryTeal,
                                                size: 26,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Wrap(
                                                    spacing: 6,
                                                    runSpacing: 4,
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Salas de Chat de Voz',
                                                        style: GoogleFonts.hankenGrotesk(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.redAccent,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: const Text(
                                                          'EN VIVO',
                                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text(
                                                    'Practica en grupo con moderación de IA en tiempo real',
                                                    style: TextStyle(
                                                      color: AppColors.onSurfaceVariant,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.tertiaryTeal, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    // 2. Ruta de Aprendizaje por Etapas (Roadmap Interactivo A1-C2)
                                    LearningPathRoadmap(
                                      activeUserLevel: cefrCode,
                                    ),

                                    const SizedBox(height: 28),

                                    // 3. Historial de Lecciones Superadas
                                    const CompletedLessonsHistoryList(
                                      completedLessons: [],
                                    ),

                                    const SizedBox(height: 28),

                                    // Section Title: Mis Logros y Estadísticas
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.workspace_premium_rounded,
                                          color: AppColors.primaryPurple,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Mis Logros y Estadísticas',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Achievements Horizontal List
                                    SizedBox(
                                      height: 130,
                                      child: achievementsAsync.when(
                                        data: (achievements) {
                                          final list = achievements.isNotEmpty
                                              ? achievements
                                              : [
                                                  {
                                                    'title': 'Primeros Pasos 🥇',
                                                    'description': 'Completa tu primera llamada de voz con el Tutor IA',
                                                    'tier': 'gold',
                                                    'is_unlocked': true,
                                                    'progress': 1.0,
                                                    'current_value': 1,
                                                    'target_value': 1,
                                                  },
                                                  {
                                                    'title': 'Racha de Fuego ⚡',
                                                    'description': 'Practica diariamente durante 3 días consecutivos',
                                                    'tier': 'silver',
                                                    'is_unlocked': streak >= 3,
                                                    'progress': (streak / 3.0).clamp(0.0, 1.0),
                                                    'current_value': streak,
                                                    'target_value': 3,
                                                  },
                                                  {
                                                    'title': 'Hablante Fluido 🗣️',
                                                    'description': 'Acumula más de 30 minutos de conversación',
                                                    'tier': 'bronze',
                                                    'is_unlocked': false,
                                                    'progress': 0.45,
                                                    'current_value': 15,
                                                    'target_value': 30,
                                                  },
                                                  {
                                                    'title': 'Metas Cumplidas 🎯',
                                                    'description': 'Supera 5 metas de escenarios conversacionales',
                                                    'tier': 'gold',
                                                    'is_unlocked': false,
                                                    'progress': 0.60,
                                                    'current_value': 3,
                                                    'target_value': 5,
                                                  },
                                                ];

                                          return ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: list.length,
                                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                                            itemBuilder: (context, index) {
                                              final ach = list[index];
                                              final isUnlocked = ach['is_unlocked'] as bool? ?? false;
                                              final tier = ach['tier'] as String? ?? 'bronze';
                                              final progress = ach['progress'] as double? ?? 0.0;
                                              final title = ach['title'] as String? ?? '';
                                              final desc = ach['description'] as String? ?? '';
                                              final currentVal = ach['current_value'] as int? ?? 0;
                                              final targetVal = ach['target_value'] as int? ?? 1;

                                              IconData trophyIcon = Icons.emoji_events_rounded;
                                              Color trophyColor;
                                              if (tier == 'gold') {
                                                trophyColor = const Color(0xFFFFD700);
                                              } else if (tier == 'silver') {
                                                trophyColor = const Color(0xFFC0C0C0);
                                              } else {
                                                trophyColor = const Color(0xFFCD7F32);
                                              }

                                              return SizedBox(
                                                width: 260,
                                                child: GlassCard(
                                                  blur: 20,
                                                  opacity: isUnlocked ? 0.08 : 0.03,
                                                  border: Border.all(
                                                    color: isUnlocked
                                                        ? trophyColor.withValues(alpha: 0.3)
                                                        : Colors.white.withValues(alpha: 0.05),
                                                    width: 1,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: isUnlocked
                                                              ? trophyColor.withValues(alpha: 0.1)
                                                              : Colors.white.withValues(alpha: 0.02),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          trophyIcon,
                                                          color: isUnlocked ? trophyColor : Colors.white24,
                                                          size: 28,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              title,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              desc,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                color: AppColors.onSurfaceVariant,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(2),
                                                                    child: LinearProgressIndicator(
                                                                      value: progress.clamp(0.0, 1.0),
                                                                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                                        isUnlocked ? trophyColor : AppColors.primaryPurpleDim,
                                                                      ),
                                                                      minHeight: 3,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                  '$currentVal/$targetVal',
                                                                  style: TextStyle(
                                                                    color: isUnlocked ? trophyColor : AppColors.onSurfaceVariant,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 10,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        loading: () => const Center(
                                          child: CircularProgressIndicator(color: AppColors.primaryPurple),
                                        ),
                                        error: (err, stack) => Center(
                                          child: Text(
                                            'Error al cargar logros: $err',
                                            style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Section Title: Fluency & Response Latency
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.speed_rounded,
                                          color: AppColors.tertiaryTeal,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Fluidez & Tiempo de Expresión',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    ref.watch(userFluencyStatsProvider).when(
                                      data: (fluencyData) {
                                        final double latency = (fluencyData['avg_response_latency_seconds'] as num? ?? 1.8).toDouble();
                                        final int wpm = fluencyData['avg_speaking_wpm'] as int? ?? 130;
                                        final int score = fluencyData['fluency_score'] as int? ?? 82;

                                        return Row(
                                          children: [
                                            // Card 1: Response Latency
                                            Expanded(
                                              child: GlassCard(
                                                blur: 20,
                                                opacity: 0.08,
                                                padding: const EdgeInsets.all(14),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Row(
                                                      children: [
                                                        Icon(Icons.timer_outlined, color: AppColors.secondaryBlue, size: 16),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          'Respuesta',
                                                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      '${latency.toStringAsFixed(1)}s',
                                                      style: GoogleFonts.hankenGrotesk(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    const Text(
                                                      '⚡ Latencia de duda',
                                                      style: TextStyle(color: AppColors.tertiaryTeal, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Card 2: Speaking Speed WPM
                                            Expanded(
                                              child: GlassCard(
                                                blur: 20,
                                                opacity: 0.08,
                                                padding: const EdgeInsets.all(14),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Row(
                                                      children: [
                                                        Icon(Icons.record_voice_over_rounded, color: AppColors.primaryPurple, size: 16),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          'Velocidad',
                                                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      '$wpm WPM',
                                                      style: GoogleFonts.hankenGrotesk(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '🗣️ Score Fluidez: $score%',
                                                      style: const TextStyle(color: AppColors.primaryPurpleDim, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),

                                    const SizedBox(height: 24),
                                    const _FluencyLatencyChart(),

                                    const SizedBox(height: 20),
                                    const _SkillsRadarChart(),

                                    const SizedBox(height: 20),
                                    const _PracticeHeatmap(),

                                    const SizedBox(height: 100), // Spacing for bottom navigation
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),

          // Floating Bottom Navigation Bar (4 Items: Inicio, Lecciones, Progreso, Ajustes)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GlassCard(
                blur: 30.0,
                opacity: 0.08,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.fort_rounded,
                      label: 'Santuario',
                      isActive: currentTab == 0,
                      onTap: () {
                        ref.read(dashboardTabProvider.notifier).state = 0;
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Mazmorras',
                      isActive: currentTab == 1,
                      onTap: () {
                        ref.read(dashboardTabProvider.notifier).state = 1;
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.military_tech_rounded,
                      label: 'Estado Hunter',
                      isActive: currentTab == 2,
                      onTap: () {
                        ref.read(dashboardTabProvider.notifier).state = 2;
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.settings_rounded,
                      label: 'Ajustes',
                      isActive: currentTab == 3,
                      onTap: () {
                        ref.read(dashboardTabProvider.notifier).state = 3;
                      },
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
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.tertiaryTeal.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isActive
                  ? Border.all(color: AppColors.tertiaryTeal.withValues(alpha: 0.4), width: 1)
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.tertiaryTeal.withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.tertiaryTeal : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 24,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? AppColors.tertiaryTeal : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





class _ProgressTabView extends ConsumerWidget {
  final Map<String, dynamic> profile;
  final Map<String, dynamic> progress;

  const _ProgressTabView({required this.profile, required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyPracticeAsync = ref.watch(weeklyPracticeProvider);
    final learnedVocabularyAsync = ref.watch(learnedVocabularyProvider);
    final String avatarUrl = profile['avatar_url'] as String? ?? 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Profile';
    final String displayName = profile['display_name'] as String? ?? 'Estudiante TutorSaaS';
    final String cefrCode = progress['level_code'] as String? ?? 'B1';
    final String cefrName = progress['level'] as String? ?? 'Intermedio';
    final String langEmoji = progress['language_emoji'] as String? ?? '🇺🇸';
    final String langName = progress['language'] as String? ?? 'Inglés';
    final int xp = progress['xp'] as int? ?? 0;
    final int streak = progress['streak'] as int? ?? 0;

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
              opacity: 0.08,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple,
                        width: 2.5,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$langEmoji Aprendiendo $langName • Nivel $cefrCode ($cefrName)',
                          style: const TextStyle(
                            color: AppColors.tertiaryTeal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.primaryPurpleDim, size: 20),
                    onPressed: () => context.push('/profile-edit'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📜 Botón Épico: Ventana de Estado del Cazador (HUD Holográfico)
            GlassCard(
              blur: 25,
              opacity: 0.15,
              border: Border.all(color: AppColors.tertiaryTeal, width: 1.5),
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => StatusWindowModal.show(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryTeal.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.tertiaryTeal),
                      ),
                      child: const Icon(
                        Icons.military_tech_rounded,
                        color: AppColors.tertiaryTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📜 VENTANA DE ESTADO DEL MONARCA',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Ver matriz de 11 atributos, títulos equipados y radar de poder',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_full_rounded, color: AppColors.tertiaryTeal, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Key Real DB Stats Grid
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    blur: 20,
                    opacity: 0.06,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          '$xp XP',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text('Puntos XP', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    blur: 20,
                    opacity: 0.06,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          '$streak Días',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text('Racha Activa', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    blur: 20,
                    opacity: 0.06,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(Icons.psychology_rounded, color: AppColors.tertiaryTeal, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          cefrCode,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text('Nivel Activo', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Weekly Practice Chart Title & Card
            const Text(
              'Práctica Semanal (Minutos de Voz)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            weeklyPracticeAsync.when(
              data: (practiceList) => GlassCard(
                blur: 20,
                opacity: 0.06,
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
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 16,
                            height: height > 6 ? height : 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryPurple, AppColors.tertiaryTeal],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
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
                opacity: 0.04,
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
              ),
              error: (e, s) => const GlassCard(
                blur: 20,
                opacity: 0.04,
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Error al cargar datos de práctica',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Quests Gamification Widget
            DailyQuestsWidget(
              streakDays: streak,
              onClaimReward: (xpEarned) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡Recompensa Canjeada! +$xpEarned XP sumados a tu perfil'),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // League Leaderboard Gamification Widget
            LeagueLeaderboardWidget(
              activeLeague: 'Liga Plata 🥈',
              userRank: 3,
              userXp: xp,
              userLevelCode: cefrCode,
            ),

            const SizedBox(height: 24),

            // Learned Vocabulary Section with SRS Repaso Button
            learnedVocabularyAsync.when(
              data: (vocabList) {
                final displayList = vocabList.take(4).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Vocabulario Aprendido (${vocabList.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            if (vocabList.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () => SrsFlashcardModal.show(context, vocabList),
                                icon: const Icon(Icons.style_rounded, size: 14),
                                label: const Text('Repaso SRS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            if (vocabList.isNotEmpty)
                              TextButton(
                                onPressed: () => _showAllVocabModal(context, vocabList),
                                child: const Text('VER TODO', style: TextStyle(color: AppColors.tertiaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (displayList.isEmpty)
                      const GlassCard(
                        blur: 20,
                        opacity: 0.04,
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Aún no has acumulado vocabulario en las llamadas de voz.',
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                          ),
                        ),
                      )
                    else
                      ...displayList.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GlassCard(
                              blur: 20,
                              opacity: 0.05,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['word'] as String? ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          item['translation'] as String? ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['category'] as String? ?? 'Vocabulario',
                                      style: const TextStyle(
                                        color: AppColors.tertiaryTeal,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showAllVocabModal(BuildContext context, List<Map<String, dynamic>> vocabList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vocabulario Aprendido (${vocabList.length})',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: vocabList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = vocabList[index];
                        return GlassCard(
                          blur: 20,
                          opacity: 0.05,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['word'] as String? ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      item['translation'] as String? ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['category'] as String? ?? 'Vocabulario',
                                  style: const TextStyle(
                                    color: AppColors.tertiaryTeal,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Widget de Botón de Micrófono con Pulso Animado (Efecto de Neón)
class MicPulseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const MicPulseButton({super.key, required this.onPressed});

  @override
  State<MicPulseButton> createState() => _MicPulseButtonState();
}

class _MicPulseButtonState extends State<MicPulseButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Pulse Outer Ring
                Container(
                  width: 100 + (_controller.value * 60),
                  height: 100 + (_controller.value * 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 1.0 - _controller.value),
                      width: 2,
                    ),
                  ),
                ),
                // Inner button layout
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.secondaryBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'HABLAR AHORA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Tarjeta de Lección Glassmorphic Reusable
class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final String level;
  final double progress;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.level,
    required this.progress,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
      blur: 20,
      opacity: 0.05,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Lesson Icon container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Lesson title, progress, level badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Neon Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 4,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: accentColor,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
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
    );
  }
}

// ── 1. Curva Neón de Fluidez & Latencia (fl_chart) ──────────────────────────
class _FluencyLatencyChart extends ConsumerWidget {
  const _FluencyLatencyChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(fluencyTrendsProvider);

    return GlassCard(
      blur: 20,
      opacity: 0.08,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart_rounded, color: AppColors.tertiaryTeal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Evolución de Fluidez & Latencia',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.tertiaryTeal, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('WPM', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                  const SizedBox(width: 8),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondaryBlue, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Latencia (s)', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: trendsAsync.when(
              data: (dataList) {
                final list = dataList.isEmpty
                    ? [
                        {'avg_response_latency_seconds': 3.2, 'avg_speaking_wpm': 88},
                        {'avg_response_latency_seconds': 2.7, 'avg_speaking_wpm': 104},
                        {'avg_response_latency_seconds': 2.2, 'avg_speaking_wpm': 118},
                        {'avg_response_latency_seconds': 1.8, 'avg_speaking_wpm': 130},
                      ]
                    : dataList;

                final wpmSpots = list.asMap().entries.map((e) {
                  final wpm = (e.value['avg_speaking_wpm'] as num? ?? 100).toDouble();
                  return FlSpot(e.key.toDouble(), wpm);
                }).toList();

                final latencySpots = list.asMap().entries.map((e) {
                  final lat = (e.value['avg_response_latency_seconds'] as num? ?? 2.0).toDouble();
                  return FlSpot(e.key.toDouble(), lat * 25);
                }).toList();

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 160,
                    lineBarsData: [
                      LineChartBarData(
                        spots: wpmSpots,
                        isCurved: true,
                        color: AppColors.tertiaryTeal,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.tertiaryTeal.withValues(alpha: 0.15),
                        ),
                      ),
                      LineChartBarData(
                        spots: latencySpots,
                        isCurved: true,
                        color: AppColors.secondaryBlue,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Radar Holográfico 5-D de Habilidades ──────────────────────────────────
class _SkillsRadarChart extends ConsumerWidget {
  const _SkillsRadarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radarAsync = ref.watch(skillsRadarProvider);

    return GlassCard(
      blur: 20,
      opacity: 0.08,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_rounded, color: AppColors.primaryPurple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Radar Holográfico 5-D de Habilidades',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: radarAsync.when(
              data: (radarMap) {
                final fluency = radarMap['fluency'] ?? 80;
                final vocab = radarMap['vocab'] ?? 75;
                final phonetics = radarMap['phonetics'] ?? 85;
                final grammar = radarMap['grammar'] ?? 82;
                final goals = radarMap['goals'] ?? 90;

                return RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    radarBorderData: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    gridBorderData: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
                    radarBackgroundColor: Colors.transparent,
                    ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                    tickBorderData: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return RadarChartTitle(text: 'Fluidez\n${fluency.toInt()}%');
                        case 1:
                          return RadarChartTitle(text: 'Vocabulario\n${vocab.toInt()}%');
                        case 2:
                          return RadarChartTitle(text: 'Fonética\n${phonetics.toInt()}%');
                        case 3:
                          return RadarChartTitle(text: 'Gramática\n${grammar.toInt()}%');
                        case 4:
                          return RadarChartTitle(text: 'Metas\n${goals.toInt()}%');
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppColors.primaryPurple.withValues(alpha: 0.25),
                        borderColor: AppColors.primaryPurple,
                        entryRadius: 3,
                        borderWidth: 2,
                        dataEntries: [
                          RadarEntry(value: fluency),
                          RadarEntry(value: vocab),
                          RadarEntry(value: phonetics),
                          RadarEntry(value: grammar),
                          RadarEntry(value: goals),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3. Mapa de Calor de Práctica Diaria (4 Semanas) ─────────────────────────
class _PracticeHeatmap extends ConsumerWidget {
  const _PracticeHeatmap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(practiceHeatmapProvider);

    return GlassCard(
      blur: 20,
      opacity: 0.08,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_view_week_rounded, color: Colors.amberAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consistencia de Práctica (4 Semanas)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          heatmapAsync.when(
            data: (heatmapList) {
              final Map<String, int> dateToMinutes = {};
              for (final row in heatmapList) {
                final dateStr = (row['date'] as String? ?? '').split('T').first;
                final mins = (row['minutes_practiced'] as num? ?? 0).toInt();
                if (dateStr.isNotEmpty) {
                  dateToMinutes[dateStr] = mins;
                }
              }

              final now = DateTime.now();

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(28, (index) {
                      final dayDate = now.subtract(Duration(days: 27 - index));
                      final dayStr = "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";
                      final minutes = dateToMinutes[dayStr] ?? 0;

                      Color cellColor;
                      if (minutes == 0) {
                        cellColor = Colors.white.withValues(alpha: 0.05);
                      } else if (minutes < 10) {
                        cellColor = AppColors.primaryPurple.withValues(alpha: 0.3);
                      } else if (minutes < 20) {
                        cellColor = AppColors.primaryPurple;
                      } else {
                        cellColor = AppColors.tertiaryTeal;
                      }

                      return Expanded(
                        child: Tooltip(
                          message: '$dayStr: $minutes min',
                          child: Container(
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hace 4 semanas', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      Text('Hoy', style: TextStyle(color: AppColors.tertiaryTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
