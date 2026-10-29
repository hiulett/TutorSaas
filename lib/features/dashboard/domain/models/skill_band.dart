/// Nivel cualitativo de una habilidad (P-35 / #120).
///
/// El radar no debe fingir precisión: las puntuaciones vienen de una
/// evaluación por lenguaje (estimación), no de un medidor de voz. Por eso se
/// muestran bandas en vez de porcentajes.
enum SkillBand {
  /// Sin datos suficientes.
  unknown,

  /// Menos de 40.
  low,

  /// Entre 40 y 69.
  medium,

  /// 70 o más.
  high;

  static const double lowThreshold = 40;
  static const double highThreshold = 70;

  static SkillBand fromScore(num? score) {
    if (score == null) return SkillBand.unknown;
    final value = score.toDouble();
    if (!value.isFinite || value <= 0) return SkillBand.unknown;
    if (value >= highThreshold) return SkillBand.high;
    if (value >= lowThreshold) return SkillBand.medium;
    return SkillBand.low;
  }
}
