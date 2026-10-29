import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tts_preferences.dart';

/// P-34a / c / g (#119): barra de estado de la conversación.
///
/// - "Escuchando…" mientras graba (P-34g).
/// - "Pensando… 3s" mientras espera al modelo (P-34g: latencia visible).
/// - "El tutor está hablando" con velocidad, ajustes de voz y "Detener"
///   (P-34a corta la narración; P-34c cambia la velocidad en caliente).
///
/// Solo UI/estado: no toca el pipeline record → STT → LLM → TTS.
class ConversationStatusBar extends StatefulWidget {
  const ConversationStatusBar({
    super.key,
    required this.isRecording,
    required this.isProcessing,
    required this.isPlaying,
    required this.ttsSpeed,
    required this.listeningLabel,
    required this.thinkingLabel,
    required this.speakingLabel,
    required this.stopLabel,
    required this.voiceSettingsTooltip,
    required this.onStopTts,
    required this.onOpenVoiceSettings,
    required this.onSpeedChanged,
  });

  final bool isRecording;
  final bool isProcessing;
  final bool isPlaying;
  final double ttsSpeed;
  final String listeningLabel;
  final String thinkingLabel;
  final String speakingLabel;
  final String stopLabel;
  final String voiceSettingsTooltip;
  final VoidCallback onStopTts;
  final VoidCallback onOpenVoiceSettings;
  final ValueChanged<double> onSpeedChanged;

  @override
  State<ConversationStatusBar> createState() => _ConversationStatusBarState();
}

class _ConversationStatusBarState extends State<ConversationStatusBar> {
  Timer? _thinkingTicker;
  int _elapsedSeconds = 0;

  bool get _isActive =>
      widget.isRecording || widget.isProcessing || widget.isPlaying;

  @override
  void initState() {
    super.initState();
    if (widget.isProcessing) _startThinkingTicker();
  }

  @override
  void didUpdateWidget(covariant ConversationStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing && !oldWidget.isProcessing) {
      _startThinkingTicker();
    } else if (!widget.isProcessing && oldWidget.isProcessing) {
      _stopThinkingTicker();
    }
  }

  @override
  void dispose() {
    _thinkingTicker?.cancel();
    super.dispose();
  }

  void _startThinkingTicker() {
    _thinkingTicker?.cancel();
    _elapsedSeconds = 0;
    _thinkingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopThinkingTicker() {
    _thinkingTicker?.cancel();
    _thinkingTicker = null;
    _elapsedSeconds = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox.shrink();

    final Color accent;
    final IconData icon;
    final String baseLabel;
    if (widget.isRecording) {
      accent = AppColors.manaCyan;
      icon = Icons.mic_rounded;
      baseLabel = widget.listeningLabel;
    } else if (widget.isProcessing) {
      accent = AppColors.guildAmber;
      icon = Icons.auto_awesome_rounded;
      baseLabel = widget.thinkingLabel;
    } else {
      accent = AppColors.runeViolet;
      icon = Icons.volume_up_rounded;
      baseLabel = widget.speakingLabel;
    }

    final label = widget.isProcessing && _elapsedSeconds > 0
        ? '$baseLabel ${_elapsedSeconds}s'
        : baseLabel;

    return Container(
      key: const Key('conversation-status-bar'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  key: const Key('conversation-status-label'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              IconButton(
                key: const Key('conversation-voice-settings'),
                tooltip: widget.voiceSettingsTooltip,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: widget.onOpenVoiceSettings,
              ),
            ],
          ),
          if (widget.isPlaying)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...TtsPreferences.supportedSpeeds.map(_buildSpeedChip),
                  _buildStopButton(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(double speed) {
    final selected =
        (TtsPreferences.normalizeSpeed(widget.ttsSpeed) - speed).abs() < 0.001;
    return InkWell(
      key: Key('conversation-speed-${TtsPreferences.label(speed)}'),
      onTap: () => widget.onSpeedChanged(speed),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.runeViolet.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.runeViolet : Colors.white24,
          ),
        ),
        child: Text(
          TtsPreferences.label(speed),
          style: TextStyle(
            color: selected ? AppColors.runeVioletText : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return TextButton.icon(
      key: const Key('conversation-stop-tts'),
      onPressed: widget.onStopTts,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.crimsonRed,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.stop_circle_outlined, size: 16),
      label: Text(
        widget.stopLabel,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
