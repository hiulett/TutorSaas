import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/services/revenuecat_service.dart';
import 'package:tutorsaas/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:tutorsaas/features/subscription/presentation/providers/subscription_providers.dart';

/// Flujo premium con RevenueCat simulado (P-18 / #103).
class _FakeSubscriptionRepository implements SubscriptionRepository {
  int syncCalls = 0;
  bool premium = false;

  @override
  Future<void> syncEntitlement() async {
    syncCalls++;
  }

  @override
  Future<bool> isUserPremium(String userId) async => premium;
}

class _FakeRevenueCatService extends RevenueCatService {
  _FakeRevenueCatService({required this.proActive, this.throwOnCheck = false});

  final bool proActive;
  final bool throwOnCheck;
  int configureCalls = 0;

  @override
  Future<void> configure(String userId) async {
    configureCalls++;
  }

  @override
  Future<bool> isProActive() async {
    if (throwOnCheck) throw StateError('revenuecat caido');
    return proActive;
  }
}

void main() {
  test('entitlement activo deja el estado en premium', () async {
    final repo = _FakeSubscriptionRepository();
    final rc = _FakeRevenueCatService(proActive: true);

    final notifier = PremiumStatusNotifier(repo, rc, 'user-1');
    await pumpEventQueue();

    expect(rc.configureCalls, 1);
    expect(notifier.state, isTrue);
  });

  test('sin entitlement el estado queda en false', () async {
    final repo = _FakeSubscriptionRepository();
    final rc = _FakeRevenueCatService(proActive: false);

    final notifier = PremiumStatusNotifier(repo, rc, 'user-2');
    await pumpEventQueue();

    expect(notifier.state, isFalse);
  });

  test('un fallo del SDK no rompe: el estado se queda en false', () async {
    final repo = _FakeSubscriptionRepository();
    final rc = _FakeRevenueCatService(proActive: false, throwOnCheck: true);

    final notifier = PremiumStatusNotifier(repo, rc, 'user-3');
    await pumpEventQueue();

    expect(notifier.state, isFalse);
  });

  test('sync-entitlement no se repite dentro de la misma hora (TTL)', () async {
    final repo = _FakeSubscriptionRepository();
    final rc = _FakeRevenueCatService(proActive: false);

    PremiumStatusNotifier(repo, rc, 'user-4');
    await pumpEventQueue();
    final afterFirst = repo.syncCalls;

    PremiumStatusNotifier(repo, rc, 'user-4');
    await pumpEventQueue();

    expect(
      repo.syncCalls,
      afterFirst,
      reason: 'el segundo no vuelve a sincronizar',
    );
  });
}
