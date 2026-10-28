import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SubscriptionRepositoryImpl(supabaseClient);
});

/// Issue #64: garantiza que el SDK de RevenueCat esté configurado con el
/// usuario actual **antes** de presentar el paywall o el Customer Center.
///
/// Antes, `configure()` solo se lanzaba (sin esperarse) desde
/// `PremiumStatusNotifier`, así que pulsar «comprar» rápido abría el paywall
/// con el SDK sin inicializar y fallaba con `configurationError`.
final revenueCatReadyProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  try {
    await ref.read(revenueCatServiceProvider).configure(user.id);
  } catch (e) {
    debugPrint('RevenueCat configure failed: $e');
  }
});

/// Estado premium derivado de RevenueCat (entitlement "DungeonsSpeak Pro")
/// con fallback a la tabla `user_subscriptions` si RevenueCat no está
/// configurado (dev/tests).
class PremiumStatusNotifier extends StateNotifier<bool> {
  final SubscriptionRepository _repository;
  final RevenueCatService _rcService;
  final String? _userId;

  /// P-19: TTL de la reconciliacion con RevenueCat.
  static DateTime? _lastEntitlementSync;

  PremiumStatusNotifier(this._repository, this._rcService, this._userId)
      : super(false) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (_userId == null) return;
    try {
      // RevenueCat: entitlement Pro activo = premium (fuente autoritativa).
      if (ApiConstants.revenueCatApiKey.isNotEmpty) {
        await _rcService.configure(_userId);
        // Issue #69: alinea Supabase con RevenueCat antes de leer el estado,
        // así el maná y la clase reflejan la compra aunque el webhook falle.
        // P-19: como mucho una sincronización por hora; el provider se recrea
        // a menudo y no debe golpear la Edge Function cada vez.
        final lastSync = _lastEntitlementSync;
        final needsSync = lastSync == null ||
            DateTime.now().difference(lastSync) > const Duration(hours: 1);
        if (needsSync) {
          _lastEntitlementSync = DateTime.now();
          try {
            await _repository.syncEntitlement();
          } catch (syncError, syncStack) {
            _lastEntitlementSync = null;
            ErrorTracker.logSilent(
              'subscription.syncEntitlement',
              syncError,
              stackTrace: syncStack,
            );
          }
        }
        final active = await _rcService.isProActive();
        if (mounted) {
          state = active;
        }
        return;
      }
      // Fallback (sin RevenueCat): consulta la tabla de suscripciones.
      final isPrem = await _repository.isUserPremium(_userId);
      if (mounted) {
        state = isPrem;
      }
    } catch (e, st) {
      ErrorTracker.logSilent('lib/features/subscription/presentation/providers/subscription_providers.dart:63', e, stackTrace: st);
    }
  }

  void setPremium(bool val) {
    if (mounted) {
      state = val;
    }
  }
}

final isPremiumProvider =
    StateNotifierProvider.autoDispose<PremiumStatusNotifier, bool>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final rcService = ref.watch(revenueCatServiceProvider);
  final user = ref.watch(currentUserProvider);
  return PremiumStatusNotifier(repo, rcService, user?.id);
});
