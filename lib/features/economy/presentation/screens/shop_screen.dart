import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/economy_wallet.dart';
import '../../domain/models/shop_offer.dart';

/// TIENDA ARCANO (P-32).
///
/// Tres sumideros reales, cada uno con su moneda:
/// - **ORO** (`purchase_cosmetic`): cosméticos del catálogo, desbloqueados por
///   nivel de cazador (`required_level`).
/// - **GEMAS** (`purchase_cosmetic` / `purchase_streak_freeze`): cosméticos
///   premium y freeze de racha (máx. 3).
/// - **FRAGMENTOS** (`craft_cosmetic`): crafteo de cosméticos con receta.
///
/// El nivel de cazador (XP/1000 + 1) se anuncia aquí con su próxima meta y con
/// las recompensas de nivel pendientes de reclamar. Todos los cobros los hace
/// el servidor; el cliente nunca escribe saldos.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedTab = 'oro';
  bool _isBusy = false;

  // ── Acciones ──────────────────────────────────────────────────────────────

  void _invalidateEconomy() {
    ref.invalidate(inventoryProvider);
    ref.invalidate(goldBalanceProvider);
    ref.invalidate(gemBalanceProvider);
    ref.invalidate(fragmentBalanceProvider);
    ref.invalidate(economyWalletProvider);
    ref.invalidate(levelRewardsProvider);
  }

  Future<bool> _confirmPurchase(String name, String priceLabel) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.medievalStone,
        title: Row(
          children: [
            const Icon(
              Icons.storefront_rounded,
              color: AppColors.manaCyan,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n?.confirm_purchase ?? 'CONFIRMAR COMPRA',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Text(
          l10n?.purchase_confirm_question(name, priceLabel) ??
              '¿Adquirir "$name" por $priceLabel?',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurface.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              (l10n?.cancel ?? 'Cancel').toUpperCase(),
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n?.buy ?? 'COMPRAR',
              style: const TextStyle(
                color: AppColors.royalGold,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _priceLabel(ShopOffer offer, CurrencyKind currency) {
    final l10n = AppLocalizations.of(context);
    return switch (currency) {
      CurrencyKind.gold =>
        l10n?.price_gold('${offer.priceGold}') ?? '${offer.priceGold} ORO',
      CurrencyKind.gems =>
        l10n?.price_gems('${offer.priceGems}') ?? '${offer.priceGems} GEMAS',
      CurrencyKind.fragments =>
        l10n?.craft_cost('${offer.craftFragments}') ??
            '${offer.craftFragments} FRAG',
    };
  }

  String _failureMessage(String? reason) {
    final l10n = AppLocalizations.of(context);
    return switch (reason) {
      'insufficient' =>
        _selectedTab == 'fragmentos'
            ? (l10n?.fragments_insufficient ?? 'FRAGMENTOS INSUFICIENTES')
            : _selectedTab == 'gemas'
            ? (l10n?.gems_insufficient ?? 'GEMAS INSUFICIENTES')
            : (l10n?.gold_insufficient ?? 'ORO INSUFICIENTE'),
      'level_locked' => l10n?.shop_level_locked ?? 'NIVEL INSUFICIENTE',
      'already_owned' => l10n?.owned ?? 'ADQUIRIDO',
      'cap_reached' => l10n?.streak_freeze_cap ?? 'MÁXIMO DE FREEZES',
      _ => l10n?.purchase_failed ?? 'NO SE PUDO COMPLETAR LA COMPRA',
    };
  }

  void _snack(String message, {bool success = true}) {
    if (!mounted) return;
    SystemSnack.show(
      context,
      message,
      type: success ? SystemSnackType.success : SystemSnackType.error,
    );
  }

  Future<void> _acquire(ShopOffer offer, CurrencyKind currency) async {
    final user = ref.read(currentUserProvider);
    if (user == null || _isBusy) return;
    final l10n = AppLocalizations.of(context);

    final priceLabel = _priceLabel(offer, currency);
    final confirmed = await _confirmPurchase(offer.name, priceLabel);
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final repo = ref.read(economyRepositoryProvider);
      final Map<String, dynamic> res;
      if (currency == CurrencyKind.fragments) {
        res = await repo.craftCosmetic(user.id, offer.id);
      } else {
        res = await repo.buyCosmetic(
          userId: user.id,
          itemId: offer.id,
          currency: currency.code,
        );
      }
      _invalidateEconomy();
      if (res['success'] == true) {
        _snack(
          currency == CurrencyKind.fragments
              ? (l10n?.craft_success ?? '¡COSMÉTICO CRAFTEADO!')
              : (l10n?.cosmetic_purchased ?? '¡COSMÉTICO ADQUIRIDO!'),
        );
      } else {
        final reason = res['reason'] as String?;
        // P-44 (#129): el servidor exige un plan mínimo para los cosméticos
        // exclusivos; se dice cuál en vez de un error genérico.
        final requiredPlan = (res['required_plan'] as String?)?.toUpperCase();
        if (reason == 'plan_required' && requiredPlan != null) {
          _snack(
            l10n?.shop_plan_required_body(requiredPlan) ??
                'Este objeto es exclusivo del plan $requiredPlan.',
            success: false,
          );
        } else {
          _snack(_failureMessage(reason), success: false);
        }
      }
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/economy/presentation/screens/shop_screen.dart:_acquire',
        e,
        stackTrace: st,
      );
      _snack(_failureMessage('request_failed'), success: false);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _buyStreakFreeze() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _isBusy) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirmPurchase(
      l10n?.streak_freeze_title ?? 'FREEZE DE RACHA',
      l10n?.price_gems('30') ?? '30 GEMAS',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final repo = ref.read(economyRepositoryProvider);
      final res = await repo.buyStreakFreeze(
        userId: user.id,
        // Idempotente: un doble toque accidental no compra dos veces.
        refKey:
            'streak_freeze:${user.id}:${DateTime.now().microsecondsSinceEpoch}',
      );
      _invalidateEconomy();
      _snack(
        res['success'] == true
            ? (l10n?.streak_freeze_bought ?? '¡FREEZE DE RACHA ADQUIRIDO!')
            : _failureMessage(res['reason'] as String?),
        success: res['success'] == true,
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/economy/presentation/screens/shop_screen.dart:_buyFreeze',
        e,
        stackTrace: st,
      );
      _snack(_failureMessage('request_failed'), success: false);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _claimLevelRewards() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _isBusy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isBusy = true);
    try {
      final repo = ref.read(economyRepositoryProvider);
      final res = await repo.claimLevelRewards(user.id);
      _invalidateEconomy();
      if (res['success'] == true) {
        final granted = res['granted'];
        final count = granted is List ? granted.length : 0;
        _snack(
          count == 0
              ? (l10n?.level_rewards_none ?? 'SIN RECOMPENSAS PENDIENTES')
              : (l10n?.level_rewards_claimed_ok(count) ??
                    '¡$count RECOMPENSAS DE NIVEL RECLAMADAS!'),
        );
      } else {
        _snack(_failureMessage(res['reason'] as String?), success: false);
      }
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/economy/presentation/screens/shop_screen.dart:_claim',
        e,
        stackTrace: st,
      );
      _snack(_failureMessage('request_failed'), success: false);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // ── Estilos ───────────────────────────────────────────────────────────────

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
      case 'title':
        return l10n?.cosmetic_title ?? 'TITLE';
      case 'frame':
        return l10n?.cosmetic_frame ?? 'FRAME';
      case 'aura':
        return l10n?.cosmetic_aura ?? 'AURA';
      case 'pet':
        return l10n?.cosmetic_pet ?? 'COMPANION';
      case 'emote':
        return l10n?.cosmetic_emote ?? 'EMOTE';
      case 'table_theme':
        return l10n?.cosmetic_theme ?? 'THEME';
      default:
        return category.toUpperCase();
    }
  }

  CurrencyKind get _tabCurrency => switch (_selectedTab) {
    'gemas' => CurrencyKind.gems,
    'fragmentos' => CurrencyKind.fragments,
    _ => CurrencyKind.gold,
  };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final manaAsync = ref.watch(manaStateProvider);
    final mana = manaAsync.value ?? const {'remaining': 0};
    final int manaRemaining = mana['remaining'] as int? ?? 0;
    final wallet =
        ref.watch(economyWalletProvider).value ?? const EconomyWallet();
    final rewards = ref.watch(levelRewardsProvider).value ?? const [];
    final inventory = ref.watch(inventoryProvider).value ?? [];
    final ownedCodes = inventory
        .map((i) => i['item_code'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toSet();

    final claims = LevelReward.claimableOf(rewards);

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.dashboardGate,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(l10n, manaRemaining, wallet),
              const SizedBox(height: 8),
              _buildWalletRow(l10n, wallet),
              if (claims.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildLevelRewardBanner(l10n, wallet, claims),
              ],
              const SizedBox(height: 12),
              _buildTabs(l10n, wallet),
              const SizedBox(height: 12),
              Expanded(child: _buildContent(l10n, wallet, ownedCodes)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AppLocalizations? l10n,
    int manaRemaining,
    EconomyWallet wallet,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.onSurface,
            ),
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
          // Maná del Oráculo: no se gana jugando, se cobra por turno.
          _balanceChip(
            icon: Icons.bolt_rounded,
            color: AppColors.runeViolet,
            value: '$manaRemaining',
            label: l10n?.mana_label ?? 'MANÁ',
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n?.my_items ?? 'MIS ÍTEMS',
            icon: const Icon(Icons.backpack_rounded, color: AppColors.manaCyan),
            onPressed: () => context.push('/inventory'),
          ),
        ],
      ),
    );
  }

  /// UX-22 (#259): chip de moneda. El icono es la única pista visual del tipo
  /// de moneda, así que lleva `Tooltip` (para quien ve) y `semanticLabel`
  /// (para TalkBack), y el valor queda como texto del mismo nodo.
  Widget _balanceChip({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.voidBg.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14, semanticLabel: label),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Nivel de cazador + las tres monedas, en una fila desplazable para que no
  /// haya overflow en pantallas estrechas.
  Widget _buildWalletRow(AppLocalizations? l10n, EconomyWallet wallet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.manaCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: AppColors.manaCyan.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.military_tech_rounded,
                  color: AppColors.manaCyan,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  (l10n?.level_label('${wallet.level}') ??
                          'NV. ${wallet.level}')
                      .toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.manaCyan,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${wallet.xpIntoLevel}/${wallet.xpPerLevel} XP',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _balanceChip(
            icon: Icons.monetization_on_rounded,
            color: AppColors.royalGold,
            value: '${wallet.gold}',
            label: l10n?.shop_tab_gold ?? 'ORO',
          ),
          const SizedBox(width: 8),
          _balanceChip(
            icon: Icons.diamond_rounded,
            color: AppColors.runeViolet,
            value: '${wallet.gems}',
            label: l10n?.shop_tab_gems ?? 'GEMAS',
          ),
          const SizedBox(width: 8),
          _balanceChip(
            icon: Icons.auto_awesome_mosaic_rounded,
            color: AppColors.emeraldGreen,
            value: '${wallet.fragments}',
            label: l10n?.shop_tab_fragments ?? 'FRAGMENTOS',
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRewardBanner(
    AppLocalizations? l10n,
    EconomyWallet wallet,
    List<LevelReward> claims,
  ) {
    final nextLevel = claims.first.level;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderColor: AppColors.royalGold.withValues(alpha: 0.55),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.royalGold,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (l10n?.level_rewards_pending(claims.length) ??
                            '${claims.length} RECOMPENSAS DE NIVEL')
                        .toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalGold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n?.level_rewards_banner_hint('$nextLevel') ??
                        'NIVEL $nextLevel ALCANZADO · RECLAMA TU ORO',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isBusy ? null : _claimLevelRewards,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalGold,
                foregroundColor: AppColors.voidBg,
                minimumSize: const Size(48, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                (l10n?.level_rewards_claim(claims.length) ??
                        'RECLAMAR ${claims.length}')
                    .toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(AppLocalizations? l10n, EconomyWallet wallet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabButton(
            'oro',
            '${l10n?.shop_tab_gold ?? 'ORO'} · ${wallet.gold}',
            Icons.monetization_on_rounded,
            AppColors.royalGold,
          ),
          const SizedBox(width: 8),
          _tabButton(
            'gemas',
            '${l10n?.shop_tab_gems ?? 'GEMAS'} · ${wallet.gems}',
            Icons.diamond_rounded,
            AppColors.runeViolet,
          ),
          const SizedBox(width: 8),
          _tabButton(
            'fragmentos',
            '${l10n?.shop_tab_fragments ?? 'FRAGMENTOS'} · ${wallet.fragments}',
            Icons.auto_awesome_mosaic_rounded,
            AppColors.emeraldGreen,
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String id, String label, IconData icon, Color color) {
    final isSelected = _selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : AppColors.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.onSurface.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.voidBg : color),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.voidBg
                    : AppColors.onSurface.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    AppLocalizations? l10n,
    EconomyWallet wallet,
    Set<String> ownedCodes,
  ) {
    final catalogAsync = ref.watch(shopCatalogProvider);
    final catalog = catalogAsync.value ?? const <ShopOffer>[];

    if (catalogAsync.isLoading && catalog.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.manaCyan),
      );
    }
    if (catalog.isEmpty) return _buildEmpty(l10n);

    final currency = _tabCurrency;
    final offers = catalog
        .where((o) => o.priceFor(currency) > 0)
        .toList(growable: false);

    final next = ShopOffer.nextUnlock(catalog, wallet.level);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (_selectedTab == 'gemas') _buildStreakFreezeCard(l10n, wallet),
        if (next != null) _buildGoalHint(l10n, wallet, next),
        if (_selectedTab == 'fragmentos')
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              (l10n?.fragments_exchange_desc ??
                      'LOS FRAGMENTOS CRAFTEAN COSMÉTICOS. ELIGE BIEN, CAZADOR.')
                  .toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        if (offers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              (l10n?.shop_tab_empty ?? 'AÚN NO HAY OBJETOS EN ESTA MONEDA.')
                  .toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        for (final offer in offers)
          _buildOfferCard(
            l10n,
            wallet,
            offer,
            currency,
            ownedCodes.contains(offer.id),
          ),
      ],
    );
  }

  Widget _buildGoalHint(
    AppLocalizations? l10n,
    EconomyWallet wallet,
    ShopOffer next,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: AppColors.manaCyan, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              (l10n?.shop_next_unlock(
                        next.name.toUpperCase(),
                        next.requiredLevel,
                      ) ??
                      'PRÓXIMO DESBLOQUEO: ${next.name.toUpperCase()} · NV. ${next.requiredLevel}')
                  .toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.manaCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakFreezeCard(AppLocalizations? l10n, EconomyWallet wallet) {
    final isMax = wallet.streakFreezes >= 3;
    final canAfford = wallet.gems >= 30;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: AppColors.runeViolet.withValues(alpha: 0.45),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.runeViolet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: AppColors.runeViolet.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.ac_unit_rounded,
                color: AppColors.runeViolet,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (l10n?.streak_freeze_title ?? 'FREEZE DE RACHA')
                        .toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n?.streak_freeze_desc ??
                        'PROTEGE UN DÍA PERDIDO. MÁXIMO 3.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${wallet.streakFreezes}/3 · '
                    '${l10n?.price_gems('30') ?? '30 GEMAS'}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.runeViolet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: (isMax || !canAfford || _isBusy)
                  ? null
                  : _buyStreakFreeze,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.runeViolet,
                foregroundColor: AppColors.voidBg,
                disabledBackgroundColor: AppColors.onSurface.withValues(
                  alpha: 0.10,
                ),
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                isMax
                    ? (l10n?.streak_freeze_max ?? 'AL MÁXIMO')
                    : (l10n?.buy ?? 'COMPRAR'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    AppLocalizations? l10n,
    EconomyWallet wallet,
    ShopOffer offer,
    CurrencyKind currency,
    bool owned,
  ) {
    final (icon, color) = _cosmeticStyle(offer.category);
    final block = offer.blockReason(currency, wallet, owned: owned);
    final lockedByLevel = block == ShopBlockReason.level;
    final balance = currency.balanceIn(wallet);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: owned
            ? AppColors.emeraldGreen.withValues(alpha: 0.4)
            : color.withValues(alpha: lockedByLevel ? 0.15 : 0.3),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(
                lockedByLevel ? Icons.lock_rounded : icon,
                color: lockedByLevel ? AppColors.onSurfaceVariant : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.onSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _cosmeticLabel(l10n, offer.category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (offer.requiredLevel > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: lockedByLevel
                                ? AppColors.onSurface.withValues(alpha: 0.12)
                                : AppColors.manaCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'NV. ${offer.requiredLevel}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: lockedByLevel
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.manaCyan,
                            ),
                          ),
                        ),
                      // P-44 (#129): cosmético exclusivo de un plan. La compra
                      // la bloquea el servidor; aquí solo se anuncia.
                      if (offer.requiredPlanLabel != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.runeViolet.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: AppColors.runeViolet.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            offer.requiredPlanLabel!,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.runeViolet,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        currency == CurrencyKind.gold
                            ? Icons.monetization_on_rounded
                            : currency == CurrencyKind.gems
                            ? Icons.diamond_rounded
                            : Icons.auto_awesome_mosaic_rounded,
                        color: currency == CurrencyKind.gold
                            ? AppColors.royalGold
                            : currency == CurrencyKind.gems
                            ? AppColors.runeViolet
                            : AppColors.emeraldGreen,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _priceLabel(offer, currency),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: block == ShopBlockReason.balance
                                ? AppColors.onSurfaceVariant
                                : currency == CurrencyKind.gold
                                ? AppColors.royalGold
                                : currency == CurrencyKind.gems
                                ? AppColors.runeViolet
                                : AppColors.emeraldGreen,
                          ),
                        ),
                      ),
                      if (!owned && block == ShopBlockReason.balance) ...[
                        const SizedBox(width: 6),
                        Text(
                          '($balance)',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: block == null && !_isBusy
                  ? () => _acquire(offer, currency)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: owned
                    ? AppColors.emeraldGreen.withValues(alpha: 0.2)
                    : color,
                foregroundColor: AppColors.voidBg,
                disabledBackgroundColor: AppColors.onSurface.withValues(
                  alpha: 0.10,
                ),
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                switch (block) {
                  ShopBlockReason.owned => l10n?.owned ?? 'ADQUIRIDO',
                  ShopBlockReason.level => 'NV. ${offer.requiredLevel}',
                  _ =>
                    currency == CurrencyKind.fragments
                        ? (l10n?.craft_action ?? 'CRAFTEAR')
                        : (l10n?.buy ?? 'COMPRAR'),
                },
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations? l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storefront_rounded,
              color: AppColors.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.gold_shop_unavailable ??
                  'La Tienda de Oro aún no está disponible.\nVuelve a intentarlo en un momento.',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              // P-11f: reintento real en vez de un mensaje técnico.
              onPressed: () {
                ref.invalidate(shopCatalogProvider);
                ref.invalidate(economyWalletProvider);
              },
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.emeraldGreen,
                size: 16,
              ),
              label: Text(
                l10n?.retry ?? 'REINTENTAR',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emeraldGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
