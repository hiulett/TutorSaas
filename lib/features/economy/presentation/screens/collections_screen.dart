import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Trofeos del Reino del Verbo (RPG-04).
/// Muestra el catálogo de colecciones del cazador en un grid de 2 columnas;
/// las desbloqueadas se marcan con un check dorado y las bloqueadas se
/// muestran en escala de grises con un candado.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsData {
  final List<Map<String, dynamic>> catalog;
  final Set<String> unlockedCodes;

  const _CollectionsData({required this.catalog, required this.unlockedCodes});
}

/// Carga el catálogo de colecciones y las desbloqueadas por el cazador actual.
final collectionsProvider = FutureProvider.autoDispose<_CollectionsData>((ref) async {
  final user = ref.watch(currentUserProvider);
  final supabase = ref.read(supabaseClientProvider);
  try {
    final catalogRes = await supabase.from('hunter_collection_catalog').select();
    final catalog = List<Map<String, dynamic>>.from(catalogRes as List);

    Set<String> unlocked = {};
    if (user != null) {
      final unlockedRes = await supabase
          .from('hunter_collections')
          .select('collection_code')
          .eq('user_id', user.id);
      unlocked = (unlockedRes as List)
          .map((r) => (r as Map<String, dynamic>)['collection_code'] as String? ?? '')
          .where((code) => code.isNotEmpty)
          .toSet();
    }
    return _CollectionsData(catalog: catalog, unlockedCodes: unlocked);
  } catch (e) {
    debugPrint('RPG-04: error cargando colecciones: $e');
    return const _CollectionsData(catalog: [], unlockedCodes: {});
  }
});

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final collectionsAsync = ref.watch(collectionsProvider);
    final catalog = collectionsAsync.value?.catalog ?? const [];
    final unlocked = collectionsAsync.value?.unlockedCodes ?? const {};

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'COLECCIONES DEL CAZADOR',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalGold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      '${unlocked.length}/${catalog.length}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.manaCyan,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: collectionsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.manaCyan)),
                  error: (_, __) => Center(
                    child: Text(l10n.collections_load_error, style: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                  data: (_) {
                    if (catalog.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events_outlined, color: AppColors.onSurfaceVariant, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'SIN TROFEOS REGISTRADOS',
                              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.onSurfaceVariant, letterSpacing: 1.5),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: catalog.length,
                      itemBuilder: (context, index) {
                        final collection = catalog[index];
                        final code = collection['code'] as String? ?? '';
                        final isUnlocked = unlocked.contains(code);
                        return _CollectionCard(
                          collection: collection,
                          isUnlocked: isUnlocked,
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

class _CollectionCard extends StatelessWidget {
  final Map<String, dynamic> collection;
  final bool isUnlocked;

  const _CollectionCard({required this.collection, required this.isUnlocked});

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'raro':
        return AppColors.manaCyan;
      case 'epico':
        return AppColors.runeViolet;
      case 'legendario':
        return AppColors.royalGold;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarity = collection['rarity'] as String? ?? 'comun';
    final rarityColor = _rarityColor(rarity);
    final name = collection['name'] as String? ?? '';
    final description = collection['description'] as String? ?? '';
    final emoji = collection['icon_emoji'] as String? ?? '🏆';

    final card = GlassCard(
      borderRadius: 4,
      opacity: AppColors.glassOpacity,
      border: Border.all(color: isUnlocked ? rarityColor.withValues(alpha: 0.5) : AppColors.onSurface.withValues(alpha: 0.1)),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: rarityColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  rarity.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: rarityColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: isUnlocked
                ? const Icon(Icons.check_circle_rounded, color: AppColors.royalGold, size: 20)
                : Icon(Icons.lock_rounded, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), size: 18),
          ),
        ],
      ),
    );

    if (isUnlocked) return card;

    // Bloqueadas: escala de grises + opacidad 0.4
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: Opacity(opacity: 0.4, child: card),
    );
  }
}
