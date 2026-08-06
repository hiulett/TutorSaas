import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../data/models/lesson_catalog.dart';
import '../../domain/models/lesson_unlock_service.dart';
import '../../domain/models/mission_progress_service.dart';
import '../providers/dashboard_providers.dart';

/// Mapa de Mazmorras (paridad con PlantillaHtml/learning_dungeon_map_gateways).
/// Muestra portales por nivel CEFR con bloqueo según progreso del jugador y
/// navegación a la conversación de cada lección.
class DungeonMapScreen extends ConsumerWidget {
  const DungeonMapScreen({super.key});

  static const List<String> _levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(userProgressProvider).value ?? {};
    final String cefrCode = progress['level_code'] as String? ?? 'A1';
    final int userLevelIndex = _levelOrder.indexOf(cefrCode.toUpperCase());
    final int effectiveIndex = userLevelIndex < 0 ? 0 : userLevelIndex;

    final completedLessonsAsync = ref.watch(completedLessonsProvider);
    final completedLessons = completedLessonsAsync.value ?? [];

    bool isLessonUnlocked(String lessonId) {
      final lesson = LessonCatalog.catalog.firstWhere(
        (l) => l.id == lessonId,
        orElse: () => LessonCatalog.catalog.first,
      );
      final state = LessonUnlockService.classify(
        lesson: lesson,
        userCefr: cefrCode,
        completedLessons: completedLessons,
        catalog: LessonCatalog.catalog,
      );
      return state != LessonUnlockState.locked;
    }

    // Agrupar catálogo por nivel.
    final Map<String, List<LessonData>> byLevel = {};
    for (final lesson in LessonCatalog.catalog) {
      byLevel.putIfAbsent(lesson.level.toUpperCase(), () => []).add(lesson);
    }

    // Progreso real del nivel actual por objetivos completados:
    // Σ completados(nivel) / Σ totales(nivel). Si el nivel no tiene lecciones,
    // usa el progreso global de todos los objetivos del catálogo.
    final completedGoalRows = ref.watch(completedGoalsProvider).value ?? [];
    final List<LessonData> currentLevelLessons =
        byLevel[_levelOrder[effectiveIndex]] ?? const [];
    final List<LessonData> progressLessons = currentLevelLessons.isEmpty
        ? LessonCatalog.catalog
        : currentLevelLessons;
    final double headerProgress = MissionProgressService.lessonProgress(
      completedGoals: progressLessons.fold<int>(
        0,
        (sum, l) =>
            sum +
            MissionProgressService.completedGoalsForScenario(
              completedGoalRows,
              l.id,
            ),
      ),
      totalGoals: progressLessons.fold<int>(
        0,
        (sum, l) => sum + l.goals.length,
      ),
    );

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.dashboardGate,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAPA DE MAZMORRAS',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'ELIGE UN PORTAL SEGÚN TU RANGO',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: AppColors.manaCyan.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.royalGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'RANGO $cefrCode',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SegmentedBar(
                  value: headerProgress,
                  segments: _levelOrder.length,
                  height: 6,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (int i = 0; i < _levelOrder.length; i++)
                      _buildLevelPortal(context, theme, _levelOrder[i], byLevel[_levelOrder[i]] ?? const [], i, effectiveIndex, isLessonUnlocked),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelPortal(
    BuildContext context,
    ThemeData theme,
    String level,
    List<LessonData> lessons,
    int index,
    int userIndex,
    bool Function(String) isLessonUnlocked,
  ) {
    final isUnlocked = index <= userIndex;
    final isCurrent = index == userIndex;
    final portalColor = isCurrent
        ? AppColors.manaCyan
        : isUnlocked
            ? AppColors.runeViolet
            : AppColors.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderColor: portalColor.withValues(alpha: isUnlocked ? 0.5 : 0.15),
        showRunicCorners: isUnlocked,
        runicColor: portalColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isUnlocked
                          ? [portalColor, AppColors.manaCyan.withValues(alpha: 0.4)]
                          : [AppColors.onSurface.withValues(alpha: 0.10), AppColors.onSurface.withValues(alpha: 0.10)],
                    ),
                    border: Border.all(color: portalColor.withValues(alpha: 0.6), width: 1.5),
                  ),
                  child: Icon(
                    isUnlocked ? Icons.view_module_rounded : Icons.lock_rounded,
                    color: isUnlocked ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.38),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrent ? 'PORTAL ACTUAL — NIVEL $level' : 'NIVEL $level',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.38),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lessons.length} mazmorras disponibles',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: isUnlocked ? AppColors.onSurfaceVariant : AppColors.onSurface.withValues(alpha: 0.24),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isUnlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                  color: portalColor.withValues(alpha: isUnlocked ? 1 : 0.3),
                ),
              ],
            ),
            if (isUnlocked && lessons.isNotEmpty) ...[
              const SizedBox(height: 12),
              // Mini list of lessons (gateways)
              ...lessons.take(3).map((lesson) => _buildLessonRow(context, lesson, level, isLessonUnlocked(lesson.id))),
              if (lessons.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '+${lessons.length - 3} MAZMORRAS MÁS…',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: portalColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLessonRow(BuildContext context, LessonData lesson, String level, bool isUnlocked) {
    return GestureDetector(
      onTap: isUnlocked
          ? () => context.push(
                '/conversation',
                extra: {
                  'scenarioId': lesson.id,
                  'scenarioTitle': lesson.title,
                },
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.onSurface.withValues(alpha: 0.03)
              : AppColors.onSurface.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isUnlocked
                ? AppColors.onSurface.withValues(alpha: 0.08)
                : AppColors.onSurface.withValues(alpha: 0.03),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 16,
              color: isUnlocked ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lesson.title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isUnlocked
                      ? AppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            Text(
              lesson.category.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: isUnlocked ? AppColors.onSurfaceVariant : AppColors.onSurface.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isUnlocked ? Icons.play_circle_outline_rounded : Icons.lock_outline_rounded,
              color: isUnlocked ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.25),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
