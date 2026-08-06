import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/quest_card.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../conversation/presentation/widgets/conversational_tactics_navigator.dart';
import '../../data/models/lesson_catalog.dart';
import '../../domain/models/lesson_unlock_service.dart';
import '../../domain/models/mission_progress_service.dart';
import '../providers/dashboard_providers.dart';

class LearningPathRoadmap extends ConsumerStatefulWidget {
  final String activeUserLevel;
  final List<Map<String, dynamic>> completedLessonsHistory;

  const LearningPathRoadmap({
    super.key,
    required this.activeUserLevel,
    this.completedLessonsHistory = const [],
  });

  static const Color accentGreen = AppColors.accentGreen;

  @override
  ConsumerState<LearningPathRoadmap> createState() => _LearningPathRoadmapState();
}

class _LearningPathRoadmapState extends ConsumerState<LearningPathRoadmap> {
  late String _selectedLevel;
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.activeUserLevel.toUpperCase();
    if (!_levels.contains(_selectedLevel)) {
      _selectedLevel = 'B1';
    }
  }

  @override
  void didUpdateWidget(covariant LearningPathRoadmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeUserLevel != widget.activeUserLevel) {
      setState(() {
        _selectedLevel = widget.activeUserLevel.toUpperCase();
      });
    }
  }

  IconData _getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'handshake':
        return Icons.handshake_rounded;
      case 'people':
        return Icons.people_alt_rounded;
      case 'schedule':
        return Icons.access_time_filled_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'explore':
        return Icons.explore_rounded;
      case 'devices':
        return Icons.devices_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedGoalRows = ref.watch(completedGoalsProvider).value ?? [];
    final stageLessons = LessonCatalog.catalog
        .where((l) => l.level.toUpperCase() == _selectedLevel)
        .toList();

    // Progreso de etapa por objetivos: Σ completados(etapa) / Σ totales(etapa).
    final stageCompletedGoals = stageLessons.fold<int>(
      0,
      (sum, l) =>
          sum +
          MissionProgressService.completedGoalsForScenario(
            completedGoalRows,
            l.id,
          ),
    );
    final stageTotalGoals = stageLessons.fold<int>(
      0,
      (sum, l) => sum + l.goals.length,
    );
    final stageProgress = MissionProgressService.lessonProgress(
      completedGoals: stageCompletedGoals,
      totalGoals: stageTotalGoals,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.map_rounded,
              color: AppColors.runeViolet,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ruta por Etapas (CEFR)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$stageCompletedGoals/$stageTotalGoals Objetivos',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _levels.map((lvl) {
              final isSelected = lvl == _selectedLevel;
              final isUserCurrentLevel = lvl == widget.activeUserLevel.toUpperCase();

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevel = lvl;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.runeViolet
                          : isUserCurrentLevel
                              ? AppColors.runeViolet.withValues(alpha: 0.15)
                              : AppColors.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.runeViolet
                            : isUserCurrentLevel
                                ? AppColors.manaCyan
                                : AppColors.onSurface.withValues(alpha: 0.08),
                        width: isSelected || isUserCurrentLevel ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          lvl,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isSelected ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (isUserCurrentLevel) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.manaCyan,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: stageProgress,
            minHeight: 4,
            backgroundColor: AppColors.onSurface.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.manaCyan),
          ),
        ),

        const SizedBox(height: 16),

        if (stageLessons.isEmpty)
          const GlassCard(
            blur: 15,
            opacity: AppColors.glassOpacity,
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No hay lecciones registradas para esta etapa aún.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stageLessons.length,
            itemBuilder: (context, index) {
              final lesson = stageLessons[index];
              final state = LessonUnlockService.classify(
                lesson: lesson,
                userCefr: widget.activeUserLevel,
                completedLessons: widget.completedLessonsHistory,
                catalog: LessonCatalog.catalog,
              );
              final isCompleted = state == LessonUnlockState.completedByPlayer;
              final isNextLesson = state == LessonUnlockState.nextAvailable;
              final isUnlockedByOracle = state == LessonUnlockState.unlockedByOracle;
              final isLocked = state == LessonUnlockState.locked;

              final lessonCompletedGoals = MissionProgressService
                  .completedGoalsForScenario(completedGoalRows, lesson.id);
              final lessonTotalGoals = lesson.goals.length;
              final lessonProgress = MissionProgressService.lessonProgress(
                completedGoals: lessonCompletedGoals,
                totalGoals: lessonTotalGoals,
              );
              final iconData = _getIconData(lesson.iconKey);

              return _RoadmapNodeTile(
                lesson: lesson,
                index: index + 1,
                total: stageLessons.length,
                isCompleted: isCompleted,
                isNextLesson: isNextLesson,
                isUnlockedByOracle: isUnlockedByOracle,
                isLocked: isLocked,
                progress: lessonProgress,
                progressSegments: lessonTotalGoals <= 0 ? 1 : lessonTotalGoals,
                iconData: iconData,
                isLast: index == stageLessons.length - 1,
              );
            },
          ),
      ],
    );
  }
}

