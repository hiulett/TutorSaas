import '../../domain/models/conversation_message.dart';

abstract class ConversationRepository {
  Future<String> transcribeAudio(String audioPath);
  Stream<String> getTutorResponseStream(List<Map<String, String>> history);
  Future<String> generateTtsAudio(String text);

  // Persistence & Analysis
  Future<Map<String, dynamic>> getOrCreateConversation(String userId, {String? scenarioId});
  Future<List<ConversationMessage>> loadConversationMessages(String conversationId);
  Future<void> saveMessage(String conversationId, String senderRole, String text);
  Future<void> analyzeAndSaveSessionProgress(String userId, String conversationId, List<ConversationMessage> messages, {String? scenarioId});

  /// Ask DeepSeek to evaluate which lesson goals the student has achieved
  /// based on the full conversation history. Returns map of goalId → achieved.
  Future<Map<String, bool>> evaluateGoals(
    String conversationJson,
    List<Map<String, dynamic>> goalItems,
  );

  // Goal & Phrase Persistence
  Future<void> saveCompletedGoal(String userId, String scenarioId, String? conversationId, String goalId, String goalText);
  Future<Map<String, bool>> loadCompletedGoals(String userId, String scenarioId);
  Future<void> saveCompletedPhrase(String userId, String scenarioId, String? conversationId, String phraseId, String phraseText, {int accuracy});
  Future<Map<String, bool>> loadCompletedPhrases(String userId, String scenarioId);

  // Fluency & Response Latency Logging
  Future<void> logFluencyMetrics(String userId, String? scenarioId, double latencySeconds, int speakingWpm);
}
