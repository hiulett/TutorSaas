import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class HunterTitleItem {
  final String code;
  final String name;
  final String attributeCategory;
  final String rankTier; // F, E, D, C, B, A, S, SS, SSS
  final String icon;
  final String description;
  final Color color;

  const HunterTitleItem({
    required this.code,
    required this.name,
    required this.attributeCategory,
    required this.rankTier,
    required this.icon,
    required this.description,
    required this.color,
  });

  /// Nombre localizado según el código del título (fallback al nombre base).
  String localizedName(AppLocalizations? l10n) {
    switch (code) {
      case 'orco_caverna_f': return l10n?.hunter_title_orco_caverna_f ?? name;
      case 'escriba_novato_e': return l10n?.hunter_title_escriba_novato_e ?? name;
      case 'escriba_ciudad_d': return l10n?.hunter_title_escriba_ciudad_d ?? name;
      case 'escriba_imperial_c': return l10n?.hunter_title_escriba_imperial_c ?? name;
      case 'pluma_erudito_b': return l10n?.hunter_title_pluma_erudito_b ?? name;
      case 'pluma_archimago_a': return l10n?.hunter_title_pluma_archimago_a ?? name;
      case 'pluma_celestial_s': return l10n?.hunter_title_pluma_celestial_s ?? name;
      case 'monarca_sintaxis_ss': return l10n?.hunter_title_monarca_sintaxis_ss ?? name;
      case 'creador_abismo_sss': return l10n?.hunter_title_creador_abismo_sss ?? name;
      case 'murcielago_ciego_f': return l10n?.hunter_title_murcielago_ciego_f ?? name;
      case 'oido_halcon_novato_d': return l10n?.hunter_title_oido_halcon_novato_d ?? name;
      case 'oido_halcon_abismo_c': return l10n?.hunter_title_oido_halcon_abismo_c ?? name;
      case 'sonar_monarca_sombras_s': return l10n?.hunter_title_sonar_monarca_sombras_s ?? name;
      case 'oidor_susurros_sss': return l10n?.hunter_title_oidor_susurros_sss ?? name;
      case 'monarca_impecable_5star': return l10n?.hunter_title_monarca_impecable_5star ?? name;
      default: return name;
    }
  }

  /// Descripción localizada según el código del título (fallback a la base).
  String localizedDescription(AppLocalizations? l10n) {
    switch (code) {
      case 'orco_caverna_f': return l10n?.hunter_title_orco_caverna_f_desc ?? description;
      case 'escriba_novato_e': return l10n?.hunter_title_escriba_novato_e_desc ?? description;
      case 'escriba_ciudad_d': return l10n?.hunter_title_escriba_ciudad_d_desc ?? description;
      case 'escriba_imperial_c': return l10n?.hunter_title_escriba_imperial_c_desc ?? description;
      case 'pluma_erudito_b': return l10n?.hunter_title_pluma_erudito_b_desc ?? description;
      case 'pluma_archimago_a': return l10n?.hunter_title_pluma_archimago_a_desc ?? description;
      case 'pluma_celestial_s': return l10n?.hunter_title_pluma_celestial_s_desc ?? description;
      case 'monarca_sintaxis_ss': return l10n?.hunter_title_monarca_sintaxis_ss_desc ?? description;
      case 'creador_abismo_sss': return l10n?.hunter_title_creador_abismo_sss_desc ?? description;
      case 'murcielago_ciego_f': return l10n?.hunter_title_murcielago_ciego_f_desc ?? description;
      case 'oido_halcon_novato_d': return l10n?.hunter_title_oido_halcon_novato_d_desc ?? description;
      case 'oido_halcon_abismo_c': return l10n?.hunter_title_oido_halcon_abismo_c_desc ?? description;
      case 'sonar_monarca_sombras_s': return l10n?.hunter_title_sonar_monarca_sombras_s_desc ?? description;
      case 'oidor_susurros_sss': return l10n?.hunter_title_oidor_susurros_sss_desc ?? description;
      case 'monarca_impecable_5star': return l10n?.hunter_title_monarca_impecable_5star_desc ?? description;
      default: return description;
    }
  }
}

class DungeonMonsterItem {
  final String id;
  final String name;
  final String level;
  final String avatarUrl;
  final String description;
  final bool isBoss;

