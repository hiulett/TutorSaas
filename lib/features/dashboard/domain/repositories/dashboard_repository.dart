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
}
