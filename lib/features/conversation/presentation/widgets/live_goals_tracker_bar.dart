import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';
import '../../../dashboard/domain/models/mission_progress_service.dart';

class LiveGoalsTrackerBar extends StatelessWidget {
  final List<ScenarioGoalItem> goals;
  final Map<String, bool> goalEvaluationResults;
  final VoidCallback onTapCompass;

  const LiveGoalsTrackerBar({
    super.key,
    required this.goals,
    required this.goalEvaluationResults,
    required this.onTapCompass,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();

    final completedCount = MissionProgressService.countCompletedGoals(goalEvaluationResults);
    final totalCount = goals.length;
    final progressRatio = MissionProgressService.lessonProgress(
      completedGoals: completedCount,
      totalGoals: totalCount,
    );

    return GestureDetector(
      onTap: onTapCompass,
      child: GlassCard(
        // Issue #56: el detector interno bloquea el tap del padre.
        onTap: onTapCompass,
        blur: 4, opacity: AppColors.glassOpacity,
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: AppColors.emeraldGreen, size: 16),
                const SizedBox(width: 8),
                Text('$completedCount/$totalCount', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: goals.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final g = entry.value;
                        final isDone = goalEvaluationResults[g.id] == true;
                        return _GoalChip(index: idx, isDone: isDone);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.explore_rounded, color: AppColors.manaCyanDim, size: 18),
              ],
            ),
            if (totalCount > 0) ...[
              const SizedBox(height: 8),
              SegmentedBar(
                value: progressRatio,
                segments: totalCount,
                height: 4,
                color: AppColors.emeraldGreen,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatefulWidget {
  final int index;
  final bool isDone;

  const _GoalChip({required this.index, required this.isDone});

  @override
  State<_GoalChip> createState() => _GoalChipState();
}

class _GoalChipState extends State<_GoalChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  bool _wasDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.standard);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: AppMotion.curveSpring)),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void didUpdateWidget(_GoalChip old) {
    super.didUpdateWidget(old);
    if (widget.isDone && !old.isDone) {
      _wasDone = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.isDone;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _wasDone ? _scaleAnim.value : 1.0;
        final glow = _wasDone ? _glowAnim.value : (isDone ? 1.0 : 0.0);
        return Container(
          margin: const EdgeInsets.only(right: 6),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDone ? AppColors.emeraldGreen.withValues(alpha: 0.2 + glow * 0.3) : AppColors.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isDone ? AppColors.emeraldGreen.withValues(alpha: 0.5 + glow * 0.5) : AppColors.onSurface.withValues(alpha: 0.12)),
                boxShadow: isDone && glow > 0 ? [BoxShadow(color: AppColors.emeraldGreen.withValues(alpha: glow * 0.4), blurRadius: 8 * glow)] : null,
              ),
              child: Row(
                children: [
                  Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 12, color: isDone ? AppColors.emeraldGreen : AppColors.onSurface.withValues(alpha: 0.38)),
                  const SizedBox(width: 4),
                  Text('M${widget.index}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDone ? AppColors.emeraldGreen : AppColors.onSurface.withValues(alpha: 0.7))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
