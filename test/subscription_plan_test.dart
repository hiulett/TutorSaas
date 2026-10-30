import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/subscription/domain/models/subscription_plan.dart';

/// P-44 (#129) / P-45 (#130): el catálogo de planes llega del servidor.
/// Lo que se prueba aquí es que el cliente no inventa capacidades: pinta el
/// trial solo si `trial_days > 0` y usa las semanas que publica la tabla.
void main() {
  group('SubscriptionPlan', () {
    test('lee el trial y las semanas de historial de la fila', () {
      final noble = SubscriptionPlan.fromMap(const {
        'id': 'noble',
        'name': 'NOBLE',
        'price': r'$4.99',
        'billing_cycle': 'monthly',
        'trial_days': 7,
        'weekly_report_weeks': 4,
        'mana_allowance': 17000,
        'features': ['17.000 de maná/mes'],
      });

      expect(noble.hasTrial, isTrue);
      expect(noble.trialDays, 7);
      expect(
        noble.trialHeadline((days, price) => '$days d / $price'),
        '7 d / \$4.99',
      );
      expect(noble.weeklyReportWeeks, 4);
      expect(noble.manaAllowance, 17000);
      expect(noble.features, hasLength(1));
    });

    test('sin trial_days no promete prueba gratuita', () {
      final realeza = SubscriptionPlan.fromMap(const {
        'id': 'realeza',
        'name': 'REALEZA',
        'price': r'$9.99',
      });

      expect(realeza.hasTrial, isFalse);
      expect(realeza.trialDays, 0);
      // Valores seguros si el servidor no manda las columnas nuevas.
      expect(realeza.weeklyReportWeeks, 1);
      expect(realeza.manaAllowance, 0);
      expect(realeza.features, isEmpty);
    });

    test('ignore features con tipos raros en vez de romper', () {
      final plan = SubscriptionPlan.fromMap(const {
        'id': 'plebeyo',
        'name': 'PLEBEYO',
        'features': [1, null, '  ', 'x'],
      });

      expect(plan.features, ['1', 'x']);
    });
  });

  group('PlanCatalog', () {
    test('cuenta los exclusivos por plan', () {
      const catalog = PlanCatalog(
        plans: [
          SubscriptionPlan(id: 'plebeyo', name: 'PLEBEYO'),
          SubscriptionPlan(id: 'realeza', name: 'REALEZA'),
        ],
        exclusiveByPlan: {'realeza': 2},
      );

      expect(catalog.isEmpty, isFalse);
      expect(catalog.exclusivesFor(catalog.plans[0]), 0);
      expect(catalog.exclusivesFor(catalog.plans[1]), 2);
    });

    test('un catálogo vacío deja el paywall sin comparativa', () {
      expect(const PlanCatalog().isEmpty, isTrue);
    });
  });
}
