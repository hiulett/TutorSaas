import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/mission_repository.dart';
import '../../domain/models/mission_models.dart';

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MissionRepository(client);
});

final activeMissionsProvider = FutureProvider.autoDispose<List<MissionInstance>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getActiveMissions(user.id);
});

final completedMissionsProvider = FutureProvider.autoDispose<List<MissionInstance>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getCompletedMissions(user.id);
});

final dailyTemplatesProvider = FutureProvider.autoDispose<List<MissionTemplate>>((ref) async {
  return ref.watch(missionRepositoryProvider).getTemplates(type: 'daily');
});

final secretMissionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getSecretMissions(user.id);
});

final emergencyMissionsProvider = FutureProvider.autoDispose<List<EmergencyMission>>((ref) async {
  return ref.watch(missionRepositoryProvider).getActiveEmergencies();
});

final recentRewardsProvider = FutureProvider.autoDispose<List<RewardHistory>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getRecentRewards(user.id);
});
