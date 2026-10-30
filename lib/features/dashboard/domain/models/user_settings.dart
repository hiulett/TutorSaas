import '../../../notifications/domain/models/reminder_settings.dart';

class UserSettings {
  final String correctionLevel;
  final String correctionStyle;
  final String tutorPersonality;
  final int dailyGoalMinutes;

  /// P-34c (#119): multiplicador del TTS del tutor (0.75x / 1x / 1.25x).
  final double ttsSpeed;

  /// P-34c (#119): nombre de la voz del motor TTS. `null` = voz del sistema.
  final String? tutorVoiceId;
  final bool notificationsEnabled;
  final bool hapticsEnabled;
  final bool soundEnabled;

  /// P-34f (#198): `true` = mantener pulsado el micrófono para hablar.
  /// `false` = tap-to-toggle (comportamiento histórico).
  final bool micModeHoldToTalk;
  final String notificationTime;

  /// Dias ISO del recordatorio diario (1 = lunes ... 7 = domingo).
  final List<int> notificationDays;
  final List<String> interests;
  final String motivation;

  UserSettings({
    required this.correctionLevel,
    required this.correctionStyle,
    required this.tutorPersonality,
    required this.dailyGoalMinutes,
    this.ttsSpeed = 1.0,
    this.tutorVoiceId,
    required this.notificationsEnabled,
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.micModeHoldToTalk = false,
    required this.notificationTime,
    this.notificationDays = ReminderSettings.everyDay,
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
      notificationDays: ReminderSettings.everyDay,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      correctionLevel: json['correction_level'] as String? ?? 'short',
      correctionStyle: json['correction_style'] as String? ?? 'balanced',
      tutorPersonality: json['tutor_personality'] as String? ?? 'friendly',
      dailyGoalMinutes: json['daily_goal_minutes'] as int? ?? 15,
      ttsSpeed: (json['tts_speed'] as num?)?.toDouble() ?? 1.0,
      tutorVoiceId: json['tutor_voice_id'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? false,
      hapticsEnabled: json['haptics_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      micModeHoldToTalk: json['mic_mode_hold_to_talk'] as bool? ?? false,
      notificationTime: json['notification_time'] as String? ?? '20:00:00',
      notificationDays: ReminderSettings.normalizeDays(
        json['notification_days'],
      ),
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
      'tts_speed': ttsSpeed,
      'tutor_voice_id': tutorVoiceId,
      'notifications_enabled': notificationsEnabled,
      'haptics_enabled': hapticsEnabled,
      'sound_enabled': soundEnabled,
      'mic_mode_hold_to_talk': micModeHoldToTalk,
      'notification_time': notificationTime,
      'notification_days': notificationDays,
      'interests': interests,
      'motivation': motivation,
    };
  }

  UserSettings copyWith({
    String? correctionLevel,
    String? correctionStyle,
    String? tutorPersonality,
    int? dailyGoalMinutes,
    double? ttsSpeed,
    String? tutorVoiceId,
    bool? notificationsEnabled,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? micModeHoldToTalk,
    String? notificationTime,
    List<int>? notificationDays,
    List<String>? interests,
    String? motivation,
  }) {
    return UserSettings(
      correctionLevel: correctionLevel ?? this.correctionLevel,
      correctionStyle: correctionStyle ?? this.correctionStyle,
      tutorPersonality: tutorPersonality ?? this.tutorPersonality,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      tutorVoiceId: tutorVoiceId ?? this.tutorVoiceId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      micModeHoldToTalk: micModeHoldToTalk ?? this.micModeHoldToTalk,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationDays: notificationDays ?? this.notificationDays,
      interests: interests ?? this.interests,
      motivation: motivation ?? this.motivation,
    );
  }
}
