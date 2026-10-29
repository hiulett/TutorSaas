import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/home_widget/domain/models/home_widget_launch.dart';

/// P-36 (#121): el widget abre la app con un Uri propio. Este mapeo decide a
/// qué ruta de `go_router` va cada toque.
void main() {
  test('el botón Practicar abre la conversación', () {
    expect(
      HomeWidgetLaunch.routeFor(Uri.parse('homeWidget://practice')),
      HomeWidgetLaunch.practiceRoute,
    );
  });

  test('tocar el resto del widget abre el inicio', () {
    expect(
      HomeWidgetLaunch.routeFor(Uri.parse('homeWidget://home')),
      HomeWidgetLaunch.homeRoute,
    );
  });

  test('acepta la forma con barra (host vacío)', () {
    expect(
      HomeWidgetLaunch.routeFor(Uri.parse('homeWidget:///practice')),
      HomeWidgetLaunch.practiceRoute,
    );
  });

  test('un destino desconocido no navega', () {
    expect(
      HomeWidgetLaunch.routeFor(Uri.parse('homeWidget://paywall')),
      isNull,
    );
  });

  test('un esquema ajeno (deep link de auth) no navega', () {
    expect(
      HomeWidgetLaunch.routeFor(
        Uri.parse('io.supabase.tutorsaas://login-callback'),
      ),
      isNull,
    );
  });

  test('sin Uri no navega', () {
    expect(HomeWidgetLaunch.routeFor(null), isNull);
  });

  test('las rutas existen en el contrato del router', () {
    expect(HomeWidgetLaunch.practiceRoute, '/conversation');
    expect(HomeWidgetLaunch.homeRoute, '/home');
  });
}
