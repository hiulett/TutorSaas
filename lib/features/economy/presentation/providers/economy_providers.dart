import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/cache/cached_future_controller.dart';
import '../../../../core/cache/json_disk_cache.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/economy_repository_impl.dart';
import '../../domain/repositories/economy_repository.dart';

final economyRepositoryProvider = Provider<EconomyRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EconomyRepositoryImpl(client);
});

/// Estado diario (recompensa, invocaciones, pergaminos) con cache TTL 10 min +
/// SWR: muestra el valor cacheado al instante y refresca en segundo plano
/// (también detecta el cambio de día). Se invalida al reclamar la recompensa.
final dailyStateProvider =
    StateNotifierProvider<
      CachedFutureController<Map<String, dynamic>>,
      AsyncValue<Map<String, dynamic>>
    >((ref) {
      final repo = ref.watch(economyRepositoryProvider);
      return CachedFutureController<Map<String, dynamic>>(
        ttl: const Duration(minutes: 10),
        userIdGetter: () => ref.read(currentUserProvider)?.id,
        fetcher: () async {
          final user = ref.read(currentUserProvider);
          if (user == null) {
            return {
              'invocations_used': 0,
              'invocations_max': 20,
              'pergaminos_used': 0,
              'pergaminos_max': 5,
              'daily_reward_claimed': false,
              'bonus_invocations': 0,
            };
          }
          return repo.getDailyState(user.id);
        },
      );
    });

final streakProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'current_streak': 0, 'longest_streak': 0};
  final repo = ref.watch(economyRepositoryProvider);
  return repo.getStreak(user.id);
});

final gemBalanceProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.keepAlive();
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final repo = ref.watch(economyRepositoryProvider);
  return repo.getGems(user.id);
});

final canInvokeProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final repo = ref.watch(economyRepositoryProvider);
  return repo.canInvoke(user.id);
});

final inventoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return [];
      final repo = ref.watch(economyRepositoryProvider);
      return repo.getInventory(user.id);
    });

/// Códigos de los cosméticos equipados (aura y marco) desde `player_inventory`.
final equippedCosmeticsProvider =
    Provider<({String? auraCode, String? frameCode})>((ref) {
      final inventory = ref.watch(inventoryProvider).value ?? [];
      String? auraCode;
      String? frameCode;
      for (final i in inventory) {
        if (i['is_equipped'] != true) continue;
        final type = i['item_type'] as String?;
        if (type == 'aura') auraCode = i['item_code'] as String?;
        if (type == 'frame') frameCode = i['item_code'] as String?;
      }
      return (auraCode: auraCode, frameCode: frameCode);
    });

/// Color del aura cosmética equipada (para el glow del Aura).
Color auraCosmeticColor(String? code) {
  switch (code) {
    case 'aura_fuego':
      return AppColors.crimsonRed;
    case 'aura_sombras':
      return AppColors.runeViolet;
    case 'aura_mana':
    default:
      return AppColors.manaCyan;
  }
}

/// Color del marco cosmético equipado (borde del avatar).
Color frameCosmeticColor(String? code) {
  switch (code) {
    case 'frame_dragón':
      return AppColors.crimsonRed;
    case 'frame_abismo':
      return AppColors.runeViolet;
    case 'frame_escudo':
    default:
      return AppColors.royalGold;
  }
}

final battlePassProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null)
    return {
      'level': 1,
      'xp_progress': 0,
      'is_premium': false,
      'claimed_rewards': <String>[],
    };
  return ref.watch(economyRepositoryProvider).getBattlePass(user.id);
});

final goldBalanceProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  return ref.watch(economyRepositoryProvider).getGold(user.id);
});

final fragmentBalanceProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  return ref.watch(economyRepositoryProvider).getFragments(user.id);
});

/// Saldo de Maná (FASE B): única fuente de energía. La asignación mensual del
/// plan + el maná comprado (porciones/gemas) forman el saldo; cada acción IA
/// descuenta el costo configurable (ai_action_costs). Nada se gana jugando.
///
/// Cache TTL 3 min + SWR: muestra el saldo al instante y refresca en segundo
/// plano. Se invalida tras consumir maná o comprar.
final manaStateProvider =
    StateNotifierProvider<
      CachedFutureController<Map<String, dynamic>>,
      AsyncValue<Map<String, dynamic>>
    >((ref) {
      final repo = ref.watch(economyRepositoryProvider);
      return CachedFutureController<Map<String, dynamic>>(
        ttl: const Duration(minutes: 1),
        userIdGetter: () => ref.read(currentUserProvider)?.id,
        fetcher: () async {
          final user = ref.read(currentUserProvider);
          if (user == null) {
            return {
              'allowance': 1800,
              'purchased': 0,
              'used': 0,
              'remaining': 1800,
              'expires_at': null,
              'plan': 'Plan Gratuito',
              'class': 'plebeyo',
              'is_free': true,
              'daily_limit': 200,
              'daily_used': 0,
              'daily_remaining': 200,
            };
          }
          return repo.getManaState(user.id);
        },
      );
    });

