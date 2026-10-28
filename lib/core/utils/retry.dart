import 'dart:math';

/// Reintenta [action] con backoff exponencial y jitter (P-19).
///
/// Pensado para llamadas criticas de red: 300 ms, 600 ms, 1,2 s... mas un
/// jitter de hasta 250 ms para no sincronizar reintentos entre clientes.
Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration baseDelay = const Duration(milliseconds: 300),
  Random? random,
}) async {
  if (maxAttempts < 1) {
    throw ArgumentError.value(maxAttempts, 'maxAttempts', 'debe ser >= 1');
  }
  final rng = random ?? Random();
  var attempt = 0;
  while (true) {
    attempt++;
    try {
      return await action();
    } catch (_) {
      if (attempt >= maxAttempts) rethrow;
      final backoffMs = baseDelay.inMilliseconds * (1 << (attempt - 1));
      await Future<void>.delayed(
        Duration(milliseconds: backoffMs + rng.nextInt(250)),
      );
    }
  }
}
