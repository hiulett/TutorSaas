/// Título de habilidad (ganado por desempeño conversacional, no comprable).
import '../../../../l10n/app_localizations.dart';

class SkillTitle {
  final String code;
  final String line; // fluidez|fonetica|lexico|precision|constancia|carisma
  final int tier;    // 1..4 (1 humilde → 4 legendario)
  final String rarity;
  final double threshold;
  final String name;
  final String description;

  const SkillTitle({
    required this.code,
    required this.line,
    required this.tier,
    required this.rarity,
    required this.threshold,
    required this.name,
    this.description = '',
  });

  /// Nombre localizado según el código del título (fallback al nombre base).
  String localizedName(AppLocalizations? l10n) {
    switch (code) {
      case 'titulo_fluidez_1': return l10n?.skill_fluidez_1 ?? name;
      case 'titulo_fluidez_2': return l10n?.skill_fluidez_2 ?? name;
      case 'titulo_fluidez_3': return l10n?.skill_fluidez_3 ?? name;
      case 'titulo_fluidez_4': return l10n?.skill_fluidez_4 ?? name;
      case 'titulo_fonetica_1': return l10n?.skill_fonetica_1 ?? name;
      case 'titulo_fonetica_2': return l10n?.skill_fonetica_2 ?? name;
      case 'titulo_fonetica_3': return l10n?.skill_fonetica_3 ?? name;
      case 'titulo_fonetica_4': return l10n?.skill_fonetica_4 ?? name;
      case 'titulo_lexico_1': return l10n?.skill_lexico_1 ?? name;
      case 'titulo_lexico_2': return l10n?.skill_lexico_2 ?? name;
      case 'titulo_lexico_3': return l10n?.skill_lexico_3 ?? name;
      case 'titulo_lexico_4': return l10n?.skill_lexico_4 ?? name;
      case 'titulo_precision_1': return l10n?.skill_precision_1 ?? name;
      case 'titulo_precision_2': return l10n?.skill_precision_2 ?? name;
      case 'titulo_precision_3': return l10n?.skill_precision_3 ?? name;
      case 'titulo_precision_4': return l10n?.skill_precision_4 ?? name;
      case 'titulo_constancia_1': return l10n?.skill_constancia_1 ?? name;
      case 'titulo_constancia_2': return l10n?.skill_constancia_2 ?? name;
      case 'titulo_constancia_3': return l10n?.skill_constancia_3 ?? name;
      case 'titulo_constancia_4': return l10n?.skill_constancia_4 ?? name;
      case 'titulo_carisma_1': return l10n?.skill_carisma_1 ?? name;
      case 'titulo_carisma_2': return l10n?.skill_carisma_2 ?? name;
      case 'titulo_carisma_3': return l10n?.skill_carisma_3 ?? name;
      case 'titulo_carisma_4': return l10n?.skill_carisma_4 ?? name;
      default: return name;
    }
  }

