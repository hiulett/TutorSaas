import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../../core/analytics/analytics_taxonomy.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../providers/subscription_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Pantalla de suscripción basada en el **paywall nativo de RevenueCat**.
///
/// Muestra los products configurados en RevenueCat (Lifetime / Yearly /
/// Monthly) con la UI gestionada por RevenueCat. Si el entitlement Pro está
/// activo, ofrece gestionar la suscripción (Customer Center) en su lugar.
///
/// Flujo recomendado (best practice):
/// 1. La pantalla presenta `presentPaywall()` al abrirse.
/// 2. Si el resultado es `purchased`/`restored`, se actualiza el estado
///    premium y se muestra el Customer Center para gestionar.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPresenting = false;

  /// Issue #72: último error al abrir el paywall. Si no es null se muestra un
  /// bloque de reintento en lugar de dejar al usuario con un snackbar efímero.
  String? _paywallError;

  void _track(String event, [Map<String, Object?>? properties]) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    RetentionAnalytics.instance.track(user.id, event, properties: properties);
  }

  @override
  void initState() {
    super.initState();
    // Issue #35: embudo del paywall (no se registraba ninguna vista).
    final user = ref.read(currentUserProvider);
    if (user != null) {
      RetentionAnalytics.instance.track(
        user.id,
        AnalyticsEvent.paywallViewed,
        properties: const {'source': 'paywall_screen'},
      );
    }
  }

  /// Issue #67: refresca plan, maná y clase tras comprar o restaurar.
  void _refreshAfterPurchase() {
    ref.invalidate(revenueCatEntitlementsProvider);
    ref.invalidate(revenueCatProProvider);
    ref.invalidate(revenueCatCustomerInfoProvider);
    ref.invalidate(manaStateProvider);
    ref.invalidate(dailyStateProvider);
    ref.invalidate(canInvokeProvider);
  }

  /// Issue #67: restaura compras de verdad (antes solo abría el paywall).
  Future<void> _restorePurchases() async {
    if (_isPresenting) return;
    setState(() => _isPresenting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(revenueCatReadyProvider.future);
      if (!mounted) return;
      final service = ref.read(revenueCatServiceProvider);
      final info = await service.restore();
      if (!mounted) return;
      if (service.resultGrantsPro(info)) {
        ref.read(isPremiumProvider.notifier).setPremium(true);
        _refreshAfterPurchase();
        _track(AnalyticsEvent.restoreResult, const {'result': 'granted'});
        SystemSnack.show(context, l10n.paywall_restored,
            type: SystemSnackType.success);
      } else {
        _track(AnalyticsEvent.restoreResult, const {'result': 'nothing'});
        SystemSnack.show(
          context,
          l10n.paywall_nothing_to_restore,
          type: SystemSnackType.info,
        );
      }
    } catch (e) {
      debugPrint('Restore purchases failed: $e');
      _track(AnalyticsEvent.restoreResult, {'result': 'error', 'error': e.toString()});
      if (mounted) {
        SystemSnack.show(context, l10n.paywall_load_error,
            type: SystemSnackType.error);
      }
    } finally {
      if (mounted) setState(() => _isPresenting = false);
    }
  }

  Future<void> _openPaywall() async {
    if (_isPresenting) return;
    setState(() {
      _isPresenting = true;
      _paywallError = null;
    });
    final l10n = AppLocalizations.of(context)!;
    _track(AnalyticsEvent.purchaseStarted);
    try {
      // Issue #64: el SDK debe estar configurado antes de presentar el paywall;
      // si no, `presentPaywall` falla con configurationError.
      await ref.read(revenueCatReadyProvider.future);
      if (!mounted) return;
      final service = ref.read(revenueCatServiceProvider);
      final result = await service.presentPaywall();

      if (!mounted) return;
      switch (result) {
        case PaywallResult.purchased:
          ref.read(isPremiumProvider.notifier).setPremium(true);
          _refreshAfterPurchase();
          _track(AnalyticsEvent.purchaseSucceeded);
          SystemSnack.show(
            context,
            l10n.paywall_success,
            type: SystemSnackType.success,
          );
          break;
        case PaywallResult.restored:
          _refreshAfterPurchase();
          _track(AnalyticsEvent.purchaseSucceeded, const {'via': 'restore'});
          SystemSnack.show(context, l10n.paywall_restored,
              type: SystemSnackType.success);
          break;
        // El usuario cerró el paywall sin comprar, no se presentó o hubo error:
        // sin acción adicional.
        case PaywallResult.cancelled:
        case PaywallResult.notPresented:
          _track(AnalyticsEvent.purchaseCancelled, {'result': result.name});
          break;
        case PaywallResult.error:
          _track(AnalyticsEvent.purchaseFailed, const {'error': 'paywall_result_error'});
          if (mounted) setState(() => _paywallError = l10n.paywall_load_error);
          break;
      }
    } catch (e) {
      debugPrint('Paywall failed: $e');
      // Issue #72: además del snackbar, dejar un estado con reintento.
      _track(AnalyticsEvent.purchaseFailed, {'error': e.toString()});
      if (mounted) {
        setState(() => _paywallError = l10n.paywall_load_error);
        SystemSnack.show(
          context,
          '${l10n.paywall_load_error} $e',
          type: SystemSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isPresenting = false);
    }
  }

  Future<void> _openCustomerCenter() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Issue #64: misma garantía que en el paywall.
      await ref.read(revenueCatReadyProvider.future);
      if (!mounted) return;
      await ref.read(revenueCatServiceProvider).presentCustomerCenter();
    } catch (e) {
      if (mounted) {
        SystemSnack.show(context, '${l10n.paywall_load_error} $e',
            type: SystemSnackType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);
    final entitlementsAsync = ref.watch(revenueCatEntitlementsProvider);

    return Scaffold(
      body: CyberManhwaBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.onSurface, size: 28),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    ),
                    TextButton(
                      onPressed: _isPresenting ? null : _restorePurchases,
                      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                      child: Text(
                        l10n.paywall_restore,
                        style: AppTypography.stat(context).copyWith(
                          color: AppColors.runeViolet,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      // Crown icon
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.runeViolet.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.runeViolet.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.runeViolet,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        isPremium
                            ? l10n.paywall_active_title
                            : l10n.paywall_upgrade_title,
                        textAlign: TextAlign.center,
                        style: AppTypography.headline(context).copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPremium
                            ? l10n.paywall_active_subtitle
                            : l10n.paywall_upgrade_subtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMuted(context),
                      ),
                      const SizedBox(height: 32),

                      entitlementsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.runeViolet),
                          ),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            l10n.paywall_load_error,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMuted(context),
                          ),
                        ),
                        data: (_) => _buildActions(context, isPremium),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isPremium) {
    final l10n = AppLocalizations.of(context)!;

    // CTA principal: si no es premium → abrir el paywall nativo de RevenueCat.
    // Si es premium → gestionar suscripción (Customer Center).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Issue #72: estado de error persistente con reintento (el CTA sigue
        // activo, así que basta con volver a pulsarlo).
        if (_paywallError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.errorRed, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _paywallError!,
                    style: AppTypography.bodyMuted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton(
          onPressed: _isPresenting
              ? null
              : isPremium
                  ? _openCustomerCenter
                  : _openPaywall,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.runeViolet,
            foregroundColor: AppColors.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            elevation: 8,
            shadowColor: AppColors.runeViolet.withValues(alpha: 0.3),
          ),
          child: _isPresenting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.onSurface,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  isPremium
                      ? l10n.paywall_manage_subscription
                      : l10n.paywall_subscribe,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (isPremium)
          TextButton(
            onPressed: _isPresenting ? null : _restorePurchases,
            child: Text(
              l10n.paywall_restore,
              style: AppTypography.stat(context).copyWith(
                color: AppColors.manaCyan,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          l10n.paywall_legal,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMuted(context).copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
