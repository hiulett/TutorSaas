import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    // Upsert placement result into Supabase
    await _client.from('placement_results').upsert({
      'user_id': userId,
      'cefr_level': cefrLevel,
      'learning_goal': learningGoal,
      'main_difficulty': mainDifficulty,
      'quiz_score': quizScore,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');

    // Also update the user_profiles table with the computed level
    await _client.from('user_profiles').upsert({
      'id': userId,
      'cefr_level': cefrLevel,
      'placement_completed': true,
    }, onConflict: 'id');
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final placementRepositoryProvider = Provider<PlacementRepository>((ref) {
  final client = Supabase.instance.client;
  return PlacementRepositoryImpl(client);
});
