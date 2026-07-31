import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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
