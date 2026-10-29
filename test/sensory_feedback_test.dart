import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/services/sensory_feedback.dart';

/// P-37 (#122): el pulido sensorial respeta los ajustes del usuario.
void main() {
  SensoryPlan plan(
    SensoryEvent event, {
    bool haptics = true,
    bool sound = true,
  }) =>
      SensoryPlan.forEvent(event, hapticsEnabled: haptics, soundEnabled: sound);

  test('meta cumplida: vibracion fuerte y sonido', () {
    final p = plan(SensoryEvent.goalCompleted);

    expect(p.haptic, isTrue);
    expect(p.sound, isTrue);
    expect(p.intensity, SensoryIntensity.heavy);
    expect(p.isSilent, isFalse);
  });

  test('subida de nivel: vibracion media y sonido', () {
    final p = plan(SensoryEvent.levelUp);

    expect(p.intensity, SensoryIntensity.medium);
    expect(p.sound, isTrue);
  });

  test('repaso y seleccion: solo vibracion ligera', () {
    expect(plan(SensoryEvent.reviewCompleted).sound, isFalse);
    expect(
      plan(SensoryEvent.reviewCompleted).intensity,
      SensoryIntensity.light,
    );
    expect(plan(SensoryEvent.selection).intensity, SensoryIntensity.light);
  });

  test('con la vibracion apagada no se pide haptic', () {
    expect(plan(SensoryEvent.goalCompleted, haptics: false).haptic, isFalse);
    expect(plan(SensoryEvent.levelUp, haptics: false).haptic, isFalse);
  });

  test('con sonido apagado no se pide audio', () {
    expect(plan(SensoryEvent.goalCompleted, sound: false).sound, isFalse);
    expect(plan(SensoryEvent.levelUp, sound: false).sound, isFalse);
  });

  test('todo apagado es silencio total', () {
    for (final event in SensoryEvent.values) {
      final p = plan(event, haptics: false, sound: false);
      expect(p.isSilent, isTrue, reason: '$event');
    }
  });
}
