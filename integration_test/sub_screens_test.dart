// Subpantallas: recorre lo que hay DENTRO de las pantallas (pestañas, filtros,
// pestaña del dock) sobre un dispositivo real y reporta, pantalla a pantalla,
// si el toque deja una excepción de Flutter pendiente.
//
// Uso:
//   flutter test integration_test/sub_screens_test.dart -d <device>
//
// Complementa a `all_routes_test.dart`, que solo monta cada ruta. Igual que
// allí: sin `pumpAndSettle` (las pantallas tienen animaciones infinitas) y sin
// dependencias nuevas.
//
// Regla de oro: el test falla SOLO si Flutter lanza una excepción. Que un texto
// no exista (copy distinto, idioma distinto, datos vacíos, redirección por
// sesión) se reporta en el log y no rompe la ejecución: por eso todos los
// selectores se comprueban antes de tocar y los toques van con
// `warnIfMissed: false`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tutorsaas/app/app.dart';
import 'package:tutorsaas/app/router.dart';
import 'package:tutorsaas/core/constants/api_constants.dart';
import 'package:tutorsaas/features/dashboard/presentation/screens/settings_screen.dart';

/// Pestañas de la tienda (`ShopScreen._selectedTab`): ORO · GEMAS ·
/// FRAGMENTOS. Se buscan por texto porque cada pestaña es un
/// `AnimatedContainer` sin identificador propio.
const List<String> _shopTabWords = <String>['ORO', 'GEMAS', 'FRAGMENTOS'];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('subpantallas sin excepcion', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    try {
      await Supabase.initialize(
        url: ApiConstants.supabaseUrl,
        publishableKey: ApiConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('INIT Supabase ya inicializado o falló: $e');
    }

    await tester.pumpWidget(const ProviderScope(child: TutorSaaSApp()));
    // Deja arrancar el splash (navega como máximo a los ~3 s).
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TutorSaaSApp)),
    );
    final GoRouter router = container.read(routerProvider);

    final failures = <String>[];
    var screens = 0;

    /// Navega sin `pumpAndSettle` y devuelve el path donde se quedó (puede no
    /// ser el pedido: el `redirect` del router manda a welcome/onboarding si no
    /// hay sesión o perfil).
    Future<String> go(String path) async {
      try {
        router.go(path);
      } catch (e) {
        debugPrint('GO $path no pudo navegar: ${_short(e)}');
      }
      await _pump(tester);
      return router.routerDelegate.currentConfiguration.uri.path;
    }

    /// Ejecuta un paso, drena las excepciones de Flutter que dejó y emite una
    /// única línea `SCREEN <nombre> exception=<...>`.
    Future<void> report(String name, Future<String> Function() body) async {
      screens++;
      var extra = '';
      try {
        extra = await body();
      } catch (e) {
        // Un `tester.tap` que no encuentra nada no es una excepción de la app:
        // se anota y se sigue.
        extra = 'throw=${_short(e)}';
      }
      final Object? failure = _pendingException(tester);
      if (failure != null) failures.add(name);
      debugPrint(
        'SCREEN $name exception=${failure ?? 'none'}'
        '${extra.isEmpty ? '' : ' $extra'}',
      );
    }

    // Lo que reviente en el arranque no se imputa a ninguna pantalla, pero
    // cuenta como fallo porque también es una excepción de Flutter.
    final Object? bootFailure = _pendingException(tester);
    if (bootFailure != null) {
      failures.add('arranque');
      debugPrint('SCREEN arranque exception=$bootFailure');
    }

    // ── 1. /shop: montar y tocar cada pestaña de moneda ─────────────────────
    await report('shop', () async {
      final landed = await go('/shop');
      final tabs = find.byType(AnimatedContainer).evaluate().length;
      return 'landed=$landed pestañas=$tabs';
    });

    for (final word in _shopTabWords) {
      await report('shop:$word', () async {
        // Cada pestaña es el `AnimatedContainer` que envuelve su etiqueta
        // («ORO · 120»); se sube desde el texto para no depender del índice.
        var outcome = await _tap(tester, _shopTab(word));
        if (outcome == 'missing') {
          // Si el copy cambió, se cae al orden de las pestañas.
          outcome = await _tap(
            tester,
            find.byType(AnimatedContainer).at(_shopTabWords.indexOf(word)),
          );
        }
        return 'tap=$outcome';
      });
    }

    // ── 2. /missions: montar y tocar el primer filtro/sección ───────────────
    await report('missions', () async {
      final landed = await go('/missions');
      final tabs = find.byType(Tab).evaluate().length;
      return 'landed=$landed pestañas=$tabs';
    });

    // Diarias (el primero) y Semanales. `Tab` es estable al copy.
    for (var index = 0; index < 2; index++) {
      await report('missions:filtro$index', () async {
        final outcome = await _tap(tester, find.byType(Tab).at(index));
        return 'tap=$outcome';
      });
    }

    // ── 3. /inventory: abrir y comprobar que hay al menos un título ─────────
    await report('inventory', () async {
      final landed = await go('/inventory');
      final titles = _inventoryTitleHits();
      // El filtro de categoría («ALL») solo cambia estado local: se toca para
      // cubrir la sección sin escribir nada en el servidor.
      final outcome = await _tap(tester, find.text('ALL'));
      if (titles == 0) {
        debugPrint(
          'AVISO inventory: no encontré el título «INVENTARIO/INVENTORY» '
          '(¿copy o idioma distinto?)',
        );
      }
      return 'landed=$landed titulos=$titles tapFiltro=$outcome';
    });

    // ── 4. /my-errors y /weekly-report: montar sin excepción ────────────────
    await report('my-errors', () async {
      final landed = await go('/my-errors');
      return 'landed=$landed';
    });

    await report('weekly-report', () async {
      final landed = await go('/weekly-report');
      // El informe lo calcula el servidor (`get_weekly_report`): se le da algo
      // más de margen antes de leer la excepción.
      await _pump(tester, 4);
      return 'landed=$landed';
    });

    // ── 5. /settings no es ruta: se llega por el dock de /home ──────────────
    await report('home', () async {
      final landed = await go('/home');
      return 'landed=$landed';
    });

    await report('home:CONFIG', () async {
      // `l10n.config` es «CONFIG» en los tres idiomas.
      var outcome = await _tap(tester, find.text('CONFIG'), pumps: 6);
      if (outcome == 'missing') {
        outcome = await _tap(tester, find.textContaining('CONFIG'), pumps: 6);
      }
      final mounted = find.byType(SettingsScreen).evaluate().isNotEmpty;
      // La cabecera es «CONFIGURACIÓN DEL SISTEMA» (es) / «CONFIGURAÇÃO DO
      // SISTEMA» (pt) / «SYSTEM CONFIG» (en): `textContaining` para no atarse
      // al idioma del dispositivo.
      final header =
          find.textContaining('CONFIGURACI').evaluate().isNotEmpty ||
          find.textContaining('SYSTEM CONFIG').evaluate().isNotEmpty;
      return 'tap=$outcome settings=$mounted configuracion=$header';
    });

    debugPrint('RESUMEN subpantallas=$screens fallos=${failures.length}');
    expect(failures, isEmpty, reason: 'Pantallas con excepción: $failures');
  });
}

