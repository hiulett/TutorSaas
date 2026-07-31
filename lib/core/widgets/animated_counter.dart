import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.duration = const Duration(milliseconds: 600),
    this.autoStart = true,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.autoStart) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
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
        final start = (widget.previous ?? 0).toDouble();
        final value = start + (widget.target - start) * _animation.value;
        return Text(
          value.round().toString(),
          style: widget.style ?? GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
        );
      },
    );
  }
}
