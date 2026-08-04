import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Botón de micrófono con pulso animado (REF-01, extraído del dashboard).
class MicPulseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const MicPulseButton({super.key, required this.onPressed});

  @override
  State<MicPulseButton> createState() => _MicPulseButtonState();
}

class _MicPulseButtonState extends State<MicPulseButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Pulse Outer Ring
                Container(
                  width: 100 + (_controller.value * 60),
                  height: 100 + (_controller.value * 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.runeViolet.withValues(alpha: 1.0 - _controller.value),
                      width: 2,
                    ),
                  ),
                ),
                // Inner button layout
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.runeViolet,
                        AppColors.manaCyan,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.runeViolet.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: AppColors.onSurface,
                        size: 40,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'HABLAR AHORA',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
