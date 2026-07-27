import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String emoji,
    @Default(false) bool isUnlocked,
    DateTime? unlockedAt,
    /// Progress toward unlocking: 0.0 – 1.0
    @Default(0.0) double progress,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        emoji: map['emoji'] as String? ?? '🏆',
        isUnlocked: map['is_unlocked'] as bool? ?? false,
        unlockedAt: map['unlocked_at'] != null
            ? DateTime.tryParse(map['unlocked_at'] as String)
            : null,
        progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      );
}