  /// Descripción localizada según el código del título (fallback a la base).
  String localizedDescription(AppLocalizations? l10n) {
    switch (code) {
      case 'titulo_fluidez_1': return l10n?.skill_fluidez_1_desc ?? description;
      case 'titulo_fluidez_2': return l10n?.skill_fluidez_2_desc ?? description;
      case 'titulo_fluidez_3': return l10n?.skill_fluidez_3_desc ?? description;
      case 'titulo_fluidez_4': return l10n?.skill_fluidez_4_desc ?? description;
      case 'titulo_fonetica_1': return l10n?.skill_fonetica_1_desc ?? description;
      case 'titulo_fonetica_2': return l10n?.skill_fonetica_2_desc ?? description;
      case 'titulo_fonetica_3': return l10n?.skill_fonetica_3_desc ?? description;
      case 'titulo_fonetica_4': return l10n?.skill_fonetica_4_desc ?? description;
      case 'titulo_lexico_1': return l10n?.skill_lexico_1_desc ?? description;
      case 'titulo_lexico_2': return l10n?.skill_lexico_2_desc ?? description;
      case 'titulo_lexico_3': return l10n?.skill_lexico_3_desc ?? description;
      case 'titulo_lexico_4': return l10n?.skill_lexico_4_desc ?? description;
      case 'titulo_precision_1': return l10n?.skill_precision_1_desc ?? description;
      case 'titulo_precision_2': return l10n?.skill_precision_2_desc ?? description;
      case 'titulo_precision_3': return l10n?.skill_precision_3_desc ?? description;
      case 'titulo_precision_4': return l10n?.skill_precision_4_desc ?? description;
      case 'titulo_constancia_1': return l10n?.skill_constancia_1_desc ?? description;
      case 'titulo_constancia_2': return l10n?.skill_constancia_2_desc ?? description;
      case 'titulo_constancia_3': return l10n?.skill_constancia_3_desc ?? description;
      case 'titulo_constancia_4': return l10n?.skill_constancia_4_desc ?? description;
      case 'titulo_carisma_1': return l10n?.skill_carisma_1_desc ?? description;
      case 'titulo_carisma_2': return l10n?.skill_carisma_2_desc ?? description;
      case 'titulo_carisma_3': return l10n?.skill_carisma_3_desc ?? description;
      case 'titulo_carisma_4': return l10n?.skill_carisma_4_desc ?? description;
      default: return description;
    }
  }
}

/// Catálogo central de los 24 títulos de habilidad (6 líneas × 4 niveles).
/// Los niveles bajos son humildes y suben a legendario con el desempeño.
class HunterSkillTitleCatalog {
  HunterSkillTitleCatalog._();