class _RoadmapNodeTile extends StatelessWidget {
  final LessonData lesson;
  final int index;
  final int total;
  final bool isCompleted;
  final bool isNextLesson;
  final bool isUnlockedByOracle;
  final bool isLocked;
  final double progress;
  final int progressSegments;
  final IconData iconData;
  final bool isLast;

  const _RoadmapNodeTile({
    required this.lesson,
    required this.index,
    required this.total,
    required this.isCompleted,
    required this.isNextLesson,
    required this.isUnlockedByOracle,
    required this.isLocked,
    required this.progress,
    required this.progressSegments,
    required this.iconData,
    required this.isLast,
  });

  static const Color accentGreen = AppColors.accentGreen;

  @override
  Widget build(BuildContext context) {
    Color nodeColor;
    Color borderColor;

    if (isCompleted) {
      nodeColor = accentGreen.withValues(alpha: 0.2);
      borderColor = accentGreen;
    } else if (isNextLesson) {
      nodeColor = AppColors.runeViolet.withValues(alpha: 0.25);
      borderColor = AppColors.manaCyan;
    } else if (isUnlockedByOracle) {
      nodeColor = AppColors.runeViolet.withValues(alpha: 0.12);
      borderColor = AppColors.runeViolet;
    } else {
      nodeColor = AppColors.onSurface.withValues(alpha: 0.03);
      borderColor = AppColors.onSurface.withValues(alpha: 0.1);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor,
                  border: Border.all(
                    color: borderColor,
                    width: isNextLesson ? 2.0 : 1.5,
                  ),
                  boxShadow: isNextLesson
                      ? [
                          BoxShadow(
                            color: AppColors.runeViolet.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.emoji_events_rounded, color: accentGreen, size: 20)
                      : isNextLesson
                          ? const Icon(Icons.play_arrow_rounded, color: AppColors.onSurface, size: 24)
                          : isUnlockedByOracle
                              ? const Icon(Icons.auto_awesome_rounded, color: AppColors.runeViolet, size: 18)
                              : Icon(Icons.lock_rounded, color: AppColors.onSurface.withValues(alpha: 0.38), size: 18),
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? accentGreen.withValues(alpha: 0.5)
                        : isUnlockedByOracle
                            ? AppColors.runeViolet.withValues(alpha: 0.3)
                            : AppColors.onSurface.withValues(alpha: 0.08),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: QuestCard(
                title: lesson.title,
                description: lesson.description,
                rank: isCompleted
                    ? 'S'
                    : (isNextLesson ? 'B' : (isUnlockedByOracle ? 'O' : 'D')),
                gemReward: isCompleted ? 0 : 15,
                xpReward: isCompleted ? 0 : 100,
                progress: progress,
                progressSegments: progressSegments,
                onTap: isLocked ? () {
                  SystemSnack.show(context, '🔒 MAZMORRA BLOQUEADA: Completa los desafíos previos.', type: SystemSnackType.error);
                } : () {
                  ConversationalTacticsNavigator.show(
                    context,
                    scenarioId: lesson.id,
                    scenarioTitle: lesson.title,
                    onStart: (tactic) {
                      context.push(
                        '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}&tactic=$tactic',
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
