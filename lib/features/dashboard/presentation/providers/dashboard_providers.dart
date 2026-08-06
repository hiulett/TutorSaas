import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/models/hunter_catalog.dart';
import '../../domain/models/user_settings.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return DashboardRepositoryImpl(supabaseClient);
});

final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

final userProgressProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return {
      'xp': 0,
      'streak': 0,
      'level': 'Principiante',
      'level_code': 'A1',
      'language': 'Inglés',
      'language_emoji': '🇺🇸',
    };
  }
  return ref.read(dashboardRepositoryProvider).getUserProgress(user.id);
});

final recommendedLessonsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  // Watch userProgressProvider to reload recommended lessons when user progress/onboarding state changes
  ref.watch(userProgressProvider);
  // Watch dashboardRefreshProvider to reload after endSession
  ref.watch(dashboardRefreshProvider);
  return ref.read(dashboardRepositoryProvider).getRecommendedLessons(user.id);
});

final userAchievementsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  // Watch userProgressProvider to reload achievements when user statistics or onboarding state updates
  ref.watch(userProgressProvider);
  // Watch dashboardRefreshProvider to reload after endSession
  ref.watch(dashboardRefreshProvider);
  return ref.read(dashboardRepositoryProvider).getUserAchievements(user.id);
});

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  final DashboardRepository _repository;
  final String? _userId;

  UserSettingsNotifier(this._repository, this._userId) : super(UserSettings.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_userId == null) return;
    try {
      final data = await _repository.getUserSettings(_userId);
      if (data.isNotEmpty) {
        state = UserSettings.fromJson(data);
      }
    } catch (_) {}
  }

  Future<void> updateSetting(String key, dynamic value) async {
    if (_userId == null) return;
    final updatedMap = state.toJson();
    updatedMap[key] = value;
    state = UserSettings.fromJson(updatedMap);
    await _repository.updateUserSettings(_userId, updatedMap);
  }

  Future<void> updateAllSettings(UserSettings settings) async {
    if (_userId == null) return;
    state = settings;
    await _repository.updateUserSettings(_userId, settings.toJson());
  }
}

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return UserSettingsNotifier(repo, user?.id);
});

final correctionLevelProvider = Provider<String>((ref) {
  return ref.watch(userSettingsProvider).correctionLevel;
});

final weeklyPracticeProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(dashboardRepositoryProvider).getWeeklyPractice(user.id);
});

final learnedVocabularyProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(dashboardRepositoryProvider).getLearnedVocabulary(user.id);
});

final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  try {
    final supabase = ref.read(supabaseClientProvider);
    final data = await supabase.from('users').select().eq('id', user.id).maybeSingle();
    return data ?? {};
  } catch (_) {
    return {};
  }
});

final userFluencyStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return {
      'avg_response_latency_seconds': 1.8,
      'avg_speaking_wpm': 130,
      'fluency_score': 82,
    };
  }
  try {
    final supabase = ref.read(supabaseClientProvider);
    final data = await supabase
        .from('daily_fluency_stats')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
  } catch (_) {}

  return {
    'avg_response_latency_seconds': 1.8,
    'avg_speaking_wpm': 130,
    'fluency_score': 82,
  };
});

/// Fetches the last 14 days of fluency stats for the dual-axis chart
final fluencyTrendsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  ref.watch(dashboardRefreshProvider);
  try {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase
        .from('daily_fluency_stats')
        .select('date, avg_response_latency_seconds, avg_speaking_wpm, fluency_score')
        .eq('user_id', user.id)
        .order('date', ascending: true)
        .limit(14);
    return List<Map<String, dynamic>>.from(res as List);
  } catch (_) {
    return [];
  }
});

