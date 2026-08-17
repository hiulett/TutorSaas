abstract class DashboardRepository {
  Future<Map<String, dynamic>> getUserProgress(String userId);
  Future<List<Map<String, dynamic>>> getRecommendedLessons(String userId);
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId);
  Future<String> getCorrectionLevel(String userId);
  Future<void> updateCorrectionLevel(String userId, String level);
  Future<List<Map<String, dynamic>>> getWeeklyPractice(String userId);
  Future<List<Map<String, dynamic>>> getLearnedVocabulary(String userId);
  Future<Map<String, dynamic>> getUserSettings(String userId);
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings);
  Future<void> logPracticeSession(String userId, int minutes);
  Future<void> saveVocabularyFromSession(String userId, List<String> userTexts);
  Future<void> updateVocabularySrsScore(String userId, String vocabularyId, double qualityScore);
  Future<void> updateUserProfile(
    String userId, {
    String? displayName,
    String? avatarUrl,
    String? nativeLanguage,
    String? bio,
    int? strStat,
    int? intStat,
    int? dexStat,
    int? lukStat,
    String? equippedTitleCode,
  });

  /// Títulos de habilidad ganados por el usuario (filas de `user_titles`).
  Future<List<Map<String, dynamic>>> getEarnedTitles(String userId);

  /// Métricas reales de conversación usadas por los títulos de habilidad.
  Future<Map<String, dynamic>> getConversationMetrics(String userId);

  /// Evalúa el desempeño real (métricas de conversación) y registra los
  /// títulos ganados. Devuelve los códigos de títulos recién ganados.
  /// [carisma] (0-100) es el score de carisma evaluado por IA de la sesión.
  Future<List<String>> syncEarnedTitles(String userId, {double carisma = 0});
}
