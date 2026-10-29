import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import 'package:tutorsaas/core/utils/retry.dart';
import '../../../../core/cache/cached_future_controller.dart';
import '../../../../core/cache/json_disk_cache.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/models/hunter_catalog.dart';
import '../../data/models/hunter_skill_titles.dart';
import '../../domain/models/aura_system.dart';
import '../../domain/models/daily_goal_progress.dart';
import '../../domain/models/user_settings.dart';
import '../../../economy/presentation/providers/economy_providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return DashboardRepositoryImpl(supabaseClient);
});

final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

/// P-23 (#108): progreso de la meta diaria calculado en servidor.
///
/// Lee `practice_sessions` (minutos reales de hoy) y `user_settings`
/// (`daily_goal_minutes`). Depende de `userSettingsProvider` para que el cambio
/// de meta en Ajustes se refleje al instante, sin recargar la pantalla.
final dailyGoalProgressProvider = FutureProvider.autoDispose<DailyGoalProgress?>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  ref.watch(dashboardRefreshProvider);
  ref.watch(userSettingsProvider);
  try {
    final tzOffset = DateTime.now().timeZoneOffset.inMinutes;
    final res = await ref
        .watch(supabaseClientProvider)
        .rpc(
          'get_daily_goal_progress',
          params: {'p_tz_offset_minutes': tzOffset},
        );
    if (res is Map) {
      return DailyGoalProgress.fromMap(Map<String, dynamic>.from(res));
    }
    return null;
  } catch (e, st) {
    ErrorTracker.logSilent(
      'lib/features/dashboard/presentation/providers/dashboard_providers.dart:daily_goal',
      e,
      stackTrace: st,
    );
    return null;
  }
});

/// Marca la celebración de la meta diaria. Devuelve `true` solo la primera vez
/// del día (el servidor lo garantiza con una clave única usuario+día).
final dailyGoalCelebrationProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    try {
      final tzOffset = DateTime.now().timeZoneOffset.inMinutes;
      final res = await ref
          .read(supabaseClientProvider)
          .rpc(
            'claim_daily_goal_celebration',
            params: {'p_tz_offset_minutes': tzOffset},
          );
      if (res is Map) return res['claimed'] == true;
      return false;
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/dashboard/presentation/providers/dashboard_providers.dart:daily_goal_claim',
        e,
        stackTrace: st,
      );
      return false;
    }
  };
});

/// Issue #24: palabras pendientes de repaso (SM-2).
final dueVocabularyProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const [];
      return ref.watch(dashboardRepositoryProvider).getDueVocabulary(user.id);
    });

/// Issue #74: evidencia de aprendizaje calculada en servidor
/// (`learning_evidence`): retención a 7 días, palabras dominadas y misiones.
final learningEvidenceProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const {};
      try {
        final res = await ref
            .watch(supabaseClientProvider)
            .rpc('learning_evidence');
        return Map<String, dynamic>.from(res as Map);
      } catch (e) {
        debugPrint('learning_evidence failed: $e');
        return const {};
      }
    });

/// P-19: si la ultima consulta de progreso fallo, la UI muestra un banner y
/// el ultimo progreso bueno (memoria + disco) en vez de ceros.
final progressOfflineProvider = StateProvider<bool>((ref) => false);
final progressCachedAtProvider = StateProvider<DateTime?>((ref) => null);

String _progressCacheKey(String userId) => 'dashboard_progress_$userId';

final userProgressProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  ref.keepAlive();
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

  final repo = ref.read(dashboardRepositoryProvider);
  try {
    final fresh = await retryWithBackoff(() => repo.getUserProgress(user.id));
    final now = DateTime.now();
    await JsonDiskCache.writeString(
      _progressCacheKey(user.id),
      jsonEncode({...fresh, '_cached_at': now.toIso8601String()}),
    );
    ref.read(progressOfflineProvider.notifier).state = false;
    ref.read(progressCachedAtProvider.notifier).state = now;
    return fresh;
  } catch (e, st) {
    ErrorTracker.logSilent('dashboard.userProgress', e, stackTrace: st);
    ref.read(progressOfflineProvider.notifier).state = true;
    final raw = await JsonDiskCache.readString(_progressCacheKey(user.id));
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final cached = Map<String, dynamic>.from(decoded);
          final at = DateTime.tryParse(
            cached.remove('_cached_at') as String? ?? '',
          );
          ref.read(progressCachedAtProvider.notifier).state = at;
          return cached;
        }
      } catch (parseError, parseStack) {
        ErrorTracker.logSilent(
          'dashboard.progressCache',
          parseError,
          stackTrace: parseStack,
        );
      }
    }
    rethrow;
  }
});

final recommendedLessonsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return [];
      // Watch userProgressProvider to reload recommended lessons when user progress/onboarding state changes
      ref.watch(userProgressProvider);
      // Watch dashboardRefreshProvider to reload after endSession
      ref.watch(dashboardRefreshProvider);
      return ref
          .read(dashboardRepositoryProvider)
          .getRecommendedLessons(user.id);
    });

final userAchievementsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
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

  UserSettingsNotifier(this._repository, this._userId)
    : super(UserSettings.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_userId == null) return;
    try {
      final data = await _repository.getUserSettings(_userId);
      if (data.isNotEmpty) {
        state = UserSettings.fromJson(data);
      }
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/dashboard/presentation/providers/dashboard_providers.dart:94',
        e,
        stackTrace: st,
      );
    }
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

final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
      final repo = ref.watch(dashboardRepositoryProvider);
      final user = ref.watch(currentUserProvider);
      return UserSettingsNotifier(repo, user?.id);
    });

final correctionLevelProvider = Provider<String>((ref) {
  return ref.watch(userSettingsProvider).correctionLevel;
});

final weeklyPracticeProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return [];
      return ref.read(dashboardRepositoryProvider).getWeeklyPractice(user.id);
    });

final learnedVocabularyProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return [];
      return ref
          .read(dashboardRepositoryProvider)
          .getLearnedVocabulary(user.id);
    });

final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  ref.keepAlive();
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  try {
    final supabase = ref.read(supabaseClientProvider);
    final data = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    // P-11i: la clase vive en user_language_profiles; avatar_url es solo foto.
    final lang = await supabase
        .from('user_language_profiles')
        .select('character_class')
        .eq('user_id', user.id)
        .maybeSingle();
    return {
      ...?data,
      if (lang?['character_class'] != null)
        'character_class': lang!['character_class'],
    };
  } catch (_) {
    return {};
  }
});

final userFluencyStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
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
  } catch (e, st) {
    ErrorTracker.logSilent(
      'lib/features/dashboard/presentation/providers/dashboard_providers.dart:169',
      e,
      stackTrace: st,
    );
  }

  return {
    'avg_response_latency_seconds': 1.8,
    'avg_speaking_wpm': 130,
    'fluency_score': 82,
  };
});

/// Fetches the last 14 days of fluency stats for the dual-axis chart
final fluencyTrendsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return [];
      ref.watch(dashboardRefreshProvider);
      try {
        final supabase = ref.read(supabaseClientProvider);
        final res = await supabase
            .from('daily_fluency_stats')
            .select(
              'date, avg_response_latency_seconds, avg_speaking_wpm, fluency_score',
            )
            .eq('user_id', user.id)
            .order('date', ascending: true)
            .limit(14);
        return List<Map<String, dynamic>>.from(res as List);
      } catch (_) {
        return [];
      }
    });

