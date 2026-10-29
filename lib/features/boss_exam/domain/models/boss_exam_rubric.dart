/// P-31 (#116) — Rúbrica fija del jefe de mazmorra.
///
/// Seis dimensiones con umbral explícito. El servidor
/// (`evaluate-placement`) es quien decide el ascenso con esta misma regla; el
/// cliente solo la replica para explicar el resultado y para los tests.
class BossExamRubric {
  const BossExamRubric({
    required this.dimensions,
    required this.average,
    required this.complete,
  });

  /// Media de aprobación (0..100).
  static const int passAverage = 65;

  /// Suelo por dimensión: ninguna puede quedar por debajo.
  static const int minDimension = 45;

  /// Orden canónico de las 6 dimensiones evaluadas.
  static const List<String> dimensionKeys = [
    'listening',
    'fluency',
    'grammar',
    'vocabulary',
    'pronunciation',
    'naturalness',
  ];

  /// Puntuación por dimensión (solo las presentes en la respuesta).
  final Map<String, int> dimensions;
  final int average;

  /// `true` si llegan las 6 dimensiones con puntuación.
  final bool complete;

  bool get passed =>
      complete &&
      average >= passAverage &&
      dimensions.values.every((value) => value >= minDimension);

  /// Dimensiones por debajo del suelo, de menor a mayor.
  List<String> get failingDimensions {
    final failing = dimensions.entries
        .where((entry) => entry.value < minDimension)
        .map((entry) => entry.key)
        .toList();
    failing.sort((a, b) => (dimensions[a] ?? 0).compareTo(dimensions[b] ?? 0));
    return failing;
  }

  /// La dimensión más floja (para "qué reforzar").
  String get weakestDimension {
    if (dimensions.isEmpty) return '';
    return dimensions.entries
        .reduce((worst, entry) => entry.value < worst.value ? entry : worst)
        .key;
  }

  static const BossExamRubric empty = BossExamRubric(
    dimensions: {},
    average: 0,
    complete: false,
  );

  factory BossExamRubric.fromScores(Map<String, dynamic> scores) {
    final dimensions = <String, int>{};
    for (final key in dimensionKeys) {
      final value = scores[key];
      if (value is num) {
        dimensions[key] = value.round().clamp(0, 100).toInt();
      } else if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) dimensions[key] = parsed.clamp(0, 100);
      }
    }
    final average = dimensions.isEmpty
        ? 0
        : (dimensions.values.reduce((a, b) => a + b) / dimensions.length)
              .round();
    return BossExamRubric(
      dimensions: dimensions,
      average: average,
      complete: dimensions.length == dimensionKeys.length,
    );
  }
}
