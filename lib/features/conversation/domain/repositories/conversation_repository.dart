import '../../../corrections/domain/models/correction_turn_result.dart';
import '../../../vocabulary/domain/models/curated_vocabulary.dart';
import '../../domain/models/conversation_message.dart';
import '../../domain/models/goal_evaluation_result.dart';
import '../../domain/models/help_phrase.dart';

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
  Future<Map<String, dynamic>> getOrCreateConversation(
    String userId, {
    String? scenarioId,
  });
  Future<List<ConversationMessage>> loadConversationMessages(
    String conversationId,
  );
  Future<void> saveMessage(
    String conversationId,
    String senderRole,
    String text,
  );

  /// P-33 (#118): extrae hasta 8 palabras nuevas de la sesión con el LLM y las
  /// persiste vía RPC (validación + dedupe + primer repaso en servidor).
  /// Devuelve las palabras realmente insertadas (puede ser vacío).
  Future<List<CuratedVocabularyItem>> curateSessionVocabulary(
    String userId,
    String conversationId,
    List<ConversationMessage> messages,
  );

  /// Ask DeepSeek to evaluate which lesson goals the student has achieved
  /// based on the full conversation history. Returns map of goalId → achieved.
  /// P-29: la misma llamada devuelve también las correcciones del turno,
  /// para no añadir una petición extra por turno.
  Future<GoalEvaluationResult> evaluateGoals(
    String conversationJson,
    List<Map<String, dynamic>> goalItems,
  );

  /// P-29-b (#193): pide SOLO las correcciones del turno cuando la sesión no
  /// tiene metas de lección pendientes (conversación libre). Usa su propio
  /// `action_code` (`correction_turn`) para que el proxy cobre en maná; un 402
  /// se devuelve como [CorrectionTurnOutcome.noMana] y no rompe el chat.
  Future<CorrectionTurnResult> evaluateTurnCorrections(
    String conversationText, {
    String? conversationId,
  });

  /// Evalúa la "carisma" conversacional (coherencia, naturalidad, confianza,
  /// continuidad) de las respuestas del estudiante. Devuelve 0-100.
  Future<int> evaluateCarismaScore(List<String> userTexts);

  // Goal & Phrase Persistence
  Future<void> saveCompletedGoal(
    String userId,
    String scenarioId,
    String? conversationId,
    String goalId,
    String goalText,
  );
  Future<Map<String, bool>> loadCompletedGoals(
    String userId,
    String scenarioId,
  );
  Future<void> saveCompletedPhrase(
    String userId,
    String scenarioId,
    String? conversationId,
    String phraseId,
    String phraseText, {
    int accuracy,
  });
  Future<Map<String, bool>> loadCompletedPhrases(
    String userId,
    String scenarioId,
  );

  /// P-34b (#119): frases de ayuda del escenario desde `scenario_phrases`.
  /// Devuelve vacío si la tabla no tiene datos (hoy es el caso en producción).
  Future<List<HelpPhrase>> loadScenarioPhrases(
    String scenarioId, {
    int limit = 3,
  });

  // Fluency & Response Latency Logging
  Future<void> logFluencyMetrics(
    String userId,
    String? scenarioId,
    double latencySeconds,
    int speakingWpm,
  );

  // Audio Quota & Limits Checking
  Future<Map<String, dynamic>> checkAiAudioQuota(String userId);
  Future<Map<String, dynamic>> trackAiAudioTime(
    String userId,
    int durationSeconds,
  );
}
