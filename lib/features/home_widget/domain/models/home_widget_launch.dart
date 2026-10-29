/// Rutas que puede pedir el widget de pantalla de inicio (P-36 / #121).
///
/// El botón "Practicar" del widget abre la app con `homeWidget://practice` y
/// el resto del widget con `homeWidget://home`. Este mapeo es lógica pura para
/// poder probarlo sin Android.
abstract final class HomeWidgetLaunch {
  static const String practiceUri = 'homeWidget://practice';
  static const String homeUri = 'homeWidget://home';

  static const String practiceRoute = '/conversation';
  static const String homeRoute = '/home';

  /// `null` si el Uri no lo envió el widget (o no lo reconocemos).
  static String? routeFor(Uri? uri) {
    if (uri == null) return null;
    if (uri.scheme.toLowerCase() != 'homewidget') return null;
    final target = uri.host.isNotEmpty
        ? uri.host.toLowerCase()
        : uri.path.replaceAll('/', '').toLowerCase();
    switch (target) {
      case 'practice':
        return practiceRoute;
      case 'home':
        return homeRoute;
      default:
        return null;
    }
  }
}
