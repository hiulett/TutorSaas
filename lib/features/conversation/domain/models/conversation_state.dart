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
  }) = _ConversationState;

  /// Returns initial empty state. First message is set by [initSession].
  factory ConversationState.initial() => const ConversationState(
        messages: [],
      );
}
