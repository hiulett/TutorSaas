import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../subscription/domain/premium_status.dart';
import '../../domain/repositories/economy_repository.dart';

class EconomyRepositoryImpl implements EconomyRepository {
  final SupabaseClient _client;

  EconomyRepositoryImpl(this._client);

  /// Best-effort fire-and-forget logging of a usage event into api_request_logs.
  /// Never throws and never blocks the main flow (wrapped in its own try-catch).
  Future<void> _logEvent(String userId, String eventType) async {
    if (userId.isEmpty || eventType.isEmpty) return;
    try {
      await _client.from('api_request_logs').insert({
        'user_id': userId,
        'endpoint': eventType,
      });
      debugPrint('api_request_logs event logged: $eventType');
    } catch (e) {
      debugPrint('Error logging api_request_logs event ($eventType): $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyState(String userId) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      final existing = await _client
          .from('player_daily_state')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (existing != null) return Map<String, dynamic>.from(existing);

      // Get streak for bonus invocations
      final streak = await getStreak(userId);
      final streakDays = (streak['current_streak'] as int?) ?? 0;
      final bonus = (streakDays ~/ 7) * 5; // +5 invocations per 7-day streak

      final created = await _client
          .from('player_daily_state')
          .insert({
            'user_id': userId,
            'date': today,
            'invocations_used': 0,
            'invocations_max': 20 + bonus,
            'pergaminos_used': 0,
            'pergaminos_max': 5,
            'daily_reward_claimed': false,
            'bonus_invocations': bonus,
          })
          .select()
          .single();

      return Map<String, dynamic>.from(created);
    } catch (_) {
      return {
        'invocations_used': 0,
        'invocations_max': 20,
        'pergaminos_used': 0,
        'pergaminos_max': 5,
        'daily_reward_claimed': false,
        'bonus_invocations': 0,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> useInvocation(String userId) async {
    final state = await getDailyState(userId);
    final used = (state['invocations_used'] as int?) ?? 0;
    final max = (state['invocations_max'] as int?) ?? 20;

    if (used >= max) {
      throw Exception('EL_NUCLEO_ARCANO_AGOTADO');
    }

    await _client
        .from('player_daily_state')
        .update({'invocations_used': used + 1})
        .eq('user_id', userId)
        .eq('date', DateTime.now().toIso8601String().split('T').first);

    return {...state, 'invocations_used': used + 1};
  }

  @override
  Future<bool> canInvoke(String userId) async {
    try {
      final state = await getDailyState(userId);
      final used = (state['invocations_used'] as int?) ?? 0;
      final max = (state['invocations_max'] as int?) ?? 20;
      return used < max;
    } catch (_) {
      return true; // fallback: allow if DB fails
    }
  }

  @override
  Future<Map<String, dynamic>> getStreak(String userId) async {
    try {
      final existing = await _client
          .from('player_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) return Map<String, dynamic>.from(existing);

      final created = await _client
          .from('player_streaks')
          .insert({
            'user_id': userId,
            'current_streak': 0,
            'longest_streak': 0,
            'last_active_date': DateTime.now()
                .toIso8601String()
                .split('T')
                .first,
          })
          .select()
          .single();

      return Map<String, dynamic>.from(created);
    } catch (_) {
      return {'current_streak': 0, 'longest_streak': 0};
    }
  }

  @override
  Future<Map<String, dynamic>> updateStreak(String userId) async {
    final streak = await getStreak(userId);
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T').first;
    final lastActive = streak['last_active_date'] as String?;

    int newStreak = 1;
    if (lastActive != null) {
      try {
        final lastDate = DateTime.parse(lastActive);
        final diff = today.difference(lastDate).inDays;
        if (diff == 1) {
          newStreak = ((streak['current_streak'] as int?) ?? 0) + 1;
        } else if (diff == 0) {
          final current = (streak['current_streak'] as int?) ?? 0;
          // Issue #29: en el primer día la fila nace con last_active_date=hoy y
          // current_streak=0; mantener 0 dejaba la racha en 0 hasta el día 2.
          newStreak = current > 0 ? current : 1;
        } else {
          // Day was lost (diff > 1): consume a freeze if available,
          // otherwise reset the streak.
          final freezes = await getStreakFreezes(userId);
          if (freezes > 0) {
            newStreak = (streak['current_streak'] as int?) ?? 0;
            await _client
                .from('player_streaks')
                .update({'streak_freezes': freezes - 1})
                .eq('user_id', userId);
          }
          // else: newStreak stays 1 (reset)
        }
      } catch (_) {
        newStreak = 1;
      }
    }

    final longest = (streak['longest_streak'] as int?) ?? 0;
    final newLongest = newStreak > longest ? newStreak : longest;

    await _client.from('player_streaks').upsert({
      'user_id': userId,
      'current_streak': newStreak,
      'longest_streak': newLongest,
      'last_active_date': todayStr,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');

    return {
      'current_streak': newStreak,
      'longest_streak': newLongest,
      'last_active_date': todayStr,
    };
  }

  @override
  @override
  Future<Map<String, int>> claimDailyReward(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final state = await getDailyState(userId);
      if (state['daily_reward_claimed'] == true) return const {};

      final streak = await getStreak(userId);
      final days = (streak['current_streak'] as int?) ?? 0;

      // Calculate reward based on streak (fuente única de la recompensa).
      int gems = 5;
      int pergaminos = 2;
      if (days >= 7) {
        gems = 50;
        pergaminos = 5;
      }
      if (days >= 14) {
        gems = 100;
        pergaminos = 8;
      }
      if (days >= 30) {
        gems = 300;
        pergaminos = 15;
      }

      await _client.rpc(
        'add_gems',
        params: {'p_user_id': userId, 'p_amount': gems},
      );

      await _client.rpc(
        'increment_pergaminos_max',
        params: {'p_user_id': userId, 'p_amount': pergaminos},
      );

      await _client
          .from('player_daily_state')
          .update({'daily_reward_claimed': true})
          .eq('user_id', userId)
          .eq('date', today);

      unawaited(_logEvent(userId, 'claim_daily'));
      unawaited(RetentionAnalytics.instance.track(userId, 'claim_daily'));
      return {'gems': gems, 'pergaminos': pergaminos};
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInventory(String userId) async {
    try {
      final data = await _client
          .from('player_inventory')
          .select('*')
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> purchaseItem(String userId, String itemCode) async {
    try {
      final isConsumable = itemCode.startsWith('consumible_');

      // Check if already owned (only for non-consumables)
      if (!isConsumable) {
        final existing = await _client
            .from('player_inventory')
            .select('id')
            .eq('user_id', userId)
            .eq('item_code', itemCode)
            .maybeSingle();
        if (existing != null) return false;
      }

      // Get item price
      final catalog = await _client
          .from('cosmetic_catalog')
          .select('price_gems')
          .eq('id', itemCode)
          .maybeSingle();
      if (catalog == null) return false;

      final price = catalog['price_gems'] as int? ?? 0;
      if (price == 0) return false;

      // Spend gems
      final spent = await spendGems(userId, price);
      if (!spent) return false;

      if (isConsumable) {
        final today = DateTime.now().toIso8601String().split('T').first;
        final dailyState = await getDailyState(userId);
        final currentMax = (dailyState['invocations_max'] as int?) ?? 20;

        if (itemCode == 'consumible_invocacion5') {
          await _client
              .from('player_daily_state')
              .update({'invocations_max': currentMax + 5})
              .eq('user_id', userId)
              .eq('date', today);
        } else if (itemCode == 'consumible_invocacion20') {
          await _client
              .from('player_daily_state')
              .update({'invocations_max': currentMax + 20})
              .eq('user_id', userId)
              .eq('date', today);
        } else if (itemCode == 'consumible_pergamino10') {
          // +10 pergaminos de repaso al máximo diario.
          await _client.rpc(
            'increment_pergaminos_max',
            params: {'p_user_id': userId, 'p_amount': 10},
          );
        } else if (itemCode == 'consumible_pergamino50') {
          // +50 pergaminos de repaso al máximo diario.
          await _client.rpc(
            'increment_pergaminos_max',
            params: {'p_user_id': userId, 'p_amount': 50},
          );
        }
      } else {
        await _client.from('player_inventory').insert({
          'user_id': userId,
          'item_code': itemCode,
          'item_type': 'cosmetic',
          'is_equipped': false,
        });
      }

      unawaited(_logEvent(userId, 'purchase_item'));
      unawaited(RetentionAnalytics.instance.track(userId, 'purchase_item'));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> purchaseCosmeticWithGold(String userId, String itemCode) async {
    try {
      // Issue #2: compra atómica en servidor (valida saldo, catálogo,
      // disponibilidad y ownership; entrega el ítem en la misma transacción).
      final res = await _client.rpc(
        'purchase_cosmetic',
        params: {
          'p_user_id': userId,
          'p_item_id': itemCode,
          'p_currency': 'gold',
        },
      );
      final ok = res is Map && res['success'] == true;
      if (ok) {
        unawaited(_logEvent(userId, 'purchase_cosmetic_gold'));
        unawaited(
          RetentionAnalytics.instance.track(userId, 'purchase_cosmetic_gold'),
        );
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> toggleEquip(String userId, String itemCode) async {
    try {
      final item = await _client
          .from('player_inventory')
          .select('is_equipped')
          .eq('user_id', userId)
          .eq('item_code', itemCode)
          .maybeSingle();
      if (item == null) return;

      // Issue #2: el equipado también pasa por RPC; la tabla sigue sin INSERT
      // ni UPDATE directo para que un cliente no pueda autoentregarse ítems.
      await _client.rpc(
        'equip_cosmetic',
        params: {
          'p_user_id': userId,
          'p_item_id': itemCode,
          'p_equip': item['is_equipped'] != true,
        },
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/economy/data/repositories/economy_repository_impl.dart:352',
        e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> addGems(String userId, int amount) async {
    try {
      await _client.rpc(
        'add_gems',
        params: {'p_user_id': userId, 'p_amount': amount},
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/economy/data/repositories/economy_repository_impl.dart:362',
        e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> spendGems(String userId, int amount) async {
    try {
      final profile = await _client
          .from('user_language_profiles')
          .select('total_gems')
          .eq('user_id', userId)
          .maybeSingle();
      final gems = (profile?['total_gems'] as int?) ?? 0;
      if (gems < amount) return false;

      await _client.rpc(
        'spend_gems',
        params: {'p_user_id': userId, 'p_amount': amount},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> getGems(String userId) async {
    try {
      final profile = await _client
          .from('user_language_profiles')
          .select('total_gems')
          .eq('user_id', userId)
          .maybeSingle();
      return (profile?['total_gems'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> purchaseStreakFreeze(String userId) async {
    try {
      const freezeCost = 30;

      // Ensure the streak row exists before updating the freeze count
      await getStreak(userId);

      final current = await getStreakFreezes(userId);
      await _client
          .from('player_streaks')
          .update({'streak_freezes': current + 1})
          .eq('user_id', userId);

      final spent = await spendGems(userId, freezeCost);
      if (!spent) {
        // Roll back the freeze if the gems could not be charged.
        await _client
            .from('player_streaks')
            .update({'streak_freezes': current})
            .eq('user_id', userId);
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('purchaseStreakFreeze error: $e');
      return false;
    }
  }

  @override
  Future<int> getStreakFreezes(String userId) async {
    try {
      final existing = await _client
          .from('player_streaks')
          .select('streak_freezes')
          .eq('user_id', userId)
          .maybeSingle();
      if (existing == null) return 0;
      return (existing['streak_freezes'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('getStreakFreezes error: $e');
      return 0;
    }
  }

  @override
  Future<void> generateDailyPergaminos(String userId) async {
    // This would be called by a batch job (Edge Function).
    // For now, generate placeholder content.
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final existing = await _client
          .from('player_pergaminos')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', today)
          .maybeSingle();

      if (existing != null) return; // Already generated today

      // Insert placeholder pergaminos (real content generated by Edge Function)
      for (int i = 0; i < 5; i++) {
        await _client.from('player_pergaminos').insert({
          'user_id': userId,
          'content': {
            'type': 'dialogue_practice',
            'title': 'Práctica ${i + 1}',
            'phrases': [
              {'en': 'Hello, how are you?', 'es': 'Hola, ¿cómo estás?'},
              {'en': 'I am fine, thank you.', 'es': 'Estoy bien, gracias.'},
            ],
            'questions': ['What is your name?', 'Where are you from?'],
          },
          'is_used': false,
        });
      }
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/economy/data/repositories/economy_repository_impl.dart:477',
        e,
        stackTrace: st,
      );
    }
  }

  // ── Battle Pass ──────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getBattlePass(String userId) async {
    const season = 'season_2026_02';
    try {
      final existing = await _client
          .from('guild_battle_pass')
          .select()
          .eq('user_id', userId)
          .eq('season', season)
          .maybeSingle();

      if (existing != null) return Map<String, dynamic>.from(existing);

      final created = await _client
          .from('guild_battle_pass')
          .insert({
            'user_id': userId,
            'season': season,
            'level': 1,
            'xp_progress': 0,
            'is_premium': false,
            'claimed_rewards': const <String>[],
          })
          .select()
          .single();

      return Map<String, dynamic>.from(created);
    } catch (_) {
      return {
        'season': season,
        'level': 1,
        'xp_progress': 0,
        'is_premium': false,
        'claimed_rewards': <String>[],
      };
    }
  }

  // ── Gold & Fragments (T-504) ─────────────────────────────────────────────

  @override
  Future<int> getGold(String userId) async {
    try {
      final profile = await _client
          .from('user_language_profiles')
          .select('total_gold')
          .eq('user_id', userId)
          .maybeSingle();
      return (profile?['total_gold'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> spendGold(String userId, int amount) async {
    try {
      final profile = await _client
          .from('user_language_profiles')
          .select('total_gold')
          .eq('user_id', userId)
          .maybeSingle();
      final gold = (profile?['total_gold'] as num?)?.toInt() ?? 0;
      if (gold < amount) return false;

      await _client
          .from('user_language_profiles')
          .update({'total_gold': gold - amount})
          .eq('user_id', userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> getFragments(String userId) async {
    try {
      final profile = await _client
          .from('user_language_profiles')
          .select('fragments')
          .eq('user_id', userId)
          .maybeSingle();
      return (profile?['fragments'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> addFragments(String userId, int amount) async {
    try {
      await _client.rpc(
        'add_fragments',
        params: {'p_user_id': userId, 'p_amount': amount},
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/economy/data/repositories/economy_repository_impl.dart:568',
        e,
        stackTrace: st,
      );
    }
  }

  /// Maná del Oráculo extra según el plan contratado.
  /// Escala con monthly_audio_minutes_limit del subscription_plans:
  ///   free (30 min) → +0, monthly (300 min) → +20, annual/lifetime (1200 min) → +40.
  @override
  Future<int> getPlanManaBonus(String userId) async {
    try {
      final sub = await _client
          .from('user_subscriptions')
          .select('plan_id, status, period_end')
          .eq('user_id', userId)
          .maybeSingle();
      // Issue #65: misma regla que en el resto de la app.
      if (!isPremiumSubscription(sub)) return 0;
      final planId = sub!['plan_id'] as String;

      final plan = await _client
          .from('subscription_plans')
          .select('monthly_audio_minutes_limit')
          .eq('id', planId)
          .maybeSingle();
      final minutes =
          (plan?['monthly_audio_minutes_limit'] as num?)?.toInt() ?? 0;
      if (minutes >= 1200) return 40;
      if (minutes >= 300) return 20;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // ── FASE B: Maná monetizado + Aura sin tope ──────────────────────────────

  @override
  Future<Map<String, dynamic>> consumeMana(
    String userId,
    String actionCode,
  ) async {
    try {
      final res = await _client.rpc(
        'consume_mana',
        params: {'p_user_id': userId, 'p_action_code': actionCode},
      );
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      debugPrint('consumeMana error: $e');
      return {'success': false, 'reason': 'error'};
    }
  }

  @override
  Future<Map<String, dynamic>> closeSession(String sessionId) async {
    final res = await _client.rpc(
      'close_session',
      params: {'p_session_id': sessionId},
    );
    if (res is Map) return Map<String, dynamic>.from(res);
    return const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> getManaState(String userId) async {
    try {
      final res = await _client.rpc(
        'get_mana_state',
        params: {'p_user_id': userId},
      );
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      debugPrint('getManaState error: $e');
      // Fallback sin inventar saldo: 0 en lugar de un valor falso (1800).
      return {
        'allowance': 0,
        'purchased': 0,
        'used': 0,
        'remaining': 0,
        'expires_at': null,
        'plan': 'Plan Gratuito',
        'class': 'plebeyo',
        'is_free': true,
        'daily_limit': 200,
        'daily_used': 0,
        'daily_remaining': 0,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> addAuraXp(
    String userId,
    String sessionId,
    Map<String, double> radar,
    int metas,
    int bonusNivel,
  ) async {
    try {
      final res = await _client.rpc(
        'add_aura_xp',
        params: {
          'p_user_id': userId,
          'p_session_id': sessionId,
          'p_radar': radar,
          'p_metas': metas,
          'p_bonus_nivel': bonusNivel,
        },
      );
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      debugPrint('addAuraXp error: $e');
      return {'added': 0, 'error': 'error'};
    }
  }

  @override
  Future<void> addGold(String userId, int amount) async {
    try {
      await _client.rpc(
        'add_gold',
        params: {'p_user_id': userId, 'p_amount': amount},
      );
    } catch (e) {
      debugPrint('addGold error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> refundFailedTurn({
    required String turnRef,
    required String actionCode,
  }) async {
    try {
      final res = await _client.rpc(
        'refund_failed_turn',
        params: {'p_turn_ref': turnRef, 'p_action_code': actionCode},
      );
      if (res is Map) return Map<String, dynamic>.from(res);
      return const <String, dynamic>{};
    } catch (e) {
      debugPrint('refundFailedTurn error: $e');
      return const <String, dynamic>{};
    }
  }

  @override
  Future<Map<String, dynamic>> registerPractice({
    required String sessionId,
    required int minutes,
    required int objectives,
    int tzOffsetMinutes = 0,
  }) async {
    try {
      final res = await _client.rpc(
        'register_practice',
        params: {
          'p_session_id': sessionId,
          'p_minutes': minutes,
          'p_objectives': objectives,
          'p_tz_offset_minutes': tzOffsetMinutes,
        },
      );
      if (res is Map) return Map<String, dynamic>.from(res);
      return const <String, dynamic>{};
    } catch (e) {
      debugPrint('registerPractice error: $e');
      return const <String, dynamic>{};
    }
  }

  @override
  Future<Map<String, dynamic>> claimSessionDrop({
    required String sessionId,
    required int completedGoals,
  }) async {
    try {
      final res = await _client.rpc(
        'claim_session_drop',
        params: {
          'p_session_id': sessionId,
          'p_completed_goals': completedGoals,
        },
      );
      if (res is Map) return Map<String, dynamic>.from(res);
      return const <String, dynamic>{};
    } catch (e) {
      debugPrint('claimSessionDrop error: $e');
      return const <String, dynamic>{};
    }
  }

  @override
  Future<void> addXp(String userId, int amount) async {
    try {
      await _client.rpc(
        'add_xp',
        params: {'p_user_id': userId, 'p_amount': amount},
      );
    } catch (e) {
      debugPrint('addXp error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPrestigeTitle(String userId) async {
    try {
      final res = await _client.rpc(
        'get_prestige_title',
        params: {'p_user_id': userId},
      );
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      debugPrint('getPrestigeTitle error: $e');
      return {'tier_code': null, 'name': null};
    }
  }

  // ── Inventario equipable de maná ─────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getManaItems(String userId) async {
    try {
      final res = await _client
          .from('mana_items')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('getManaItems error: $e');
      return [];
    }
  }

  @override
  Future<bool> equipManaItem(String userId, String itemId) async {
    try {
      final res = await _client.rpc(
        'equip_mana_item',
        params: {'p_user_id': userId, 'p_item_id': itemId},
      );
      return res == true;
    } catch (e) {
      debugPrint('equipManaItem error: $e');
      return false;
    }
  }

  @override
  Future<bool> desequipManaItem(String userId, String itemId) async {
    try {
      final res = await _client.rpc(
        'desequip_mana_item',
        params: {'p_user_id': userId, 'p_item_id': itemId},
      );
      return res == true;
    } catch (e) {
      debugPrint('desequipManaItem error: $e');
      return false;
    }
  }
}
