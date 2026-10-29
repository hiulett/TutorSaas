import '../../../vocabulary/domain/models/curated_vocabulary.dart';
import '../../domain/models/conversation_message.dart';

abstract class ConversationRepository {
  Future<String> transcribeAudio(String audioPath);
  /// [actionCode] y [conversationId] viajan al proxy para el registro de uso
  /// de IA (P-14). No cambian el contenido de la conversación.
  Stream<String> getTutorResponseStream(
    List<Map<String, String>> history, {
    String actionCode = 'free_chat_turn',
    String? conversationId,
  });
  Future<String> generateTtsAudio(String text);

  // Persistence & Analysis
  Future<Map<String, dynamic>> getOrCreateConversation(String userId, {String? scenarioId});
  Future<List<ConversationMessage>> loadConversationMessages(String conversationId);
  Future<void> saveMessage(String conversationId, String senderRole, String text);
  /// P-33 (#118): extrae hasta 8 palabras nuevas de la sesión con el LLM y las
  /// persiste vía RPC (validación + dedupe + primer repaso en servidor).
  /// Devuelve las palabras realmente insertadas (puede ser vacío).
  Future<List<CuratedVocabularyItem>> curateSessionVocabulary(String userId, String conversationId, List<ConversationMessage> messages);

  /// Ask DeepSeek to evaluate which lesson goals the student has achieved
  /// based on the full conversation history. Returns map of goalId → achieved.
  Future<Map<String, bool>> evaluateGoals(
    String conversationJson,
    List<Map<String, dynamic>> goalItems,
  );

  /// Evalúa la "carisma" conversacional (coherencia, naturalidad, confianza,
  /// continuidad) de las respuestas del estudiante. Devuelve 0-100.
  Future<int> evaluateCarismaScore(List<String> userTexts);

  // Goal & Phrase Persistence
  Future<void> saveCompletedGoal(String userId, String scenarioId, String? conversationId, String goalId, String goalText);
  Future<Map<String, bool>> loadCompletedGoals(String userId, String scenarioId);
  Future<void> saveCompletedPhrase(String userId, String scenarioId, String? conversationId, String phraseId, String phraseText, {int accuracy});
  Future<Map<String, bool>> loadCompletedPhrases(String userId, String scenarioId);

  // Fluency & Response Latency Logging
  Future<void> logFluencyMetrics(String userId, String? scenarioId, double latencySeconds, int speakingWpm);

  // Audio Quota & Limits Checking
  Future<Map<String, dynamic>> checkAiAudioQuota(String userId);
  Future<Map<String, dynamic>> trackAiAudioTime(String userId, int durationSeconds);
}
