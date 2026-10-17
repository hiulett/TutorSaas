import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/quest_card.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/lesson_catalog.dart';
import '../../domain/models/lesson_unlock_service.dart';
import '../../domain/models/lesson_halo.dart';
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
  final List<String> _levels = ['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  /// Alto estimado de cada tile del mapa (~96px) para limitar 12 visibles.
  static const double _tileHeight = 96.0;

  /// ¿La lección [candidate] es una sub misión de [parent]?
  /// Convención: las sub misiones generadas usan el id del padre como prefijo
  /// (p. ej. `parentId_refuerzo_vocab`) o comparten categoría + skill.
  static bool _isSubMissionOf(LessonData candidate, LessonData parent) {
    final cId = candidate.id.toLowerCase();
    final pId = parent.id.toLowerCase();
    if (cId.startsWith('${pId}_')) return true;
    if (cId.contains('_refuerzo_') || cId.contains('_sub_')) return true;
    return false;
  }

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
                AppLocalizations.of(context)?.path_roadmap_title ?? 'Ruta por Etapas (CEFR)',
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
          GlassCard(
            blur: 15,
            opacity: AppColors.glassOpacity,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                AppLocalizations.of(context)?.path_stage_empty ?? 'No hay lecciones registradas para esta etapa aún.',
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          // Mapa de Mazmorras: solo 12 nodos visibles; el resto con scroll
          // interno (el tile tiene ~96px de alto). La altura no excede el
          // viewport disponible (evita overflow en pantallas pequeñas/tests).
          LayoutBuilder(
            builder: (context, constraints) {
              final maxH = constraints.maxHeight > 0
                  ? constraints.maxHeight
                  : double.infinity;
              final desired = 12 * _tileHeight;
              final height = maxH.isFinite && desired > maxH ? maxH : desired;
              return SizedBox(
                height: height,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: stageLessons.length,
                  itemBuilder: (context, index) {
                    final lesson = stageLessons[index];
                    final state = LessonUnlockService.classify(
                      lesson: lesson,
                  userCefr: widget.activeUserLevel,
                  goalRows: completedGoalRows,
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
                final isMastered = lessonProgress >= 1.0;
                final iconData = _getIconData(lesson.iconKey);

                // Sub misiones de esta lección (mazmorras ocultas desbloqueadas):
                // lecciones generadas cuyo skill_focus coincide o que son de la
                // misma "misión" (se resuelven por el id de padre en la BD).
                final submisions = LessonCatalog.catalog
                    .where((l) =>
                        l.level == lesson.level &&
                        l.id != lesson.id &&
                        (l.id.contains(lesson.id) || _isSubMissionOf(l, lesson)))
                    .take(3)
                    .toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoadmapNodeTile(
                      lesson: lesson,
                      index: index + 1,
                      total: stageLessons.length,
                      isCompleted: isCompleted,
                      isNextLesson: isNextLesson,
                      isUnlockedByOracle: isUnlockedByOracle,
                      isLocked: isLocked,
                      isMastered: isMastered,
                      haloColor: LessonHalo.colorFor(lessonProgress),
                      haloAlpha: LessonHalo.intensityFor(lessonProgress),
                      haloBlur: LessonHalo.blurFor(lessonProgress),
                      progress: lessonProgress,
                      progressSegments: lessonTotalGoals <= 0 ? 1 : lessonTotalGoals,
                      iconData: iconData,
                      isLast: false,
                    ),
                    // Sub misiones indentadas (solo las desbloqueadas).
                    ...submisions.map((sm) => _SubMissionTile(lesson: sm)),
                  ],
                );
              },
            ),
              );
            },
          ),
        const SizedBox(height: 14),
        // Tarjeta "Evaluación del Oráculo" — reto de promoción del nivel.
        _OracleChallengeCard(
          level: _selectedLevel,
          completedLessons: stageLessons
              .where((l) => LessonUnlockService.classify(
                    lesson: l,
                    userCefr: widget.activeUserLevel,
                    goalRows: completedGoalRows,
                    catalog: LessonCatalog.catalog,
                  ) ==
                  LessonUnlockState.completedByPlayer)
              .length,
          totalLessons: stageLessons.length,
        ),
      ],
    );
  }
}

class _RoadmapNodeTile extends StatefulWidget {
  final LessonData lesson;
  final int index;
  final int total;
  final bool isCompleted;
  final bool isNextLesson;
  final bool isUnlockedByOracle;
  final bool isLocked;
  final bool isMastered;
  final Color haloColor;
  final double haloAlpha;
  final double haloBlur;
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
    required this.isMastered,
    required this.haloColor,
    required this.haloAlpha,
    required this.haloBlur,
    required this.progress,
    required this.progressSegments,
    required this.iconData,
    required this.isLast,
  });

  @override
  State<_RoadmapNodeTile> createState() => _RoadmapNodeTileState();
}

