import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/hunter_class.dart';
import '../../domain/models/hunter_class_data.dart';

/// Obtiene las clases de cazador desde la tabla `hunter_classes`.
///
/// Si la BD aún no tiene la tabla/migración aplicada (proyecto en read-only o
/// pre-migración), hace fallback al catálogo estático [HunterClass.catalog]
/// para no romper el onboarding.
final hunterClassesProvider = FutureProvider.autoDispose<List<HunterClassData>>(
  (ref) async {
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('hunter_classes')
          .select()
          .eq('is_active', true)
          .order('display_order');
      if (rows.isNotEmpty) {
        return rows.map((m) => HunterClassData.fromMap(m)).toList();
      }
    } catch (e) {
      debugPrint('hunter_classes fetch failed, using catalog fallback: $e');
    }
    return _catalogFallback();
  },
);

/// Convierte el catálogo estático (8 clases) a [HunterClassData] para el
/// fallback. Mantiene los textos i18n vía los builders de [HunterClass].
List<HunterClassData> _catalogFallback() {
  final fallback = <HunterClassData>[];

  void add({
    required String id,
    required String nameEn,
    required String roleEn,
    required String descEn,
    required IconData icon,
    required Color color,
    required String element,
    required String aura,
    required String rarity,
    required int order,
    required String avatar,
    int atk = 50,
    int def = 50,
    int mag = 50,
    int spd = 50,
    int sup = 50,
    int surv = 50,
  }) {
    fallback.add(HunterClassData(
      id: id,
      nameEn: nameEn,
      roleEn: roleEn,
      descriptionEn: descEn,
      icon: icon,
      element: element,
      aura: aura,
      rarity: rarity,
      color: color,
      displayOrder: order,
      imageUrl: avatar,
      isStarter: true,
      difficulty: 1,
      statsAttack: atk,
      statsDefense: def,
      statsMagic: mag,
      statsSpeed: spd,
      statsSupport: sup,
      statsSurvival: surv,
    ));
  }

  add(
    id: 'warrior',
    nameEn: 'Berserker',
    roleEn: 'Vanguard',
    descEn:
        'Outspoken and brave. You speak first and think later. Ideal for overcoming the fear of speaking.',
    icon: Icons.shield_rounded,
    color: AppColors.crimsonRed,
    element: 'Fuego',
    aura: 'carmesí',
    rarity: 'comun',
    order: 1,
    avatar: 'assets/images/avatars/avatar_berserker_01.png',
    atk: 85, def: 55, mag: 20, spd: 60, sup: 35, surv: 70,
  );
  add(
    id: 'mage',
    nameEn: 'Arcane Mage',
    roleEn: 'Strategist',
    descEn:
        'Analytical and precise. You observe and structure before speaking. Ideal for perfecting grammar.',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.runeViolet,
    element: 'Arcano',
    aura: 'violeta',
    rarity: 'comun',
    order: 2,
    avatar: 'assets/images/avatars/avatar_mage_01.png',
    atk: 35, def: 45, mag: 95, spd: 40, sup: 60, surv: 45,
  );
  add(
    id: 'assassin',
    nameEn: 'Assassin',
    roleEn: 'Precision Striker',
    descEn:
        'Tactical observer. You aim for precision and stealthy efficiency. Ideal for high-accuracy vocabulary.',
    icon: Icons.colorize,
    color: AppColors.collabBlue,
    element: 'Sombra',
    aura: 'azul oscuro',
    rarity: 'comun',
    order: 3,
    avatar: 'assets/images/avatars/avatar_assassin_01.png',
    atk: 80, def: 35, mag: 30, spd: 95, sup: 25, surv: 50,
  );
  add(
    id: 'knight',
    nameEn: 'Knight',
    roleEn: 'Sentinel',
    descEn:
        'Constant and methodical. You stand firm in your routines. Ideal for building streaks and consistency.',
    icon: Icons.military_tech_rounded,
    color: AppColors.royalGold,
    element: 'Tierra',
    aura: 'dorada',
    rarity: 'comun',
    order: 4,
    avatar: 'assets/images/avatars/avatar_knight_01.png',
    atk: 55, def: 95, mag: 15, spd: 35, sup: 70, surv: 90,
  );
  add(
    id: 'archer',
    nameEn: 'Archer',
    roleEn: 'Marksman',
    descEn:
        'Agile and quick. You learn on the go within context. Ideal for mastering useful expressions.',
    icon: Icons.gps_fixed,
    color: AppColors.emeraldGreen,
    element: 'Viento',
    aura: 'esmeralda',
    rarity: 'comun',
    order: 5,
    avatar: 'assets/images/avatars/avatar_archer_01.png',
    atk: 65, def: 40, mag: 40, spd: 80, sup: 45, surv: 55,
  );
  add(
    id: 'summoner',
    nameEn: 'Summoner',
    roleEn: 'Combo Master',
    descEn:
        'Creative and associative. You connect concepts and conjure ideas. Ideal for idiomatic phrases.',
    icon: Icons.auto_fix_high_rounded,
    color: AppColors.blindMagenta,
    element: 'Estelar',
    aura: 'magenta',
    rarity: 'comun',
    order: 6,
    avatar: 'assets/images/avatars/avatar_summoner_01.png',
    atk: 45, def: 40, mag: 85, spd: 55, sup: 75, surv: 45,
  );
  add(
    id: 'paladin',
    nameEn: 'Paladin',
    roleEn: 'Guardian',
    descEn:
        'Goal-driven protector. Guided by clear duties. Ideal for formal and structured conversations.',
    icon: Icons.volunteer_activism,
    color: AppColors.tutorBubbleBlue,
    element: 'Luz',
    aura: 'celeste',
    rarity: 'raro',
    order: 7,
    avatar: 'assets/images/avatars/avatar_paladin_01.png',
    atk: 60, def: 80, mag: 55, spd: 40, sup: 90, surv: 85,
  );
  add(
    id: 'necromancer',
    nameEn: 'Necromancer',
    roleEn: 'Researcher',
    descEn:
        'Etymological explorer. You resurrect the roots of the language. Ideal for Latin roots and word origins.',
    icon: Icons.gavel,
    color: AppColors.gemPurple,
    element: 'Óseo',
    aura: 'púrpura',
    rarity: 'epico',
    order: 8,
    avatar: 'assets/images/avatars/avatar_necromancer_01.png',
    atk: 50, def: 45, mag: 90, spd: 35, sup: 50, surv: 55,
  );

  return fallback;
}
