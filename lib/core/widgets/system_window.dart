import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'glass_card.dart';

class SystemWindow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final Color? accentColor;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;

  const SystemWindow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.accentColor,
    this.showCloseButton = false,
    this.onClose,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final activeAccent = accentColor ?? AppColors.manaCyan;

    return GlassCard(
      showRunicCorners: true,
      runicColor: activeAccent,
      borderColor: activeAccent.withValues(alpha: 0.6),
      padding: EdgeInsets.zero, // Padding will be structured inside
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: activeAccent.withValues(alpha: 0.3), width: 1),
              ),
              color: AppColors.voidBg.withValues(alpha: 0.2),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: activeAccent, size: 18),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: activeAccent.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showCloseButton)
                  GestureDetector(
                    onTap: onClose ?? () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: activeAccent.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        color: activeAccent.withValues(alpha: 0.1),
                      ),
                      child: Icon(Icons.close_rounded, color: activeAccent, size: 14),
                    ),
                  ),
              ],
            ),
          ),

          // Content Area
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
