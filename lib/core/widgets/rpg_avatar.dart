import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class RpgAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final double size;
  final Color? borderColor;
  final bool isBoss;
  final String? hunterClass;

  const RpgAvatar({
    super.key,
    this.avatarUrl,
    required this.initials,
    this.size = 50.0,
    this.borderColor,
    this.isBoss = false,
    this.hunterClass,
  });

  /// Mapa de clase → asset local del avatar (avatares del onboarding).
  static const Map<String, String> _classAssets = {
    'warrior': 'assets/images/avatars/avatar_berserker_01.png',
    'mage': 'assets/images/avatars/avatar_mage_01.png',
    'assassin': 'assets/images/avatars/avatar_assassin_01.png',
    'knight': 'assets/images/avatars/avatar_knight_01.png',
    'archer': 'assets/images/avatars/avatar_archer_01.png',
    'summoner': 'assets/images/avatars/avatar_summoner_01.png',
    'paladin': 'assets/images/avatars/avatar_paladin_01.png',
    'necromancer': 'assets/images/avatars/avatar_necromancer_01.png',
  };

  @override
  Widget build(BuildContext context) {
    // Ignore DiceBear to enforce RPG immersion
    final bool isDiceBear = avatarUrl?.contains('dicebear.com') ?? false;
    final bool isClassName = _classAssets.containsKey(avatarUrl);
    final bool hasValidImage = avatarUrl != null && !isDiceBear && !isClassName && avatarUrl!.isNotEmpty && avatarUrl!.startsWith('http');
    final String? classAsset = isClassName ? _classAssets[avatarUrl] : null;

    final String resolvedClass = hunterClass ?? (isClassName ? avatarUrl! : 'warrior');

    Color borderCol = borderColor ?? AppColors.manaCyan;
    if (isBoss) {
      borderCol = AppColors.bossRed;
    } else {
      switch (resolvedClass.toLowerCase()) {
        case 'monarch':
        case 'legendary':
          borderCol = AppColors.rarityLegendary;
          break;
        case 'elite':
        case 'epic':
          borderCol = AppColors.rarityEpic;
          break;
        case 'rare':
        case 'assassin':
          borderCol = AppColors.rarityRare;
          break;
        case 'warrior':
          borderCol = AppColors.hpBarRed;
          break;
        case 'mage':
          borderCol = AppColors.manaCyan;
          break;
        case 'necromancer':
          borderCol = AppColors.runeViolet;
          break;
        case 'knight':
        case 'paladin':
          borderCol = AppColors.royalGold;
          break;
        case 'archer':
          borderCol = AppColors.emeraldGreen;
          break;
        case 'summoner':
          borderCol = AppColors.blindMagenta;
          break;
        default:
          borderCol = AppColors.manaCyan;
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: borderCol, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: borderCol.withValues(alpha: 0.4),
            blurRadius: 8.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: hasValidImage
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(resolvedClass),
              )
            : classAsset != null
                ? Image.asset(
                    classAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallback(resolvedClass),
                  )
                : _buildFallback(resolvedClass),
      ),
    );
  }

  Widget _buildFallback(String resolvedClass) {
    IconData classIcon;
    Color iconColor;

    switch (resolvedClass.toLowerCase()) {
      case 'mage':
        classIcon = Icons.auto_awesome;
        iconColor = AppColors.manaCyan;
        break;
      case 'assassin':
        classIcon = Icons.colorize;
        iconColor = AppColors.rarityRare;
        break;
      case 'warrior':
        classIcon = Icons.shield;
        iconColor = AppColors.hpBarRed;
        break;
      case 'necromancer':
        classIcon = Icons.gavel;
        iconColor = AppColors.runeViolet;
        break;
      case 'priest':
      case 'paladin':
        classIcon = Icons.volunteer_activism;
        iconColor = AppColors.emeraldGreen;
        break;
      case 'knight':
        classIcon = Icons.military_tech;
        iconColor = AppColors.royalGold;
        break;
      case 'archer':
        classIcon = Icons.gps_fixed;
        iconColor = AppColors.emeraldGreen;
        break;
      case 'summoner':
        classIcon = Icons.auto_fix_high;
        iconColor = AppColors.blindMagenta;
        break;
      default:
        classIcon = Icons.shield_moon;
        iconColor = AppColors.manaCyan;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainerLow,
            AppColors.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: isBoss 
            ? Icon(Icons.security, size: size * 0.5, color: AppColors.bossRed)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(classIcon, size: size * 0.35, color: iconColor),
                  if (size >= 45) ...[
                    const SizedBox(height: 2),
                    Text(
                      initials.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: size * 0.20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
