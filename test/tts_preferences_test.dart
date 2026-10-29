import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/tts_preferences.dart';
import 'package:tutorsaas/features/dashboard/domain/models/user_settings.dart';

/// P-34c (#119): velocidad del TTS acotada a los valores que acepta el check
/// de `user_settings.tts_speed`.
void main() {
  group('TtsPreferences', () {
    test('normaliza cualquier valor al soportado más cercano', () {
      expect(TtsPreferences.normalizeSpeed(0.75), 0.75);
      expect(TtsPreferences.normalizeSpeed(1.0), 1.0);
      expect(TtsPreferences.normalizeSpeed(1.25), 1.25);
      expect(TtsPreferences.normalizeSpeed(0.8), 0.75);
      expect(TtsPreferences.normalizeSpeed(1.1), 1.0);
      expect(TtsPreferences.normalizeSpeed(1.3), 1.25);
      expect(TtsPreferences.normalizeSpeed(null), 1.0);
      expect(TtsPreferences.normalizeSpeed(double.nan), 1.0);
      expect(TtsPreferences.normalizeSpeed(double.infinity), 1.0);
    });

    test('aplica el multiplicador sobre la velocidad base', () {
      expect(TtsPreferences.speechRateFor(1.0), 0.48);
      expect(TtsPreferences.speechRateFor(0.75), closeTo(0.36, 0.0001));
      expect(TtsPreferences.speechRateFor(1.25), closeTo(0.60, 0.0001));
    });

    test('etiqueta de UI', () {
      expect(TtsPreferences.label(0.75), '0.75×');
      expect(TtsPreferences.label(1.0), '1×');
      expect(TtsPreferences.label(1.25), '1.25×');
    });
  });

  group('UserSettings tts', () {
    test('fromJson/toJson conservan tts_speed y tutor_voice_id', () {
      final settings = UserSettings.fromJson(const {
        'correction_level': 'short',
        'tts_speed': 1.25,
        'tutor_voice_id': 'en-us-x-iol',
      });

      expect(settings.ttsSpeed, 1.25);
      expect(settings.tutorVoiceId, 'en-us-x-iol');

      final json = settings.toJson();
      expect(json['tts_speed'], 1.25);
      expect(json['tutor_voice_id'], 'en-us-x-iol');
    });

    test('sin columnas usa los valores por defecto', () {
      final settings = UserSettings.fromJson(const {});
      expect(settings.ttsSpeed, 1.0);
      expect(settings.tutorVoiceId, isNull);
    });
  });
}
