import 'package:flutter/foundation.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';

/// Medicion del arranque real de la app (P-19 / #104).
///
/// `markProcessStart()` se llama en la primera linea de `main()` y
/// `markReady()` cuando el splash termina el trabajo real (warm-up). El
/// resultado se envia con el primer `app_open`, que ya tiene `user_id`.
class StartupProbe {
  StartupProbe._();

  static DateTime? _processStart;
  static int? _readyMs;
  static int? _warmupMs;
  static bool _warmupTimedOut = false;

  static void markProcessStart() {
    _processStart ??= DateTime.now();
  }

  /// Milisegundos desde el inicio del proceso (0 si no se marco).
  static int get elapsedMs {
    final start = _processStart;
    if (start == null) return 0;
    return DateTime.now().difference(start).inMilliseconds;
  }

  static void markReady({required int warmupMs, required bool timedOut}) {
    _warmupMs = warmupMs;
    _warmupTimedOut = timedOut;
    _readyMs = elapsedMs;
    final summary =
        '[Startup] listo en ${_readyMs}ms '
        '(warm-up ${warmupMs}ms${timedOut ? ', timeout' : ''})';
    debugPrint(summary);
    ErrorTracker.logEvent(
      'app_startup',
      parameters: {
        'startup_ms': _readyMs,
        'warmup_ms': warmupMs,
        'warmup_timeout': timedOut,
      },
    );
  }

  /// Propiedades para el evento `app_open` (solo metricas, sin PII).
  static Map<String, Object?> appOpenProperties() {
    return {
      if (_readyMs != null) 'startup_ms': _readyMs!,
      if (_warmupMs != null) 'warmup_ms': _warmupMs!,
      if (_warmupTimedOut) 'warmup_timeout': true,
    };
  }
}
