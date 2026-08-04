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
      'icon': Icons.bolt_rounded,
    },
    {
      'id': 'consumible_invocacion20',
      'name': '+20 INVOCACIONES AL ORÁCULO',
      'desc': 'Restaura 20 de Maná diario para conversar con el Oráculo.',
      'price': 180,
      'icon': Icons.offline_bolt_rounded,
    },
    {
      'id': 'consumible_pergamino10',
      'name': '10 PERGAMINOS DE SABIDURÍA',
      'desc': 'Agrega pergaminos a tu inventario de repaso.',
      'price': 100,
      'icon': Icons.menu_book_rounded,
    },
  ];

  final List<Map<String, dynamic>> _cosmetics = [
    {
      'id': 'title_eloquente',
      'name': 'ELOCUENTE DEL GREMIO',
      'desc': 'Título exclusivo de Cazador. Otorga prestigio.',
      'price': 500,
      'icon': Icons.military_tech_rounded,
    },
    {
      'id': 'title_cazador_sombras',
      'name': 'CAZADOR DE SOMBRAS',
      'desc': 'Título rúnico de Cazador de Nivel A.',
      'price': 800,
      'icon': Icons.gavel_rounded,
    },
    {
      'id': 'frame_escudo',
      'name': 'ESCUDO DEL GREMIO',
      'desc': 'Marco cosmético metálico para tu avatar.',
      'price': 600,
      'icon': Icons.verified_user_rounded,
    },
  ];

  final List<Map<String, dynamic>> _training = [
    {
      'id': 'entrenamiento_fluidez',
      'name': 'ENTRENAMIENTO DE FLUIDEZ',
      'desc': 'Entrena con el Oráculo: +5 invocaciones al núcleo arcano del día.',
      'price': 100,
      'bonus': 5,
      'icon': Icons.self_improvement_rounded,
    },
    {
      'id': 'entrenamiento_elite',
      'name': 'ENTRENAMIENTO ÉLITE',
      'desc': 'Rutina intensiva: +15 invocaciones al núcleo arcano del día.',
      'price': 250,
      'bonus': 15,
      'icon': Icons.local_fire_department_rounded,
    },
  ];

  List<Map<String, dynamic>> _getDailyOffers() {
    final pool = <Map<String, dynamic>>[..._consumables, ..._cosmetics];
    final length = pool.length;
    if (length == 0) return const [];
    final date = DateTime.now().toIso8601String().split('T').first;
    final seed = '\$fecha-$date';
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

  Future<void> _buyItem(String itemId, int price) async {
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

  Future<void> _buyTraining(String itemId, int price, int bonus) async {
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.onSurface.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.10)),
                              ),
                              child: Icon(item['icon'] as IconData, color: isOwned ? AppColors.emeraldGreen : accent, size: 24),
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
                                  _buyTraining(item['id'] as String, item['price'] as int, item['bonus'] as int);
                                } else {
                                  _buyItem(item['id'] as String, item['price'] as int);
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
        _buyItem(item['id'] as String, item['price'] as int);
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.royalGold.withValues(alpha: 0.12),
              AppColors.voidBg.withValues(alpha: 0.35),
            ],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.royalGold, width: 1.2),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item['icon'] as IconData, color: accent, size: 22),
                const Spacer(),
                Text(
                  item['name'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.diamond_rounded, color: AppColors.royalGold, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${item['price']} GEMAS',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.royalGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isOwned
                      ? 'ADQUIRIDO'
                      : canAfford
                          ? 'TOCAR PARA COMPRAR'
                          : 'MANÁ INSUFICIENTE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isOwned
                        ? AppColors.emeraldGreen
                        : canAfford
                            ? accent
                            : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.royalGold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-OFR-',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.voidBg,
                    letterSpacing: 0.5,
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
