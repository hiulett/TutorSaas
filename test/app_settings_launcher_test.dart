import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/platform/app_settings_launcher.dart';

/// P-34e (#119): el canal de ajustes nunca lanza y devuelve false si falla.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('tutorsaas/app_settings');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('devuelve true cuando Android abre los ajustes', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'openAppPermissionSettings');
      return true;
    });

    final launcher = const AppSettingsLauncher(channel: channel);
    expect(await launcher.openAppPermissionSettings(), isTrue);
  });

  test('devuelve false si Android informa un error', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'open_failed', message: 'sin intent');
    });

    final launcher = AppSettingsLauncher(channel: channel);
    expect(await launcher.openAppPermissionSettings(), isFalse);
  });

  test('devuelve false si el canal no existe', () async {
    // Sin handler registrado el canal responde MissingPluginException.
    final launcher = AppSettingsLauncher(channel: channel);
    expect(await launcher.openAppPermissionSettings(), isFalse);
  });
}
