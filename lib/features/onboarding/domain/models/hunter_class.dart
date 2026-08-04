import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class HunterClass {
  final String id;
  final IconData icon;
  final Color color;
  final String element;
  final String aura;
  final String avatarAsset;
  final String Function(AppLocalizations) nameBuilder;
  final String Function(AppLocalizations) descBuilder;
  final String Function(AppLocalizations) archetypeBuilder;

  const HunterClass({
    required this.id,
    required this.icon,
    required this.color,
    required this.element,
    required this.aura,
    required this.avatarAsset,
    required this.nameBuilder,
    required this.descBuilder,
    required this.archetypeBuilder,
  });

  String getName(AppLocalizations l10n) => nameBuilder(l10n);
  String getDesc(AppLocalizations l10n) => descBuilder(l10n);
  String getArchetype(AppLocalizations l10n) => archetypeBuilder(l10n);

  static const List<HunterClass> catalog = [
    HunterClass(
      id: 'warrior',
      icon: Icons.shield_rounded,
      color: AppColors.crimsonRed,
      element: 'Fuego',
      aura: 'carmesí',
      avatarAsset: 'assets/images/avatars/avatar_berserker_01.png',
      nameBuilder: _getWarriorName,
      descBuilder: _getWarriorDesc,
      archetypeBuilder: _getWarriorArch,
    ),
    HunterClass(
      id: 'mage',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.runeViolet,
      element: 'Arcano',
      aura: 'violeta',
      avatarAsset: 'assets/images/avatars/avatar_mage_01.png',
      nameBuilder: _getMageName,
      descBuilder: _getMageDesc,
      archetypeBuilder: _getMageArch,
    ),
    HunterClass(
      id: 'assassin',
      icon: Icons.colorize,
      color: AppColors.collabBlue,
      element: 'Sombra',
      aura: 'azul oscuro',
      avatarAsset: 'assets/images/avatars/avatar_assassin_01.png',
      nameBuilder: _getAssassinName,
      descBuilder: _getAssassinDesc,
      archetypeBuilder: _getAssassinArch,
    ),
    HunterClass(
      id: 'knight',
      icon: Icons.military_tech_rounded,
      color: AppColors.royalGold,
      element: 'Tierra',
      aura: 'dorada',
      avatarAsset: 'assets/images/avatars/avatar_knight_01.png',
      nameBuilder: _getKnightName,
      descBuilder: _getKnightDesc,
      archetypeBuilder: _getKnightArch,
    ),
    HunterClass(
      id: 'archer',
      icon: Icons.gps_fixed,
      color: AppColors.emeraldGreen,
      element: 'Viento',
      aura: 'esmeralda',
      avatarAsset: 'assets/images/avatars/avatar_archer_01.png',
      nameBuilder: _getArcherName,
      descBuilder: _getArcherDesc,
      archetypeBuilder: _getArcherArch,
    ),
    HunterClass(
      id: 'summoner',
      icon: Icons.auto_fix_high_rounded,
      color: AppColors.blindMagenta,
      element: 'Estelar',
      aura: 'magenta',
      avatarAsset: 'assets/images/avatars/avatar_summoner_01.png',
      nameBuilder: _getSummonerName,
      descBuilder: _getSummonerDesc,
      archetypeBuilder: _getSummonerArch,
    ),
    HunterClass(
      id: 'paladin',
      icon: Icons.volunteer_activism,
      color: AppColors.tutorBubbleBlue,
      element: 'Luz',
      aura: 'celeste',
      avatarAsset: 'assets/images/avatars/avatar_paladin_01.png',
      nameBuilder: _getPaladinName,
      descBuilder: _getPaladinDesc,
      archetypeBuilder: _getPaladinArch,
    ),
    HunterClass(
      id: 'necromancer',
      icon: Icons.gavel,
      color: AppColors.gemPurple,
      element: 'Óseo',
      aura: 'púrpura',
      avatarAsset: 'assets/images/avatars/avatar_necromancer_01.png',
      nameBuilder: _getNecromancerName,
      descBuilder: _getNecromancerDesc,
      archetypeBuilder: _getNecromancerArch,
    ),
  ];

  static HunterClass findById(String id) {
    final targetId = (id == 'rogue' || id == 'assassin') ? 'assassin' : id;
    return catalog.firstWhere((c) => c.id == targetId, orElse: () => catalog.first);
  }

  static String _getWarriorName(AppLocalizations l) => l.class_warrior_name;
  static String _getWarriorDesc(AppLocalizations l) => l.class_warrior_desc;
  static String _getWarriorArch(AppLocalizations l) => l.class_warrior_arch;

  static String _getMageName(AppLocalizations l) => l.class_mage_name;
  static String _getMageDesc(AppLocalizations l) => l.class_mage_desc;
  static String _getMageArch(AppLocalizations l) => l.class_mage_arch;

  static String _getAssassinName(AppLocalizations l) => l.class_assassin_name;
  static String _getAssassinDesc(AppLocalizations l) => l.class_assassin_desc;
  static String _getAssassinArch(AppLocalizations l) => l.class_assassin_arch;

  static String _getKnightName(AppLocalizations l) => l.class_knight_name;
  static String _getKnightDesc(AppLocalizations l) => l.class_knight_desc;
  static String _getKnightArch(AppLocalizations l) => l.class_knight_arch;

  static String _getArcherName(AppLocalizations l) => l.class_archer_name;
  static String _getArcherDesc(AppLocalizations l) => l.class_archer_desc;
  static String _getArcherArch(AppLocalizations l) => l.class_archer_arch;

  static String _getSummonerName(AppLocalizations l) => l.class_summoner_name;
  static String _getSummonerDesc(AppLocalizations l) => l.class_summoner_desc;
  static String _getSummonerArch(AppLocalizations l) => l.class_summoner_arch;

  static String _getPaladinName(AppLocalizations l) => l.class_paladin_name;
  static String _getPaladinDesc(AppLocalizations l) => l.class_paladin_desc;
  static String _getPaladinArch(AppLocalizations l) => l.class_paladin_arch;

  static String _getNecromancerName(AppLocalizations l) => l.class_necromancer_name;
  static String _getNecromancerDesc(AppLocalizations l) => l.class_necromancer_desc;
  static String _getNecromancerArch(AppLocalizations l) => l.class_necromancer_arch;
}