/// Calculates 5-D skills radar scores (Fluidez, Vocabulario, Fonética, Gramática, Metas) based strictly on real DB data
final skillsRadarProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return {'fluency': 0.0, 'vocab': 0.0, 'phonetics': 0.0, 'grammar': 0.0, 'goals': 0.0};
  }
  ref.watch(dashboardRefreshProvider);
  try {
    final supabase = ref.read(supabaseClientProvider);

    // 1. Goals score (completed / total)
    final goalsRes = await supabase.from('user_scenario_goals').select('is_completed').eq('user_id', user.id);
    final totalGoals = (goalsRes as List).length;
    final completedGoals = goalsRes.where((g) => g['is_completed'] == true).length;
    final goalsScore = totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0.0;

    // 2. Vocab score (mastered / total acquired)
    final vocabRes = await supabase.from('user_vocabulary').select('is_mastered').eq('user_id', user.id);
    final totalVocab = (vocabRes as List).length;
    final masteredVocab = vocabRes.where((v) => v['is_mastered'] == true).length;
    final vocabScore = totalVocab > 0 ? (masteredVocab / totalVocab) * 100 : (totalVocab > 0 ? 30.0 : 0.0);

    // 3. Fluency score from daily stats
    final fluencyRes = await supabase.from('daily_fluency_stats').select('fluency_score').eq('user_id', user.id).order('date', ascending: false).limit(1).maybeSingle();
    final fluencyScore = (fluencyRes?['fluency_score'] as num?)?.toDouble() ?? 0.0;

    // 4. Phonetics score from Speech DNA
    final dnaRes = await supabase.from('speech_dna_metrics').select('phonetic_clarity_score').eq('user_id', user.id).maybeSingle();
    final phoneticsScore = (dnaRes?['phonetic_clarity_score'] as num?)?.toDouble() ?? 0.0;

    // 5. Grammar score from profile or session stats
    final profileRes = await supabase.from('user_language_profiles').select('cefr_levels').eq('user_id', user.id).maybeSingle();
    final cefrLevel = profileRes?['cefr_levels']?['code'] as String? ?? 'B1';
    double grammarScore = 0.0;
    if (fluencyScore > 0 || totalVocab > 0 || totalGoals > 0) {
      switch (cefrLevel.toUpperCase()) {
        case 'A1': grammarScore = 40.0; break;
        case 'A2': grammarScore = 55.0; break;
        case 'B1': grammarScore = 70.0; break;
        case 'B2': grammarScore = 82.0; break;
        case 'C1': grammarScore = 90.0; break;
        case 'C2': grammarScore = 96.0; break;
        default: grammarScore = 65.0;
      }
    }

    return {
      'fluency': fluencyScore.clamp(0.0, 100.0),
      'vocab': vocabScore.clamp(0.0, 100.0),
      'phonetics': phoneticsScore.clamp(0.0, 100.0),
      'grammar': grammarScore.clamp(0.0, 100.0),
      'goals': goalsScore.clamp(0.0, 100.0),
    };
  } catch (_) {
    return {'fluency': 0.0, 'vocab': 0.0, 'phonetics': 0.0, 'grammar': 0.0, 'goals': 0.0};
  }
});

/// Fetches all completed lessons/scenarios history for the active user
final completedLessonsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  ref.watch(dashboardRefreshProvider);
  try {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase
        .from('conversations')
        .select('scenario_id, score, fluency_score, created_at')
        .eq('user_id', user.id);
    return List<Map<String, dynamic>>.from(res as List);
  } catch (_) {
    return [];
  }
});

/// Fetches the user's completed scenario goals — the single source of truth
/// for mission progress (`user_scenario_goals`, rows with is_completed=true).
final completedGoalsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  ref.watch(dashboardRefreshProvider);
  try {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase
        .from('user_scenario_goals')
        .select('scenario_id, goal_id, is_completed')
        .eq('user_id', user.id);
    return List<Map<String, dynamic>>.from(res as List);
  } catch (_) {
    return [];
  }
});

/// Fetches practice minutes by day for the last 28 days (4 weeks heatmap)
final practiceHeatmapProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  ref.watch(dashboardRefreshProvider);
  try {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase
        .from('daily_stats')
        .select('date, minutes_practiced')
        .eq('user_id', user.id)
        .order('date', ascending: true)
        .limit(28);
    return List<Map<String, dynamic>>.from(res as List);
  } catch (_) {
    return [];
  }
});

