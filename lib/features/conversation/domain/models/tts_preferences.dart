/// P-34c (#119): parámetros del motor TTS del tutor.
///
/// Vive fuera de la UI para que el notifier y los tests compartan la misma
/// normalización: solo se admiten 0.75x, 1x y 1.25x (el check de
/// `user_settings.tts_speed` impone los mismos valores en servidor).
abstract final class TtsPreferences {
  /// Velocidad nativa del motor con multiplicador 1x. `flutter_tts` usa
  /// 0.5 como "normal" en Android; 0.48 es el valor histórico del tutor.
  static const double baseSpeechRate = 0.48;

  static const double defaultSpeed = 1.0;

  static const List<double> supportedSpeeds = <double>[0.75, 1.0, 1.25];

  /// Devuelve el valor soportado más cercano (nunca lanza).
  static double normalizeSpeed(double? value) {
    if (value == null || value.isNaN || value.isInfinite) {
      return defaultSpeed;
    }
    var best = defaultSpeed;
    var bestDelta = double.infinity;
    for (final speed in supportedSpeeds) {
      final delta = (speed - value).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = speed;
      }
    }
    return best;
  }

  /// Velocidad que se pasa a `FlutterTts.setSpeechRate`.
  static double speechRateFor(double speed) =>
      baseSpeechRate * normalizeSpeed(speed);

  /// Etiqueta corta para la UI (p. ej. `0.75×`).
  static String label(double speed) {
    final normalized = normalizeSpeed(speed);
    if (normalized == 1.0) return '1×';
    if (normalized == 0.75) return '0.75×';
    return '1.25×';
  }
}
