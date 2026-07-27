import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/lesson_catalog.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _supabaseClient;

  DashboardRepositoryImpl(this._supabaseClient);

  @override
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_language_profiles')
          .select('xp_points, current_streak, languages(code, name, flag_emoji), cefr_levels(code, name)')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return {
          'xp': 120,
          'streak': 1,
          'level': 'Principiante',
          'level_code': 'A1',
          'language': 'Inglés',
          'language_emoji': '🇺🇸',
        };
      }

      final xp = response['xp_points'] as int? ?? 0;
      final streak = response['current_streak'] as int? ?? 0;
      
      final languages = response['languages'] as Map<String, dynamic>?;
      final languageName = languages?['name'] as String? ?? 'Inglés';
      final languageEmoji = languages?['flag_emoji'] as String? ?? '🇺🇸';

      final cefr = response['cefr_levels'] as Map<String, dynamic>?;
      final cefrName = cefr?['name'] as String? ?? 'Principiante';
      final cefrCode = cefr?['code'] as String? ?? 'A1';

      return {
        'xp': xp,
        'streak': streak,
        'level': cefrName,
        'level_code': cefrCode,
        'language': languageName,
        'language_emoji': languageEmoji,
      };
    } catch (_) {
      return {
        'xp': 120,
        'streak': 1,
        'level': 'Principiante',
        'level_code': 'A1',
        'language': 'Inglés',
        'language_emoji': '🇺🇸',
      };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecommendedLessons(String userId) async {
    try {
      // 1. Fetch user language profile to get language_id and difficulty level
      final profileResponse = await _supabaseClient
          .from('user_language_profiles')
          .select('language_id, cefr_levels!inner(code)')
          .eq('user_id', userId)
          .maybeSingle();

      String levelCode = 'A1';
      int? languageId;
      if (profileResponse != null) {
        languageId = profileResponse['language_id'] as int?;
        final cefrMap = profileResponse['cefr_levels'] as Map<String, dynamic>?;
        levelCode = cefrMap?['code'] as String? ?? 'A1';
      }

      // 2. Fetch user settings to get interests and daily goal
      final settingsResponse = await _supabaseClient
          .from('user_settings')
          .select('interests, daily_goal_minutes')
          .eq('user_id', userId)
          .maybeSingle();

      final List<String> userInterests = List<String>.from(settingsResponse?['interests'] ?? []);
      final int dailyGoalMinutes = settingsResponse?['daily_goal_minutes'] as int? ?? 15;

      // 3. Query Supabase public.scenarios matching language_id and difficulty_level
      List<Map<String, dynamic>> scenarios = [];
      try {
        var query = _supabaseClient
            .from('scenarios')
            .select('id, title, description, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, language_id')
            .eq('difficulty_level', levelCode)
            .eq('is_active', true);
            
        if (languageId != null) {
          query = query.eq('language_id', languageId);
        }

        final scenariosResponse = await query;
        scenarios = List<Map<String, dynamic>>.from(scenariosResponse);
        for (final sc in scenarios) {
          LessonCatalog.updateCatalogFromMap(sc);
        }
      } catch (_) {}

      // Filter and prioritize scenarios matching user's onboarding interests & daily goal
      if (scenarios.isNotEmpty) {
        if (userInterests.isNotEmpty) {
          scenarios.sort((a, b) {
            final aCat = (a['category'] as String? ?? '').toLowerCase();
            final bCat = (b['category'] as String? ?? '').toLowerCase();
            final aMatches = userInterests.any((i) => aCat == i.toLowerCase() || aCat.contains(i.toLowerCase()));
            final bMatches = userInterests.any((i) => bCat == i.toLowerCase() || bCat.contains(i.toLowerCase()));
            if (aMatches && !bMatches) return -1;
            if (!aMatches && bMatches) return 1;

            // Secondary sorting by estimated minutes proximity to daily goal
            final aMins = a['estimated_minutes'] as int? ?? 15;
            final bMins = b['estimated_minutes'] as int? ?? 15;
            final aDiff = (aMins - dailyGoalMinutes).abs();
            final bDiff = (bMins - dailyGoalMinutes).abs();
            return aDiff.compareTo(bDiff);
          });
        }
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
          final phrasesDone = sid != null ? (completedPhrasesCount[sid] ?? 0) : 0;

          final bool isCompleted = goalsDone >= totalGoals;
          final double progress = (goalsDone / totalGoals).clamp(0.0, 1.0);

          int stars = 0;
          if (isCompleted) {
            if (phrasesDone >= totalPhrases) {
              stars = 3;
            } else if (phrasesDone >= (totalPhrases / 2).ceil()) {
              stars = 2;
            } else {
              stars = 1;
            }
          }

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
        if (targetLangCode != null && l.targetLanguageCode != targetLangCode) return false;
        return l.level == levelCode;
      }).toList();

      return filteredCatalog.take(15).map((l) => {
        'id': l.id,
        'title': l.title,
        'description': l.description,
        'difficulty_level': l.level,
        'category': l.category,
        'progress': 0.0,
        'is_completed': false,
        'stars': 0,
        'icon_key': l.iconKey,
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    try {
      // 1. Fetch user stats from database
      final profilesRes = await _supabaseClient
          .from('user_language_profiles')
          .select('current_streak, language_id')
          .eq('user_id', userId);

      final streak = profilesRes.isNotEmpty ? (profilesRes.first['current_streak'] as int? ?? 0) : 0;
      final languagesCount = profilesRes.map((p) => p['language_id']).toSet().length;

      final convosRes = await _supabaseClient
          .from('conversations')
          .select('id')
          .eq('user_id', userId);
      final conversationsCount = convosRes.length;
      final convoIds = convosRes.map((c) => c['id']).toList();

      debugPrint('[Achievements] conversations=$conversationsCount convoIds=$convoIds');

      int messagesCount = 0;
      if (convoIds.isNotEmpty) {
        final messagesRes = await _supabaseClient
            .from('messages')
            .select('id')
            .inFilter('conversation_id', convoIds)
            .eq('role', 'user');
        messagesCount = messagesRes.length;
        debugPrint('[Achievements] messagesCount=$messagesCount');
      }

      final vocabRes = await _supabaseClient
          .from('user_vocabulary')
          .select('id')
          .eq('user_id', userId);
      final vocabularyCount = vocabRes.length;

      const double maxPronunciation = 0.0; // Default or extended later if needed

      // 2. Fetch all achievements
      final allAchievements = await _supabaseClient
          .from('achievements')
          .select();

      // 3. Fetch unlocked achievements
      final unlockedRes = await _supabaseClient
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_id', userId);
      final unlockedIds = unlockedRes.map((ua) => ua['achievement_id'] as int).toSet();

      final List<Map<String, dynamic>> results = [];

      for (final ach in allAchievements) {
        final id = ach['id'] as int;
        final code = ach['code'] as String;
        final title = ach['title'] as String;
        final description = ach['description'] as String? ?? '';
        final tier = ach['icon_url'] as String? ?? 'bronze'; // We use icon_url to store the tier
        final xpReward = ach['xp_reward'] as int? ?? 0;
        final conditionType = ach['condition_type'] as String?;
        final conditionValue = ach['condition_value'] as int? ?? 1;

        int currentValue = 0;
        if (conditionType == 'streak') {
          currentValue = streak;
        } else if (conditionType == 'conversations') {
          currentValue = conversationsCount;
        } else if (conditionType == 'messages') {
          currentValue = messagesCount;
        } else if (conditionType == 'languages') {
          currentValue = languagesCount;
        } else if (conditionType == 'vocabulary') {
          currentValue = vocabularyCount;
        } else if (conditionType == 'pronunciation') {
          currentValue = maxPronunciation.toInt();
        }

        final isUnlocked = unlockedIds.contains(id) || currentValue >= conditionValue;

        // Auto unlock if completed but not recorded
        if (currentValue >= conditionValue && !unlockedIds.contains(id)) {
          try {
            await _supabaseClient.from('user_achievements').upsert({
              'user_id': userId,
              'achievement_id': id,
            }, onConflict: 'user_id, achievement_id');
          } catch (_) {}
        }

        results.add({
          'id': id,
          'code': code,
          'title': title,
          'description': description,
          'tier': tier,
          'xp_reward': xpReward,
          'current_value': currentValue,
          'target_value': conditionValue,
          'is_unlocked': isUnlocked,
          'progress': currentValue / conditionValue,
        });
      }

      // Sort: unlocked first, then by tier
      results.sort((a, b) {
        if (a['is_unlocked'] && !b['is_unlocked']) return -1;
        if (!a['is_unlocked'] && b['is_unlocked']) return 1;
        return 0;
      });

      return results;
    } catch (_) {
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

      final List<Map<String, dynamic>> rawData = List<Map<String, dynamic>>.from(response);

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

      int maxMinutes = 15; // default minimum max value to calculate height factor
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
          .select('times_seen, vocabulary_items(word, translation, part_of_speech)')
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
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings) async {
    // Remove fields that don't belong in the user_settings table
    final cleanSettings = Map<String, dynamic>.from(settings);
    cleanSettings.remove('id');

    await _supabaseClient.from('user_settings').upsert(
      {
        'user_id': userId,
        ...cleanSettings,
      },
      onConflict: 'user_id',
    );
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
        await _supabaseClient
            .from('daily_stats')
            .insert({
              'user_id': userId,
              'language_id': langId,
              'date': todayStr,
              'minutes_practiced': minutes,
              'conversations_count': 1,
              'words_learned': 0,
              'xp_earned': minutes * 10,
            });
      }

      // Also update total minutes, xp_points and streak in user language profile
      final currentProfile = await _supabaseClient
          .from('user_language_profiles')
          .select('total_minutes, xp_points, current_streak, longest_streak, last_practice_date')
          .eq('user_id', userId)
          .eq('language_id', langId)
          .maybeSingle();

      if (currentProfile != null) {
        final totalMins = currentProfile['total_minutes'] as int? ?? 0;
        final xpPoints = currentProfile['xp_points'] as int? ?? 0;
        int currentStreak = currentProfile['current_streak'] as int? ?? 0;
        int longestStreak = currentProfile['longest_streak'] as int? ?? 0;
        final lastPracticeStr = currentProfile['last_practice_date'] as String?;
        
        final todayStr = DateTime.now().toIso8601String().split('T').first;
        
        if (lastPracticeStr == null) {
          currentStreak = 1;
        } else {
          try {
            final lastPracticeDate = DateTime.parse(lastPracticeStr);
            final todayDate = DateTime.parse(todayStr);
            final diffDays = todayDate.difference(lastPracticeDate).inDays;
            
            if (diffDays == 1) {
              currentStreak += 1;
            } else if (diffDays > 1) {
              currentStreak = 1;
            }
          } catch (_) {
            currentStreak = 1;
          }
        }
        
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }

        await _supabaseClient
            .from('user_language_profiles')
            .update({
              'total_minutes': totalMins + minutes,
              'xp_points': xpPoints + (minutes * 10),
              'current_streak': currentStreak,
              'longest_streak': longestStreak,
              'last_practice_date': todayStr,
            })
            .eq('user_id', userId)
            .eq('language_id', langId);
      }
    } catch (e) {
      // Log or ignore database error
    }
  }

  @override
  Future<void> saveVocabularyFromSession(String userId, List<String> userTexts) async {
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
                'part_of_speech': word.endsWith('ly') ? 'Adverbio' : (word.endsWith('ing') || word.endsWith('ed') ? 'Verbo' : 'Sustantivo'),
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
            'next_review_at': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'last_seen_at': DateTime.now().toIso8601String(),
          });
        } else {
          final currentSeen = existingUserVocab['times_seen'] as int? ?? 0;
          await _supabaseClient.from('user_vocabulary').update({
            'times_seen': currentSeen + 1,
            'last_seen_at': DateTime.now().toIso8601String(),
          }).eq('id', existingUserVocab['id']);
        }
      }
    } catch (_) {
      // Ignore
    }
  }

  @override
  Future<void> updateVocabularySrsScore(String userId, String vocabularyId, double qualityScore) async {
    try {
      final existing = await _supabaseClient
          .from('user_vocabulary')
          .select('id, ease_factor, interval_days, times_seen, times_correct')
          .eq('user_id', userId)
          .eq('vocabulary_id', vocabularyId)
          .maybeSingle();

      if (existing == null) return;

      double easeFactor = (existing['ease_factor'] as num? ?? 2.5).toDouble();
      int intervalDays = existing['interval_days'] as int? ?? 1;
      int timesSeen = existing['times_seen'] as int? ?? 1;
      int timesCorrect = existing['times_correct'] as int? ?? 1;

      // SuperMemo SM-2 Formula
      final q = qualityScore.clamp(0.0, 5.0);
      easeFactor = easeFactor + (0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02));
      if (easeFactor < 1.3) easeFactor = 1.3;

      if (q < 3.0) {
        intervalDays = 1;
      } else {
        timesCorrect += 1;
        if (intervalDays == 1) {
          intervalDays = 6;
        } else {
          intervalDays = (intervalDays * easeFactor).round();
        }
      }

      timesSeen += 1;
      final isMastered = timesCorrect >= 3 && intervalDays >= 14;
      final nextReviewDate = DateTime.now().add(Duration(days: intervalDays)).toIso8601String();

      await _supabaseClient.from('user_vocabulary').update({
        'ease_factor': easeFactor,
        'interval_days': intervalDays,
        'times_seen': timesSeen,
        'times_correct': timesCorrect,
        'is_mastered': isMastered,
        'next_review_at': nextReviewDate,
        'last_seen_at': DateTime.now().toIso8601String(),
      }).eq('id', existing['id']);
    } catch (_) {
      // Ignore database errors during offline/fallback mode
    }
  }

  @override
  Future<void> updateUserProfile(String userId, {String? displayName, String? avatarUrl, String? nativeLanguage}) async {
    final Map<String, dynamic> updates = {};
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (nativeLanguage != null) updates['native_language'] = nativeLanguage;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _supabaseClient.from('users').update(updates).eq('id', userId);
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
