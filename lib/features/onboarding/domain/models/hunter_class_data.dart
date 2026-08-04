import 'package:flutter/material.dart';

/// Representa una clase de cazador obtenida desde la tabla `hunter_classes`.
///
/// A diferencia del catálogo estático `HunterClass` (fallback en memoria), esta
/// estructura permite escalar añadiendo registros en la BD sin tocar código.
/// Incluye metadatos preparados para el sistema de progresión futuro
/// (habilidades, afinidad, dificultad, estilo de juego).
class HunterClassData {
  final String id;
  final String nameEn;
  final String nameEs;
  final String namePt;
  final String roleEn;
  final String roleEs;
  final String rolePt;
  final String descriptionEn;
  final String descriptionEs;
  final String descriptionPt;
  final String imageUrl;
  final IconData icon;
  final String element;
  final String aura;
  final String rarity;
  final Color color;
  final int displayOrder;
  final bool isActive;
  final bool isStarter;
  final int difficulty;
  final String combatTypeEn;
  final String combatTypeEs;
  final String combatTypePt;
  final String affinityEn;
  final String affinityEs;
  final String affinityPt;
  final List<String> abilitiesEn;
  final List<String> abilitiesEs;
  final List<String> abilitiesPt;
  final String playstyleEn;
  final String playstyleEs;
  final String playstylePt;

  // ── Stats de combate (radar 6-D, 0-100) ────────────────────────────────────
  final int statsAttack;
  final int statsDefense;
  final int statsMagic;
  final int statsSpeed;
  final int statsSupport;
  final int statsSurvival;

  const HunterClassData({
    required this.id,
    required this.nameEn,
    this.nameEs = '',
    this.namePt = '',
    required this.roleEn,
    this.roleEs = '',
    this.rolePt = '',
    this.descriptionEn = '',
    this.descriptionEs = '',
    this.descriptionPt = '',
    this.imageUrl = '',
    this.icon = Icons.shield_moon_rounded,
    this.element = '',
    this.aura = '',
    this.rarity = 'comun',
    this.color = const Color(0xFF00E5FF),
    this.displayOrder = 0,
    this.isActive = true,
    this.isStarter = true,
    this.difficulty = 1,
    this.combatTypeEn = '',
    this.combatTypeEs = '',
    this.combatTypePt = '',
    this.affinityEn = '',
    this.affinityEs = '',
    this.affinityPt = '',
    this.abilitiesEn = const [],
    this.abilitiesEs = const [],
    this.abilitiesPt = const [],
    this.playstyleEn = '',
    this.playstyleEs = '',
    this.playstylePt = '',
    this.statsAttack = 50,
    this.statsDefense = 50,
    this.statsMagic = 50,
    this.statsSpeed = 50,
    this.statsSupport = 50,
    this.statsSurvival = 50,
  });

  String nameFor(String locale) {
    switch (locale.substring(0, 2).toLowerCase()) {
      case 'es':
        return nameEs.isNotEmpty ? nameEs : nameEn;
      case 'pt':
        return namePt.isNotEmpty ? namePt : nameEn;
      default:
        return nameEn;
    }
  }

  String roleFor(String locale) {
    switch (locale.substring(0, 2).toLowerCase()) {
      case 'es':
        return roleEs.isNotEmpty ? roleEs : roleEn;
      case 'pt':
        return rolePt.isNotEmpty ? rolePt : roleEn;
      default:
        return roleEn;
    }
  }

  String descriptionFor(String locale) {
    switch (locale.substring(0, 2).toLowerCase()) {
      case 'es':
        return descriptionEs.isNotEmpty ? descriptionEs : descriptionEn;
      case 'pt':
        return descriptionPt.isNotEmpty ? descriptionPt : descriptionEn;
      default:
        return descriptionEn;
    }
  }

  String combatTypeFor(String locale) {
    switch (locale.substring(0, 2).toLowerCase()) {
      case 'es':
        return combatTypeEs.isNotEmpty ? combatTypeEs : combatTypeEn;
      case 'pt':
        return combatTypePt.isNotEmpty ? combatTypePt : combatTypeEn;
      default:
        return combatTypeEn;
    }
  }

  String affinityFor(String locale) {
    switch (locale.substring(0, 2).toLowerCase()) {
      case 'es':
        return affinityEs.isNotEmpty ? affinityEs : affinityEn;
      case 'pt':
        return affinityPt.isNotEmpty ? affinityPt : affinityEn;
      default:
        return affinityEn;
    }
  }

