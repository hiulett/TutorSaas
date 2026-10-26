import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Reporte de fallos con Sentry.
///
/// Sin `SENTRY_DSN` (build normal o tests) queda desactivado: no se inicializa
/// el SDK ni se envia nada. Con DSN, captura errores de Flutter y de plataforma.
///
/// Privacidad: sin PII por defecto y sin breadcrumbs, para no arrastrar texto de
/// la UI ni contenido de conversaciones.
class CrashReporter {
  CrashReporter._();

  static bool _enabled = false;

  static bool get isEnabled => _enabled;

  static const String _dsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  static const String _environment = String.fromEnvironment(
    'SENTRY_ENV',
    defaultValue: 'production',
  );
  static const String _release = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.21+22',
  );

  static Future<void> init() async {
    if (_dsn.isEmpty) {
      if (kDebugMode) {
        debugPrint('CrashReporter: SENTRY_DSN vacio, reporte desactivado.');
      }
      return;
    }

    try {
      await SentryFlutter.init((options) {
        options.dsn = _dsn;
        options.environment = _environment;
        options.release = _release;
        options.sendDefaultPii = false;
        options.attachStacktrace = true;
        options.tracesSampleRate = 0.0;
        // Sin migas de pan: evita capturar texto de pantallas.
        options.maxBreadcrumbs = 0;
      }, appRunner: () {});

      _enabled = true;

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        unawaited(
          Sentry.captureException(details.exception, stackTrace: details.stack),
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(Sentry.captureException(error, stackTrace: stack));
        return true;
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CrashReporter: fallo al inicializar: $e');
      }
    }
  }

  static Future<void> capture(Object error, StackTrace? stackTrace) async {
    if (!_enabled) return;
    try {
      await Sentry.captureException(error, stackTrace: stackTrace);
    } catch (_) {
      // El reportero nunca debe romper la app.
    }
  }
}
