import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// TIENDA ARCANO (FASE C).
///
/// - MANÁ: Porciones y packs de Gemas de Maná (pago real). Catálogo en BD.
/// - ORO: Cosméticos comprados con Oro (moneda ganada jugando).
///   Precios y catálogo desde cosmetic_catalog.price_gold.
/// - CANJE: Pantalla de fragmentos (títulos de prestigio).
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  // Issue #8: la pestaña de maná (Stripe en navegador externo) se retiró.
  // Se mantiene 'oro'; el maná se obtiene con el plan (RevenueCat).
  String _selectedTab = 'oro'; // 'oro'
  bool _isBuying = false;

  Future<bool> _confirmPurchase(String name, String priceLabel) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.medievalStone,
        title: Row(
          children: [
            const Icon(Icons.storefront_rounded, color: AppColors.manaCyan, size: 20),
            const SizedBox(width: 8),
            Text(l10n?.confirm_purchase ?? 'CONFIRMAR COMPRA', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          l10n?.purchase_confirm_question(name, priceLabel) ?? '¿Adquirir "$name" por $priceLabel?',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.85), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text((l10n?.cancel ?? 'Cancel').toUpperCase(), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n?.buy ?? 'COMPRAR', style: const TextStyle(color: AppColors.royalGold, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Compra de maná: crea el Checkout de Stripe y lo abre en el navegador.
  /// El webhook acredita el maná; al volver, el saldo se refresca solo.
  Future<void> _goBuyMana(Map<String, dynamic> product, String type) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final url = await ref
        .read(economyRepositoryProvider)
        .createManaCheckout(user.id, product['id'] as String? ?? '', type);
    if (!mounted) return;
    if (url == null || url.isEmpty) {
      SystemSnack.show(
        context,
        AppLocalizations.of(context)?.purchase_error_stripe ??
            'No se pudo iniciar el pago. Revisa la configuración de Stripe.',
        type: SystemSnackType.error,
      );
      return;
    }
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (ok) {
      ref.invalidate(manaStateProvider);
    } else if (mounted) {
      SystemSnack.show(
        context,
        AppLocalizations.of(context)?.checkout_error ?? 'No se pudo abrir el checkout.',
        type: SystemSnackType.error,
      );
    }
  }

  Future<void> _buyGoldCosmetic(Map<String, dynamic> item) async {
    final price = (item['price_gold'] as num?)?.toInt() ?? 0;
    final name = item['name'] as String? ?? 'este objeto';
    final priceLabel = AppLocalizations.of(context)?.price_gold('$price') ?? '$price ORO';
    final confirmed = await _confirmPurchase(name, priceLabel);
    if (!confirmed || !mounted) return;
    setState(() => _isBuying = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final ok = await ref
            .read(economyRepositoryProvider)
            .purchaseCosmeticWithGold(user.id, item['id'] as String? ?? '');
        ref.invalidate(inventoryProvider);
        ref.invalidate(goldBalanceProvider);
        if (mounted) {
          SystemSnack.show(
            context,
            ok
                ? (AppLocalizations.of(context)?.cosmetic_purchased ?? '¡COSMÉTICO ADQUIRIDO! 🪙')
                : (AppLocalizations.of(context)?.gold_insufficient ?? 'ORO INSUFICIENTE O YA ADQUIRIDO ❌'),
            type: ok ? SystemSnackType.success : SystemSnackType.error,
          );
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isBuying = false);
  }

  (IconData, Color) _cosmeticStyle(String category) {
    switch (category) {
      case 'title':
        return (Icons.military_tech_rounded, AppColors.royalGold);
      case 'frame':
        return (Icons.verified_user_rounded, AppColors.manaCyan);
      case 'aura':
        return (Icons.auto_awesome_rounded, AppColors.runeViolet);
      case 'pet':
        return (Icons.pets_rounded, AppColors.emeraldGreen);
      case 'emote':
        return (Icons.emoji_emotions_rounded, AppColors.manaCyan);
      case 'table_theme':
        return (Icons.dashboard_customize_rounded, AppColors.royalGold);
      default:
        return (Icons.inventory_2_rounded, AppColors.onSurfaceVariant);
    }
  }

  String _cosmeticLabel(AppLocalizations? l10n, String category) {
    switch (category) {
      case 'title': return l10n?.cosmetic_title ?? 'TITLE';
      case 'frame': return l10n?.cosmetic_frame ?? 'FRAME';
      case 'aura': return l10n?.cosmetic_aura ?? 'AURA';
      case 'pet': return l10n?.cosmetic_pet ?? 'COMPANION';
      case 'emote': return l10n?.cosmetic_emote ?? 'EMOTE';
      case 'table_theme': return l10n?.cosmetic_theme ?? 'THEME';
      default: return category.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final manaAsync = ref.watch(manaStateProvider);
    final mana = manaAsync.value ?? const {'remaining': 1800};
    final int manaRemaining = mana['remaining'] as int? ?? 0;
    final goldAsync = ref.watch(goldBalanceProvider);
    final gold = goldAsync.value ?? 0;
    final inventoryAsync = ref.watch(inventoryProvider);
    final inventory = inventoryAsync.value ?? [];

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.dashboardGate,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Text(
                              l10n?.arcane_shop ?? 'TIENDA ARCANO',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Saldos: Maná + Oro
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.voidBg.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppColors.runeViolet, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '$manaRemaining',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.voidBg.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: AppColors.royalGold, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '$gold',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Secciones: ORO | accesos (la pestaña MANÁ se retiró en #8)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    _buildTabButton('oro', l10n?.gold_shop_tab ?? 'TIENDA DE ORO', Icons.monetization_on_rounded),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.push('/inventory'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.runeViolet.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.backpack_rounded, color: AppColors.runeViolet, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              l10n?.my_items ?? 'MIS ÍTEMS',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.runeViolet),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contenido
              Expanded(
                child: _selectedTab == 'mana'
                    ? _buildManaTab()
                    : _buildGoldTab(inventory),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab MANÁ ──────────────────────────────────────────────────────────────
  Widget _buildManaTab() {
    final l10n = AppLocalizations.of(context);
    final potionsAsync = ref.watch(manaPotionsProvider);
    final gemsAsync = ref.watch(manaGemsProvider);
    final potions = potionsAsync.value ?? const <Map<String, dynamic>>[];
    final gems = gemsAsync.value ?? const <Map<String, dynamic>>[];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        Text(
          l10n?.mana_potions_title ?? 'PORCIONES DE MANÁ',
          style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.runeViolet, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.mana_potions_desc ??
              'El maná es la energía de toda acción IA. Se adquiere con dinero real: tu estamento incluye una asignación mensual y las porciones la amplían.',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.4),
        ),
        const SizedBox(height: 12),
        ...potions.map((p) => _buildManaProductCard(
              title: p['name'] as String? ?? 'PORCIÓN',
              mana: (p['mana_amount'] as num?)?.toInt() ?? 0,
              price: (p['price_usd'] as num?)?.toDouble() ?? 0,
              badge: null,
              onBuy: () => _goBuyMana(p, 'potion'),
            )),
        const SizedBox(height: 20),
        Text(
          l10n?.mana_gems_packs_title ?? 'PACKS DE GEMAS DE MANÁ',
          style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.manaCyan, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        ...gems.map((g) => _buildManaProductCard(
              title: g['name'] as String? ?? 'PACK',
              mana: (g['mana_amount'] as num?)?.toInt() ?? 0,
              price: (g['price_usd'] as num?)?.toDouble() ?? 0,
              badge: g['badge'] as String?,
              onBuy: () => _goBuyMana(g, 'gem_pack'),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildManaProductCard({
    required String title,
    required int mana,
    required double price,
    String? badge,
    required VoidCallback onBuy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: AppColors.runeViolet.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.runeViolet.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.runeViolet, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.royalGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.royalGold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (AppLocalizations.of(context)?.plus_mana(mana) ?? '+$mana maná'),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _isBuying ? null : onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.runeViolet,
                foregroundColor: AppColors.voidBg,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                price > 0
                    ? '\$${price.toStringAsFixed(2)}'
                    : (AppLocalizations.of(context)?.buy ?? 'COMPRAR'),
                style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab ORO ───────────────────────────────────────────────────────────────
  Widget _buildGoldTab(List<dynamic> inventory) {
    final l10n = AppLocalizations.of(context);
    final cosmeticsAsync = ref.watch(goldCosmeticsProvider);
    final cosmetics = cosmeticsAsync.value ?? const <Map<String, dynamic>>[];

    if (cosmetics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_rounded, color: AppColors.onSurfaceVariant, size: 48),
              const SizedBox(height: 12),
              Text(
                l10n?.gold_shop_unavailable ??
                    'La Tienda de Oro aún no está disponible.\nAplica la migración price_gold en el SQL Editor.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: cosmetics.length,
      itemBuilder: (context, index) {
        final item = cosmetics[index];
        final category = item['category'] as String? ?? 'cosmetic';
        final (icon, color) = _cosmeticStyle(category);
        final price = (item['price_gold'] as num?)?.toInt() ?? 0;
        final isOwned = inventory.any((inv) => inv['item_code'] == item['id']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            borderColor: isOwned
                ? AppColors.emeraldGreen.withValues(alpha: 0.4)
                : color.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item['name'] as String? ?? '').toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface, height: 1.25),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _cosmeticLabel(l10n, category),
                            style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
                          ),
                          if ((item['description'] as String?)?.isNotEmpty == true) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['description'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: AppColors.royalGold, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            (AppLocalizations.of(context)?.price_gold('$price') ?? '$price ORO'),
                            style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.royalGold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: (isOwned || _isBuying)
                      ? null
                      : () => _buyGoldCosmetic(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOwned ? AppColors.emeraldGreen.withValues(alpha: 0.2) : color,
                    foregroundColor: AppColors.voidBg,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    isOwned
                        ? (AppLocalizations.of(context)?.owned ?? 'ADQUIRIDO')
                        : (AppLocalizations.of(context)?.buy ?? 'COMPRAR'),
                    style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String id, String label, IconData icon) {
    final isSelected = _selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.voidBg : AppColors.onSurface.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.voidBg : AppColors.onSurface.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
