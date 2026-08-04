import 'package:freezed_annotation/freezed_annotation.dart';

part 'placement_result.freezed.dart';
part 'placement_result.g.dart';

/// Result of the placement test taken after onboarding.
@freezed
class PlacementResult with _$PlacementResult {
  const factory PlacementResult({
    required String userId,
    /// Estimated CEFR level: A1, A2, B1, B2, C1
    required String cefrLevel,
    required String levelName,
    /// Short description of what the user can do at this level
    required String levelDescription,
    /// User's primary learning goal
    required String learningGoal,
    /// Main self-reported difficulty
    required String mainDifficulty,
    /// Score on the quick comprehension quiz (0–3)
    required int quizScore,
    /// Study plan bullet points generated for this level
    required List<String> studyPlan,
    DateTime? completedAt,
    /// Game rank assigned by the AI placement evaluator (E, D, C, B, A, S, SS, SSS)
    String? gameRank,
    /// Dimension scores (0-100) from the AI evaluator
    Map<String, int>? scores,
    /// Strengths detected by the AI evaluator
    List<String>? strengths,
    /// Weaknesses detected by the AI evaluator
    List<String>? weaknesses,
    /// AI explanation of the assigned level
    String? explanation,
    /// Recommended focus area from the AI evaluator
    String? recommendedFocus,
  }) = _PlacementResult;

  factory PlacementResult.fromJson(Map<String, dynamic> json) =>
      _$PlacementResultFromJson(json);
}