  const DungeonMonsterItem({
    required this.id,
    required this.name,
    required this.level,
    required this.avatarUrl,
    required this.description,
    this.isBoss = false,
  });
}

class HunterCatalog {
  // 11 Attribute Categories:
  // 1. grammar (Precisión Gramatical)
  // 2. latency (Latencia de Respuesta)
  // 3. blind (Agudeza Auditiva A Ciegas)
  // 4. vocabulary (Capacidad Léxica SRS)
  // 5. phonetics (Precisión Fonética)
  // 6. volume (Volumen de Oratoria)
  // 7. presence (Presencia Social)
  // 8. stage (Dominio del Escenario)
  // 9. hosting (Liderazgo de Gremio)
  // 10. chalice (Audacia del Cáliz)
  // 11. chat (Comunicación Táctica)

  static final List<HunterTitleItem> titles = [
    // Grammar
    const HunterTitleItem(code: 'orco_caverna_f', name: 'Escritura de Orco de Caverna', attributeCategory: 'grammar', rankTier: 'F', icon: '👹', description: 'Primeros pasos cometiendo errores con valentía.', color: AppColors.onSurfaceVariant),
    const HunterTitleItem(code: 'escriba_novato_e', name: 'Escriba Novato', attributeCategory: 'grammar', rankTier: 'E', icon: '📜', description: '50% de oraciones limpias.', color: AppColors.emeraldGreen),
    const HunterTitleItem(code: 'escriba_ciudad_d', name: 'Escriba de la Ciudad', attributeCategory: 'grammar', rankTier: 'D', icon: '📜', description: '65% de precisión gramatical.', color: AppColors.manaCyan),
    const HunterTitleItem(code: 'escriba_imperial_c', name: 'Escriba de la Biblioteca Imperial', attributeCategory: 'grammar', rankTier: 'C', icon: '📜', description: '75% de precisión gramatical.', color: AppColors.manaCyan),
    const HunterTitleItem(code: 'pluma_erudito_b', name: 'Pluma del Erudito Real', attributeCategory: 'grammar', rankTier: 'B', icon: '🪶', description: '85% de precisión gramatical.', color: AppColors.runeViolet),
    const HunterTitleItem(code: 'pluma_archimago_a', name: 'Pluma Arcanista del Archimago', attributeCategory: 'grammar', rankTier: 'A', icon: '🪶', description: '92% de precisión gramatical.', color: AppColors.royalGold),
    const HunterTitleItem(code: 'pluma_celestial_s', name: 'Pluma Celestial del Sabio', attributeCategory: 'grammar', rankTier: 'S', icon: '✨', description: '97% de precisión gramatical.', color: AppColors.guildAmber),
    const HunterTitleItem(code: 'monarca_sintaxis_ss', name: 'Monarca de la Sintaxis Sagrada', attributeCategory: 'grammar', rankTier: 'SS', icon: '👑', description: '99% de precisión gramatical.', color: AppColors.crimsonRed),
    const HunterTitleItem(code: 'creador_abismo_sss', name: 'Creador de Lenguajes del Abismo', attributeCategory: 'grammar', rankTier: 'SSS', icon: '🌌', description: '100% de precisión gramatical impecable.', color: AppColors.rankGold),

    // Blind Listening
    const HunterTitleItem(code: 'murcielago_ciego_f', name: 'Murciélago Ciego', attributeCategory: 'blind', rankTier: 'F', icon: '🦇', description: 'Escuchas iniciales con chat de texto.', color: AppColors.onSurfaceVariant),
    const HunterTitleItem(code: 'oido_halcon_novato_d', name: 'Oído de Halcón Novato', attributeCategory: 'blind', rankTier: 'D', icon: '🦅', description: '2 lecciones sin chat.', color: AppColors.manaCyan),
    const HunterTitleItem(code: 'oido_halcon_abismo_c', name: 'Oído de Halcón del Abismo', attributeCategory: 'blind', rankTier: 'C', icon: '🦅', description: '4 lecciones superadas a ciegas.', color: AppColors.manaCyan),
    const HunterTitleItem(code: 'sonar_monarca_sombras_s', name: 'Sonar Absoluto del Monarca de las Sombras', attributeCategory: 'blind', rankTier: 'S', icon: '🌑', description: '16 lecciones superadas a ciegas.', color: AppColors.guildAmber),
    const HunterTitleItem(code: 'oidor_susurros_sss', name: 'Oidor de los Susurros del Universo', attributeCategory: 'blind', rankTier: 'SSS', icon: '🌌', description: 'Más de 30 lecciones pasadas a ciegas.', color: AppColors.rankGold),

    // Mythic 5th Star Title
    const HunterTitleItem(code: 'monarca_impecable_5star', name: 'Monarca Impecable de la Perfección', attributeCategory: 'mythic', rankTier: 'SSS', icon: '🏆', description: 'Otorgado por lograr la 5ª Estrella Mítica (0 errores a ciegas).', color: AppColors.rankMagenta),
  ];

