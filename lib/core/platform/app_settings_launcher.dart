import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// P-34e (#119): puente mínimo a los ajustes de Android.
///
/// No se añade un plugin nuevo: `MainActivity` expone un `MethodChannel` que
/// abre la pantalla de permisos de la app. Si el canal no está disponible
/// (tests, plataforma no Android), devuelve `false` en vez de lanzar.
class AppSettingsLauncher {
  const AppSettingsLauncher({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'tutorsaas/app_settings';

  final MethodChannel _channel;

  /// Abre `Ajustes > Apps > Dungeon of English > Permisos`.
  ///
  /// Devuelve `true` si Android abrió la pantalla. Nunca lanza.
  Future<bool> openAppPermissionSettings() async {
    try {
      final opened = await _channel.invokeMethod<bool>(
        'openAppPermissionSettings',
      );
      return opened ?? false;
    } on PlatformException catch (e) {
      debugPrint('No se pudo abrir los ajustes de la app: ${e.message}');
      return false;
    } on MissingPluginException catch (e) {
      debugPrint('Canal de ajustes no disponible: $e');
      return false;
    }
  }
}

final appSettingsLauncherProvider = Provider<AppSettingsLauncher>(
  (ref) => const AppSettingsLauncher(),
);