// ── Helpers ────────────────────────────────────────────────────────────────

/// Bombea sin `pumpAndSettle`: hay animaciones infinitas en la app.
Future<void> _pump(WidgetTester tester, [int rounds = 6]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// La pestaña de la tienda que contiene `word` (su `AnimatedContainer`).
Finder _shopTab(String word) => find.ancestor(
  of: find.textContaining(word),
  matching: find.byType(AnimatedContainer),
);

/// Toca el primer resultado de [finder] sin romper si no existe, si está fuera
/// de la vista o si no es alcanzable. Devuelve `ok`, `missing` o
/// `error:<texto>`.
Future<String> _tap(
  WidgetTester tester,
  Finder finder, {
  int pumps = 4,
}) async {
  if (finder.evaluate().isEmpty) return 'missing';
  // Las pestañas de la tienda viven en un scroll horizontal: en pantallas
  // estrechas la tercera puede quedar fuera. Si no hay scrollable, se sigue.
  try {
    await tester.ensureVisible(finder.first);
    await tester.pump();
  } catch (e) {
    debugPrint('REVEAL skip (${_short(e)})');
  }
  try {
    await tester.tap(finder.first, warnIfMissed: false);
  } catch (e) {
    await _pump(tester, pumps);
    return 'error:${_short(e)}';
  }
  await _pump(tester, pumps);
  return 'ok';
}

/// Toma la primera excepción pendiente del binding y limpia la cola (si no se
/// drena, flutter_test hace fallar el test al terminar).
Object? _pendingException(WidgetTester tester) {
  Object? first;
  for (var i = 0; i < 10; i++) {
    final Object? current = tester.takeException();
    if (current == null) break;
    first ??= current;
  }
  return first;
}

/// Títulos posibles del inventario según el `.arb` (es / en / pt).
int _inventoryTitleHits() {
  var hits = 0;
  for (final Finder finder in <Finder>[
    find.text('INVENTARIO'),
    find.text('INVENTORY'),
  ]) {
    hits += finder.evaluate().length;
  }
  return hits;
}

/// Primera parte del error, acotada para que el log quepa en una línea.
String _short(Object? error) {
  final text = (error ?? 'null')
      .toString()
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return text.length <= 160 ? text : '${text.substring(0, 160)}…';
}
