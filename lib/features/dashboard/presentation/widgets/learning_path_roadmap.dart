import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/lesson_catalog.dart';

class LearningPathRoadmap extends StatefulWidget {
  final String activeUserLevel;
  final List<Map<String, dynamic>> completedLessonsHistory;

  const LearningPathRoadmap({
    super.key,
    required this.activeUserLevel,
    this.completedLessonsHistory = const [],
  });

  static const Color accentGreen = Color(0xFF10B981);

  @override
  State<LearningPathRoadmap> createState() => _LearningPathRoadmapState();
}

class _LearningPathRoadmapState extends State<LearningPathRoadmap> {
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

  bool _isLessonCompleted(String lessonId) {
    return widget.completedLessonsHistory.any(
      (item) => item['scenario_id'] == lessonId || item['id'] == lessonId,
    );
  }

  int _getLessonScore(String lessonId) {
    final item = widget.completedLessonsHistory.firstWhere(
      (element) => element['scenario_id'] == lessonId || element['id'] == lessonId,
      orElse: () => {},
    );
    if (item.containsKey('score')) {
      return (item['score'] as num).toInt();
    }
    if (item.containsKey('fluency_score')) {
      return (item['fluency_score'] as num).toInt();
    }
    return 88;
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
    final stageLessons = LessonCatalog.catalog
        .where((l) => l.level.toUpperCase() == _selectedLevel)
        .toList();

    final completedCount = stageLessons.where((l) => _isLessonCompleted(l.id)).length;
    final totalCount = stageLessons.isEmpty ? 1 : stageLessons.length;
    final stageProgress = (completedCount / totalCount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.map_rounded,
              color: AppColors.primaryPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ruta por Etapas (CEFR)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$completedCount/$totalCount Superadas',
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
                          ? AppColors.primaryPurple
                          : isUserCurrentLevel
                              ? AppColors.primaryPurple.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : isUserCurrentLevel
                                ? AppColors.tertiaryTeal
                                : Colors.white.withValues(alpha: 0.08),
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
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                        if (isUserCurrentLevel) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.tertiaryTeal,
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
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiaryTeal),
          ),
        ),

        const SizedBox(height: 16),

        if (stageLessons.isEmpty)
          const GlassCard(
            blur: 15,
            opacity: 0.05,
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
              final isCompleted = _isLessonCompleted(lesson.id);
              final isNextLesson = !isCompleted &&
                  (index == 0 || _isLessonCompleted(stageLessons[index - 1].id));
              final isLocked = !isCompleted && !isNextLesson;

              final score = isCompleted ? _getLessonScore(lesson.id) : null;
              final iconData = _getIconData(lesson.iconKey);

              return _RoadmapNodeTile(
                lesson: lesson,
                index: index + 1,
                total: stageLessons.length,
                isCompleted: isCompleted,
                isNextLesson: isNextLesson,
                isLocked: isLocked,
                score: score,
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
  final bool isLocked;
  final int? score;
  final IconData iconData;
  final bool isLast;

  const _RoadmapNodeTile({
    required this.lesson,
    required this.index,
    required this.total,
    required this.isCompleted,
    required this.isNextLesson,
    required this.isLocked,
    required this.score,
    required this.iconData,
    required this.isLast,
  });

  static const Color accentGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    Color nodeColor;
    Color borderColor;

    if (isCompleted) {
      nodeColor = accentGreen.withValues(alpha: 0.2);
      borderColor = accentGreen;
    } else if (isNextLesson) {
      nodeColor = AppColors.primaryPurple.withValues(alpha: 0.25);
      borderColor = AppColors.tertiaryTeal;
    } else {
      nodeColor = Colors.white.withValues(alpha: 0.03);
      borderColor = Colors.white.withValues(alpha: 0.1);
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
                            color: AppColors.primaryPurple.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: accentGreen, size: 22)
                      : isNextLesson
                          ? const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24)
                          : const Icon(Icons.lock_rounded, color: Colors.white38, size: 18),
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? accentGreen.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  if (!isLocked) {
                    context.push(
                      '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}',
                    );
                  }
                },
                child: GlassCard(
                  blur: 20,
                  opacity: isCompleted ? 0.08 : (isNextLesson ? 0.12 : 0.03),
                  border: Border.all(
                    color: isNextLesson
                        ? AppColors.primaryPurple.withValues(alpha: 0.4)
                        : isCompleted
                            ? accentGreen.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.04),
                    width: 1,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Etapa ${lesson.level} • Módulo $index',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isNextLesson
                                          ? AppColors.tertiaryTeal
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isNextLesson) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.tertiaryTeal.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ACTUAL',
                                      style: GoogleFonts.hankenGrotesk(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.tertiaryTeal,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lesson.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isLocked ? Colors.white38 : Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lesson.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: isLocked ? Colors.white24 : AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  3,
                                  (i) => Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: i < (score != null && score! >= 95 ? 3 : (score != null && score! >= 85 ? 2 : 1))
                                        ? Colors.amber
                                        : Colors.white24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${score ?? 90}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentGreen,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isNextLesson)
                        IconButton(
                          icon: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: AppColors.primaryPurple,
                            size: 32,
                          ),
                          onPressed: () {
                            context.push(
                              '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}',
                            );
                          },
                        )
                      else
                        const Icon(Icons.lock_rounded, color: Colors.white24, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
