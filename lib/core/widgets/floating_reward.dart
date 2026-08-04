import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

class FloatingReward extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Offset startPosition;

  const FloatingReward({
    super.key,
    required this.text,
    this.icon,
    this.color = AppColors.royalGold,
    this.startPosition = Offset.zero,
  });

  static void show(BuildContext context, String text, {IconData? icon, Color? color}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _FloatingRewardOverlay(text: text, icon: icon, color: color ?? AppColors.royalGold),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }

  @override
  State<FloatingReward> createState() => _FloatingRewardState();
}

class _FloatingRewardState extends State<FloatingReward>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.reward);
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.5)).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.curveStandard),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: MediaQuery.of(context).size.width * 0.5 - 60,
          child: Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, -_slideAnim.value.dy * 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: widget.color.withValues(alpha: 0.5)),
                  boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.3), blurRadius: 12)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[Icon(widget.icon!, color: widget.color, size: 18), const SizedBox(width: 6)],
                    Text(widget.text, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingRewardOverlay extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  const _FloatingRewardOverlay({required this.text, this.icon, required this.color});
  @override
  State<_FloatingRewardOverlay> createState() => _FloatingRewardOverlayState();
}

class _FloatingRewardOverlayState extends State<_FloatingRewardOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)); _controller.forward(); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final fade = _controller.value < 0.6 ? 1.0 : 1.0 - ((_controller.value - 0.6) / 0.4);
        final offset = -_controller.value * 40;
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.3 + offset, left: 0, right: 0,
          child: Opacity(
            opacity: fade.clamp(0.0, 1.0),
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: widget.color.withValues(alpha: 0.5)),
                    boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.3), blurRadius: 12)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[Icon(widget.icon!, color: widget.color, size: 20), const SizedBox(width: 8)],
                      Text(widget.text, style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
