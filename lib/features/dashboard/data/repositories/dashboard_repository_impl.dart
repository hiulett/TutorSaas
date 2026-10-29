import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/models/title_evaluator.dart';
import '../../domain/models/lesson_completion.dart';
import '../../domain/services/lesson_relevance.dart';
import '../models/lesson_catalog.dart';
import '../models/hunter_skill_titles.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _supabaseClient;

  DashboardRepositoryImpl(this._supabaseClient);

  // P-19b (#163): una sola RPC devuelve progreso + logros. Cache corta para
  // que los dos providers que se reconstruyen juntos no la llamen dos veces.
  Map<String, dynamic>? _stateCache;
  DateTime? _stateAt;
  static const Duration _stateTtl = Duration(seconds: 20);

  Future<Map<String, dynamic>> _dashboardState(String userId) async {
    final cached = _stateCache;
    final at = _stateAt;
    if (cached != null &&
        at != null &&
        DateTime.now().difference(at) < _stateTtl) {
      return cached;
    }
    final res = await _supabaseClient.rpc(
      'get_dashboard_state',
      params: {'p_user_id': userId},
    );
    final map = res is Map
        ? Map<String, dynamic>.from(res)
        : <String, dynamic>{};
    _stateCache = map;
    _stateAt = DateTime.now();
    return map;
  }

  @override
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    // P-19b (#163): progreso y logros salen de la misma RPC.
    final state = await _dashboardState(userId);
    final progress = state['progress'];
    if (progress is Map) return Map<String, dynamic>.from(progress);
    throw StateError('get_dashboard_state sin progress');
  }

  @override
  Future<List<Map<String, dynamic>>> getRecommendedLessons(
    String userId,
  ) async {
    try {
      // 1. Fetch user language profile to get language_id and difficulty level
      final profileResponse = await _supabaseClient
          .from('user_language_profiles')
          .select('language_id, cefr_levels!inner(code)')
          .eq('user_id', userId)
          .maybeSingle();

      String levelCode = 'A1';
      int languageId = 1;
      if (profileResponse != null) {
        languageId = profileResponse['language_id'] as int? ?? 1;
        final cefrMap = profileResponse['cefr_levels'] as Map<String, dynamic>?;
        levelCode = cefrMap?['code'] as String? ?? 'A1';
      }

      // 2. Fetch user settings to get interests and daily goal
      final settingsResponse = await _supabaseClient
          .from('user_settings')
          .select('interests, daily_goal_minutes')
          .eq('user_id', userId)
          .maybeSingle();

      final List<String> settingsInterests = List<String>.from(
        settingsResponse?['interests'] ?? [],
      );
      final int dailyGoalMinutes =
          settingsResponse?['daily_goal_minutes'] as int? ?? 15;

      // P-40 (#125): el onboarding también guarda los intereses en el perfil
      // pedagógico (`user_ai_profiles.focus_areas`). Se unen ambos orígenes:
      // antes solo se leía `user_settings.interests`, que en producción está
      // vacío, así que la selección por intereses nunca se aplicaba.
      final List<String> userInterests = await _loadInterests(
        userId,
        settingsInterests,
      );

      // 3. Query Supabase public.scenarios matching language_id and difficulty_level
      List<Map<String, dynamic>> scenarios = [];
      try {
        final query = _supabaseClient
            .from('scenarios')
            .select(
              'id, title, description, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, language_id',
            )
            .eq('difficulty_level', levelCode)
            .eq('language_id', languageId)
            .eq('is_active', true);

        final scenariosResponse = await query;
        scenarios = List<Map<String, dynamic>>.from(scenariosResponse);
        for (final sc in scenarios) {
          LessonCatalog.updateCatalogFromMap(sc);
        }
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/dashboard/data/repositories/dashboard_repository_impl.dart:117',
          e,
          stackTrace: st,
        );
      }

      // P-40 (#125): prioriza las lecciones que tocan los intereses del alumno
      // (categoría, título o descripción) y, a igualdad, las que se acercan a su
      // meta diaria. Sin intereses el orden es solo por duración.
      if (scenarios.isNotEmpty) {
        LessonRelevance.sortForUser(
          scenarios,
          interests: userInterests,
          dailyGoalMinutes: dailyGoalMinutes,
        );
      }

      // 4. Query completed goals & phrases from DB to calculate real progress and 1-3 Stars mastery
      final Map<String, int> completedGoalsCount = {};
      final Map<String, int> completedPhrasesCount = {};

      try {
        final goalsRes = await _supabaseClient
            .from('user_scenario_goals')
            .select('scenario_id')
            .eq('user_id', userId)
            .eq('is_completed', true);

        for (final item in goalsRes as List) {
          final sid = item['scenario_id'] as String?;
          if (sid != null) {
            completedGoalsCount[sid] = (completedGoalsCount[sid] ?? 0) + 1;
          }
        }

        final phrasesRes = await _supabaseClient
            .from('user_scenario_phrases')
            .select('scenario_id')
            .eq('user_id', userId)
            .eq('is_completed', true);

        for (final item in phrasesRes as List) {
          final sid = item['scenario_id'] as String?;
          if (sid != null) {
            completedPhrasesCount[sid] = (completedPhrasesCount[sid] ?? 0) + 1;
          }
        }
      } catch (e) {
        debugPrint('[Progress] Error loading goals/phrases: $e');
      }

      if (scenarios.isNotEmpty) {
        final mappedList = scenarios.map((s) {
          final sid = s['id'] as String?;
          final rawGoals = s['goals'] as List? ?? [];
          final rawPhrases = s['useful_phrases'] as List? ?? [];
          final totalGoals = rawGoals.isNotEmpty ? rawGoals.length : 3;
          final totalPhrases = rawPhrases.isNotEmpty ? rawPhrases.length : 4;

          final goalsDone = sid != null ? (completedGoalsCount[sid] ?? 0) : 0;
          final phrasesDone = sid != null
              ? (completedPhrasesCount[sid] ?? 0)
              : 0;

          final bool isCompleted = LessonCompletion.isPassed(
            goalsDone,
            totalGoals,
          );
          final double progress = (goalsDone / totalGoals).clamp(0.0, 1.0);

          // Estrellas derivadas de la misma regla que el desbloqueo (P-38).
          final stars = LessonCompletion.stars(
            completed: goalsDone,
            total: totalGoals,
            phrasesUsed: phrasesDone,
            phrasesTotal: totalPhrases,
          );

          return {
            ...s,
            'progress': progress,
            'is_completed': isCompleted,
            'stars': stars,
            'goals_done': goalsDone,
            'total_goals': totalGoals,
            'phrases_done': phrasesDone,
            'total_phrases': totalPhrases,
          };
        }).toList();

        // Sort so that the uncompleted or unmastered lessons appear first
        mappedList.sort((a, b) {
          final aComp = a['is_completed'] as bool? ?? false;
          final bComp = b['is_completed'] as bool? ?? false;
          if (!aComp && bComp) return -1;
          if (aComp && !bComp) return 1;

          final aStars = a['stars'] as int? ?? 0;
          final bStars = b['stars'] as int? ?? 0;
          return aStars.compareTo(bStars);
        });

        return mappedList.take(15).toList();
      }

      // Fallback if no DB scenarios are present
      final targetLangCode = _getLanguageCodeFromId(languageId);
      final filteredCatalog = LessonCatalog.catalog.where((l) {
        if (targetLangCode != null && l.targetLanguageCode != targetLangCode) {
          return false;
        }
        return l.level == levelCode;
      }).toList();

      return filteredCatalog
          .take(15)
          .map(
            (l) => {
              'id': l.id,
              'title': l.title,
              'description': l.description,
              'difficulty_level': l.level,
              'category': l.category,
              'progress': 0.0,
              'is_completed': false,
              'stars': 0,
              'icon_key': l.iconKey,
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// P-40 (#125): intereses del alumno desde `user_settings` **y**
  /// `user_ai_profiles.focus_areas` (el onboarding escribe ambos; en producción
  /// `user_settings.interests` está vacío, así que sin esta unión la selección
  /// por intereses nunca se aplicaba).
  Future<List<String>> _loadInterests(
    String userId,
    List<String> settingsInterests,
  ) async {
    final seen = <String>{};
    final result = <String>[];
    void add(String? raw) {
      final value = raw?.trim() ?? '';
      if (value.isEmpty) return;
      if (!seen.add(value.toLowerCase())) return;
      result.add(value);
    }

    for (final interest in settingsInterests) {
      add(interest);
    }

    try {
      final profile = await _supabaseClient
          .from('user_ai_profiles')
          .select('focus_areas')
          .eq('user_id', userId)
          .maybeSingle();
      final focusAreas = profile?['focus_areas'];
      if (focusAreas is List) {
        for (final area in focusAreas) {
          if (area is String) add(area);
        }
      }
    } catch (e) {
      debugPrint('No se pudieron leer los intereses del perfil de IA: $e');
    }

    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    try {
      final state = await _dashboardState(userId);
      final achievements = state['achievements'];
      if (achievements is List) {
        return achievements
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      return [];
    } catch (e, st) {
      ErrorTracker.logSilent(
        'dashboard.getUserAchievements',
        e,
        stackTrace: st,
      );
      return [];
    }
  }

  @override
  Future<String> getCorrectionLevel(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_settings')
          .select('correction_level')
          .eq('user_id', userId)
          .maybeSingle();
      return response?['correction_level'] as String? ?? 'short';
    } catch (_) {
      return 'short';
    }
  }

  @override
  Future<void> updateCorrectionLevel(String userId, String level) async {
    try {
      await _supabaseClient.from('user_settings').upsert({
        'user_id': userId,
        'correction_level': level,
      });
    } catch (e) {
      // Log or ignore database error in fallback/offline modes
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyPractice(String userId) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final response = await _supabaseClient
          .from('daily_stats')
          .select('date, minutes_practiced')
          .eq('user_id', userId)
          .gte('date', sevenDaysAgo.toIso8601String().split('T').first)
          .lte('date', now.toIso8601String().split('T').first);

      final List<Map<String, dynamic>> rawData =
          List<Map<String, dynamic>>.from(response);

      // Create map of date to minutes
      final Map<String, int> minutesByDate = {};
      for (final item in rawData) {
        final dateStr = item['date'] as String;
        final minutes = item['minutes_practiced'] as int? ?? 0;
        minutesByDate[dateStr] = minutes;
      }

      // Generate the last 7 days of practice
      final List<Map<String, dynamic>> results = [];
      final List<String> weekdayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

      int maxMinutes =
          15; // default minimum max value to calculate height factor
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dateStr = day.toIso8601String().split('T').first;
        final minutes = minutesByDate[dateStr] ?? 0;
        if (minutes > maxMinutes) {
          maxMinutes = minutes;
        }
      }

      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dateStr = day.toIso8601String().split('T').first;
        final minutes = minutesByDate[dateStr] ?? 0;
        // Day index in Dart starts at 1 for Monday, 7 for Sunday
        final weekdayIndex = day.weekday - 1;

        results.add({
          'day': weekdayNames[weekdayIndex],
          'minutes': minutes,
          'heightFactor': minutes / maxMinutes,
        });
      }

      return results;
    } catch (_) {
      // Fallback
      return [
        {'day': 'L', 'minutes': 0, 'heightFactor': 0.0},
        {'day': 'M', 'minutes': 0, 'heightFactor': 0.0},
        {'day': 'M', 'minutes': 0, 'heightFactor': 0.0},
        {'day': 'J', 'minutes': 0, 'heightFactor': 0.0},
        {'day': 'V', 'minutes': 0, 'heightFactor': 0.0},
        {'day': 'S', 'minutes': 0, 'heightFactor': 0.0},
        {'day': 'D', 'minutes': 0, 'heightFactor': 0.0},
      ];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLearnedVocabulary(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_vocabulary')
          .select(
            'times_seen, vocabulary_items(word, translation, part_of_speech)',
          )
          .eq('user_id', userId)
          .order('last_seen_at', ascending: false);

      final List<Map<String, dynamic>> results = [];
      for (final item in response) {
        final vocab = item['vocabulary_items'] as Map<String, dynamic>?;
        if (vocab != null) {
          results.add({
            'word': vocab['word'] as String? ?? '',
            'translation': vocab['translation'] as String? ?? '',
            'category': vocab['part_of_speech'] as String? ?? 'Vocabulario',
          });
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getUserSettings(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response ?? {};
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> updateUserSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    // Remove fields that don't belong in the user_settings table
    final cleanSettings = Map<String, dynamic>.from(settings);
    cleanSettings.remove('id');

    await _supabaseClient.from('user_settings').upsert({
      'user_id': userId,
      ...cleanSettings,
    }, onConflict: 'user_id');
  }

  @override
  Future<void> logPracticeSession(String userId, int minutes) async {
    try {
      // 1. Get user language_id
      final profile = await _supabaseClient
          .from('user_language_profiles')
          .select('language_id')
          .eq('user_id', userId)
          .maybeSingle();
      final langId = profile?['language_id'] as int? ?? 1;

      // 2. Query today's daily stats entry
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final existing = await _supabaseClient
          .from('daily_stats')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();

      if (existing != null) {
        final currentMins = existing['minutes_practiced'] as int? ?? 0;
        final currentConv = existing['conversations_count'] as int? ?? 0;
        await _supabaseClient
            .from('daily_stats')
            .update({
              'minutes_practiced': currentMins + minutes,
              'conversations_count': currentConv + 1,
            })
            .eq('id', existing['id']);
      } else {
        await _supabaseClient.from('daily_stats').insert({
          'user_id': userId,
          'language_id': langId,
          'date': todayStr,
          'minutes_practiced': minutes,
          'conversations_count': 1,
          'words_learned': 0,
          'xp_earned': minutes * 10,
        });
      }

      // La racha y los minutos los aplica la RPC register_practice (servidor):
      // el trigger guard_language_profile descarta estas escrituras del cliente.
    } catch (e) {
      // Log or ignore database error
    }
  }

  @override
  Future<void> saveVocabularyFromSession(
    String userId,
    List<String> userTexts,
  ) async {
    try {
      final Set<String> words = {};
      final RegExp wordRegExp = RegExp(r'\b[a-zA-Z]{4,15}\b');
      for (final text in userTexts) {
        final matches = wordRegExp.allMatches(text.toLowerCase());
        for (final match in matches) {
          final word = match.group(0);
          if (word != null) {
            words.add(word);
          }
        }
      }

      if (words.isEmpty) return;

      final profile = await _supabaseClient
          .from('user_language_profiles')
          .select('language_id')
          .eq('user_id', userId)
          .maybeSingle();
      final langId = profile?['language_id'] as int? ?? 1;

      final Map<String, String> commonTranslations = {
        'hello': 'hola',
        'world': 'mundo',
        'please': 'por favor',
        'thank': 'gracias',
        'thanks': 'gracias',
        'sorry': 'lo siento',
        'happy': 'feliz',
        'friend': 'amigo',
        'house': 'casa',
        'school': 'escuela',
        'teacher': 'profesor',
        'student': 'estudiante',
        'english': 'inglés',
        'speak': 'hablar',
        'write': 'escribir',
        'read': 'leer',
        'learn': 'aprender',
        'conversation': 'conversación',
        'practice': 'practicar',
        'sentence': 'frase',
        'tutor': 'tutor',
        'understand': 'entender',
        'correction': 'corrección',
        'mistake': 'error',
        'grammar': 'gramática',
        'vocabulary': 'vocabulario',
        'level': 'nivel',
        'settings': 'ajustes',
        'profile': 'perfil',
        'save': 'guardar',
        'changes': 'cambios',
        'goal': 'meta',
        'weekly': 'semanal',
        'streak': 'racha',
        'daily': 'diario',
      };

      for (final word in words.take(8)) {
        var existingVocab = await _supabaseClient
            .from('vocabulary_items')
            .select()
            .eq('language_id', langId)
            .eq('word', word)
            .maybeSingle();

        late final String vocabId;

        if (existingVocab == null) {
          final translation = commonTranslations[word] ?? word;
          final insertRes = await _supabaseClient
              .from('vocabulary_items')
              .insert({
                'language_id': langId,
                'word': word,
                'translation': translation,
                'part_of_speech': word.endsWith('ly')
                    ? 'Adverbio'
                    : (word.endsWith('ing') || word.endsWith('ed')
                          ? 'Verbo'
                          : 'Sustantivo'),
                'native_language': 'es',
                'difficulty_level': 'A2',
              })
              .select('id')
              .single();
          vocabId = insertRes['id'] as String;
        } else {
          vocabId = existingVocab['id'] as String;
        }

        final existingUserVocab = await _supabaseClient
            .from('user_vocabulary')
            .select()
            .eq('user_id', userId)
            .eq('vocabulary_id', vocabId)
            .maybeSingle();

        if (existingUserVocab == null) {
          await _supabaseClient.from('user_vocabulary').insert({
            'user_id': userId,
            'vocabulary_id': vocabId,
            'times_seen': 1,
            'times_correct': 1,
            'ease_factor': 2.5,
            'interval_days': 1,
            'next_review_at': DateTime.now()
                .add(const Duration(days: 1))
                .toIso8601String(),
            'last_seen_at': DateTime.now().toIso8601String(),
          });
        } else {
          final currentSeen = existingUserVocab['times_seen'] as int? ?? 0;
          await _supabaseClient
              .from('user_vocabulary')
              .update({
                'times_seen': currentSeen + 1,
                'last_seen_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existingUserVocab['id']);
        }
      }
    } catch (_) {
      // Ignore
    }
  }

  @override
  Future<void> updateVocabularySrsScore(
    String userId,
    String vocabularyId,
    double qualityScore, {
    String cardType = 'recognition',
  }) async {
    // Issue #74: el SM-2 y el registro del repaso se calculan en servidor
    // (record_vocabulary_review) para que la evidencia de retención no dependa
    // de lo que el cliente afirme. La RPC valida la identidad con auth.uid().
    // Issue #78: `cardType` distingue reconocimiento de producción; solo la
    // producción cuenta para `mastered`.
    try {
      await _supabaseClient.rpc(
        'record_vocabulary_review',
        params: {
          'p_vocabulary_id': vocabularyId,
          'p_quality': qualityScore,
          'p_card_type': cardType,
        },
      );
    } catch (e) {
      debugPrint('record_vocabulary_review failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDueVocabulary(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      // Issue #24: antes `next_review_at` solo se escribía; nunca se consultaba.
      final res = await _supabaseClient
          .from('user_vocabulary')
          .select(
            'id, vocabulary_id, next_review_at, interval_days, vocabulary_items:vocabulary_id(word, translation)',
          )
          .eq('user_id', userId)
          .or('next_review_at.is.null,next_review_at.lte.$nowIso')
          .order('next_review_at', ascending: true, nullsFirst: true)
          .limit(limit);

      return (res as List)
          .map((row) {
            final map = Map<String, dynamic>.from(row as Map);
            final vocab =
                (map['vocabulary_items'] as Map?)?.cast<String, dynamic>() ??
                const {};
            return <String, dynamic>{
              'id': map['id'],
              'vocabulary_id': map['vocabulary_id'],
              'word': vocab['word'] ?? '',
              'translation': vocab['translation'] ?? '',
              'interval_days': map['interval_days'] ?? 1,
            };
          })
          .where((m) => (m['word'] as String).isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('getDueVocabulary error: $e');
      return const [];
    }
  }

  @override
  Future<void> updateUserProfile(
    String userId, {
    String? displayName,
    String? avatarUrl,
    String? nativeLanguage,
    String? bio,
    int? strStat,
    int? intStat,
    int? dexStat,
    int? lukStat,
    String? equippedTitleCode,
  }) async {
    // equipped_title_code es canónico en user_language_profiles (no en users).
    if (equippedTitleCode != null) {
      try {
        await _supabaseClient
            .from('user_language_profiles')
            .update({'equipped_title_code': equippedTitleCode})
            .eq('user_id', userId);
      } catch (_) {
        // Ignorar fallos del título; el resto del perfil continúa.
      }
    }

    final Map<String, dynamic> updates = {};
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (nativeLanguage != null) updates['native_language'] = nativeLanguage;
    if (bio != null) updates['bio'] = bio;
    if (strStat != null) updates['str_stat'] = strStat;
    if (intStat != null) updates['int_stat'] = intStat;
    if (dexStat != null) updates['dex_stat'] = dexStat;
    if (lukStat != null) updates['luk_stat'] = lukStat;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _supabaseClient.from('users').update(updates).eq('id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getEarnedTitles(String userId) async {
    try {
      final res = await _supabaseClient
          .from('user_titles')
          .select('line, title_code, tier, earned_at')
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getConversationMetrics(String userId) async {
    try {
      return await _fetchConversationMetrics(userId);
    } catch (_) {
      return {
        'fluency': 0.0,
        'phonetics': 0.0,
        'vocab': 0,
        'precision': 0.0,
        'streak': 0,
      };
    }
  }

  /// Lee las métricas reales de conversación del cazador.
  Future<Map<String, dynamic>> _fetchConversationMetrics(String userId) async {
    double fluency = 0;
    final fluencyRes = await _supabaseClient
        .from('daily_fluency_stats')
        .select('fluency_score')
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();
    if (fluencyRes != null) {
      fluency = (fluencyRes['fluency_score'] as num?)?.toDouble() ?? 0;
    }

    double phonetics = 0;
    final dnaRes = await _supabaseClient
        .from('speech_dna_metrics')
        .select('phonetic_clarity_score')
        .eq('user_id', userId)
        .maybeSingle();
    if (dnaRes != null) {
      phonetics = (dnaRes['phonetic_clarity_score'] as num?)?.toDouble() ?? 0;
    }

    int vocab = 0;
    final vocabRes = await _supabaseClient
        .from('user_vocabulary')
        .select('id')
        .eq('user_id', userId)
        .eq('is_mastered', true);
    vocab = (vocabRes as List).length;

    // Precisión: proxy por nivel CEFR (coherente con el radar de habilidades).
    double precision = 0;
    final profileRes = await _supabaseClient
        .from('user_language_profiles')
        .select('cefr_levels(code)')
        .eq('user_id', userId)
        .maybeSingle();
    final cefr =
        (profileRes?['cefr_levels'] as Map<String, dynamic>?)?['code']
            as String?;
    switch ((cefr ?? 'A1').toUpperCase()) {
      case 'PRE-A1':
        precision = 30;
        break;
      case 'A2':
        precision = 55;
        break;
      case 'B1':
        precision = 70;
        break;
      case 'B2':
        precision = 82;
        break;
      case 'C1':
        precision = 90;
        break;
      case 'C2':
        precision = 96;
        break;
      default:
        precision = 40; // A1
    }

    int streak = 0;
    final streakRes = await _supabaseClient
        .from('user_language_profiles')
        .select('current_streak, carisma_score')
        .eq('user_id', userId)
        .maybeSingle();
    if (streakRes != null) {
      streak = (streakRes['current_streak'] as num?)?.toInt() ?? 0;
    }
    final double carisma =
        (streakRes?['carisma_score'] as num?)?.toDouble() ?? 0;

    return {
      'fluency': fluency,
      'phonetics': phonetics,
      'vocab': vocab,
      'precision': precision,
      'streak': streak,
      'carisma': carisma,
    };
  }

  @override
  Future<List<String>> syncEarnedTitles(
    String userId, {
    double carisma = 0,
  }) async {
    final newlyEarned = <String>[];
    try {
      final metrics = await _fetchConversationMetrics(userId);

      // Persistir el score de carisma de la sesión (para progreso futuro).
      if (carisma > 0) {
        try {
          await _supabaseClient
              .from('user_language_profiles')
              .update({'carisma_score': carisma})
              .eq('user_id', userId);
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/dashboard/data/repositories/dashboard_repository_impl.dart:881',
            e,
            stackTrace: st,
          );
        }
      }

      final codes = TitleEvaluator.earnedCodes(
        fluency: (metrics['fluency'] as num?)?.toDouble() ?? 0,
        phonetics: (metrics['phonetics'] as num?)?.toDouble() ?? 0,
        vocab: (metrics['vocab'] as num?)?.toInt() ?? 0,
        precision: (metrics['precision'] as num?)?.toDouble() ?? 0,
        streak: (metrics['streak'] as num?)?.toInt() ?? 0,
        carisma: carisma,
      );

      final existingRes = await _supabaseClient
          .from('user_titles')
          .select('title_code')
          .eq('user_id', userId);
      final existing = (existingRes as List)
          .map((r) => r['title_code'] as String)
          .toSet();

      for (final code in codes) {
        if (existing.contains(code)) continue;
        final title = HunterSkillTitleCatalog.forCode(code);
        if (title == null) continue;
        try {
          await _supabaseClient.from('user_titles').insert({
            'user_id': userId,
            'line': title.line,
            'title_code': code,
            'tier': title.tier,
          });
          newlyEarned.add(code);
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/dashboard/data/repositories/dashboard_repository_impl.dart:912',
            e,
            stackTrace: st,
          );
        }
      }
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/dashboard/data/repositories/dashboard_repository_impl.dart:914',
        e,
        stackTrace: st,
      );
    }
    return newlyEarned;
  }

  /// Converts a DB language_id to a 2-letter language code (e.g., 1 → 'en').
  /// Falls back to 'en' for unknown IDs.
  String? _getLanguageCodeFromId(int? languageId) {
    if (languageId == null) return null;
    const knownCodes = <int, String>{
      1: 'en',
      2: 'fr',
      3: 'de',
      4: 'it',
      5: 'pt',
    };
    return knownCodes[languageId];
  }
}
