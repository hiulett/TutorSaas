import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

class AnimatedCounter extends StatefulWidget {
  final int target;
  final int? previous;
  final TextStyle? style;
  final Duration duration;
  final bool autoStart;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.previous,
    this.style,
    this.duration = AppMotion.standard,
    this.autoStart = true,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Valor desde el que se anima. Arranca en el objetivo (no en 0): si el
  /// provider emite tarde o varias veces, el número debe mostrar la cifra real
  /// y no quedarse a medio camino de una animación que empieza de cero.
  late int _from;

  @override
  void initState() {
    super.initState();
    _from = widget.previous ?? widget.target;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.autoStart) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _from = old.target;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final start = _from.toDouble();
        final value = start + (widget.target - start) * _animation.value;
        return Text(
          value.round().toString(),
          style: widget.style ?? GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface),
        );
      },
    );
  }
}
