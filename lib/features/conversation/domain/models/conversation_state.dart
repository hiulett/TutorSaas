import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversation_message.dart';

part 'conversation_state.freezed.dart';

@freezed
class ConversationState with _$ConversationState {
  const factory ConversationState({
    required List<ConversationMessage> messages,
    @Default(false) bool isRecording,
    @Default(false) bool isProcessing,
    @Default(false) bool isPlaying,
    @Default('') String currentTranscribingText,
    String? errorMessage,
    /// Optional scenario context loaded before a roleplay session
    String? activeScenarioId,
    String? activeScenarioName,

    /// AI-evaluated goal results: key = goal.id, value = achieved
    @Default({}) Map<String, bool> goalEvaluationResults,

    /// Counter of goals completed since last build (drives FloatingReward).
    @Default(0) int newGoalsCompleted,

    /// Selected conversational tactic ('fluency' | 'grammar' | 'hints').
    @Default('fluency') String selectedTactic,

    // ── Oracle Evaluation Mode (onboarding Step 4) ────────────────────────
    /// True when this session is the Oracle conversational placement exam.
    @Default(false) bool isOracleEvaluation,

    /// Language the user is being evaluated in (the language to learn).
    @Default('en') String oracleTargetLanguage,

    /// The user's native language (used for instructions fallback only).
    @Default('es') String oracleNativeLanguage,

    /// Non-null once the Oracle finishes the exam; holds the placement result.
    Map<String, dynamic>? oracleResult,
  }) = _ConversationState;

  /// Returns initial empty state. First message is set by [initSession].
  factory ConversationState.initial() => const ConversationState(
        messages: [],
      );
}
