import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../providers/economy_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  bool _isBuying = false;
  String _selectedTab = 'consumable'; // or 'cosmetic'

  final List<Map<String, dynamic>> _consumables = [
    {
      'id': 'consumible_invocacion5',
      'name': '+5 INVOCACIONES AL ORÁCULO',
      'desc': 'Restaura 5 de Maná diario para conversar con el Oráculo.',
      'price': 50,
      'image': 'assets/images/shop/shop_invocation_potion.png',
    },
    {
      'id': 'consumible_invocacion20',
      'name': '+20 INVOCACIONES AL ORÁCULO',
      'desc': 'Restaura 20 de Maná diario para conversar con el Oráculo.',
      'price': 180,
      'image': 'assets/images/shop/shop_invocation_potion.png',
    },
    {
      'id': 'consumible_pergamino10',
      'name': '10 PERGAMINOS DE SABIDURÍA',
      'desc': 'Agrega pergaminos a tu inventario de repaso.',
      'price': 100,
      'image': 'assets/images/shop/shop_scroll_sage.png',
    },
  ];

  final List<Map<String, dynamic>> _cosmetics = [
    {
      'id': 'title_eloquente',
      'name': 'ELOCUENTE DEL GREMIO',
      'desc': 'Título exclusivo de Cazador. Otorga prestigio.',
      'price': 500,
      'image': 'assets/images/shop/shop_title_eloquent.png',
    },
    {
      'id': 'title_cazador_sombras',
      'name': 'CAZADOR DE SOMBRAS',
      'desc': 'Título rúnico de Cazador de Nivel A.',
      'price': 800,
      'image': 'assets/images/shop/shop_title_shadow.png',
    },
    {
      'id': 'frame_escudo',
      'name': 'ESCUDO DEL GREMIO',
      'desc': 'Marco cosmético metálico para tu avatar.',
      'price': 600,
      'image': 'assets/images/shop/shop_frame_guild.png',
    },
  ];

  final List<Map<String, dynamic>> _training = [
    {
      'id': 'entrenamiento_fluidez',
      'name': 'ENTRENAMIENTO DE FLUIDEZ',
      'desc': 'Entrena con el Oráculo: +5 invocaciones al núcleo arcano del día.',
      'price': 100,
      'bonus': 5,
      'image': 'assets/images/shop/shop_training_fluency.png',
    },
    {
      'id': 'entrenamiento_elite',
      'name': 'ENTRENAMIENTO ÉLITE',
      'desc': 'Rutina intensiva: +15 invocaciones al núcleo arcano del día.',
      'price': 250,
      'bonus': 15,
      'image': 'assets/images/shop/shop_training_elite.png',
    },
  ];

  /// Ruta del asset de imagen de un ítem (fallback a icono si no hay imagen).
  String _itemImage(Map<String, dynamic> item) =>
      item['image'] as String? ?? 'assets/images/shop/shop_invocation_potion.png';

  /// Ofertas del día: dos ítems deterministas que cambian por fecha real.
  List<Map<String, dynamic>> _getDailyOffers() {
    final pool = <Map<String, dynamic>>[..._consumables, ..._cosmetics];
    final length = pool.length;
    if (length == 0) return const [];
    final date = DateTime.now().toIso8601String().split('T').first;
    final seed = 'shop-$date';
    var hash = 0x811c9dc5;
    for (final unit in seed.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    final first = hash % length;
    if (length == 1) return [pool[first]];
    final secondSeed = (hash ~/ length) % (length - 1);
    final second = secondSeed >= first ? secondSeed + 1 : secondSeed;
    return [pool[first], pool[second]];
  }

  /// Diálogo de confirmación antes de comprar.
  Future<bool> _confirmPurchase(
    String name,
    String priceLabel,
    IconData icon,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.medievalStone,
        title: Row(
          children: [
            Icon(icon, color: AppColors.manaCyan, size: 20),
            const SizedBox(width: 8),
            const Text('CONFIRMAR COMPRA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          '¿Adquirir "$name" por $priceLabel?',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.85), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('COMPRAR', style: TextStyle(color: AppColors.royalGold, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _buyItem(String itemId, int price, {String? name}) async {
    final confirmed = await _confirmPurchase(
      name ?? 'este objeto',
      '$price GEMAS',
      Icons.diamond_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _isBuying = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final success = await ref.read(economyRepositoryProvider).purchaseItem(user.id, itemId);
        if (success) {
          ref.invalidate(gemBalanceProvider);
          ref.invalidate(inventoryProvider);
          if (mounted) {
            SystemSnack.show(context, '¡COMPRA COMPLETADA CON ÉXITO! 💎',
                type: SystemSnackType.success);
          }
        } else {
          if (mounted) {
            SystemSnack.show(context, 'MANÁ INSUFICIENTE O ÍTEM YA ADQUIRIDO ❌',
                type: SystemSnackType.error);
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isBuying = false);
  }

  Future<void> _buyTraining(String itemId, int price, int bonus, {String? name}) async {
    final confirmed = await _confirmPurchase(
      name ?? 'este entrenamiento',
      '$price ORO',
      Icons.monetization_on_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _isBuying = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final repo = ref.read(economyRepositoryProvider);
        final spent = await repo.spendGold(user.id, price);
        if (spent) {
          final state = await repo.getDailyState(user.id);
          final currentMax = (state['invocations_max'] as num?)?.toInt() ?? 20;
          final today = DateTime.now().toIso8601String().split('T').first;
          await ref.read(supabaseClientProvider).from('player_daily_state')
              .update({'invocations_max': currentMax + bonus})
              .eq('user_id', user.id)
              .eq('date', today);
          ref.invalidate(goldBalanceProvider);
          ref.invalidate(dailyStateProvider);
          if (mounted) {
            SystemSnack.show(context,
                '¡ENTRENAMIENTO COMPLETADO! +$bonus AL NÚCLEO ARCANO 🪙',
                type: SystemSnackType.success);
          }
        } else {
          if (mounted) {
            SystemSnack.show(context, 'ORO INSUFICIENTE ❌',
                type: SystemSnackType.error);
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isBuying = false);
  }

  @override
  Widget build(BuildContext context) {
    final gemsAsync = ref.watch(gemBalanceProvider);
    final goldAsync = ref.watch(goldBalanceProvider);
    final inventoryAsync = ref.watch(inventoryProvider);
    final gems = gemsAsync.value ?? 0;
    final gold = goldAsync.value ?? 0;
    final inventory = inventoryAsync.value ?? [];

    final activeList = switch (_selectedTab) {
      'consumable' => _consumables,
      'training' => _training,
      _ => _cosmetics,
    };

    final dailyOffers = _getDailyOffers();
    final offerIds = dailyOffers.map((item) => item['id']).toSet();
    final gridItems =
        activeList.where((item) => !offerIds.contains(item['id'])).toList();

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
                              'TIENDA ARCANO',
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
                    const SizedBox(width: 8),
                    // Gem & Gold balance
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.voidBg.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.diamond_rounded, color: AppColors.manaCyan, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$gems',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                              const Icon(Icons.monetization_on_rounded, color: AppColors.royalGold, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$gold',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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

              // Cabecera decorativa del mercado arcano
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0E16),
                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.25)),
                    ),
                    child: Image.asset(
                      'assets/images/shop/shop_bg_header.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0B0E16),
                        alignment: Alignment.center,
                        child: Text(
                          'MERCADO ARCANO',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.manaCyan.withValues(alpha: 0.4),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tab Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    _buildTabButton('consumable', 'CONSUMIBLES'),
                    const SizedBox(width: 12),
                    _buildTabButton('cosmetics', 'COSMÉTICOS'),
                    const SizedBox(width: 12),
                    _buildTabButton('training', 'ENTRENAMIENTO'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Daily Offers
              _buildDailyOffersSection(dailyOffers, gems, inventory),
              const SizedBox(height: 16),

              // Item Grid
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: gridItems.length,
                  itemBuilder: (context, index) {
                    final item = gridItems[index];
                    final isTraining = _selectedTab == 'training';
                    final isOwned = !isTraining && inventory.any((inv) => inv['item_code'] == item['id']);
                    final canAfford = isTraining ? gold >= item['price'] : gems >= item['price'];
                    final accent = isTraining ? AppColors.royalGold : AppColors.manaCyan;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        borderColor: isOwned
                            ? AppColors.emeraldGreen.withValues(alpha: 0.4)
                            : (canAfford ? accent.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.10)),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Imagen del producto (fondo sólido #0B0E16 integrado)
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B0E16),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isOwned ? AppColors.emeraldGreen.withValues(alpha: 0.4) : accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset(
                                  _itemImage(item),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF0B0E16),
                                    child: Icon(Icons.inventory_2_rounded, color: accent, size: 24),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['desc'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        isTraining ? Icons.monetization_on_rounded : Icons.diamond_rounded,
                                        color: AppColors.royalGold,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isTraining ? '${item['price']} ORO' : '${item['price']} GEMAS',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.royalGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: (isOwned || _isBuying) ? null : () {
                                if (isTraining) {
                                  _buyTraining(
                                    item['id'] as String,
                                    item['price'] as int,
                                    item['bonus'] as int,
                                    name: item['name'] as String?,
                                  );
                                } else {
                                  _buyItem(
                                    item['id'] as String,
                                    item['price'] as int,
                                    name: item['name'] as String?,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isOwned ? AppColors.emeraldGreen.withValues(alpha: 0.2) : accent,
                                foregroundColor: AppColors.voidBg,
                                minimumSize: const Size(48, 48),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: Text(
                                isOwned ? 'ADQUIRIDO' : 'COMPRAR',
                                style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyOffersSection(
    List<Map<String, dynamic>> offers,
    int gems,
    List<dynamic> inventory,
  ) {
    if (offers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.royalGold,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'OFERTAS DEL DÍA',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalGold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < offers.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _buildOfferCard(offers[i], gems, inventory)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> item, int gems, List<dynamic> inventory) {
    final isOwned = inventory.any((inv) => inv['item_code'] == item['id']);
    final canAfford = gems >= (item['price'] as int);
    final accent = AppColors.manaCyan;
    return GestureDetector(
      onTap: (isOwned || _isBuying) ? null : () {
        _buyItem(item['id'] as String, item['price'] as int, name: item['name'] as String?);
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.royalGold, width: 1.2),
          // Textura de madera oscura como fondo (integra con la temática)
          image: DecorationImage(
            image: const AssetImage('assets/images/shop/shop_bg_panel.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppColors.voidBg.withValues(alpha: 0.55),
              BlendMode.darken,
            ),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Imagen del producto (fondo sólido integrado)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E16),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.4)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.asset(
                      _itemImage(item),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0B0E16),
                        child: const Icon(Icons.diamond_rounded, color: AppColors.royalGold, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.diamond_rounded, color: AppColors.royalGold, size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${item['price']} GEMAS',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isOwned
                      ? 'ADQUIRIDO'
                      : canAfford
                          ? 'TOCAR PARA COMPRAR'
                          : 'MANÁ INSUFICIENTE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                    color: isOwned
                        ? AppColors.emeraldGreen
                        : canAfford
                            ? accent
                            : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            // Sello de oferta (imagen del sello dorado)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E16),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: AppColors.royalGold, width: 1.2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/shop/shop_offer_banner.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.local_offer_rounded, color: AppColors.royalGold, size: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String id, String label) {
    final isSelected = _selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.10)),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.voidBg : AppColors.onSurface.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
