abstract class OnboardingRepository {
  Future<void> saveOnboardingData({
    required String userId,
    required String targetLanguageCode,
    required String nativeLanguageCode,
    required String cefrLevelCode,
    required int dailyGoalMinutes,
    required List<String> interests,
    required String motivation,
    required String correctionStyle,
    required String tutorPersonality,
    String? primaryObstacle,
    String? learningStyle,
  });
}
