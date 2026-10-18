import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/economy_providers.dart';

/// Inventario equipable de maná (elixires y gemas).
///
/// Muestra los ítems en bolsa (sin expirar) y permite equipar UNO. El equipado
/// inicia su expiración (48h gema / 15d elixir) y su maná alimenta el consumo
/// extra que "rompe el sello" diario.
class ManaItemInventory extends ConsumerWidget {
  const ManaItemInventory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(manaItemsProvider);
    final equipped = ref.watch(equippedManaItemProvider);
    final expiry = ref.watch(equippedManaExpiryProvider);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_drink_rounded, color: AppColors.manaCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.mana_inventory_title ?? 'INVENTARIO DE MANÁ',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ítem equipado (activo)
          if (equipped != null) ...[
            _buildEquippedCard(context, ref, equipped, expiry),
            const SizedBox(height: 12),
          ],

          // Lista del inventario (no equipado)
          itemsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.runeViolet),
                ),
              ),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.mana_inventory_empty ?? 'No pudimos cargar tu inventario.',
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
            ),
            data: (items) {
              final inBag = items.where((i) => i['status'] == 'inventory').toList();
              if (inBag.isEmpty) {
                return Text(
                  l10n.mana_inventory_empty ?? 'No tienes elixires ni gemas en la bolsa.',
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                );
              }
              return Column(
                children: inBag.map((item) => _buildInventoryRow(context, ref, item)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquippedCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> equipped,
    Duration? expiry,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final type = equipped['item_type'] as String? ?? 'elixir';
    final mana = (equipped['mana_amount'] as num?)?.toInt() ?? 0;
    final isGema = type == 'gema';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.manaCyan.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.manaCyan, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isGema ? Icons.diamond_rounded : Icons.water_drop_rounded,
            color: AppColors.manaCyan,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isGema ? l10n.mana_gem_label ?? 'GEMA' : l10n.mana_elixir_label ?? 'ELIXIR'} · $mana ⚡',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface,
                  ),
                ),
                if (expiry != null)
                  Text(
                    l10n.mana_expiry_countdown(expiry.inHours, expiry.inMinutes % 60),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10, color: AppColors.royalGold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    final id = item['id']?.toString() ?? '';
    final type = item['item_type'] as String? ?? 'elixir';
    final mana = (item['mana_amount'] as num?)?.toInt() ?? 0;
    final isGema = type == 'gema';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isGema ? Icons.diamond_rounded : Icons.water_drop_rounded,
            color: isGema ? AppColors.manaCyan : AppColors.runeViolet,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${isGema ? l10n.mana_gem_label ?? 'GEMA' : l10n.mana_elixir_label ?? 'ELIXIR'} · $mana ⚡',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              final ok = await ref.read(economyRepositoryProvider).equipManaItem(user?.id ?? '', id);
              if (ok) {
                ref.invalidate(manaItemsProvider);
                ref.invalidate(manaStateProvider);
                if (context.mounted) {
                  SystemSnack.show(
                    context,
                    l10n.mana_item_equipped ?? 'Maná equipado',
                    type: SystemSnackType.success,
                  );
                }
              }
            },
            child: Text(
              l10n.mana_equip ?? 'EQUIPAR',
              style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
            ),
          ),
        ],
      ),
    );
  }
}
