import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../conversation/presentation/providers/conversation_providers.dart';
import '../../data/repositories/economy_repository_impl.dart';
import '../../domain/repositories/economy_repository.dart';

final economyRepositoryProvider = Provider<EconomyRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EconomyRepositoryImpl(client);
});

final dailyStateProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'invocations_used': 0, 'invocations_max': 20, 'pergaminos_used': 0, 'pergaminos_max': 5, 'daily_reward_claimed': false, 'bonus_invocations': 0};
  final repo = ref.watch(economyRepositoryProvider);
  return repo.getDailyState(user.id);
});

final streakProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'current_streak': 0, 'longest_streak': 0};
  final repo = ref.watch(economyRepositoryProvider);
  return repo.getStreak(user.id);
});

final gemBalanceProvider = FutureProvider.autoDispose<int>((ref) async {
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

final inventoryProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(economyRepositoryProvider);
  return repo.getInventory(user.id);
});

final battlePassProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'level': 1, 'xp_progress': 0, 'is_premium': false, 'claimed_rewards': <String>[]};
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

/// Maná del Oráculo: total = invocaciones (base 20 + racha + consumibles) +
/// bonus por plan contratado (free +0 / monthly +20 / annual/lifetime +40).
/// Muestra cuánto maná queda para hablar con el Oráculo hoy.
final oracleManaProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return {'manaMax': 20, 'manaUsed': 0, 'manaLeft': 20, 'planBonus': 0, 'planMinutes': 0};
  }
  final repo = ref.watch(economyRepositoryProvider);
  final dailyState = await repo.getDailyState(user.id);
  final planBonus = await repo.getPlanManaBonus(user.id);

  final baseMax = (dailyState['invocations_max'] as num?)?.toInt() ?? 20;
  final used = (dailyState['invocations_used'] as num?)?.toInt() ?? 0;
  final manaMax = baseMax + planBonus;
  final manaLeft = (manaMax - used).clamp(0, manaMax);

  return {
    'manaMax': manaMax,
    'manaUsed': used,
    'manaLeft': manaLeft,
    'planBonus': planBonus,
  };
});

/// Maná mensual del Oráculo: minutos de audio IA consumidos del plan
/// (vía RPC check_ai_audio_quota → user_subscriptions.used_audio_seconds).
final monthlyManaProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return {'usedSeconds': 0, 'limitSeconds': 1800, 'remainingSeconds': 1800, 'planName': 'free'};
  }
  final repo = ref.watch(conversationRepositoryProvider);
  final quota = await repo.checkAiAudioQuota(user.id);
  final used = (quota['used_seconds'] as num?)?.toInt() ?? 0;
  final limit = (quota['limit_seconds'] as num?)?.toInt() ?? 1800;
  final remaining = (quota['remaining_seconds'] as num?)?.toInt() ?? (limit - used);
  return {
    'usedSeconds': used,
    'limitSeconds': limit,
    'remainingSeconds': remaining,
    'planName': quota['plan_name'] as String? ?? 'free',
  };
});
