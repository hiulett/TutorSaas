import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String userId,
    @Default(0) int xp,
    @Default(0) int streak,
    @Default('A1') String levelCode,
    @Default('Principiante') String levelName,
    @Default('en') String targetLanguageCode,
    @Default('Inglés') String targetLanguageName,
    @Default('🇺🇸') String targetLanguageEmoji,
    @Default(0) int totalConversations,
    @Default(0) int totalMinutesPracticed,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);

  /// Constructs from the raw Map returned by Supabase RPC / repository.
  factory UserProgress.fromMap(String userId, Map<String, dynamic> map) =>
      UserProgress(
        userId: userId,
        xp: (map['xp'] as num?)?.toInt() ?? 0,
        streak: (map['streak'] as num?)?.toInt() ?? 0,
        levelCode: map['level_code'] as String? ?? 'A1',
        levelName: map['level'] as String? ?? 'Principiante',
        targetLanguageCode: map['language_code'] as String? ?? 'en',
        targetLanguageName: map['language'] as String? ?? 'Inglés',
        targetLanguageEmoji: map['language_emoji'] as String? ?? '🇺🇸',
        totalConversations: (map['total_conversations'] as num?)?.toInt() ?? 0,
        totalMinutesPracticed: (map['total_minutes'] as num?)?.toInt() ?? 0,
      );
}