/// Calculates 5-D skills radar scores (Fluidez, Vocabulario, Fonética, Gramática, Metas) based strictly on real DB data
final skillsRadarProvider = FutureProvider.autoDispose<Map<String, double>>((
  ref,
) async {
  ref.keepAlive();
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return {
      'fluency': 0.0,
      'vocab': 0.0,
      'phonetics': 0.0,
      'grammar': 0.0,
      'goals': 0.0,
    };
  }
  ref.watch(dashboardRefreshProvider);
  try {
    final supabase = ref.read(supabaseClientProvider);

    // Las 5 queries corren EN PARALELO (antes secuenciales): el radar es un
    // cuello de botella usado por auraState, hunterAttributes y endSession.
    final results = await Future.wait<dynamic>([
      supabase
          .from('user_scenario_goals')
          .select('is_completed')
          .eq('user_id', user.id),
      supabase
          .from('user_vocabulary')
          .select('is_mastered')
          .eq('user_id', user.id),
      supabase
          .from('daily_fluency_stats')
          .select('fluency_score')
          .eq('user_id', user.id)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle(),
      supabase
          .from('speech_dna_metrics')
          .select('phonetic_clarity_score')
          .eq('user_id', user.id)
          .maybeSingle(),
      supabase
          .from('user_language_profiles')
          .select('cefr_levels')
          .eq('user_id', user.id)
          .maybeSingle(),
    ]);

    // Oracle turns: scores reales de la última evaluación del Oráculo
    // (pronunciación, fluidez, gramática, vocabulario, comprensión, naturalidad).
    Map<String, dynamic>? oracleTurn;
    try {
      final assessment = await supabase
          .from('oracle_assessments')
          .select('id')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (assessment != null) {
        oracleTurn = await supabase
            .from('oracle_turns')
            .select(
              'pronunciation_score, fluency_score, grammar_score, vocabulary_score, comprehension_score, naturalness_score',
            )
            .eq('assessment_id', assessment['id'])
            .order('turn_order', ascending: false)
            .limit(1)
            .maybeSingle();
      }
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/dashboard/presentation/providers/dashboard_providers.dart:258',
        e,
        stackTrace: st,
      );
    }

    // 1. Goals score (completed / total)
    final goalsRes = (results[0] as List).cast<Map<String, dynamic>>();
    final totalGoals = goalsRes.length;
    final completedGoals = goalsRes
        .where((g) => g['is_completed'] == true)
        .length;
    final goalsScore = totalGoals > 0
        ? (completedGoals / totalGoals) * 100
        : 0.0;

    // 2. Vocab score (mastered / total acquired)
    final vocabRes = (results[1] as List).cast<Map<String, dynamic>>();
    final totalVocab = vocabRes.length;
    final masteredVocab = vocabRes
        .where((v) => v['is_mastered'] == true)
        .length;
    final vocabScore = totalVocab > 0
        ? (masteredVocab / totalVocab) * 100
        : (totalVocab > 0 ? 30.0 : 0.0);

    // 3. Fluency score from daily stats
    final fluencyRes = results[2] as Map<String, dynamic>?;
    final fluencyScore =
        (fluencyRes?['fluency_score'] as num?)?.toDouble() ?? 0.0;

    // 4. Phonetics score from Speech DNA
    final dnaRes = results[3] as Map<String, dynamic>?;
    final phoneticsScore =
        (dnaRes?['phonetic_clarity_score'] as num?)?.toDouble() ?? 0.0;

    // 5. Scores reales del último turno del Oráculo (6 ejes).
    //    Fuente real: oracle_turns (evaluación conversacional por IA).
    final pronunciationScore =
        (oracleTurn?['pronunciation_score'] as num?)?.toDouble() ?? 0.0;
    final oracleFluencyScore =
        (oracleTurn?['fluency_score'] as num?)?.toDouble() ?? 0.0;
    final grammarScore =
        (oracleTurn?['grammar_score'] as num?)?.toDouble() ?? 0.0;
    final vocabularyScore =
        (oracleTurn?['vocabulary_score'] as num?)?.toDouble() ?? 0.0;
    final comprehensionScore =
        (oracleTurn?['comprehension_score'] as num?)?.toDouble() ?? 0.0;
    final naturalnessScore =
        (oracleTurn?['naturalness_score'] as num?)?.toDouble() ?? 0.0;

    // Fallback por fuente: si el Oráculo no tiene datos, se usan las métricas
    // diarias (fluidez/daily, fonética/dna) para no mostrar 0 inventado.
    final effFluency = oracleFluencyScore > 0
        ? oracleFluencyScore
        : fluencyScore;
    final effPhonetics = pronunciationScore > 0
        ? pronunciationScore
        : phoneticsScore;
    final effVocab = vocabularyScore > 0 ? vocabularyScore : vocabScore;

    return {
      'fluency': effFluency.clamp(0.0, 100.0),
      'vocab': effVocab.clamp(0.0, 100.0),
      'phonetics': effPhonetics.clamp(0.0, 100.0),
      'grammar': grammarScore.clamp(0.0, 100.0),
      'goals': goalsScore.clamp(0.0, 100.0),
      'comprehension': comprehensionScore.clamp(0.0, 100.0),
      'naturalness': naturalnessScore.clamp(0.0, 100.0),
    };
  } catch (_) {
    return {
      'fluency': 0.0,
      'vocab': 0.0,
      'phonetics': 0.0,
      'grammar': 0.0,
      'goals': 0.0,
      'comprehension': 0.0,
      'naturalness': 0.0,
    };
  }
});