class _RoadmapNodeTileState extends State<_RoadmapNodeTile>
    with SingleTickerProviderStateMixin {
  static const Color accentGreen = AppColors.accentGreen;

  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulse = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isMastered) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _RoadmapNodeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMastered && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isMastered && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Halo según el % de metas: dorado pulsante (maestría 100%), violeta
  /// (superada ≥70%), cian (en progreso) o brillo de arranque (siguiente).
  List<BoxShadow>? _buildGlow() {
    if (widget.isMastered) {
      final t = _pulse.value;
      return [
        BoxShadow(
          color: AppColors.royalGold.withValues(alpha: 0.75 + 0.20 * t),
          blurRadius: 18 + 8 * t,
          spreadRadius: 2 + 2 * t,
        ),
      ];
    }
    if (widget.haloAlpha > 0) {
      return [
        BoxShadow(
          color: widget.haloColor.withValues(alpha: widget.haloAlpha),
          blurRadius: widget.haloBlur,
          spreadRadius: widget.haloBlur > 16 ? 2 : 0,
        ),
      ];
    }
    if (widget.isNextLesson) {
      return [
        BoxShadow(
          color: AppColors.runeViolet.withValues(alpha: 0.4),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ];
    }
    return null;
  }

  Widget _buildIcon() {
    if (widget.isCompleted) {
      return Icon(
        Icons.emoji_events_rounded,
        color: widget.isMastered ? AppColors.royalGold : accentGreen,
        size: 20,
      );
    }
    if (widget.isNextLesson) {
      return const Icon(Icons.play_arrow_rounded, color: AppColors.onSurface, size: 24);
    }
    if (widget.isUnlockedByOracle) {
      return const Icon(Icons.auto_awesome_rounded, color: AppColors.runeViolet, size: 18);
    }
    return Icon(Icons.lock_rounded, color: AppColors.onSurface.withValues(alpha: 0.38), size: 18);
  }

  @override
  Widget build(BuildContext context) {
    Color nodeColor;
    Color borderColor;

    if (widget.isCompleted) {
      nodeColor = accentGreen.withValues(alpha: 0.2);
      borderColor = widget.isMastered ? AppColors.royalGold : accentGreen;
    } else if (widget.isNextLesson) {
      nodeColor = AppColors.runeViolet.withValues(alpha: 0.25);
      borderColor = AppColors.manaCyan;
    } else if (widget.isUnlockedByOracle) {
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
                    width: widget.isNextLesson ? 2.0 : 1.5,
                  ),
                  boxShadow: _buildGlow(),
                ),
                child: Center(child: _buildIcon()),
              ),

              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: widget.isCompleted
                        ? (widget.isMastered
                            ? AppColors.royalGold.withValues(alpha: 0.6)
                            : accentGreen.withValues(alpha: 0.5))
                        : widget.isUnlockedByOracle
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
                title: widget.lesson.title,
                description: widget.lesson.description,
                rank: widget.isCompleted
                    ? 'S'
                    : (widget.isNextLesson ? 'B' : (widget.isUnlockedByOracle ? 'O' : 'D')),
                gemReward: widget.isCompleted ? 0 : 15,
                xpReward: widget.isCompleted ? 0 : 100,
                progress: widget.progress,
                progressSegments: widget.progressSegments,
                onTap: widget.isLocked ? () {
                  SystemSnack.show(context, '🔒 MAZMORRA BLOQUEADA: Completa los desafíos previos.', type: SystemSnackType.error);
                } : () {
                  context.push(
                    '/conversation?scenarioId=${widget.lesson.id}&scenarioTitle=${Uri.encodeComponent(widget.lesson.title)}',
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

/// Tile de sub misión (mazmorra oculta desbloqueada): indentado bajo su lección
/// padre, con conector visual y estilo de "refuerzo" (maná cyan, menor tamaño).
class _SubMissionTile extends ConsumerWidget {
  final LessonData lesson;

  const _SubMissionTile({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedGoalRows = ref.watch(completedGoalsProvider).value ?? [];
    final lessonProgress = MissionProgressService.lessonProgress(
      completedGoals: MissionProgressService.completedGoalsForScenario(
        completedGoalRows,
        lesson.id,
      ),
      totalGoals: lesson.goals.length,
    );
    final isMastered = lessonProgress >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 40,
            color: AppColors.manaCyan.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 10),
          Icon(
            isMastered ? Icons.check_circle_rounded : Icons.auto_awesome_rounded,
            color: isMastered ? AppColors.emeraldGreen : AppColors.manaCyan,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(
                '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMastered ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sub-Misión · ${(lessonProgress * 100).round()}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: AppColors.manaCyan.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta "Evaluación del Oráculo" — gate de promoción del nivel.
/// Se desbloquea al completar ≥80% de las lecciones del nivel; permite retar
/// al Oráculo para subir de nivel (nunca baja).
class _OracleChallengeCard extends ConsumerWidget {
  final String level;
  final int completedLessons;
  final int totalLessons;

  const _OracleChallengeCard({
    required this.level,
    required this.completedLessons,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ratio = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final unlocked = ratio >= 0.80;
    final pct = (ratio * 100).round();

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      border: Border.all(
        color: unlocked ? AppColors.royalGold : AppColors.onSurface.withValues(alpha: 0.1),
        width: unlocked ? 1.5 : 1,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (unlocked ? AppColors.royalGold : AppColors.runeViolet).withValues(alpha: 0.2),
              border: Border.all(color: unlocked ? AppColors.royalGold : AppColors.runeViolet),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: unlocked ? AppColors.royalGold : AppColors.runeViolet,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.oracle_challenge_title ?? 'EVALUACIÓN DEL ORÁCULO',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unlocked
                      ? (l10n?.oracle_challenge_ready ?? 'El Oráculo te espera. ¡Reto disponible!')
                      : (l10n != null
                          ? l10n.oracle_challenge_progress(pct)
                          : 'Completa el 80% para retar al Oráculo ($pct%)'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (unlocked)
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.royalGold),
              onPressed: () => context.push(
                '/oracle-test?mode=promotion&level=$level',
              ),
            )
          else
            Icon(
              Icons.lock_rounded,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              size: 18,
            ),
        ],
      ),
    );
  }
}
