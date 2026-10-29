/// Resumen de la evidencia de aprendizaje (R3 / #74).
///
/// Se construye a partir del JSON de `learning_evidence()` y decide si hay
/// datos suficientes para mostrar cada métrica, sin inventar ceros.
class LearningEvidenceSummary {
  const LearningEvidenceSummary({
    this.retention7d,
    this.weeksActive = 0,
    this.transferTypes = 0,
    this.firstWeekCompleted,
    this.lastWeekCompleted,
  });

  factory LearningEvidenceSummary.fromMap(Map<String, dynamic> map) {
    final retention = (map['retention_7d'] as num?)?.toDouble();
    final weeks = (map['weeks_active'] as num?)?.toInt() ?? 0;
    final transfer = (map['transfer_types'] as num?)?.toInt() ?? 0;

    int? first;
    int? last;
    final byType = map['progress_by_type'];
    if (byType is List) {
      var firstSum = 0;
      var lastSum = 0;
      var any = false;
      for (final item in byType) {
        if (item is! Map) continue;
        final f = (item['first_week'] as num?)?.toInt();
        final l = (item['last_week'] as num?)?.toInt();
        if (f == null || l == null) continue;
        firstSum += f;
        lastSum += l;
        any = true;
      }
      if (any) {
        first = firstSum;
        last = lastSum;
      }
    }

    return LearningEvidenceSummary(
      retention7d: retention,
      weeksActive: weeks,
      transferTypes: transfer,
      firstWeekCompleted: first,
      lastWeekCompleted: last,
    );
  }

  final double? retention7d;
  final int weeksActive;
  final int transferTypes;
  final int? firstWeekCompleted;
  final int? lastWeekCompleted;

  bool get hasRetention => retention7d != null;

  /// La comparación necesita al menos 4 semanas y datos en ambos extremos.
  bool get hasComparableProgress =>
      weeksActive >= 4 &&
      firstWeekCompleted != null &&
      lastWeekCompleted != null;

  bool get hasTransfer => transferTypes > 0;

  int? get retentionPercent =>
      retention7d == null ? null : (retention7d! * 100).round();
}
