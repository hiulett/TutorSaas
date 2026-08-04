import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Botón primario con micro-interacción de escala (Fase 10 · AN-D).
/// Sigue el diseño PlantillasHTML: radio 4px, acento, glow. Al presionar
/// escala sutilmente (150ms) y respeta reduce-motion del sistema.
class RunicButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isBusy;
  final String? semanticLabel;
  final String? tooltip;

  const RunicButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.runeViolet,
    this.foregroundColor = AppColors.onSurface,
    this.isBusy = false,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  State<RunicButton> createState() => _RunicButtonState();
}

class _RunicButtonState extends State<RunicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.micro,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.curvePress),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(_) => _controller.forward();
  void _handleTapUp(_) => _controller.reverse();
  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isBusy;
    final reducedMotion = AppMotion.reduceMotion(context);
    final background = enabled ? widget.backgroundColor : AppColors.onSurface.withValues(alpha: 0.12);
    final isIconOnly = widget.icon != null && widget.label.trim().isEmpty;
    final effectiveTooltip = widget.tooltip ?? (isIconOnly ? widget.semanticLabel : null);

    Widget button = Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: enabled ? _handleTapDown : null,
        onTapUp: enabled ? _handleTapUp : null,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: reducedMotion ? 1.0 : _scale.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: background.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: background,
                  foregroundColor: widget.foregroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  elevation: 0,
                ),
                child: widget.isBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: AppColors.onSurface, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
    if (effectiveTooltip != null) {
      button = Tooltip(message: effectiveTooltip, child: button);
    }
    return button;
  }
}
