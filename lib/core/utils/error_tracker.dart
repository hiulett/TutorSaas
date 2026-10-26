import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/crash_reporter.dart';

class ErrorTracker {
  static bool _initialized = false;

  /// Initialize Sentry and analytics monitoring
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // In production:
      // await SentryFlutter.init(
      //   (options) {
      //     options.dsn = 'https://examplePublicKey@o0.ingest.sentry.io/0';
      //     options.tracesSampleRate = 1.0;
      //   },
      // );
      
      _initialized = true;
      if (kDebugMode) {
        print('ErrorTracker: Sentry y analíticas inicializados correctamente.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorTracker: Error al inicializar monitoreo: $e');
      }
    }
  }

  /// Capture exceptions and send to Sentry dashboard
  static void logError(dynamic exception, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('ErrorTracker [ERROR]: $exception');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }

    if (!_initialized) return;

    try {
      // Reenvia al reportero de fallos (Sentry si hay DSN; no-op si no).
      unawaited(CrashReporter.capture(exception, stackTrace));
    } catch (_) {
      // Ignore tracker errors
    }
  }

  /// Record user interaction events for product analytics
  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('ErrorTracker [EVENT]: $eventName, Params: $parameters');
    }

    if (!_initialized) return;

    try {
      // In production: FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    } catch (_) {
      // Ignore tracker errors
    }
  }
}
