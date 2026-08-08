import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Música ambiente de la taberna (toggle manual).
///
/// Singleton que reproduce `assets/music/tavermusic.mp3` en loop a volumen
/// bajo. NO se auto-reproduce al abrir pantallas (evita interferir con el
/// primer renderizado); el usuario la enciende/apaga con un botón.
///
/// Toda operación es diferida y no bloqueante, con try-catch completo para
/// que un fallo de audio jamás afecte el widget tree.
class TavernMusicService {
  TavernMusicService._();
  static final TavernMusicService instance = TavernMusicService._();

  AudioPlayer? _player;
  bool _initialized = false;
  bool _playing = false;
  Future<void>? _pending;

  /// Reproduce la música (o la pausa si ya estaba sonando). Devuelve el
  /// estado final (true = sonando).
  Future<bool> toggle() async {
    if (_playing) {
      await pause();
      return false;
    }
    await play();
    return _playing;
  }

  Future<void> play() async {
    if (_playing) return;
    _pending ??= _ensureStarted();
    await _pending;
  }

  Future<void> pause() async {
    if (!_playing) return;
    try {
      await _player?.pause();
    } catch (_) {}
    _playing = false;
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
    _playing = false;
  }

  bool get isPlaying => _playing;

  Future<void> _ensureStarted() async {
    // Difiere la inicialización fuera del build/layout frame.
    await Future<void>.delayed(Duration.zero);
    try {
      final player = _player ??= AudioPlayer();
      if (!_initialized) {
        await player.setAsset('assets/music/tavermusic.mp3');
        await player.setLoopMode(LoopMode.one);
        await player.setVolume(0.15);
        _initialized = true;
      }
      await player.play();
      _playing = true;
    } catch (e) {
      debugPrint('TavernMusicService error (non-blocking): $e');
      _playing = false;
    }
  }
}
