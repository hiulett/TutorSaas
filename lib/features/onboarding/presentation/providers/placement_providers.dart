import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';

// ── Repository interface ─────────────────────────────────────────────────────

abstract class PlacementRepository {
  Future<void> savePlacementResult({
    required String userId,
    required String cefrLevel,
    required String learningGoal,
    required String mainDifficulty,
    required int quizScore,
  });
}

// ── Repository implementation ────────────────────────────────────────────────

class PlacementRepositoryImpl implements PlacementRepository {
  final SupabaseClient _client;

  PlacementRepositoryImpl(this._client);

  @override
  Future<void> savePlacementResult({
    required String userId,
    required String cefrLevel,
    required String learningGoal,
    required String mainDifficulty,
    required int quizScore,
  }) async {
    // 1. Get CEFR Level ID from code (A1, A2, etc.)
    int cefrId = 1;
    try {
      final cefrResponse = await _client
          .from('cefr_levels')
          .select('id')
          .eq('code', cefrLevel)
          .maybeSingle();
      if (cefrResponse != null) {
        cefrId = cefrResponse['id'] as int;
      }
    } catch (e, st) {
      ErrorTracker.logSilent('lib/features/onboarding/presentation/providers/placement_providers.dart:42', e, stackTrace: st);
    }

    // 2. Update user_language_profiles with the computed level ID
    try {
      await _client.from('user_language_profiles').upsert({
        'user_id': userId,
        'language_id': 1, // Default English language id
        'cefr_level_id': cefrId,
      }, onConflict: 'user_id, language_id');
    } catch (e, st) {
      ErrorTracker.logSilent('lib/features/onboarding/presentation/providers/placement_providers.dart:51', e, stackTrace: st);
    }

    // 3. Update public.users table with goals / difficulties inside bio
    try {
      await _client.from('users').update({
        'bio': '[Stats|STR:5|INT:5|DEX:5|LUK:5] Goal: $learningGoal | Obstacle: $mainDifficulty | Quiz: $quizScore',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e, st) {
      ErrorTracker.logSilent('lib/features/onboarding/presentation/providers/placement_providers.dart:59', e, stackTrace: st);
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final placementRepositoryProvider = Provider<PlacementRepository>((ref) {
  final client = Supabase.instance.client;
  return PlacementRepositoryImpl(client);
});