  static const List<SkillTitle> all = [
    // ── FLUIDEZ ──────────────────────────────────────────────────────────────
    SkillTitle(code: 'titulo_fluidez_1', line: 'fluidez', tier: 1, rarity: 'common', threshold: 60, name: 'Aprendiz de Palabras', description: 'Empiezas a expresarte con continuidad.'),
    SkillTitle(code: 'titulo_fluidez_2', line: 'fluidez', tier: 2, rarity: 'rare', threshold: 75, name: 'El Correo Veloz', description: 'Hablas con ritmo y fluidez notable.'),
    SkillTitle(code: 'titulo_fluidez_3', line: 'fluidez', tier: 3, rarity: 'epic', threshold: 88, name: 'Heraldo del Vendaval', description: 'Tu discurso fluye sin esfuerzo.'),
    SkillTitle(code: 'titulo_fluidez_4', line: 'fluidez', tier: 4, rarity: 'legendary', threshold: 95, name: 'Vocero de los Dioses', description: 'Fluidez casi divina al conversar.'),
    // ── FONÉTICA ─────────────────────────────────────────────────────────────
    SkillTitle(code: 'titulo_fonetica_1', line: 'fonetica', tier: 1, rarity: 'common', threshold: 55, name: 'Aprendiz de la Voz', description: 'Tu pronunciación empieza a ser clara.'),
    SkillTitle(code: 'titulo_fonetica_2', line: 'fonetica', tier: 2, rarity: 'rare', threshold: 70, name: 'Eco del Coliseo', description: 'Pronuncias con precisión destacable.'),
    SkillTitle(code: 'titulo_fonetica_3', line: 'fonetica', tier: 3, rarity: 'epic', threshold: 85, name: 'Cantor de Cristal', description: 'Tu fonética es limpia y brillante.'),
    SkillTitle(code: 'titulo_fonetica_4', line: 'fonetica', tier: 4, rarity: 'legendary', threshold: 94, name: 'Afinador Celestial', description: 'Claridad fonética de otro plano.'),
    // ── LÉXICO ───────────────────────────────────────────────────────────────
    SkillTitle(code: 'titulo_lexico_1', line: 'lexico', tier: 1, rarity: 'common', threshold: 20, name: 'Recolector de Palabras', description: 'Sumas tus primeras palabras dominadas.'),
    SkillTitle(code: 'titulo_lexico_2', line: 'lexico', tier: 2, rarity: 'rare', threshold: 80, name: 'Bibliotecario de Aldea', description: 'Tu vocabulario crece con solidez.'),
    SkillTitle(code: 'titulo_lexico_3', line: 'lexico', tier: 3, rarity: 'epic', threshold: 200, name: 'Escriba del Abismo', description: 'Dominas un vocabulario extenso.'),
    SkillTitle(code: 'titulo_lexico_4', line: 'lexico', tier: 4, rarity: 'legendary', threshold: 500, name: 'Lexicógrafo Eterno', description: 'Tu léxico no tiene fronteras.'),
    // ── PRECISIÓN (gramática) ─────────────────────────────────────────────────
    SkillTitle(code: 'titulo_precision_1', line: 'precision', tier: 1, rarity: 'common', threshold: 50, name: 'Aprendiz de las Reglas', description: 'Estructuras simples ya son sólidas.'),
    SkillTitle(code: 'titulo_precision_2', line: 'precision', tier: 2, rarity: 'rare', threshold: 70, name: 'Aprendiz de Runas', description: 'Tu gramática gana consistencia.'),
    SkillTitle(code: 'titulo_precision_3', line: 'precision', tier: 3, rarity: 'epic', threshold: 85, name: 'Gramático del Coliseo', description: 'Construyes oraciones con dominio.'),
    SkillTitle(code: 'titulo_precision_4', line: 'precision', tier: 4, rarity: 'legendary', threshold: 94, name: 'Forjador de Sintaxis', description: 'Tu precisión gramatical es legendaria.'),
    // ── CONSTANCIA ────────────────────────────────────────────────────────────
    SkillTitle(code: 'titulo_constancia_1', line: 'constancia', tier: 1, rarity: 'common', threshold: 3, name: 'Aprendiz Constante', description: 'Tres días seguidos practicando.'),
    SkillTitle(code: 'titulo_constancia_2', line: 'constancia', tier: 2, rarity: 'rare', threshold: 7, name: 'Guardián del Fuego', description: 'Una semana ininterrumpida.'),
    SkillTitle(code: 'titulo_constancia_3', line: 'constancia', tier: 3, rarity: 'epic', threshold: 30, name: 'Centinela del Amanecer', description: 'Un mes de constancia férrea.'),
    SkillTitle(code: 'titulo_constancia_4', line: 'constancia', tier: 4, rarity: 'legendary', threshold: 100, name: 'Leyenda de la Racha', description: 'Cien días de dedicación absoluta.'),
    // ── CARISMA (cualitativo — IA; seed para el futuro paso) ─────────────────
    SkillTitle(code: 'titulo_carisma_1', line: 'carisma', tier: 1, rarity: 'common', threshold: 55, name: 'Novato del Gremio', description: 'Te desenvuelves en conversaciones.'),
    SkillTitle(code: 'titulo_carisma_2', line: 'carisma', tier: 2, rarity: 'rare', threshold: 70, name: 'Alma de la Taberna', description: 'Conectas naturalmente con los demás.'),
    SkillTitle(code: 'titulo_carisma_3', line: 'carisma', tier: 3, rarity: 'epic', threshold: 85, name: 'Embajador del Reino', description: 'Llevas la conversación con soltura.'),
    SkillTitle(code: 'titulo_carisma_4', line: 'carisma', tier: 4, rarity: 'legendary', threshold: 94, name: 'Oráculo Menor', description: 'Tu carisma conversacional es de otro mundo.'),
  ];

  static SkillTitle? forCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final t in all) {
      if (t.code == code) return t;
    }
    return null;
  }

  /// Títulos de una línea ordenados por tier ascendente.
  static List<SkillTitle> lineTitles(String line) =>
      all.where((t) => t.line == line).toList()
        ..sort((a, b) => a.tier.compareTo(b.tier));

  static SkillTitle? codeFor(String line, int tier) {
    for (final t in all) {
      if (t.line == line && t.tier == tier) return t;
    }
    return null;
  }
}