  List<String> abilitiesFor(String locale) {
    switch (locale.substring(0, 2).toLowerCase()) {
      case 'es':
        return abilitiesEs.isNotEmpty ? abilitiesEs : abilitiesEn;
      case 'pt':
        return abilitiesPt.isNotEmpty ? abilitiesPt : abilitiesEn;
      default:
        return abilitiesEn;
    }
  }

  String playstyleFor(String locale) {
    switch (locale.substring(0, 2).toLowerCase()) {
      case 'es':
        return playstyleEs.isNotEmpty ? playstyleEs : playstyleEn;
      case 'pt':
        return playstylePt.isNotEmpty ? playstylePt : playstyleEn;
      default:
        return playstyleEn;
    }
  }

  /// Construye la instancia desde una fila de `hunter_classes`.
  factory HunterClassData.fromMap(Map<String, dynamic> map) {
    List<String> _list(dynamic v) {
      if (v is List) {
        return v.whereType<String>().where((s) => s.trim().isNotEmpty).toList();
      }
      return const [];
    }

    IconData _icon(String name) {
      const known = <String, IconData>{
        'shield': Icons.shield_rounded,
        'auto_awesome': Icons.auto_awesome_rounded,
        'colorize': Icons.colorize,
        'military_tech': Icons.military_tech_rounded,
        'gps_fixed': Icons.gps_fixed,
        'auto_fix_high': Icons.auto_fix_high_rounded,
        'volunteer_activism': Icons.volunteer_activism,
        'gavel': Icons.gavel,
      };
      return known[name] ?? Icons.shield_moon_rounded;
    }

    Color _color(String hex) {
      final cleaned = hex.replaceAll('#', '');
      final value = int.tryParse(cleaned, radix: 16);
      if (value == null) return const Color(0xFF00E5FF);
      return Color(0xFF000000 | value);
    }

    return HunterClassData(
      id: map['id']?.toString() ?? '',
      nameEn: map['name_en']?.toString() ?? '',
      nameEs: map['name_es']?.toString() ?? '',
      namePt: map['name_pt']?.toString() ?? '',
      roleEn: map['role_en']?.toString() ?? '',
      roleEs: map['role_es']?.toString() ?? '',
      rolePt: map['role_pt']?.toString() ?? '',
      descriptionEn: map['description_en']?.toString() ?? '',
      descriptionEs: map['description_es']?.toString() ?? '',
      descriptionPt: map['description_pt']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      icon: _icon(map['icon']?.toString() ?? ''),
      element: map['element']?.toString() ?? '',
      aura: map['aura']?.toString() ?? '',
      rarity: map['rarity']?.toString() ?? 'comun',
      color: _color(map['color']?.toString() ?? '#00E5FF'),
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      isStarter: map['is_starter'] as bool? ?? true,
      difficulty: (map['difficulty'] as num?)?.toInt() ?? 1,
      combatTypeEn: map['combat_type_en']?.toString() ?? '',
      combatTypeEs: map['combat_type_es']?.toString() ?? '',
      combatTypePt: map['combat_type_pt']?.toString() ?? '',
      affinityEn: map['affinity_en']?.toString() ?? '',
      affinityEs: map['affinity_es']?.toString() ?? '',
      affinityPt: map['affinity_pt']?.toString() ?? '',
      abilitiesEn: _list(map['abilities_en']),
      abilitiesEs: _list(map['abilities_es']),
      abilitiesPt: _list(map['abilities_pt']),
      playstyleEn: map['playstyle_en']?.toString() ?? '',
      playstyleEs: map['playstyle_es']?.toString() ?? '',
      playstylePt: map['playstyle_pt']?.toString() ?? '',
      statsAttack: (map['stats_attack'] as num?)?.toInt() ?? 50,
      statsDefense: (map['stats_defense'] as num?)?.toInt() ?? 50,
      statsMagic: (map['stats_magic'] as num?)?.toInt() ?? 50,
      statsSpeed: (map['stats_speed'] as num?)?.toInt() ?? 50,
      statsSupport: (map['stats_support'] as num?)?.toInt() ?? 50,
      statsSurvival: (map['stats_survival'] as num?)?.toInt() ?? 50,
    );
  }
}
