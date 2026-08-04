import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/retention_analytics.dart';
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

      final created = await _client.from('player_daily_state').insert({
        'user_id': userId,
        'date': today,
        'invocations_used': 0,
        'invocations_max': 20 + bonus,
        'pergaminos_used': 0,
        'pergaminos_max': 5,
        'daily_reward_claimed': false,
        'bonus_invocations': bonus,
      }).select().single();

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

      final created = await _client.from('player_streaks').insert({
        'user_id': userId,
        'current_streak': 0,
        'longest_streak': 0,
        'last_active_date': DateTime.now().toIso8601String().split('T').first,
      }).select().single();

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
          newStreak = (streak['current_streak'] as int?) ?? 0;
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
  Future<bool> claimDailyReward(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final state = await getDailyState(userId);
      if (state['daily_reward_claimed'] == true) return false;

      final streak = await getStreak(userId);
      final days = (streak['current_streak'] as int?) ?? 0;

      // Calculate reward based on streak
      int gems = 5;
      int pergaminos = 2;
      if (days >= 7) { gems = 50; pergaminos = 5; }
      if (days >= 14) { gems = 100; pergaminos = 8; }
      if (days >= 30) { gems = 300; pergaminos = 15; }

      await _client.rpc('add_gems', params: {
        'p_user_id': userId,
        'p_amount': gems,
      });

      await _client.rpc('increment_pergaminos_max', params: {
        'p_user_id': userId,
        'p_amount': pergaminos,
      });

      await _client
          .from('player_daily_state')
          .update({'daily_reward_claimed': true})
          .eq('user_id', userId)
          .eq('date', today);

      unawaited(_logEvent(userId, 'claim_daily'));
      unawaited(RetentionAnalytics.instance.track(userId, 'claim_daily'));
      return true;
    } catch (_) {
      return false;
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
        // Handle specific consumable effects
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
  Future<void> toggleEquip(String userId, String itemCode) async {
    try {
      final item = await _client
          .from('player_inventory')
          .select('id, is_equipped')
          .eq('user_id', userId)
          .eq('item_code', itemCode)
          .maybeSingle();
      if (item == null) return;

      await _client
          .from('player_inventory')
          .update({'is_equipped': item['is_equipped'] != true})
          .eq('id', item['id']);
    } catch (_) {}
  }

  @override
  Future<void> addGems(String userId, int amount) async {
    try {
      await _client.rpc('add_gems', params: {
        'p_user_id': userId,
        'p_amount': amount,
      });
    } catch (_) {}
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

      await _client.rpc('spend_gems', params: {
        'p_user_id': userId,
        'p_amount': amount,
      });
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
    } catch (_) {}
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

      final created = await _client.from('guild_battle_pass').insert({
        'user_id': userId,
        'season': season,
        'level': 1,
        'xp_progress': 0,
        'is_premium': false,
        'claimed_rewards': const <String>[],
      }).select().single();

      return Map<String, dynamic>.from(created);
    } catch (_) {
      return {'season': season, 'level': 1, 'xp_progress': 0, 'is_premium': false, 'claimed_rewards': <String>[]};
    }
  }

  @override
  Future<Map<String, dynamic>?> addBattlePassXp(String userId, int amount) async {
    try {
      const season = 'season_2026_02';
      const xpPerLevel = 1000;
      final bp = await getBattlePass(userId);

      final level = (bp['level'] as num?)?.toInt() ?? 1;
      final progress = (bp['xp_progress'] as num?)?.toInt() ?? 0;
      var newProgress = progress + amount;
      var newLevel = level;

      while (newProgress >= xpPerLevel) {
        newProgress -= xpPerLevel;
        newLevel++;
      }

      await _client.from('guild_battle_pass').upsert({
        'user_id': userId,
        'season': season,
        'level': newLevel,
        'xp_progress': newProgress,
        'is_premium': bp['is_premium'] as bool? ?? false,
        'claimed_rewards': (bp['claimed_rewards'] as List? ?? const <String>[]),
      }, onConflict: 'user_id, season').select().single();

      return {'level': newLevel, 'xp_progress': newProgress, 'season': season};
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> claimBattlePassReward(String userId, int tier) async {
    try {
      final bp = await getBattlePass(userId);
      final level = (bp['level'] as num?)?.toInt() ?? 1;
      if (tier > level) return false;

      final claimed = List<String>.from((bp['claimed_rewards'] as List? ?? const <String>[]));
      final key = 'tier_$tier';
      if (claimed.contains(key)) return false;
      claimed.add(key);

      await _client.from('guild_battle_pass').upsert({
        'user_id': userId,
        'season': bp['season'] as String? ?? 'season_2026_02',
        'level': level,
        'xp_progress': (bp['xp_progress'] as num?)?.toInt() ?? 0,
        'is_premium': bp['is_premium'] as bool? ?? false,
        'claimed_rewards': claimed,
      }, onConflict: 'user_id, season');

      return true;
    } catch (_) {
      return false;
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
      await _client.rpc('add_fragments', params: {
        'p_user_id': userId,
        'p_amount': amount,
      });
    } catch (_) {}
  }
}
