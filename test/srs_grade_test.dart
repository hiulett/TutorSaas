import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/vocabulary/domain/srs_grade.dart';

void main() {
  group('SrsGrade (#24): mapeo de respuestas al algoritmo SM-2', () {
    test('NORMAL no cuenta como lapso y avanza el intervalo', () {
      // La RPC record_vocabulary_review trata `quality < 3` como lapso.
      // Regresión: antes NORMAL era 2.5 y reiniciaba el intervalo.
      expect(SrsGrade.normal.quality, greaterThanOrEqualTo(3.0));
      expect(SrsGrade.normal.isLapse, isFalse);
    });

    test('HARD es el único grado que cuenta como lapso', () {
      expect(SrsGrade.hard.isLapse, isTrue);
      expect(SrsGrade.hard.quality, lessThan(3.0));
    });

    test('EASY queda por encima del umbral', () {
      expect(SrsGrade.easy.quality, 5.0);
      expect(SrsGrade.easy.isLapse, isFalse);
    });

    test('el orden de los grados es creciente', () {
      expect(SrsGrade.hard.quality, lessThan(SrsGrade.normal.quality));
      expect(SrsGrade.normal.quality, lessThan(SrsGrade.easy.quality));
    });
  });
}
