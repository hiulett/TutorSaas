import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class VoiceWaveformVisualizer extends StatefulWidget {
  final bool isAiSpeaking;
  final bool isUserSpeaking;

  const VoiceWaveformVisualizer({
    super.key,
    required this.isAiSpeaking,
    required this.isUserSpeaking,
  });

  @override
  State<VoiceWaveformVisualizer> createState() => _VoiceWaveformVisualizerState();
}

class _VoiceWaveformVisualizerState extends State<VoiceWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isAiSpeaking || widget.isUserSpeaking;
    final waveColor = widget.isAiSpeaking
        ? AppColors.primaryPurple
        : (widget.isUserSpeaking ? AppColors.tertiaryTeal : Colors.white24);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(16, (index) {
              final phase = (index / 16.0) * math.pi * 2;
              final sinValue = math.sin(_controller.value * math.pi * 2 + phase).abs();
              final height = isActive ? (12 + sinValue * 32) : 6.0;

              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: waveColor.withValues(alpha: isActive ? 0.85 : 0.2),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: waveColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
