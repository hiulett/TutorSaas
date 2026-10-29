import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/utils/retry.dart';

void main() {
  test('retryWithBackoff reintenta hasta tener exito', () async {
    var calls = 0;
    final result = await retryWithBackoff(() async {
      calls++;
      if (calls < 3) throw Exception('fallo transitorio');
      return 'ok';
    }, baseDelay: const Duration(milliseconds: 1));

    expect(result, 'ok');
    expect(calls, 3);
  });

  test('retryWithBackoff relanza tras agotar los intentos', () async {
    var calls = 0;
    await expectLater(
      retryWithBackoff<void>(
        () async {
          calls++;
          throw Exception('fallo persistente');
        },
        maxAttempts: 2,
        baseDelay: const Duration(milliseconds: 1),
      ),
      throwsException,
    );
    expect(calls, 2);
  });

  test('retryWithBackoff rechaza maxAttempts menor que 1', () async {
    await expectLater(
      retryWithBackoff<void>(() async {}, maxAttempts: 0),
      throwsArgumentError,
    );
  });
}