/// Aura XP acumulada (sin tope). Solo crece con la actividad.
final auraXpProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final client = ref.watch(supabaseClientProvider);
  try {
    final res = await client
        .from('user_language_profiles')
        .select('aura_xp')
        .eq('user_id', user.id)
        .maybeSingle();
    return (res?['aura_xp'] as num?)?.toInt() ?? 0;
  } catch (_) {
    return 0;
  }
});

/// Catálogo de Porciones de Maná (pago real). Configurable desde web_admin.
/// Cache TTL 30 min + disco: se pinta al instante en el cold start y se
/// refresca en segundo plano.
final manaPotionsProvider =
    StateNotifierProvider<
      CachedFutureController<List<Map<String, dynamic>>>,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      final client = ref.watch(supabaseClientProvider);
      return CachedFutureController<List<Map<String, dynamic>>>(
        ttl: const Duration(minutes: 30),
        userIdGetter: () => 'catalog',
        diskLoader: () => JsonDiskCache.readList('cache_mana_potions'),
        diskWriter: (data) =>
            JsonDiskCache.writeList('cache_mana_potions', data),
        fetcher: () async {
          try {
            final res = await client
                .from('mana_potions')
                .select('id, name, mana_amount, price_usd, description')
                .eq('is_active', true)
                .order('order_index', ascending: true);
            return List<Map<String, dynamic>>.from(res as List);
          } catch (_) {
            return const [];
          }
        },
      );
    });

/// Catálogo de packs de Gemas de Maná (pago real). Configurable desde web_admin.
/// Cache TTL 30 min + disco.
final manaGemsProvider =
    StateNotifierProvider<
      CachedFutureController<List<Map<String, dynamic>>>,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      final client = ref.watch(supabaseClientProvider);
      return CachedFutureController<List<Map<String, dynamic>>>(
        ttl: const Duration(minutes: 30),
        userIdGetter: () => 'catalog',
        diskLoader: () => JsonDiskCache.readList('cache_mana_gems'),
        diskWriter: (data) => JsonDiskCache.writeList('cache_mana_gems', data),
        fetcher: () async {
          try {
            final res = await client
                .from('mana_gems')
                .select('id, name, mana_amount, price_usd, badge')
                .eq('is_active', true)
                .order('order_index', ascending: true);
            return List<Map<String, dynamic>>.from(res as List);
          } catch (_) {
            return const [];
          }
        },
      );
    });

/// Catálogo de cosméticos vendidos por ORO (Tienda de Oro).
/// Filtra cosmetic_catalog con price_gold > 0 y tipo cosmético.
/// Cache TTL 30 min + disco.
final goldCosmeticsProvider =
    StateNotifierProvider<
      CachedFutureController<List<Map<String, dynamic>>>,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      final client = ref.watch(supabaseClientProvider);
      return CachedFutureController<List<Map<String, dynamic>>>(
        ttl: const Duration(minutes: 30),
        userIdGetter: () => 'catalog',
        diskLoader: () => JsonDiskCache.readList('cache_gold_cosmetics'),
        diskWriter: (data) =>
            JsonDiskCache.writeList('cache_gold_cosmetics', data),
        fetcher: () async {
          try {
            final res = await client
                .from('cosmetic_catalog')
                .select(
                  'id, name, description, category, price_gold, rarity, image_url',
                )
                .gt('price_gold', 0)
                .order('category', ascending: true)
                .order('price_gold', ascending: true);
            return List<Map<String, dynamic>>.from(res as List);
          } catch (_) {
            return const [];
          }
        },
      );
    });

// ── Inventario equipable de maná (elixires/gemas) ───────────────────────────

/// Inventario de maná del usuario (mana_items). Se invalida al comprar/equipar.
final manaItemsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const [];
      final repo = ref.watch(economyRepositoryProvider);
      return repo.getManaItems(user.id);
    });

/// El ítem equipado (activo) del usuario, si existe.
final equippedManaItemProvider = Provider<Map<String, dynamic>?>((ref) {
  final items = ref.watch(manaItemsProvider).value ?? const [];
  if (items.isEmpty) return null;
  for (final item in items) {
    if (item['status'] == 'equipped') return item;
  }
  return null;
});

/// Maná restante del ítem equipado, o 0 si no hay.
final equippedManaRemainingProvider = Provider<int>((ref) {
  final equipped = ref.watch(equippedManaItemProvider);
  return (equipped?['mana_amount'] as num?)?.toInt() ?? 0;
});

/// Segundos hasta que expire el ítem equipado (48h gema / 15d elixir), o null.
final equippedManaExpiryProvider = Provider<Duration?>((ref) {
  final equipped = ref.watch(equippedManaItemProvider);
  final expires = equipped?['expires_at'] as String?;
  if (expires == null) return null;
  final t = DateTime.tryParse(expires);
  if (t == null) return null;
  final diff = t.difference(DateTime.now());
  return diff.isNegative ? Duration.zero : diff;
});
