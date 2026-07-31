import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/conversation_message.dart';
import '../../domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final Dio _dio;
  final SupabaseClient? _supabaseClient;

  ConversationRepositoryImpl(this._dio, [this._supabaseClient]);

  SupabaseClient get _client => _supabaseClient ?? Supabase.instance.client;

  /// Transcribes raw audio (.m4a/.wav) using Groq Cloud Whisper API.
  @override
  Future<String> transcribeAudio(String audioPath) async {
    try {
      const apiKey = ApiConstants.groqApiKey;
      const url = ApiConstants.groqSttUrl;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioPath,
          filename: 'recording.m4a',
        ),
        'model': 'whisper-large-v3-turbo',
        'language': 'en',
        'response_format': 'json',
      });

      debugPrint('Sending audio file ($audioPath) to Groq Whisper API...');

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      debugPrint('Groq STT Status: ${response.statusCode}');
      debugPrint('Groq STT Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        if (data is Map) {
          final text = data['text'] as String?;
          debugPrint('Groq STT Result: "$text"');
          return text?.trim() ?? '';
        }
      }
      return '';
    } catch (e) {
      debugPrint('=== GROQ STT ERROR ===');
      debugPrint('Error: $e');
      if (e is DioException) {
        debugPrint('Dio error code: ${e.response?.statusCode}');
        debugPrint('Dio error response: ${e.response?.data}');
      }
      debugPrint('======================');
      rethrow;
    }
  }

  /// Streams the AI tutor's response via DeepSeek chat completions SSE.
  @override
  Stream<String> getTutorResponseStream(List<Map<String, String>> history) async* {
    String apiKey = ApiConstants.deepseekApiKey;
    String baseUrl = ApiConstants.deepseekBaseUrl;

    if (apiKey == 'placeholder_deepseek_key') {
      apiKey = 'sk-592200e11f164db5b054a9421d98bd53';
    }
    if (baseUrl.contains('example.com')) {
      baseUrl = 'https://api.deepseek.com/v1';
    }

    const maxRetries = 2;
    int attempt = 0;

    while (attempt < maxRetries) {
      attempt++;
      try {
        debugPrint('DeepSeek attempt $attempt/$maxRetries to $baseUrl');
        final response = await _dio.post(
          '$baseUrl/chat/completions',
          data: {
            'model': 'deepseek-v4-flash',
            'messages': history,
            'stream': true,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            responseType: ResponseType.stream,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 90),
          ),
        );

        final Stream<List<int>> byteStream = (response.data.stream as Stream).cast<List<int>>();
        final lineStream = byteStream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in lineStream) {
          if (line.trim().isEmpty) continue;
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6).trim();
            if (dataStr == '[DONE]') break;

            try {
              final json = jsonDecode(dataStr);
              final choices = json['choices'] as List?;
              if (choices != null && choices.isNotEmpty) {
                final choice = choices[0] as Map?;
                final delta = choice?['delta'] as Map?;
                final content = delta?['content'] ?? '';
                if (content.isNotEmpty) {
                  yield content;
                }
                if (choice?['finish_reason'] != null) {
                  break;
                }
              }
            } catch (_) {}
          } else if (line.contains('[DONE]')) {
            break;
          }
        }
        return;
      } catch (e) {
        debugPrint('=== DEEPSEEK ERROR (attempt $attempt) ===: $e');
        if (e is DioException) {
          debugPrint('DeepSeek Status Code: ${e.response?.statusCode}');
          debugPrint('DeepSeek Response Data: ${e.response?.data}');
          final resData = e.response?.data;
          if (resData is ResponseBody) {
            try {
              final content = await (resData.stream as Stream).cast<List<int>>().transform(utf8.decoder).join();
              debugPrint('DeepSeek Streamed Error Data: $content');
            } catch (err) {
              debugPrint('Error reading response stream: $err');
            }
          } else if (resData is Stream) {
            try {
              final content = await (resData as Stream).cast<List<int>>().transform(utf8.decoder).join();
              debugPrint('DeepSeek Streamed Error Data: $content');
            } catch (err) {
              debugPrint('Error reading response stream: $err');
            }
          }
          if (attempt < maxRetries &&
              (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.sendTimeout ||
               e.type == DioExceptionType.connectionError)) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.connectionError) {
            yield 'No pude conectar con el servidor. Verifica tu conexión a internet e intenta de nuevo.';
            return;
          } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            yield 'Error de autenticación con el servidor. Contacta soporte.';
            return;
          }
        }
        yield 'Tuve problemas para conectar con el tutor. Por favor intenta de nuevo.';
        return;
      }
    }
  }

  @override
  Future<String> generateTtsAudio(String text) async => '';

  /// Sends the conversation + goals to DeepSeek for AI-based goal evaluation.
  /// Returns a map of goalId → achieved (true/false).
  @override
  Future<Map<String, bool>> evaluateGoals(
    String conversationJson,
    List<Map<String, dynamic>> goalItems,
  ) async {
    try {
      String apiKey = ApiConstants.deepseekApiKey;
      String baseUrl = ApiConstants.deepseekBaseUrl;

      if (apiKey == 'placeholder_deepseek_key') {
        apiKey = 'sk-592200e11f164db5b054a9421d98bd53';
      }
      if (baseUrl.contains('example.com')) {
        baseUrl = 'https://api.deepseek.com/v1';
      }

      final systemPrompt = '''
You are a strict and objective evaluator of language learning conversations.

Your task is to analyze the conversation and determine which lesson goals the STUDENT has successfully achieved.

Lesson goals to evaluate:
${goalItems.asMap().entries.map((e) => '${e.key + 1}. [id: ${e.value['id']}] ${e.value['text']}').join('\n')}

Conversation:
$conversationJson

Guidelines for evaluation (BE EXTREMELY STRICT):
1. Only evaluate the STUDENT's messages. The tutor's messages or prompts DO NOT count towards the student's achievements.
2. A goal must only be marked as true if there is clear, explicit, and undeniable evidence in the student's text that they have successfully performed that specific skill or task.
3. For goals that specify a quantity (e.g., "at least 5 keywords", "2 clarification questions"), you MUST count them. If the student has not met the exact number, the goal is false.
4. For goals related to introducing, concluding, or resolving a scenario, the student must have actually done so. For example, "Resolve scenario and conclude" is only true if the conversation is at the end and the scenario has been successfully completed.
5. If the conversation has just started (e.g., only 1 or 2 student messages), most advanced or middle goals (like resolving, asking multiple questions, using many keywords) must be false.
6. Do not assume or extrapolate. If it's not explicitly in the student's messages, it is false.

Return ONLY a valid JSON object where keys are goal IDs and values are true/false.
Example: {"g1": true, "g2": false, "g3": false}
No markdown, no explanation, no code blocks.
''';

      final response = await _dio.post(
        '$baseUrl/chat/completions',
        data: {
          'model': 'deepseek-v4-pro',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
          ],
          'stream': false,
          'temperature': 0.3,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]?['message']?['content'] as String? ?? '';
          final cleaned = content.trim();
          debugPrint('Goal evaluation raw response: $cleaned');
          final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
          return parsed.map((k, v) => MapEntry(k, v == true));
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error evaluating goals: $e');
      return {};
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Database Persistence & Analysis Methods
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getOrCreateConversation(String userId, {String? scenarioId}) async {
    try {
      if (scenarioId != null && scenarioId.isNotEmpty) {
        // Fetch existing active conversation for this user and scenario
        final existing = await _client
            .from('conversations')
            .select()
            .eq('user_id', userId)
            .eq('scenario_id', scenarioId)
            .order('started_at', ascending: false)
            .maybeSingle();

        if (existing != null) {
          return Map<String, dynamic>.from(existing);
        }
      }

      // Create new conversation
      final profile = await _client
          .from('user_language_profiles')
          .select('language_id')
          .eq('user_id', userId)
          .maybeSingle();
      final langId = profile?['language_id'] as int? ?? 1;

      final insertRes = await _client.from('conversations').insert({
        'user_id': userId,
        'language_id': langId,
        'scenario_id': (scenarioId != null && scenarioId.isNotEmpty) ? scenarioId : null,
        'started_at': DateTime.now().toIso8601String(),
        'status': 'active',
      }).select().single();

      return Map<String, dynamic>.from(insertRes);
    } catch (e) {
      debugPrint('Error in getOrCreateConversation: $e');
      return {
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
      };
    }
  }

  @override
  Future<List<ConversationMessage>> loadConversationMessages(String conversationId) async {
    if (conversationId.startsWith('local_')) return [];
    try {
      final res = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (res as List).map((row) {
        final role = row['role'] as String? ?? 'user';
        final contentText = row['content_text'] as String? ?? '';
        return ConversationMessage(
          sender: role == 'user' ? 'user' : 'tutor',
          text: contentText,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading conversation messages: $e');
      return [];
    }
  }

  @override
  Future<void> saveMessage(String conversationId, String senderRole, String text) async {
    if (conversationId.startsWith('local_') || text.trim().isEmpty) return;
    try {
      // Get next sequence number for this conversation
      final lastMsg = await _client
          .from('messages')
          .select('sequence_number')
          .eq('conversation_id', conversationId)
          .order('sequence_number', ascending: false)
          .limit(1)
          .maybeSingle();
      final nextSeq = (lastMsg?['sequence_number'] as int? ?? 0) + 1;

      await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_role': senderRole == 'user' ? 'user' : 'assistant',
        'role': senderRole == 'user' ? 'user' : 'assistant',
        'text': text,
        'content_text': text,
        'sequence_number': nextSeq,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving message to Supabase: $e');
    }
  }

  @override
  Future<void> analyzeAndSaveSessionProgress(
    String userId,
    String conversationId,
    List<ConversationMessage> messages, {
    String? scenarioId,
  }) async {
    try {
      final userTexts = messages
          .where((m) => m.sender == 'user')
          .map((m) => m.text)
          .toList();

      if (userTexts.isEmpty) return;

      // Extract and save new learned vocabulary only.
      // Stats (XP, streak, minutes) are handled by endSession → logPracticeSession
      // to avoid double-counting on every turn.
      final Set<String> words = {};
      final RegExp wordRegExp = RegExp(r'\b[a-zA-Z]{4,15}\b');
      for (final text in userTexts) {
        final matches = wordRegExp.allMatches(text.toLowerCase());
        for (final match in matches) {
          final word = match.group(0);
          if (word != null) words.add(word);
        }
      }

      final profile = await _client
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
      };

      for (final word in words.take(6)) {
        final translation = commonTranslations[word] ?? word;
        var existingVocab = await _client
            .from('vocabulary_items')
            .select()
            .eq('language_id', langId)
            .eq('word', word)
            .maybeSingle();

        late final String vocabId;
        if (existingVocab == null) {
          final insertRes = await _client
              .from('vocabulary_items')
              .insert({
                'language_id': langId,
                'word': word,
                'translation': translation,
                'part_of_speech': word.endsWith('ly') ? 'Adverbio' : (word.endsWith('ing') ? 'Verbo' : 'Sustantivo'),
                'native_language': 'es',
                'difficulty_level': 'A2',
              })
              .select('id')
              .single();
          vocabId = insertRes['id'] as String;
        } else {
          vocabId = existingVocab['id'] as String;
        }

        final existingUserVocab = await _client
            .from('user_vocabulary')
            .select()
            .eq('user_id', userId)
            .eq('vocabulary_id', vocabId)
            .maybeSingle();

        if (existingUserVocab == null) {
          await _client.from('user_vocabulary').insert({
            'user_id': userId,
            'vocabulary_id': vocabId,
            'word': word,
            'translation': translation,
            'times_seen': 1,
            'times_correct': 1,
            'ease_factor': 2.5,
            'interval_days': 1,
            'next_review_at': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'last_seen_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('Error analyzing session progress: $e');
    }
  }

  @override
  Future<void> saveCompletedGoal(
    String userId,
    String scenarioId,
    String? conversationId,
    String goalId,
    String goalText,
  ) async {
    try {
      await _client.from('user_scenario_goals').upsert(
        {
          'user_id': userId,
          'scenario_id': scenarioId,
          'conversation_id': (conversationId != null && !conversationId.startsWith('local_')) ? conversationId : null,
          'goal_id': goalId,
          'goal_text': goalText,
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id, scenario_id, goal_id',
      );
    } catch (e) {
      debugPrint('Error saving completed goal: $e');
    }
  }

  @override
  Future<Map<String, bool>> loadCompletedGoals(String userId, String scenarioId) async {
    try {
      final res = await _client
          .from('user_scenario_goals')
          .select('goal_id')
          .eq('user_id', userId)
          .eq('scenario_id', scenarioId);

      final Map<String, bool> results = {};
      for (final item in res as List) {
        final gid = item['goal_id'] as String?;
        if (gid != null) {
          results[gid] = true;
        }
      }
      return results;
    } catch (e) {
      debugPrint('Error loading completed goals: $e');
      return {};
    }
  }

  @override
  Future<void> saveCompletedPhrase(
    String userId,
    String scenarioId,
    String? conversationId,
    String phraseId,
    String phraseText, {
    int accuracy = 95,
  }) async {
    try {
      await _client.from('user_scenario_phrases').upsert(
        {
          'user_id': userId,
          'scenario_id': scenarioId,
          'conversation_id': (conversationId != null && !conversationId.startsWith('local_')) ? conversationId : null,
          'phrase_id': phraseId,
          'phrase_text': phraseText,
          'phonetic_accuracy_score': accuracy,
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id, scenario_id, phrase_id',
      );
    } catch (e) {
      debugPrint('Error saving completed phrase: $e');
    }
  }

  @override
  Future<Map<String, bool>> loadCompletedPhrases(String userId, String scenarioId) async {
    try {
      final res = await _client
          .from('user_scenario_phrases')
          .select('phrase_id')
          .eq('user_id', userId)
          .eq('scenario_id', scenarioId);

      final Map<String, bool> results = {};
      for (final item in res as List) {
        final pid = item['phrase_id'] as String?;
        if (pid != null) {
          results[pid] = true;
        }
      }
      return results;
    } catch (e) {
      debugPrint('Error loading completed phrases: $e');
      return {};
    }
  }

  @override
  Future<void> logFluencyMetrics(
    String userId,
    String? scenarioId,
    double latencySeconds,
    int speakingWpm,
  ) async {
    try {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      
      // Calculate fluency score (0-100)
      // Latency target: <= 1.5s = 100%, 5.0s = 50%
      final latencyScore = (100 - ((latencySeconds - 1.5).clamp(0.0, 10.0) * 12)).clamp(40.0, 100.0);
      // WPM target: 120 WPM = 100%
      final wpmScore = (speakingWpm / 1.2).clamp(40.0, 100.0);
      final int overallFluency = ((latencyScore * 0.5) + (wpmScore * 0.5)).round();

      // 1. Update daily_fluency_stats
      final existingDaily = await _client
          .from('daily_fluency_stats')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();

      if (existingDaily != null) {
        final int turns = existingDaily['total_turns_count'] as int? ?? 1;
        final double prevLat = (existingDaily['avg_response_latency_seconds'] as num? ?? 2.5).toDouble();
        final int prevWpm = existingDaily['avg_speaking_wpm'] as int? ?? 110;

        final newLat = ((prevLat * turns) + latencySeconds) / (turns + 1);
        final newWpm = (((prevWpm * turns) + speakingWpm) / (turns + 1)).round();
        final newFluency = ((overallFluency + (existingDaily['fluency_score'] as int? ?? 75)) / 2).round();

        await _client.from('daily_fluency_stats').update({
          'avg_response_latency_seconds': newLat,
          'avg_speaking_wpm': newWpm,
          'fluency_score': newFluency,
          'total_turns_count': turns + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existingDaily['id']);
      } else {
        await _client.from('daily_fluency_stats').insert({
          'user_id': userId,
          'date': todayStr,
          'avg_response_latency_seconds': latencySeconds,
          'avg_speaking_wpm': speakingWpm,
          'fluency_score': overallFluency,
          'total_turns_count': 1,
        });
      }

      // 2. Update user_scenario_fluency if scenarioId is present
      if (scenarioId != null && scenarioId.isNotEmpty && !scenarioId.startsWith('local_')) {
        await _client.from('user_scenario_fluency').upsert(
          {
            'user_id': userId,
            'scenario_id': scenarioId,
            'best_response_latency_seconds': latencySeconds,
            'avg_speaking_wpm': speakingWpm,
            'fluency_score': overallFluency,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id, scenario_id',
        );
      }
    } catch (e) {
      debugPrint('Error logging fluency metrics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkAiAudioQuota(String userId) async {
    try {
      final res = await _client.rpc('check_ai_audio_quota', params: {'p_user_id': userId});
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      debugPrint('Error checking AI audio quota: $e');
      return {'is_allowed': true};
    }
  }

  @override
  Future<Map<String, dynamic>> trackAiAudioTime(String userId, int durationSeconds) async {
    try {
      final res = await _client.rpc('track_ai_audio_time', params: {
        'p_user_id': userId,
        'p_duration_seconds': durationSeconds,
      });
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      debugPrint('Error tracking AI audio time: $e');
      return {'is_allowed': true};
    }
  }
}
