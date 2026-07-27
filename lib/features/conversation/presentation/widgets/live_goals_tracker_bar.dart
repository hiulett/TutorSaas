import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';

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

  static const Color accentGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedCount = goals.where((g) => goalEvaluationResults[g.id] == true).length;
    final totalCount = goals.length;

    return GestureDetector(
      onTap: onTapCompass,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.flag_rounded,
              color: AppColors.tertiaryTeal,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Metas: $completedCount/$totalCount',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
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

                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDone
                            ? accentGreen.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDone ? accentGreen : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 12,
                            color: isDone ? accentGreen : Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'M$idx',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDone ? accentGreen : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Icon(
              Icons.explore_rounded,
              color: AppColors.primaryPurpleDim,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
