import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/onboarding_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return OnboardingRepositoryImpl(supabaseClient);
});

final devAlwaysShowOnboardingProvider = StateNotifierProvider<DevAlwaysShowOnboardingNotifier, bool>((ref) {
  return DevAlwaysShowOnboardingNotifier();
});

class DevAlwaysShowOnboardingNotifier extends StateNotifier<bool> {
  DevAlwaysShowOnboardingNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('dev_always_show_onboarding') ?? false;
  }

  Future<void> toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dev_always_show_onboarding', value);
    state = value;
  }
}
