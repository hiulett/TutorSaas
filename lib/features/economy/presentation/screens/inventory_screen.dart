import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../providers/economy_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Inventario del Cazador (T-501).
/// Lista items de `player_inventory`, permite equipar/desequipar cosméticos
/// y filtra por categoría.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _filter = 'all';

  Future<void> _toggleEquip(String itemCode) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Gate del Aura: los cosméticos de aura solo son equipables por un
    // Usuario del Aura (tras superar la Etapa Básica o acreditación del Oráculo).
    final inventory = ref.read(inventoryProvider).value ?? [];
    Map<String, dynamic>? item;
    for (final i in inventory) {
      if (i['item_code'] == itemCode) {
        item = i;
        break;
      }
    }
    final type = item?['item_type'] as String? ?? 'cosmetic';
    if (type == 'aura') {
      final aura = ref.read(auraStateProvider).value;
      if (aura != null && !aura.isAwakened) {
        SystemSnack.show(
          context,
          '🔒 AURA BLOQUEADA: Supera la Etapa Básica (PRE-A1+A1+A2) para equipar auras.',
          type: SystemSnackType.error,
          duration: const Duration(milliseconds: 1800),
        );
        return;
      }
    }

    await ref.read(economyRepositoryProvider).toggleEquip(user.id, itemCode);

    // Unificar con el título del perfil: equipar un título en el inventario
    // también actualiza `equipped_title_code` (el que muestra el HUD).
    final isBeingEquipped = item?['is_equipped'] != true;
    if (type == 'title') {
      await ref
          .read(dashboardRepositoryProvider)
          .updateUserProfile(
            user.id,
            equippedTitleCode: isBeingEquipped
                ? itemCode
                : 'oido_halcon_abismo_c',
          );
      ref.invalidate(userProfileProvider);
      ref.invalidate(userProgressProvider);
    }

    ref.invalidate(inventoryProvider);
    if (mounted) {
      SystemSnack.show(
        context,
        AppLocalizations.of(context)?.equipment_updated ?? 'EQUIPO ACTUALIZADO',
        type: SystemSnackType.info,
        duration: const Duration(milliseconds: 1200),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inventoryAsync = ref.watch(inventoryProvider);
    final inventory = inventoryAsync.value ?? [];
    final aura = ref.watch(auraStateProvider).value;

    final List<String> categories = [
      'all',
      ...inventory
          .map((i) => (i['item_type'] as String? ?? 'cosmetic'))
          .toSet(),
    ];

    final filtered = _filter == 'all'
        ? inventory
        : inventory.where((i) => i['item_type'] == _filter).toList();

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
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
                        l10n.inventory,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      '${inventory.length} ITEMS',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.manaCyan,
                      ),
                    ),
                  ],
                ),
              ),

              // Filters
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: categories.map((c) {
                    final isActive = _filter == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.manaCyan.withValues(alpha: 0.15)
                                : AppColors.onSurface.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.manaCyan
                                  : AppColors.onSurface.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            c.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? AppColors.manaCyan
                                  : AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: inventoryAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.manaCyan),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      l10n.inventory_load_error,
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.inventory_empty,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => context.push('/shop'),
                              child: Text(
                                l10n.inventory_visit_shop,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AppColors.manaCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final auraLocked =
                            (item['item_type'] as String? ?? 'cosmetic') ==
                                'aura' &&
                            !(aura?.isAwakened ?? false);
                        return _InventoryItemCard(
                          item: item,
                          auraLocked: auraLocked,
                          onEquip: () =>
                              _toggleEquip(item['item_code'] as String? ?? ''),
                        );
                      },
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
}

class _InventoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool auraLocked;
  final VoidCallback onEquip;

  const _InventoryItemCard({
    required this.item,
    required this.auraLocked,
    required this.onEquip,
  });

  IconData _iconFor(String type) {
    switch (type) {
      case 'title':
        return Icons.military_tech_rounded;
      case 'frame':
        return Icons.verified_user_rounded;
      case 'aura':
        return Icons.auto_awesome_rounded;
      case 'pet':
        return Icons.pets_rounded;
      case 'emote':
        return Icons.emoji_emotions_rounded;
      case 'consumable':
        return Icons.bolt_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'title':
        return AppColors.royalGold;
      case 'frame':
        return AppColors.manaCyan;
      case 'aura':
        return AppColors.runeViolet;
      case 'pet':
        return AppColors.emeraldGreen;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final type = item['item_type'] as String? ?? 'cosmetic';
    final color = _colorFor(type);
    final isEquipped = item['is_equipped'] == true;
    final code = item['item_code'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        border: Border.all(
          color: isEquipped
              ? color.withValues(alpha: 0.6)
              : AppColors.onSurface.withValues(alpha: 0.10),
        ),
        opacity: isEquipped ? 0.15 : 0.05,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(_iconFor(type), color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code.toUpperCase().replaceAll('_', ' '),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        type.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: color,
                        ),
                      ),
                      if (auraLocked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.onSurface.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '🔒 AURA BLOQUEADA',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      if (isEquipped) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGreen.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            l10n.inventory_equipped,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (type != 'consumable')
              ElevatedButton(
                onPressed: (auraLocked && !isEquipped) ? null : onEquip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEquipped
                      ? AppColors.onSurface.withValues(alpha: 0.12)
                      : color,
                  foregroundColor: isEquipped
                      ? AppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.voidBg,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  auraLocked && !isEquipped
                      ? '🔒'
                      : (isEquipped
                            ? (AppLocalizations.of(context)?.unequip ??
                                  'QUITAR')
                            : (AppLocalizations.of(context)?.equip ??
                                  'EQUIPAR')),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
