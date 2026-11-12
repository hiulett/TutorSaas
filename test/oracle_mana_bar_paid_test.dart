import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/cache/cached_future_controller.dart';
import 'package:tutorsaas/features/economy/presentation/providers/economy_providers.dart';
import 'package:tutorsaas/features/economy/presentation/widgets/oracle_mana_bar.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// Red de regresión de #338: `OracleManaBar` con PLAN DE PAGO y ancho real.
///
/// El caso que no cubría nada: `test/text_scale_test.dart` monta
/// `DashboardScreen` con el estado por defecto de `manaStateProvider`, que es
/// `is_free: true`. Con plan gratuito el widget pinta el maná DIARIO y **no
/// pinta la caducidad** (`if (!isFree && expiresAt != null)`), así que la fila
/// del `Wrap` que cambió #338 (coste por turno + caducidad) nunca se ejercita.
///
/// Aquí se monta el widget con el JSON real de `get_mana_state` para un plan de
/// pago, a los dos anchos de producción:
///   - 150 dp, `compact: true`: barra de la conversación
///     (`_kConversationManaBarWidth`).
///   - 280 dp, `compact: false`: HUD del dashboard (`hunter_hud_header.dart`).
///
/// Cada caso comprueba dos cosas: que el saldo y el coste por turno se ven, y
/// que no queda ninguna excepción de layout (`tester.takeException()`).
void main() {
  setUpAll(() async {
    // Sin red nunca: las variantes viven en `assets/google_fonts/`
    // (`test/bundled_fonts_test.dart` vigila que estén todas).
    GoogleFonts.config.allowRuntimeFetching = false;

    // Las fuentes se registran de forma asíncrona la primera vez que se pide un
    // estilo. Si no se esperan, los primeros frames miden con la fuente de
    // respaldo del entorno de test (avance 1 em en vez de 0.6 em de JetBrains
    // Mono) y un ancho de 150 dp mediría mal: el test acusaría un desbordamiento
    // que la app no tiene. Se precargan las DOS variantes que usa el widget
    // (regular para el coste, bold para saldo/etiqueta/caducidad).
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.jetBrainsMono();
    GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold);
    await GoogleFonts.pendingFonts();
  });

  /// JSON de `get_mana_state` con plan de pago: saldo del ciclo 15000 de 17000
  /// y caducidad el 12/11. Mismas claves que lee el widget.
  const paidMana = <String, dynamic>{
    'allowance': 17000,
    'purchased': 0,
    'used': 2000,
    'remaining': 15000,
    'expires_at': '2026-11-12T00:00:00Z',
    'plan': 'Plan Héroe',
    'class': 'heroe',
    'is_free': false,
    'daily_limit': 200,
    'daily_used': 0,
    'daily_remaining': 200,
  };

  /// Coste de una invocación al Oráculo (`ai_action_costs`). Distinto del
  /// valor por defecto (12) para que la aserción demuestre que el widget pinta
  /// el coste que recibe, no el de reserva.
  const int oracleCost = 15;

  Future<void> pumpManaBar(
    WidgetTester tester, {
    required double width,
    required double textScale,
    required bool compact,
  }) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // `manaStateProvider` es el ÚNICO estado que consume el widget
          // (`economy_providers.dart`). Se sustituye por un controlador con el
          // JSON ya servido: sin Supabase, sin red y sin depender de la
          // sesión (`currentUserProvider`).
          manaStateProvider.overrideWith(
            (ref) => CachedFutureController<Map<String, dynamic>>(
              userIdGetter: () => 'test',
              fetcher: () async => paidMana,
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Builder(
            // `Builder` + `copyWith` para heredar la MediaQuery de la vista y
            // cambiar solo la escala de texto.
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: width,
                    // Alto holgado: lo que se mide aquí es el ancho. Un alto
                    // justo añadiría un overflow vertical que no es el objeto
                    // del test.
                    height: 400,
                    child: OracleManaBar(
                      compact: compact,
                      costPerTurn: oracleCost,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // El controlador arranca en `loading` (el widget cae al estado de reserva,
    // que es free) y resuelve en un microtask. El `AnimatedCounter` tarda
    // 600 ms en llegar al saldo final y se reanima al cambiar de target.
    // Nada de `pumpAndSettle`: se avanza con duraciones fijas.
    await tester.pump(); // primer frame
    await tester.pump(const Duration(milliseconds: 100)); // llega el provider
    await tester.pump(const Duration(milliseconds: 700)); // contador animado
    await tester.pump(const Duration(milliseconds: 700)); // frame estable
  }

  /// Saldo, coste por turno y caducidad, los tres visibles a la vez.
  ///
  /// `find.text` compara el `data` del `Text`, así que sigue encontrando la
  /// caducidad aunque a 150 dp se elida visualmente.
  void expectPaidManaContent() {
    expect(find.text('MANÁ'), findsOneWidget, reason: 'etiqueta de la barra');
    expect(
      find.text('15000 / 17000'),
      findsOneWidget,
      reason: 'saldo del ciclo: restante / (asignación + comprado)',
    );
    expect(
      find.text('15000'),
      findsOneWidget,
      reason: 'el contador animado llega al saldo restante',
    );
    expect(
      find.text('$oracleCost/turno'),
      findsOneWidget,
      reason: 'coste por turno inyectado (Oráculo)',
    );
    expect(
      find.text('expira 12/11'),
      findsOneWidget,
      reason: 'con plan de pago el Wrap pinta la caducidad',
    );
    expect(
      find.text('maná disponible'),
      findsOneWidget,
      reason: 'estado del plan de pago, no "maná disponible hoy" (free)',
    );
  }

  group('OracleManaBar con plan de pago (#338)', () {
    testWidgets('150 dp + textScaler 1.1: saldo y coste sin overflow', (
      tester,
    ) async {
      await pumpManaBar(tester, width: 150, textScale: 1.1, compact: true);

      expect(
        tester.getSize(find.byType(OracleManaBar)).width,
        150,
        reason: 'el ancho de mount es el de la conversación (#338)',
      );
      expectPaidManaContent();

      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: '150 dp a textScaler 1.1 no debe desbordar: $exception',
      );
    });

    testWidgets('150 dp + textScaler 2.0: la caducidad cede sitio, sin '
        'overflow', (tester) async {
      await pumpManaBar(tester, width: 150, textScale: 2.0, compact: true);

      expect(tester.getSize(find.byType(OracleManaBar)).width, 150);
      expectPaidManaContent();

      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: '150 dp a textScaler 2.0 no debe desbordar: $exception',
      );
    });

    testWidgets('280 dp (HUD) + textScaler 2.0: sin overflow', (tester) async {
      await pumpManaBar(tester, width: 280, textScale: 2.0, compact: false);

      expect(tester.getSize(find.byType(OracleManaBar)).width, 280);
      expectPaidManaContent();

      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: '280 dp a textScaler 2.0 no debe desbordar: $exception',
      );
    });
  });
}
