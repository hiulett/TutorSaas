class UserSettings {
  final String correctionLevel;
  final String correctionStyle;
  final String tutorPersonality;
  final int dailyGoalMinutes;
  final bool notificationsEnabled;
  final String notificationTime;
  final List<String> interests;
  final String motivation;

  UserSettings({
    required this.correctionLevel,
    required this.correctionStyle,
    required this.tutorPersonality,
    required this.dailyGoalMinutes,
    required this.notificationsEnabled,
    required this.notificationTime,
    this.interests = const [],
    this.motivation = '',
  });

  factory UserSettings.initial() {
    return UserSettings(
      correctionLevel: 'short',
      correctionStyle: 'balanced',
      tutorPersonality: 'friendly',
      dailyGoalMinutes: 15,
      notificationsEnabled: false,
      notificationTime: '20:00:00',
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      correctionLevel: json['correction_level'] as String? ?? 'short',
      correctionStyle: json['correction_style'] as String? ?? 'balanced',
      tutorPersonality: json['tutor_personality'] as String? ?? 'friendly',
      dailyGoalMinutes: json['daily_goal_minutes'] as int? ?? 15,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? false,
      notificationTime: json['notification_time'] as String? ?? '20:00:00',
      interests: List<String>.from(json['interests'] ?? []),
      motivation: json['motivation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correction_level': correctionLevel,
      'correction_style': correctionStyle,
      'tutor_personality': tutorPersonality,
      'daily_goal_minutes': dailyGoalMinutes,
      'notifications_enabled': notificationsEnabled,
      'notification_time': notificationTime,
      'interests': interests,
      'motivation': motivation,
    };
  }

  UserSettings copyWith({
    String? correctionLevel,
    String? correctionStyle,
    String? tutorPersonality,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
    String? notificationTime,
    List<String>? interests,
    String? motivation,
  }) {
    return UserSettings(
      correctionLevel: correctionLevel ?? this.correctionLevel,
      correctionStyle: correctionStyle ?? this.correctionStyle,
      tutorPersonality: tutorPersonality ?? this.tutorPersonality,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      interests: interests ?? this.interests,
      motivation: motivation ?? this.motivation,
    );
  }
}
