import 'package:flutter/material.dart';
import '../../../../core/theme/app_motion.dart';

/// Mensaje con animación de entrada (slide + fade).
/// Extraído de conversation_screen (REF-02).
class AnimatedMessage extends StatefulWidget {
  final Widget child;
  final int delay;

  const AnimatedMessage({super.key, required this.child, this.delay = 0});

  @override
  State<AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<AnimatedMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.fast);
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: AppMotion.curveStandard));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _controller.forward(); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(offset: Offset(0, _slideAnim.value.dy * 20), child: widget.child),
        );
      },
    );
  }
}
