import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/hold_to_talk_gesture.dart';

/// P-34f (#198): máquina de estados pura del gesto mantener-para-hablar.
void main() {
  final t0 = DateTime.utc(2026, 10, 29, 12);

  group('umbral mínimo', () {
    test('soltar antes de 300 ms se descarta sin enviar', () {
      final gesture = HoldToTalkGesture();
      expect(gesture.press(t0), HoldToTalkAction.start);
      expect(
        gesture.release(t0.add(const Duration(milliseconds: 299))),
        HoldToTalkAction.tooShort,
      );
    });

    test('soltar justo en el umbral envía', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      expect(
        gesture.release(t0.add(HoldToTalkGesture.defaultMinHoldDuration)),
        HoldToTalkAction.send,
      );
    });

    test('una pulsación larga envía', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      expect(
        gesture.release(t0.add(const Duration(seconds: 3))),
        HoldToTalkAction.send,
      );
    });
  });

  group('cancelación por arrastre', () {
    test('soltar fuera del radio cancela aunque la pulsación sea larga', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      expect(
        gesture.drag(HoldToTalkGesture.defaultCancelDistance + 1),
        HoldToTalkAction.none,
      );
      expect(gesture.willCancel, isTrue);
      expect(
        gesture.release(t0.add(const Duration(seconds: 2))),
        HoldToTalkAction.cancel,
      );
    });

    test('volver dentro del botón recupera el envío', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      gesture.drag(HoldToTalkGesture.defaultCancelDistance + 40);
      expect(gesture.willCancel, isTrue);
      gesture.drag(10);
      expect(gesture.willCancel, isFalse);
      expect(
        gesture.release(t0.add(const Duration(milliseconds: 800))),
        HoldToTalkAction.send,
      );
    });

    test('cancelación del sistema descarta sin enviar', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      expect(gesture.cancel(), HoldToTalkAction.cancel);
      expect(gesture.isHolding, isFalse);
    });

    test('arrastrar fuera sin soltar no escribe cancelación por sí solo', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      gesture.drag(HoldToTalkGesture.defaultCancelDistance + 1);
      expect(gesture.isHolding, isTrue);
      expect(
        gesture.elapsedAt(t0.add(const Duration(seconds: 1))),
        const Duration(seconds: 1),
      );
    });
  });

  group('secuencias inválidas', () {
    test('soltar sin pulsar no hace nada', () {
      final gesture = HoldToTalkGesture();
      expect(gesture.release(t0), HoldToTalkAction.none);
      expect(gesture.cancel(), HoldToTalkAction.none);
      expect(gesture.drag(999), HoldToTalkAction.none);
    });

    test('pulsar dos veces no reinicia el gesto', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      expect(
        gesture.press(t0.add(const Duration(milliseconds: 200))),
        HoldToTalkAction.none,
      );
      // El origen sigue siendo el primer press: 350 ms después de t0.
      expect(
        gesture.release(t0.add(const Duration(milliseconds: 350))),
        HoldToTalkAction.send,
      );
    });

    test('tras liberar el gesto vuelve a estar inactivo', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      gesture.release(t0.add(const Duration(milliseconds: 400)));
      expect(gesture.isHolding, isFalse);
      expect(gesture.willCancel, isFalse);
      expect(gesture.elapsedAt(t0), Duration.zero);
    });

    test('un reloj hacia atrás no produce duraciones negativas', () {
      final gesture = HoldToTalkGesture();
      gesture.press(t0);
      expect(
        gesture.elapsedAt(t0.subtract(const Duration(seconds: 1))),
        Duration.zero,
      );
      expect(
        gesture.release(t0.subtract(const Duration(seconds: 1))),
        HoldToTalkAction.tooShort,
      );
    });
  });
}
