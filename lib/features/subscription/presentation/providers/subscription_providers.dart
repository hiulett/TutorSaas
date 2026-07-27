import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SubscriptionRepositoryImpl(supabaseClient);
});

class PremiumStatusNotifier extends StateNotifier<bool> {
  final SubscriptionRepository _repository;
  final String? _userId;

  PremiumStatusNotifier(this._repository, this._userId) : super(false) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (_userId == null) return;
    try {
      final isPrem = await _repository.isUserPremium(_userId);
      if (mounted) {
        state = isPrem;
      }
    } catch (_) {}
  }

  void setPremium(bool val) {
    if (mounted) {
      state = val;
    }
  }
}

final isPremiumProvider = StateNotifierProvider.autoDispose<PremiumStatusNotifier, bool>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return PremiumStatusNotifier(repo, user?.id);
});
