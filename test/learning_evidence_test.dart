import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/learning_evidence_summary.dart';

/// Evidencia de aprendizaje con series simuladas (R3 / #74).
void main() {
  test('sin datos no inventa metricas', () {
    final summary = LearningEvidenceSummary.fromMap(const {});

    expect(summary.hasRetention, isFalse);
    expect(summary.hasComparableProgress, isFalse);
    expect(summary.hasTransfer, isFalse);
    expect(summary.retentionPercent, isNull);
  });

  test('retencion a 7 dias se redondea a porcentaje', () {
    final summary = LearningEvidenceSummary.fromMap(const {
      'retention_7d': 0.75,
    });

    expect(summary.hasRetention, isTrue);
    expect(summary.retentionPercent, 75);
  });

  test('progreso comparable exige 4 semanas y ambos extremos', () {
    final short = LearningEvidenceSummary.fromMap(const {
      'weeks_active': 2,
      'progress_by_type': [
        {'type': 'vocab_words', 'first_week': 3, 'last_week': 5, 'weeks': 2},
      ],
    });
    expect(short.hasComparableProgress, isFalse);

    final enough = LearningEvidenceSummary.fromMap(const {
      'weeks_active': 4,
      'progress_by_type': [
        {'type': 'vocab_words', 'first_week': 3, 'last_week': 5, 'weeks': 4},
        {'type': 'speak_minutes', 'first_week': 1, 'last_week': 2, 'weeks': 4},
      ],
    });
    expect(enough.hasComparableProgress, isTrue);
    expect(enough.firstWeekCompleted, 4);
    expect(enough.lastWeekCompleted, 7);
  });

  test('transferencia cuenta tipos de mision distintos', () {
    final summary = LearningEvidenceSummary.fromMap(const {
      'transfer_types': 2,
    });

    expect(summary.hasTransfer, isTrue);
    expect(summary.transferTypes, 2);
  });
}
