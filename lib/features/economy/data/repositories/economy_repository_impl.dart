import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/economy_repository.dart';

class EconomyRepositoryImpl implements EconomyRepository {
  final SupabaseClient _client;

  EconomyRepositoryImpl(this._client);

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
        }
        // else: diff > 1, reset to 1
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

      await _client
          .from('player_daily_state')
          .update({'daily_reward_claimed': true, 'pergaminos_max': _client.rpc('increment_pergaminos_max', params: {'p_user_id': userId, 'p_amount': pergaminos})})
          .eq('user_id', userId)
          .eq('date', today);

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
      // Check if already owned
      final existing = await _client
          .from('player_inventory')
          .select('id')
          .eq('user_id', userId)
          .eq('item_code', itemCode)
          .maybeSingle();
      if (existing != null) return false;

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

      await _client.from('player_inventory').insert({
        'user_id': userId,
        'item_code': itemCode,
        'item_type': 'consumable',
        'is_equipped': false,
      });

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
}
