import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/models/drop_loot.dart';

/// Notificación tipo overlay de un drop sorpresa (RPG-05).
class DropNotification extends StatelessWidget {
  final DropLoot loot;

  const DropNotification({super.key, required this.loot});

  /// Muestra la notificación flotando en la parte superior de la pantalla.
  /// Se elimina automáticamente tras 2.5 segundos.
  static void show(BuildContext context, DropLoot loot) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _DropOverlay(
        loot: loot,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
    Timer(const Duration(milliseconds: 2500), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = loot.rarity.color;
    return GlassCard(
      borderColor: rarityColor,
      borderRadius: 4,
      showRunicCorners: loot.rarity == DropRarity.legendario,
      runicColor: rarityColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(loot.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡DROP SORPRESA!',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: rarityColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loot.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DropLoot.rarityLabel(loot.rarity),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: rarityColor,
                  ),
                ),
                if (loot.goldBonus > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+${loot.xpBonus} XP / +${loot.goldBonus} oro',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.auto_awesome_rounded, color: rarityColor, size: 22),
        ],
      ),
    );
  }
}

class _DropOverlay extends StatelessWidget {
  final DropLoot loot;
  final VoidCallback onDismiss;

  const _DropOverlay({required this.loot, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding + 24,
      left: 24,
      right: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * -24),
            child: child,
          ),
        ),
        child: DropNotification(loot: loot),
      ),
    );
  }
}
