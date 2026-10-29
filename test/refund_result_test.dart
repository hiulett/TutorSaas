import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/economy/domain/models/refund_result.dart';

/// Contrato normalizado de las compensaciones de maná.
void main() {
  test('reembolso aplicado', () {
    final result = RefundResult.fromMap(const {
      'success': true,
      'refunded': 12,
      'already_refunded': false,
      'reason': null,
    });

    expect(result.success, isTrue);
    expect(result.refunded, 12);
    expect(result.alreadyRefunded, isFalse);
    expect(result.reason, isNull);
    expect(result.isNoop, isFalse);
    expect(result.failed, isFalse);
  });

  test('segundo intento del mismo turno no es un error', () {
    final result = RefundResult.fromMap(const {
      'success': true,
      'refunded': 0,
      'already_refunded': true,
      'reason': null,
    });

    expect(result.success, isTrue);
    expect(result.isNoop, isTrue);
  });

  test('sin cargo reciente devuelve el motivo', () {
    final result = RefundResult.fromMap(const {
      'success': false,
      'refunded': 0,
      'already_refunded': false,
      'reason': 'no_recent_charge',
    });

    expect(result.failed, isTrue);
    expect(result.reason, 'no_recent_charge');
  });

  test('acepta la forma antigua con ok por compatibilidad', () {
    final result = RefundResult.fromMap(const {
      'ok': true,
      'refunded': 12,
      'already_refunded': false,
    });

    expect(result.success, isTrue);
    expect(result.refunded, 12);
  });

  test('un mapa vacio cuenta como fallo, sin inventar importes', () {
    final result = RefundResult.fromMap(const {});

    expect(result.failed, isTrue);
    expect(result.refunded, 0);
    expect(result.alreadyRefunded, isFalse);
  });

  test('error de red tiene su propio motivo', () {
    final result = RefundResult.requestFailed();

    expect(result.failed, isTrue);
    expect(result.reason, 'request_failed');
    expect(result.refunded, 0);
  });

  test('num en lugar de int no rompe el modelo', () {
    final result = RefundResult.fromMap(const {
      'success': true,
      'refunded': 12.0,
    });

    expect(result.refunded, 12);
  });
}