  /// The Oracle — principal mentor NPC for all conversations.
  static const oracle = DungeonMonsterItem(
    id: 'oracle',
    name: '🔮 Oráculo del Gremio',
    level: 'SSS',
    avatarUrl: '',
    description: 'El Oráculo del Gremio. Una entidad mística que guía a los cazadores en su aprendizaje.',
    isBoss: false,
  );

  static final List<DungeonMonsterItem> regularMonsters = [
    const DungeonMonsterItem(
      id: 'oracle',
      name: '🔮 Oráculo del Gremio',
      level: 'SSS',
      avatarUrl: '',
      description: 'El Oráculo del Gremio. Una entidad mística que guía a los cazadores.',
    ),
    const DungeonMonsterItem(
      id: 'golem_roca',
      name: 'Golem de Roca Mística',
      level: 'A2',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=GolemRock',
      description: 'Guardián de piedra paciente que prueba tu vocabulario.',
    ),
    const DungeonMonsterItem(
      id: 'sombra_fuego',
      name: 'Espectro de Fuego Neón',
      level: 'B1',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=FireSpectre',
      description: 'Ser llameante que exige velocidad y fluidez de conversación.',
    ),
    const DungeonMonsterItem(
      id: 'archimago_oscuridad',
      name: 'Archimago del Abismo',
      level: 'B2',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Archmage',
      description: 'Sabio arcano que mide la precisión de tu gramática.',
    ),
  ];

  static final List<DungeonMonsterItem> floorBosses = [
    const DungeonMonsterItem(
      id: 'boss_a1',
      name: '🐺 Lobo Alfa del Bosque Arcano',
      level: 'A1',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=WolfBoss',
      description: 'Jefe del Piso 1. Evalúa tu fluidez básica en 3 minutos.',
      isBoss: true,
    ),
    const DungeonMonsterItem(
      id: 'boss_a2',
      name: '🗿 Titán Guerrero de Bronce',
      level: 'A2',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=TitanBoss',
      description: 'Jefe del Piso 2. Prueba de fuerza auditiva en 4 minutos.',
      isBoss: true,
    ),
    const DungeonMonsterItem(
      id: 'boss_b1',
      name: '🦅 Grypho del Viento Estelar',
      level: 'B1',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=GryphonBoss',
      description: 'Jefe del Piso 3. Prueba de agilidad conversacional en 5 minutos.',
      isBoss: true,
    ),
    const DungeonMonsterItem(
      id: 'boss_b2',
      name: '⚔️ Comandante General del Ejército Rojo',
      level: 'B2',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=CommanderBoss',
      description: 'Jefe del Piso 4. Prueba táctica de oratoria en 6 minutos.',
      isBoss: true,
    ),
    const DungeonMonsterItem(
      id: 'boss_c1',
      name: '🧙‍♂️ Archimago del Abismo de Sombras',
      level: 'C1',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=ShadowBoss',
      description: 'Jefe del Piso 5. Prueba de discurso avanzado en 7 minutos.',
      isBoss: true,
    ),
    const DungeonMonsterItem(
      id: 'boss_c2',
      name: '🐉 Dragón Divino del Caos Primordial (Rango SSS)',
      level: 'C2',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=DragonBoss',
      description: 'Jefe del Piso 6. Máxima prueba del Monarca Absoluto en 8 minutos.',
      isBoss: true,
    ),
  ];
}
