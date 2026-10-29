import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/providers/dashboard_providers.dart';

/// Eventos que pueden producir respuesta sensorial (P-37 / #122).
enum SensoryEvent { goalCompleted, levelUp, reviewCompleted, selection }

enum SensoryIntensity { light, medium, heavy }

/// Qué debe sonar/vibrar para un evento, según los ajustes del usuario.
///
/// Es lógica pura y testeable: la parte que toca plugins vive en
/// [SensoryFeedback].
class SensoryPlan {
  const SensoryPlan({
    this.haptic = false,
    this.sound = false,
    this.intensity = SensoryIntensity.light,
  });

  final bool haptic;
  final bool sound;
  final SensoryIntensity intensity;

  bool get isSilent => !haptic && !sound;

  static SensoryPlan forEvent(
    SensoryEvent event, {
    required bool hapticsEnabled,
    required bool soundEnabled,
  }) {
    switch (event) {
      case SensoryEvent.goalCompleted:
        return SensoryPlan(
          haptic: hapticsEnabled,
          sound: soundEnabled,
          intensity: SensoryIntensity.heavy,
        );
      case SensoryEvent.levelUp:
        return SensoryPlan(
          haptic: hapticsEnabled,
          sound: soundEnabled,
          intensity: SensoryIntensity.medium,
        );
      case SensoryEvent.reviewCompleted:
        return SensoryPlan(
          haptic: hapticsEnabled,
          intensity: SensoryIntensity.light,
        );
      case SensoryEvent.selection:
        return SensoryPlan(
          haptic: hapticsEnabled,
          intensity: SensoryIntensity.light,
        );
    }
  }
}

/// Aplica vibración y sonido del sistema respetando los ajustes.
///
/// No hay assets de audio en el proyecto: el "sonido" es el clic del sistema,
/// disponible en Android sin añadir dependencias.
class SensoryFeedback {
  SensoryFeedback(this._ref);

  final Ref _ref;

  Future<void> fire(SensoryEvent event) async {
    final settings = _ref.read(userSettingsProvider);
    final plan = SensoryPlan.forEvent(
      event,
      hapticsEnabled: settings.hapticsEnabled,
      soundEnabled: settings.soundEnabled,
    );
    if (plan.isSilent) return;

    try {
      if (plan.haptic) {
        switch (plan.intensity) {
          case SensoryIntensity.heavy:
            await HapticFeedback.heavyImpact();
          case SensoryIntensity.medium:
            await HapticFeedback.mediumImpact();
          case SensoryIntensity.light:
            await HapticFeedback.selectionClick();
        }
      }
      if (plan.sound) {
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      // Un fallo de vibración/sonido nunca debe romper la acción.
      // ignore: avoid_print
      print('SensoryFeedback failed (non-blocking): $e');
    }
  }
}

final sensoryFeedbackProvider = Provider<SensoryFeedback>((ref) {
  return SensoryFeedback(ref);
});
