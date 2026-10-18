import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../constants/api_constants.dart';

/// Servicio de suscripciones vía RevenueCat (Google Play Billing).
///
/// Reemplaza el flujo Stripe in-app (no permitido para bienes digitales). La
/// compra se hace con el SDK de RevenueCat; el webhook `revenuecat-webhook`
/// (Supabase Edge Function) activa el plan y renueva el maná.
///
/// La API key pública se inyecta en build (`--dart-define-from-file=config.json`);
/// el default es la test key pública (solo dev).
class RevenueCatService {
  bool _configured = false;

  /// Configura el SDK. Debe llamarse tras autenticarse (appUserID = supabase uid).
  /// Idempotente: no re-configura si ya está inicializado con el mismo usuario.
  Future<void> configure(String userId) async {
    if (ApiConstants.revenueCatApiKey.isEmpty) return;
    if (_configured) return;
    await Purchases.configure(
      PurchasesConfiguration(ApiConstants.revenueCatApiKey)
        ..appUserID = userId
        // Best practice: habilita la verificación de entitlements del lado
        // del servidor de RevenueCat (reduce riesgo de spoofing en compras).
        ..entitlementVerificationMode = EntitlementVerificationMode.informational,
    );
    await Purchases.setLogLevel(LogLevel.warn);
    _configured = true;
  }

  /// Offerings activos (el paywall los muestra). `current` es el principal.
  Future<Offerings> getOfferings() async {
    if (!_configured) throw StateError('RevenueCat no configurado');
    return Purchases.getOfferings();
  }

  /// Compra un package del offering. Devuelve el CustomerInfo resultante.
  Future<CustomerInfo> purchase(Package package) async {
    if (!_configured) throw StateError('RevenueCat no configurado');
    final result = await Purchases.purchase(
      PurchaseParams.package(package),
    );
    return result.customerInfo;
  }

  /// Restaura compras previas (RevenueCat / Store).
  Future<CustomerInfo> restore() async {
    if (!_configured) throw StateError('RevenueCat no configurado');
    return Purchases.restorePurchases();
  }

  /// CustomerInfo del usuario (entitlements, suscripciones, compras).
  Future<CustomerInfo> getCustomerInfo() async {
    if (!_configured) throw StateError('RevenueCat no configurado');
    return Purchases.getCustomerInfo();
  }

  /// Entitlements activos del usuario (map identifier → info).
  Future<Map<String, EntitlementInfo>> getActiveEntitlements() async {
    if (!_configured) return const {};
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active;
  }

  /// ¿Está activo el entitlement Pro (DungeonsSpeak Pro)?
  Future<bool> isProActive() async {
    if (!_configured) return false;
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active
        .containsKey(ApiConstants.revenueCatProEntitlement);
  }

  /// Suscríbete a cambios de CustomerInfo (compra, renovación, cancelación).
  Stream<CustomerInfo> get customerInfoUpdates {
    final controller = StreamController<CustomerInfo>.broadcast();
    Purchases.addCustomerInfoUpdateListener(controller.add);
    return controller.stream;
  }

  // ── Paywall nativo de RevenueCat (presentación) ─────────────────────────

  /// Presenta el paywall nativo de RevenueCat (ofrece los packages de los
  /// products configurados: lifetime/yearly/monthly). Devuelve el resultado.
  Future<PaywallResult> presentPaywall({Offering? offering}) {
    return RevenueCatUI.presentPaywall(
      offering: offering,
      displayCloseButton: true,
    );
  }

  /// Presenta el paywall SOLO si el entitlement Pro NO está activo.
  /// Es el patrón recomendado para gates de paywall.
  Future<PaywallResult> presentPaywallIfNeeded() {
    return RevenueCatUI.presentPaywallIfNeeded(
      ApiConstants.revenueCatProEntitlement,
      displayCloseButton: true,
    );
  }

  /// Presenta el Customer Center (gestionar suscripción: cancelar, restaurar,
  /// solicitar reembolso, cambiar plan). Requiere configuración previa en el
  /// dashboard de RevenueCat (Customer Center).
  Future<void> presentCustomerCenter() {
    return RevenueCatUI.presentCustomerCenter();
  }

  /// Resultado de una compra: ¿el entitlement Pro quedó activo?
  bool resultGrantsPro(CustomerInfo info) =>
      info.entitlements.active.containsKey(ApiConstants.revenueCatProEntitlement);
}

/// Provider del servicio (singleton).
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Provider que expone los offerings (autorecarga al abrir el paywall).
final revenueCatOfferingsProvider =
    FutureProvider.autoDispose<Offerings>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  final offerings = await service.getOfferings();
  return offerings;
});

/// Provider con los entitlements activos del usuario.
final revenueCatEntitlementsProvider =
    FutureProvider.autoDispose<Map<String, EntitlementInfo>>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return service.getActiveEntitlements();
});

/// Provider con el CustomerInfo del usuario (para UI avanzada).
final revenueCatCustomerInfoProvider =
    FutureProvider.autoDispose<CustomerInfo>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return service.getCustomerInfo();
});

/// Provider: ¿entitlement Pro activo? (fuente para isPremiumProvider).
final revenueCatProProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return service.isProActive();
});