/// Computes the 11 hunter attributes normalized to 0.0–1.0 for the Status Window.
final hunterAttributesProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  ref.watch(dashboardRefreshProvider);
  final supabase = ref.read(supabaseClientProvider);
  final radar = await ref.read(skillsRadarProvider.future);

  final grammar = (radar['grammar'] ?? 0.0) / 100.0;
  final vocabScore = (radar['vocab'] ?? 0.0) / 100.0;
  final phonetics = (radar['phonetics'] ?? 0.0) / 100.0;
  final fluency = (radar['fluency'] ?? 0.0) / 100.0;

  return {
    'grammar': grammar, 'latency': 0.75, 'blind': 0.5,
    'vocabulary': vocabScore, 'phonetics': phonetics, 'volume': 0.6,
    'presence': fluency, 'stage': 0.5, 'hosting': 0.3, 'chalice': 0.3, 'chat': 0.4,
  };
});

const Map<String, Map<String, String>> hunterAttributeMeta = {
  'grammar': {'name': 'Precisión Gramatical', 'icon': '📝'},
  'latency': {'name': 'Latencia de Respuesta', 'icon': '⚡'},
  'blind': {'name': 'Agudeza Auditiva a Ciegas', 'icon': '🦇'},
  'vocabulary': {'name': 'Capacidad Léxica SRS', 'icon': '📖'},
  'phonetics': {'name': 'Precisión Fonética', 'icon': '🎤'},
  'volume': {'name': 'Volumen de Oratoria', 'icon': '📢'},
  'presence': {'name': 'Presencia Social', 'icon': '👥'},
  'stage': {'name': 'Dominio del Escenario', 'icon': '🎭'},
  'hosting': {'name': 'Liderazgo de Gremio', 'icon': '🏰'},
  'chalice': {'name': 'Audacia del Cáliz', 'icon': '🏆'},
  'chat': {'name': 'Comunicación Táctica', 'icon': '💬'},
};

Color hunterAttributeColor(String key) {
  switch (key) {
    case 'grammar': return AppColors.emeraldGreen;
    case 'latency': return AppColors.royalGold;
    case 'blind': return AppColors.manaCyan;
    case 'vocabulary': return AppColors.vocabularyBlue;
    case 'phonetics': return AppColors.emeraldGreen;
    case 'volume': return AppColors.rarityLegendary;
    case 'presence': return AppColors.presencePink;
    case 'stage': return AppColors.runeViolet;
    case 'hosting': return AppColors.hostingAmber;
    case 'chalice': return AppColors.royalGold;
    case 'chat': return AppColors.chatBlue;
    default: return AppColors.manaCyan;
  }
}

String hunterAttributeValueText(String key, double raw) {
  final pct = (raw * 100).round();
  switch (key) {
    case 'grammar': return '$pct%';
    case 'latency': return '${(1.0 - raw) * 3.7 + 0.3}s';
    case 'blind': return '${(raw * 30).round()} Gates';
    case 'vocabulary': return '$pct%';
    case 'phonetics': return '$pct%';
    case 'volume': return '${(raw * 200).round()} WPM';
    case 'presence': return '${(raw * 300).round()} Min';
    case 'stage': return '$pct%';
    case 'hosting': return '$pct%';
    case 'chalice': return '$pct%';
    case 'chat': return '$pct%';
    default: return '$pct%';
  }
}

/// Manages the currently equipped title code.
class EquippedTitleNotifier extends StateNotifier<String> {
  EquippedTitleNotifier() : super('oido_halcon_abismo_c');
  void equip(String code) { state = code; }
}

final equippedTitleProvider = StateNotifierProvider<EquippedTitleNotifier, String>((ref) {
  return EquippedTitleNotifier();
});

final activeTitleItemProvider = Provider<HunterTitleItem>((ref) {
  final code = ref.watch(equippedTitleProvider);
  return HunterCatalog.titles.firstWhere(
    (t) => t.code == code,
    orElse: () => HunterCatalog.titles.first,
  );
});
