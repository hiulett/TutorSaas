import 'package:flutter/material.dart';
import 'package:tutorsaas/core/theme/app_colors.dart';
import 'package:tutorsaas/features/conversation/domain/models/hold_to_talk_gesture.dart';

/// P-34f (#198): botón de micrófono de la conversación.
///
/// Dos interacciones sobre el mismo botón:
/// - `holdToTalk = false` (tap-to-toggle, comportamiento histórico): el toque
///   alterna entre grabar y detener.
/// - `holdToTalk = true`: empezar a grabar al pulsar, enviar al soltar dentro
///   del botón, descartar si se suelta antes del umbral y cancelar si se
///   arrastra lo suficiente lejos.
///
/// El widget no toca el pipeline de voz: solo decide cuándo se llama al
/// notifier. La lógica del gesto vive en [HoldToTalkGesture] (pura y testeable).
class ConversationMicButton extends StatefulWidget {
  const ConversationMicButton({
    super.key,
    required this.holdToTalk,
    required this.isRecording,
    required this.isProcessing,
    required this.isPlaying,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onHoldTooShort,
    required this.onHoldCancel,
    this.semanticsLabel = 'Micrófono',
    this.clock = DateTime.now,
    this.minHoldDuration = HoldToTalkGesture.defaultMinHoldDuration,
  });

  final bool holdToTalk;
  final bool isRecording;
  final bool isProcessing;
  final bool isPlaying;

  /// Tap-to-toggle: grabar / detener / cortar el TTS.
  final VoidCallback onTap;

  /// Pulsación mantenida: iniciar la grabación.
  final VoidCallback onHoldStart;

  /// Se soltó dentro del botón por encima del umbral mínimo.
  final ValueChanged<Duration> onHoldEnd;

  /// Se soltó dentro del botón antes del umbral mínimo.
  final ValueChanged<Duration> onHoldTooShort;

  /// Se soltó fuera del botón o el sistema canceló el puntero.
  final VoidCallback onHoldCancel;

  final String semanticsLabel;
  final DateTime Function() clock;
  final Duration minHoldDuration;

  @override
  State<ConversationMicButton> createState() => _ConversationMicButtonState();
}

class _ConversationMicButtonState extends State<ConversationMicButton> {
  late HoldToTalkGesture _gesture = _buildGesture();

  HoldToTalkGesture _buildGesture() =>
      HoldToTalkGesture(minHoldDuration: widget.minHoldDuration);

  @override
  void didUpdateWidget(covariant ConversationMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minHoldDuration != widget.minHoldDuration ||
        oldWidget.holdToTalk != widget.holdToTalk) {
      _gesture = _buildGesture();
    }
  }

  double _distanceFromCenter(Offset globalPosition) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return 0;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    return (globalPosition - center).distance;
  }

  void _onPointerDown(PointerDownEvent event) {
    // Durante el turno del tutor no se inicia otra grabación (misma regla que
    // el modo tap-to-toggle en `ConversationNotifier`).
    if (widget.isProcessing) return;
    if (_gesture.press(widget.clock()) == HoldToTalkAction.start) {
      setState(() {});
      widget.onHoldStart();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_gesture.isHolding) return;
    final wasCancelling = _gesture.willCancel;
    _gesture.drag(_distanceFromCenter(event.position));
    if (wasCancelling != _gesture.willCancel) setState(() {});
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_gesture.isHolding) return;
    final now = widget.clock();
    final heldFor = _gesture.elapsedAt(now);
    final action = _gesture.release(now);
    setState(() {});
    switch (action) {
      case HoldToTalkAction.send:
        widget.onHoldEnd(heldFor);
      case HoldToTalkAction.tooShort:
        widget.onHoldTooShort(heldFor);
      case HoldToTalkAction.cancel:
        widget.onHoldCancel();
      case HoldToTalkAction.none:
      case HoldToTalkAction.start:
        break;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_gesture.isHolding) return;
    final action = _gesture.cancel();
    setState(() {});
    if (action == HoldToTalkAction.cancel) widget.onHoldCancel();
  }

  @override
  Widget build(BuildContext context) {
    final cancelling = widget.holdToTalk && _gesture.willCancel;
    final button = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cancelling ? AppColors.runeViolet : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        cancelling
            ? Icons.close_rounded
            : (widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded),
        color: const Color(0xFF0F172A),
        size: 36,
      ),
    );

    if (!widget.holdToTalk) {
      return GestureDetector(
        key: const ValueKey('conversation-mic-button'),
        onTap: widget.onTap,
        child: button,
      );
    }

    return Listener(
      key: const ValueKey('conversation-mic-button'),
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Semantics(
        button: true,
        label: widget.semanticsLabel,
        child: button,
      ),
    );
  }
}
