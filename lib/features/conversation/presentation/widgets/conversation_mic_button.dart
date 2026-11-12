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
    this.semanticsHint,
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

  /// UX-13 (#252): describe con palabras qué hace el botón, porque el gesto
  /// principal (mantener pulsado) no se deduce de la etiqueta.
  final String? semanticsHint;

  final DateTime Function() clock;
  final Duration minHoldDuration;

  @override
  State<ConversationMicButton> createState() => _ConversationMicButtonState();
}

class _ConversationMicButtonState extends State<ConversationMicButton> {
  /// Tamaño fijo del control (72 dp) y de su icono.
  static const double _diameter = 72;
  static const double _iconSize = 36;

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

  /// #329: color e icono del botón según el estado, en la paleta del HUD.
  ///
  /// Prioridad: cancelación por arrastre > grabando > procesando >
  /// reproduciendo > reposo. La cancelación gana porque al soltar se descarta
  /// el clip; el resto de estados son mutuamente excluyentes en la pantalla.
  _MicSkin _skinFor({required bool cancelling}) {
    if (cancelling) {
      return const _MicSkin(AppColors.crimsonRed, Icons.close_rounded);
    }
    if (widget.isRecording) {
      return const _MicSkin(AppColors.runeViolet, Icons.stop_rounded);
    }
    if (widget.isProcessing) {
      return const _MicSkin(AppColors.royalGold, Icons.mic_rounded);
    }
    if (widget.isPlaying) {
      return const _MicSkin(AppColors.emeraldGreen, Icons.mic_rounded);
    }
    return const _MicSkin(AppColors.manaCyan, Icons.mic_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final cancelling = widget.holdToTalk && _gesture.willCancel;
    final skin = _skinFor(cancelling: cancelling);
    final button = Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradiente del propio color de estado: da volumen al bloque sin salir
        // de la paleta (antes era un círculo blanco, único fuera del HUD).
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [skin.highlight, skin.color],
        ),
        // Glow del color de estado, no negro: el botón emite luz como el HUD.
        boxShadow: [
          BoxShadow(
            color: skin.color.withValues(alpha: 0.35),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        skin.icon,
        // Contraste sobre cian/oro/violeta/esmeralda: tinta del fondo del HUD.
        color: AppColors.voidBg,
        size: _iconSize,
      ),
    );

    if (!widget.holdToTalk) {
      // UX-13: el nodo semántico declara la acción real (un toque alterna la
      // grabación). `excludeFromSemantics` evita duplicar la acción que ya
      // aporta el `GestureDetector`.
      return Semantics(
        button: true,
        label: widget.semanticsLabel,
        hint: _semanticsHint,
        onTap: widget.onTap,
        child: GestureDetector(
          key: const ValueKey('conversation-mic-button'),
          excludeFromSemantics: true,
          onTap: widget.onTap,
          child: button,
        ),
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
        hint: _semanticsHint,
        // UX-13 (#252): TalkBack no puede mantener pulsado y soltar, así que
        // el nodo expone el mismo par de acciones que el puntero: mantener
        // inicia la grabación y el toque la detiene y envía.
        onTap: widget.onTap,
        onLongPress: widget.isProcessing ? null : widget.onHoldStart,
        child: button,
      ),
    );
  }

  /// Texto por defecto del hint; la pantalla pasa la traducción cuando la hay.
  String get _semanticsHint =>
      widget.semanticsHint ??
      (widget.holdToTalk
          ? 'Mantén pulsado para grabar y toca dos veces para detener y enviar.'
          : 'Toca dos veces para empezar o detener la grabación.');
}

/// #329: color e icono del HUD para un estado concreto del micrófono.
class _MicSkin {
  const _MicSkin(this.color, this.icon);

  /// Color base del estado (siempre de `AppColors`, nunca blanco).
  final Color color;

  /// Icono que se dibuja sobre ese color.
  final IconData icon;

  /// Extremo claro del gradiente: el color base aclarado con blanco al 22 %.
  Color get highlight =>
      Color.alphaBlend(Colors.white.withValues(alpha: 0.22), color);
}
