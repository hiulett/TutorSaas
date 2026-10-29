import 'package:flutter/services.dart';

/// Detecta el error de Google Sign-In por firma no registrada.
///
/// El SDK de Android lanza `PlatformException(sign_in_failed)` con
/// `ApiException: 10` (DEVELOPER_ERROR) cuando el SHA-1 de la clave con la
/// que se firmo el APK no esta registrado en el cliente OAuth de Android.
bool isGoogleSignInConfigError(Object error) {
  if (error is! PlatformException) return false;
  if (error.code != 'sign_in_failed') return false;
  final message = error.message ?? '';
  return message.contains('ApiException: 10') || message.contains(': 10:');
}
