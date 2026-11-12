import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? shadow;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool showRunicCorners;
  final Color? runicColor;
  final String? semanticLabel;

  /// Callback al tocar la tarjeta. Se integra en el GestureDetector interno
  /// (junto a la animación de prensado) para que el tap no quede "tragado"
  /// por el hijo y los `onTap` de los padres nunca lleguen a dispararse.
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = AppColors.glassBlur,
    this.opacity = AppColors.glassOpacity,
    this.borderRadius = AppRadius.sm,
    this.border,
    this.padding,
    this.shadow,
    this.borderColor,
    this.backgroundColor,
    this.showRunicCorners = false,
    this.runicColor,
    this.semanticLabel,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _runicController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppMotion.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: AppMotion.curvePress),
    );
    _runicController = AnimationController(
      vsync: this,
      duration: AppMotion.ambient,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // UX-04: sin `Ticker` vivo cuando el sistema pide reducir animaciones.
    // 0.5 mantiene las esquinas rúnicas a media opacidad (aspecto estático).
    AppMotion.syncLoop(
      _runicController,
      allowed: AppMotion.loopsAllowed(context),
      reverse: true,
      stillValue: 0.5,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _runicController.dispose();
    super.dispose();
  }

  Widget _runicCorner(double opacity, {bool rotated = false}) {
    final rColor = widget.runicColor ?? AppColors.manaCyan;
    return Transform.rotate(
      angle: rotated ? 3.14159 : 0,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: rColor.withValues(alpha: opacity), width: 2),
            left: BorderSide(
              color: rColor.withValues(alpha: opacity),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  /// Alfa del borde cuando el llamador pide foco con `borderColor` (#327).
  ///
  /// Si el color recibido ya trae una alfa propia (< 1.0) se respeta, para que
  /// una tarjeta pueda pedir más énfasis que el foco estándar (la CTA del
  /// dashboard usa 0.6) sin tocar la API.
  static const double _focusBorderAlpha = 0.5;

  /// Alfa del halo (`boxShadow`) por defecto (#327): apenas separa la tarjeta
  /// del fondo, sin robar atención a la acción principal.
  static const double _defaultShadowAlpha = 0.12;
  static const double _defaultShadowBlur = 6;

  @override
  Widget build(BuildContext context) {
    final hasExplicitBorderColor = widget.borderColor != null;
    final bColor = widget.borderColor ?? AppColors.manaCyan;
    final borderAlpha = !hasExplicitBorderColor
        ? AppColors.glassBorderAlpha
        : (bColor.a < 1.0 ? bColor.a : _focusBorderAlpha);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _runicController]),
        // El contenido se pasa como `child` para que no se reconstruya en cada
        // frame de la animación de runas. Reconstruirlo dentro del
        // BackdropFilter dejaba un "fantasma" del texto a otra escala (#303).
        child: widget.child,
        builder: (context, child) {
          final runeOpacity = 0.3 + (_runicController.value * 0.7);
          Widget card = Container(
            decoration: BoxDecoration(
              boxShadow:
                  widget.shadow ??
                  [
                    BoxShadow(
                      color: bColor.withValues(alpha: _defaultShadowAlpha),
                      blurRadius: _defaultShadowBlur,
                    ),
                  ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        widget.backgroundColor ??
                        AppColors.surfaceGlass.withValues(
                          alpha: widget.opacity,
                        ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border:
                        widget.border ??
                        Border.all(
                          color: bColor.withValues(alpha: borderAlpha),
                          width: 1,
                        ),
                  ),
                  child: child,
                ),
              ),
            ),
          );
          if (widget.semanticLabel != null) {
            card = Semantics(
              label: widget.semanticLabel,
              container: true,
              child: card,
            );
          }
          if (!widget.showRunicCorners)
            return Transform.scale(scale: _scaleAnimation.value, child: card);
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                card,
                Positioned(
                  top: -2,
                  left: -2,
                  child: ExcludeSemantics(child: _runicCorner(runeOpacity)),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: ExcludeSemantics(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: _runicCorner(runeOpacity),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: ExcludeSemantics(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: _runicCorner(runeOpacity),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: ExcludeSemantics(
                    child: _runicCorner(runeOpacity, rotated: true),
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