/// Fetches all completed lessons/scenarios history for the active user
final completedLessonsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return [];
      ref.watch(dashboardRefreshProvider);
      try {
        final supabase = ref.read(supabaseClientProvider);
        final res = await supabase
            .from('conversations')
            .select('id, scenario_id, started_at')
            .eq('user_id', user.id);
        return List<Map<String, dynamic>>.from(res as List);
      } catch (_) {
        return [];
      }
    });

/// Fetches the user's completed scenario goals — the single source of truth
/// for mission progress (`user_scenario_goals`, rows with is_completed=true).
final completedGoalsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
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

/// Leaderboard real de XP desde la RPC `get_leaderboard` (Top N).
final leaderboardProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      ref.watch(dashboardRefreshProvider);
      try {
        final supabase = ref.read(supabaseClientProvider);
        final res = await supabase.rpc(
          'get_leaderboard',
          params: {'p_limit': 10},
        );
        return List<Map<String, dynamic>>.from(res as List);
      } catch (_) {
        return [];
      }
    });

/// Fetches practice minutes by day for the last 28 days (4 weeks heatmap)
final practiceHeatmapProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
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

/// Manages the currently equipped title code.
class EquippedTitleNotifier extends StateNotifier<String> {
  EquippedTitleNotifier() : super('oido_halcon_abismo_c');
  void equip(String code) {
    state = code;
  }
}

final equippedTitleProvider =
    StateNotifierProvider<EquippedTitleNotifier, String>((ref) {
      return EquippedTitleNotifier();
    });

final activeTitleItemProvider = Provider<HunterTitleItem>((ref) {
  final code = ref.watch(equippedTitleProvider);
  return HunterCatalog.titles.firstWhere(
    (t) => t.code == code,
    orElse: () => HunterCatalog.titles.first,
  );
});

/// Escalera universal de prestigio (FASE B): títulos ganados con Aura.
/// Cache TTL 30 min + disco: instantánea en el cold start.
final prestigeLadderProvider =
    StateNotifierProvider<
      CachedFutureController<List<Map<String, dynamic>>>,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      final supabase = ref.read(supabaseClientProvider);
      return CachedFutureController<List<Map<String, dynamic>>>(
        ttl: const Duration(minutes: 30),
        userIdGetter: () => 'catalog',
        diskLoader: () => JsonDiskCache.readList('cache_prestige_ladder'),
        diskWriter: (data) =>
            JsonDiskCache.writeList('cache_prestige_ladder', data),
        fetcher: () async {
          try {
            final res = await supabase
                .from('prestige_ladder')
                .select(
                  'tier_code, name_es, aura_xp_threshold, min_radar, ceiling_class, segment, tier_order',
                )
                .eq('is_active', true)
                .order('tier_order', ascending: true);
            return List<Map<String, dynamic>>.from(res as List);
          } catch (_) {
            return const [];
          }
        },
      );
    });

/// Título de prestigio actual (RPC server-side: aplica aura_xp + radar + techo).
final prestigeTitleProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'tier_code': null, 'name': null};
  final repo = ref.watch(economyRepositoryProvider);
  return repo.getPrestigeTitle(user.id);
});

/// Estado del Aura del cazador (System HUD).
///
/// Regla: el Aura está bloqueada hasta superar la Etapa Básica (A1 + A2) o ser
/// acreditado ≥ B1 por el Oráculo. Una vez despierta, el poder acumula con el
/// desarrollo de habilidades (radar + racha + rango).
final auraStateProvider = FutureProvider.autoDispose<AuraSnapshot>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const AuraSnapshot(
      state: AuraState.locked,
      tier: AuraTier.latente,
      power: 0,
      basicStageProgress: 0,
      basicObjectivesDone: 0,
      basicObjectivesTotal: 0,
    );
  }

  ref.watch(dashboardRefreshProvider);
  final progress = ref.watch(userProgressProvider).value ?? {};
  final goalRows = ref.watch(completedGoalsProvider).value ?? [];
  final radar = await ref.watch(skillsRadarProvider.future);
  final auraXp = await ref.watch(auraXpProvider.future);
  final titleRes = await ref.watch(prestigeTitleProvider.future);

  final accredited = AuraSystem.accreditationLevelMet(
    progress['level_code'] as String?,
  );
  final basic = AuraSystem.basicStageCounts(goalRows);
  final awakened =
      accredited || AuraSystem.isBasicStageComplete(basic.done, basic.total);

  final power = AuraSystem.computePower(
    radar: radar,
    streak: (progress['streak'] as num?)?.toInt() ?? 0,
    cefr: (progress['level_code'] as String?) ?? 'A1',
  );

  return AuraSnapshot(
    state: awakened ? AuraState.awakened : AuraState.locked,
    tier: AuraSystem.tierFor(power),
    power: power,
    auraXp: auraXp,
    prestigeTitleName: titleRes['name'] as String?,
    basicStageProgress: basic.total > 0
        ? (basic.done / basic.total).clamp(0.0, 1.0)
        : 0,
    basicObjectivesDone: basic.done,
    basicObjectivesTotal: basic.total,
    hasRankMismatch: AuraSystem.hasRankMismatch(
      progress['level_code'] as String?,
      progress['game_rank'] as String?,
    ),
  );
});

