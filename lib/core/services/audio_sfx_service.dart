import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sfxEnabledProvider = StateNotifierProvider<SfxNotifier, bool>((ref) {
  return SfxNotifier();
});

class SfxNotifier extends StateNotifier<bool> {
  static const _key = 'sfx_sound_effects_enabled';

  SfxNotifier() : super(true) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_key) ?? true;
    } catch (_) {}
  }

  Future<void> setSfxEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, enabled);
    } catch (_) {}
  }
}

class AudioSfxService {
  static Future<void> playLevelUp(WidgetRef ref) async {
    final enabled = ref.read(sfxEnabledProvider);
    if (!enabled) return;
    debugPrint('[SFX] 🎺 LEVEL UP - Sonido de Subida de Nivel de Cazador activado!');
  }

  static Future<void> playManaRecharge(WidgetRef ref) async {
    final enabled = ref.read(sfxEnabledProvider);
    if (!enabled) return;
    debugPrint('[SFX] 🔮 MANA RECHARGE - Sonido de Absorción de Cristal de Maná!');
  }

  static Future<void> playBossAlarm(WidgetRef ref) async {
    final enabled = ref.read(sfxEnabledProvider);
    if (!enabled) return;
    debugPrint('[SFX] 🚨 BOSS ALARM - Alarma de Jefe Guardián del Piso!');
  }

  static Future<void> playQuestComplete(WidgetRef ref) async {
    final enabled = ref.read(sfxEnabledProvider);
    if (!enabled) return;
    debugPrint('[SFX] ⚔️ QUEST COMPLETE - Misión del Monarca Cumplida!');
  }
}
