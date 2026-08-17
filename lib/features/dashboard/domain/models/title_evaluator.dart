import '../../data/models/hunter_skill_titles.dart';

/// Motor determinístico que calcula qué títulos de habilidad ha ganado el
/// cazador según su desempeño real (métricas de conversación).
///
/// Regla: por cada línea se evalúa la métrica contra umbrales ascendentes
/// (1 humilde → 4 legendario). El tier ganado es el más alto alcanzado; el
/// título nunca se pierde (sin retroceso).
class TitleEvaluator {
  const TitleEvaluator._();

  /// Umbrales por línea (mismo orden que [HunterSkillTitleCatalog] tiers).
  static const Map<String, List<double>> _thresholds = {
    'fluidez': [60, 75, 88, 95],
    'fonetica': [55, 70, 85, 94],
    'lexico': [20, 80, 200, 500],
    'precision': [50, 70, 85, 94],
    'constancia': [3, 7, 30, 100],
    'carisma': [55, 70, 85, 94], // se reserva para evaluación IA
  };

  /// Tier ganado (0..4) para una línea dado el valor de su métrica.
  static int tierFor(String line, double value) {
    final thresholds = _thresholds[line];
    if (thresholds == null || thresholds.isEmpty) return 0;
    var tier = 0;
    for (int i = 0; i < thresholds.length; i++) {
      if (value >= thresholds[i]) tier = i + 1;
    }
    return tier;
  }

  /// Tiers ganados (por línea) dados los valores reales.
  static Map<String, int> earnedTiers({
    double fluency = 0,
    double phonetics = 0,
    int vocab = 0,
    double precision = 0,
    int streak = 0,
    double carisma = 0,
  }) {
    return {
      'fluidez': tierFor('fluidez', fluency),
      'fonetica': tierFor('fonetica', phonetics),
      'lexico': tierFor('lexico', vocab.toDouble()),
      'precision': tierFor('precision', precision),
      'constancia': tierFor('constancia', streak.toDouble()),
      'carisma': tierFor('carisma', carisma),
    };
  }

  /// Códigos de los títulos ganados según los tiers calculados.
  static List<String> earnedCodes({
    double fluency = 0,
    double phonetics = 0,
    int vocab = 0,
    double precision = 0,
    int streak = 0,
    double carisma = 0,
  }) {
    final tiers = earnedTiers(
      fluency: fluency,
      phonetics: phonetics,
      vocab: vocab,
      precision: precision,
      streak: streak,
      carisma: carisma,
    );
    final codes = <String>[];
    tiers.forEach((line, tier) {
      if (tier <= 0) return;
      final title = HunterSkillTitleCatalog.codeFor(line, tier);
      if (title != null) codes.add(title.code);
    });
    return codes;
  }
}
