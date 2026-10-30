import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/services/revenuecat_service.dart';
import 'package:tutorsaas/features/subscription/domain/models/subscription_plan.dart';
import 'package:tutorsaas/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:tutorsaas/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:tutorsaas/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// P-44 (#129) / P-45 (#130): el paywall pinta el catálogo que publica el
/// servidor y solo promete el trial cuando el plan lo declara.
class _FakeSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<bool> isUserPremium(String userId) async => false;

  @override
  Future<void> syncEntitlement() async {}
}

class _FakeRevenueCatService extends RevenueCatService {
  @override
  Future<void> configure(String userId) async {}

  @override
  Future<bool> isProActive() async => false;
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        publishableKey: 'placeholder',
      );
    } catch (_) {
      // Ya inicializado por otro test.
    }
  });

  Future<void> pumpPaywall(
    WidgetTester tester, {
    required PlanCatalog catalog,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planCatalogProvider.overrideWith((ref) async => catalog),
          revenueCatEntitlementsProvider.overrideWith((ref) async => {}),
          isPremiumProvider.overrideWith(
            (ref) => PremiumStatusNotifier(
              _FakeSubscriptionRepository(),
              _FakeRevenueCatService(),
              null,
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: PaywallScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  const nobleWithTrial = SubscriptionPlan(
    id: 'noble',
    name: 'NOBLE',
    price: r'$4.99',
    trialDays: 7,
    weeklyReportWeeks: 4,
    manaAllowance: 17000,
  );

  testWidgets('muestra el trial de NOBLE con su precio', (tester) async {
    await pumpPaywall(
      tester,
      catalog: const PlanCatalog(plans: [nobleWithTrial], exclusiveByPlan: {}),
    );

    expect(find.text('NOBLE'), findsOneWidget);
    expect(find.text('7 días gratis, luego \$4.99/mes'), findsOneWidget);
    expect(find.text('4 semanas de historial en el informe'), findsOneWidget);
    expect(find.textContaining('17.000'), findsOneWidget);
  });

  testWidgets('sin trial en la base no hay promesa de prueba', (tester) async {
    await pumpPaywall(
      tester,
      catalog: const PlanCatalog(
        plans: [
          SubscriptionPlan(
            id: 'realeza',
            name: 'REALEZA',
            price: r'$9.99',
            weeklyReportWeeks: 52,
            manaAllowance: 20500,
          ),
        ],
        exclusiveByPlan: {'realeza': 2},
      ),
    );

    expect(find.text('REALEZA'), findsOneWidget);
    expect(find.textContaining('gratis'), findsNothing);
    expect(find.text('52 semanas de historial en el informe'), findsOneWidget);
    expect(find.text('2 cosméticos exclusivos'), findsOneWidget);
  });

  testWidgets('sin catálogo el paywall sigue mostrando el CTA', (tester) async {
    await pumpPaywall(tester, catalog: const PlanCatalog());

    expect(find.text('ELIGE TU ESTAMENTO'), findsNothing);
    expect(find.text('SUSCRIBIRSE AHORA'), findsOneWidget);
  });
}