/// Títulos de habilidad ganados por el cazador (filas de `user_titles`).
final earnedTitlesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return [];
      ref.watch(dashboardRefreshProvider);
      return ref.read(dashboardRepositoryProvider).getEarnedTitles(user.id);
    });

/// Título activo = el de mayor tier ganado (null si aún no hay ninguno).
final activeSkillTitleProvider = Provider<SkillTitle?>((ref) {
  final earned = ref.watch(earnedTitlesProvider).value ?? [];
  if (earned.isEmpty) return null;
  String? bestCode;
  var bestTier = 0;
  for (final row in earned) {
    final tier = (row['tier'] as num?)?.toInt() ?? 0;
    if (tier > bestTier) {
      bestTier = tier;
      bestCode = row['title_code'] as String?;
    }
  }
  return HunterSkillTitleCatalog.forCode(bestCode);
});

/// Métricas reales de conversación (fluidez, fonética, léxico, precisión, racha).
final titleMetricsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  ref.watch(dashboardRefreshProvider);
  return ref.read(dashboardRepositoryProvider).getConversationMetrics(user.id);
});

/// Progreso por línea de habilidad: métrica actual, título ganado y siguiente.
final titleProgressProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final earned = ref.watch(earnedTitlesProvider).value ?? [];
  final metrics = ref.watch(titleMetricsProvider).value ?? const {};

  final earnedTierByLine = <String, int>{};
  for (final row in earned) {
    final line = row['line'] as String?;
    final tier = (row['tier'] as num?)?.toInt() ?? 0;
    if (line != null && tier > (earnedTierByLine[line] ?? 0)) {
      earnedTierByLine[line] = tier;
    }
  }

  final valueByLine = <String, double>{
    'fluidez': (metrics['fluency'] as num?)?.toDouble() ?? 0,
    'fonetica': (metrics['phonetics'] as num?)?.toDouble() ?? 0,
    'lexico': (metrics['vocab'] as num?)?.toDouble() ?? 0,
    'precision': (metrics['precision'] as num?)?.toDouble() ?? 0,
    'constancia': (metrics['streak'] as num?)?.toDouble() ?? 0,
    'carisma': (metrics['carisma'] as num?)?.toDouble() ?? 0,
  };

  const order = [
    'fluidez',
    'fonetica',
    'lexico',
    'precision',
    'constancia',
    'carisma',
  ];
  const labels = {
    'fluidez': 'Fluidez',
    'fonetica': 'Fonética',
    'lexico': 'Léxico',
    'precision': 'Precisión',
    'constancia': 'Constancia',
    'carisma': 'Carisma',
  };

  final result = <Map<String, dynamic>>[];
  for (final line in order) {
    final currentValue = valueByLine[line] ?? 0;
    final earnedTier = earnedTierByLine[line] ?? 0;
    final earnedTitle = HunterSkillTitleCatalog.codeFor(line, earnedTier);
    final nextTitle = HunterSkillTitleCatalog.codeFor(line, earnedTier + 1);
    result.add({
      'line': line,
      'label': labels[line],
      'currentValue': currentValue,
      'earnedTier': earnedTier,
      'earnedTitle': earnedTitle?.name,
      'earnedCode': earnedTitle?.code,
      'nextThreshold': nextTitle?.threshold,
      'nextName': nextTitle?.name,
    });
  }
  return result;
});

/// Títulos recién ganados pendientes de mostrar (banner "TÍTULO GANADO").
final newEarnedTitlesProvider = StateProvider<List<SkillTitle>>(
  (ref) => const [],
);
