import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../domain/models/listening_exercise.dart';

/// Reproductor del diálogo del ejercicio de comprensión auditiva.
///
/// El audio se sintetiza en el dispositivo con `flutter_tts`: no hay ninguna
/// llamada a un modelo de IA (coste 0). No toca el pipeline de voz de la
/// conversación (record → STT → LLM → TTS): es un reproductor aislado que solo
/// habla texto.
abstract class ListeningAudio {
  Future<void> play(List<ListeningLine> lines);

  Future<void> stop();
}

class ListeningTts implements ListeningAudio {
  ListeningTts({FlutterTts? engine}) : _tts = engine ?? FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;
  bool _playing = false;

  bool get isPlaying => _playing;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  @override
  Future<void> play(List<ListeningLine> lines) async {
    if (lines.isEmpty) return;
    _playing = true;
    try {
      await _ensureReady();
      await _tts.stop();
      for (final line in lines) {
        // Un fallo de una línea no debe silenciar el resto del diálogo.
        try {
          await _tts.speak(line.spoken);
        } catch (e) {
          debugPrint('ListeningTts: no se pudo leer una línea: $e');
        }
      }
    } catch (e) {
      debugPrint('ListeningTts.play failed (non-blocking): $e');
    } finally {
      _playing = false;
    }
  }

  @override
  Future<void> stop() async {
    _playing = false;
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('ListeningTts.stop failed (non-blocking): $e');
    }
  }
}
