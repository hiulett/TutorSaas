import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../domain/models/conversation_message.dart';
import '../../domain/models/conversation_state.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────────────────────────────────────

final conversationDioProvider = Provider<Dio>((ref) => Dio());

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final dio = ref.watch(conversationDioProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return ConversationRepositoryImpl(dio, supabase);
});

final activeConversationIdProvider = StateProvider<String?>((ref) => null);
final activeScenarioIdProvider = StateProvider<String?>((ref) => null);

// ──────────────────────────────────────────────────────────────────────────────
// ConversationNotifier — Orchestrates Voice/Text → Groq/DeepSeek → Supabase Persistence
// ──────────────────────────────────────────────────────────────────────────────

class ConversationNotifier extends StateNotifier<ConversationState> {
  final ConversationRepository _repository;
  final Ref _ref;

  // Raw Audio Recorder for ultra-reliable voice capture
  final Record _audioRecorder = Record();

  // On-device Text-to-Speech
  final FlutterTts _tts = FlutterTts();

  bool _hasProcessedThisTurn = false;
  String? _conversationId;
  String? _userId;

  ConversationNotifier(this._repository, this._ref)
      : super(ConversationState.initial()) {
    _initTts();
  }

  // ── Session Init ────────────────────────────────────────────────────────────

  Future<void> initSession({String? scenarioId, String? scenarioTitle}) async {
    final user = _ref.read(currentUserProvider);
    _userId = user?.id ?? 'guest_user';

    // Fetch latest scenario fields from Supabase DB to sync any edits saved from web_admin
    if (scenarioId != null || scenarioTitle != null) {
      try {
        final client = Supabase.instance.client;
        var query = client.from('scenarios').select('*');
        if (scenarioId != null && scenarioId.isNotEmpty) {
          query = query.eq('id', scenarioId);
        } else if (scenarioTitle != null && scenarioTitle.isNotEmpty) {
          query = query.ilike('title', '%$scenarioTitle%');
        }
        final res = await query.maybeSingle();
        if (res != null) {
          LessonCatalog.updateCatalogFromMap(res);
        }
      } catch (_) {}
    }

    final lesson = LessonCatalog.getLessonById(
      scenarioId,
      title: scenarioTitle,
    );

    state = state.copyWith(
      activeScenarioId: scenarioId,
      activeScenarioName: scenarioTitle ?? lesson?.title ?? 'Práctica de Conversación',
    );

    // 1. For recommended lessons (with scenarioId), persist to Supabase
    if (scenarioId != null && scenarioId.isNotEmpty) {
      final convData = await _repository.getOrCreateConversation(_userId!, scenarioId: scenarioId);
      _conversationId = convData['id'] as String?;
      _ref.read(activeConversationIdProvider.notifier).state = _conversationId;

      // 2. If resuming, load historical messages from Supabase
      if (_conversationId != null) {
        final savedMessages = await _repository.loadConversationMessages(_conversationId!);
        if (savedMessages.isNotEmpty) {
          state = state.copyWith(messages: savedMessages);
        } else if (lesson != null) {
          // First time: set initial assistant message
          state = state.copyWith(messages: [
            ConversationMessage(
              sender: 'tutor',
              text: lesson.initialAssistantMessage,
            ),
          ]);
          _repository.saveMessage(_conversationId!, 'assistant', lesson.initialAssistantMessage);
        }
      }

      // Restore previously completed goals from Supabase DB
      final savedGoals = await _repository.loadCompletedGoals(_userId!, scenarioId);
      if (savedGoals.isNotEmpty) {
        state = state.copyWith(goalEvaluationResults: savedGoals);
      }
    } else {
      // Free practice — no DB persistence
      _conversationId = null;
      _ref.read(activeConversationIdProvider.notifier).state = null;

      if (lesson != null) {
        state = state.copyWith(messages: [
          ConversationMessage(sender: 'tutor', text: lesson.initialAssistantMessage),
        ]);
      } else {
        state = state.copyWith(messages: const [
          ConversationMessage(sender: 'tutor', text: 'Hello! How can I help you practice today?'),
        ]);
      }
    }
  }

  // ── TTS Init ────────────────────────────────────────────────────────────────

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
    _tts.setCompletionHandler(() {
      state = state.copyWith(isPlaying: false);
    });
    _tts.setErrorHandler((msg) {
      state = state.copyWith(isPlaying: false);
    });
  }

  // ── Start Audio Recording ────────────────────────────────────────────────────

  Future<void> startRecording() async {
    if (state.isRecording || state.isProcessing) return;

    if (state.isPlaying) {
      await _tts.stop();
      state = state.copyWith(isPlaying: false);
    }

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        state = state.copyWith(
          errorMessage: 'Sin permiso de micrófono. Actívalo en la configuración.',
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final recordingPath =
          '${tempDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        path: recordingPath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 16000,
      );

      _hasProcessedThisTurn = false;
      state = state.copyWith(
        isRecording: true,
        currentTranscribingText: 'Escuchando tu voz...',
        errorMessage: null,
      );
      debugPrint('Groq STT: Audio recording started at $recordingPath');
    } catch (e) {
      debugPrint('Error starting audio recording: $e');
      state = state.copyWith(
        isRecording: false,
        errorMessage: 'Error al acceder al micrófono: $e',
      );
    }
  }

  // ── Stop Audio Recording & Transcribe with Groq ──────────────────────────────

  Future<void> stopRecording() async {
    if (!state.isRecording) return;

    try {
      state = state.copyWith(
        isRecording: false,
        isProcessing: true,
        currentTranscribingText: 'Procesando con Groq IA...',
      );

      final audioPath = await _audioRecorder.stop();
      debugPrint('Groq STT: Recording stopped. File path: $audioPath');

      if (audioPath != null && audioPath.isNotEmpty) {
        final file = File(audioPath);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        debugPrint('Groq STT: Recording file size=$size bytes');

        if (!exists || size < 100) {
          state = state.copyWith(
            isProcessing: false,
            currentTranscribingText: '',
            errorMessage: 'La grabación fue muy corta o vacía. Habla de nuevo.',
          );
          return;
        }

        final transcription = await _repository.transcribeAudio(audioPath);

        if (transcription.trim().isNotEmpty) {
          state = state.copyWith(currentTranscribingText: '');
          await _processTranscription(transcription.trim());
        } else {
          state = state.copyWith(
            isProcessing: false,
            currentTranscribingText: '',
            errorMessage: 'No se detectó voz en el audio. Intenta hablar más cerca del micrófono.',
          );
        }
      } else {
        state = state.copyWith(
          isProcessing: false,
          currentTranscribingText: '',
          errorMessage: 'No se pudo generar la grabación.',
        );
      }
    } catch (e) {
      debugPrint('Error stopping audio recording: $e');
      String userMsg = 'Error al procesar el audio: $e';
      if (e is DioException) {
        final code = e.response?.statusCode;
        userMsg = 'Error de conexión con Groq STT ($code). Revisa tu internet o la API Key.';
      }
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        currentTranscribingText: '',
        errorMessage: userMsg,
      );
    }
  }

  // ── Send Direct Text Message from Keyboard ──────────────────────────────────

  Future<void> sendTextMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isProcessing) return;

    if (state.isPlaying) {
      await _tts.stop();
      state = state.copyWith(isPlaying: false);
    }

    state = state.copyWith(
      isProcessing: true,
      currentTranscribingText: 'Enviando mensaje...',
    );

    await _processTranscription(trimmed);
  }

  // ── Process Transcription / Text → LLM → Supabase → TTS ────────────────────

  Future<void> _processTranscription(String userText) async {
    if (_hasProcessedThisTurn) return;
    _hasProcessedThisTurn = true;

    try {
      // 1. Build user message
      final ConversationMessage userMessage;
      if (userText.toLowerCase().contains('i want')) {
        userMessage = ConversationMessage(
          sender: 'user',
          text: userText,
          originalText: userText,
          correctionExplanation:
              'Para sonar más educado en inglés, es recomendable usar "I would like" en lugar de "I want".',
        );
      } else {
        userMessage = ConversationMessage(sender: 'user', text: userText);
      }

      state = state.copyWith(
        messages: [...state.messages.where((m) => m.text.isNotEmpty), userMessage],
        currentTranscribingText: '',
      );

      // Save user message to Supabase (only persisted lessons)
      if (_conversationId != null) {
        await _repository.saveMessage(_conversationId!, 'user', userText);
      }

      // 2. Build system instructions and history for DeepSeek
      final correctionLevel = _ref.read(correctionLevelProvider);
      String correctionInstructions = '';
      switch (correctionLevel) {
        case 'important_only':
          correctionInstructions =
              'Only correct mistakes that prevent understanding or represent severe grammar errors. '
              'Keep corrections minimal and very brief.';
          break;
        case 'short':
          correctionInstructions =
              'Provide a very short correction (one line max) then immediately continue the conversation. '
              'Do not explain grammar rules.';
          break;
        case 'moderate':
          correctionInstructions =
              'Provide the correction and a brief explanation of 1 to 2 lines, then continue the conversation.';
          break;
        case 'detailed':
        default:
          correctionInstructions =
              'Provide detailed corrections with full grammar explanations. '
              'Suggest alternative phrasing and explain why the error occurred. '
              'Then ask a follow-up question to continue.';
      }

      final lesson = state.activeScenarioId != null && state.activeScenarioId!.isNotEmpty
          ? LessonCatalog.getLessonById(state.activeScenarioId)
          : null;

      final roleContext = lesson != null
          ? 'You are an AI Language Tutor roleplaying as ${lesson.assistantRole} in a ${lesson.scenarioContext}. '
            'The user is playing the role of ${lesson.userRole}. Target CEFR Level: ${lesson.level}. '
            'Keep your response appropriate for CEFR level ${lesson.level} '
            '(use simple language for A1/A2, intermediate for B1/B2, advanced for C1, '
            'native-level fluency and complex discourse for C2). '
            'IMPORTANT: You MUST ALWAYS respond in English. Never use Spanish or any other language. '
            'Converse naturally in English according to this role. '
          : 'You are an AI Language Tutor. '
            'IMPORTANT: You MUST ALWAYS respond in English. Never use Spanish or any other language. '
            'Converse naturally in English. ';

      final List<Map<String, String>> historyList = [
        {
          'role': 'system',
          'content':
              '$roleContext'
              'Analyze the user message, point out any grammar or vocabulary mistakes adhering to: $correctionInstructions. '
              'If the user writes in Spanish, gently remind them to use English and help them translate. '
              'Ask a natural follow-up question to continue the conversation.',
        },
        ...state.messages.map((m) => {
              'role': m.sender == 'user' ? 'user' : 'assistant',
              'content': m.text,
            }),
      ];

      // 3. Add typing indicator placeholder for tutor
      const tutorPlaceholder = ConversationMessage(sender: 'tutor', text: '');
      state = state.copyWith(messages: [...state.messages, tutorPlaceholder]);

      // 4. Stream DeepSeek response
      final stream = _repository.getTutorResponseStream(historyList);
      String fullTutorResponse = '';

      await for (final chunk in stream) {
        fullTutorResponse += chunk;
        final updatedMessages = List<ConversationMessage>.from(state.messages);
        updatedMessages[updatedMessages.length - 1] = ConversationMessage(
          sender: 'tutor',
          text: fullTutorResponse,
        );
        state = state.copyWith(messages: updatedMessages);
      }

      state = state.copyWith(isProcessing: false);
      _hasProcessedThisTurn = false;

      // 5. Speak response via TTS immediately & simultaneously with text display
      if (fullTutorResponse.isNotEmpty) {
        _speakTts(fullTutorResponse);
      }

      // 6. Run database persistence and analytics asynchronously in the background
      _asyncSaveAndAnalyzeSession(
        conversationId: _conversationId,
        fullTutorResponse: fullTutorResponse,
        userId: _userId,
        userText: userText,
        lesson: lesson,
      );
    } catch (e) {
      debugPrint('Conversation error: $e');
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Error al procesar la respuesta. Intenta de nuevo.',
      );
    }
  }

  void _asyncSaveAndAnalyzeSession({
    required String? conversationId,
    required String fullTutorResponse,
    required String? userId,
    required String userText,
    required LessonData? lesson,
  }) async {
    try {
      if (conversationId != null && fullTutorResponse.isNotEmpty) {
        await _repository.saveMessage(conversationId, 'assistant', fullTutorResponse);
      }

      if (userId != null && userText.isNotEmpty) {
        final wordCount = userText.trim().split(RegExp(r'\s+')).length;
        final int estimatedWpm = ((wordCount / 4.0) * 60).round().clamp(50, 200);
        const double latencySec = 1.8;
        _repository.logFluencyMetrics(userId, state.activeScenarioId, latencySec, estimatedWpm);

        if (lesson != null && lesson.usefulPhrases.isNotEmpty) {
          for (final phrase in lesson.usefulPhrases) {
            final firstWord = phrase.phrase.toLowerCase().split(' ').first;
            if (userText.toLowerCase().contains(firstWord)) {
              _repository.saveCompletedPhrase(userId, state.activeScenarioId!, conversationId, phrase.id, phrase.phrase, accuracy: 95);
            }
          }
        }
      }

      if (userId != null && conversationId != null) {
        await _repository.analyzeAndSaveSessionProgress(
          userId,
          conversationId,
          state.messages,
          scenarioId: state.activeScenarioId,
        );
      }

      if (lesson != null && lesson.goals.isNotEmpty) {
        _evaluateGoalsWithAi(lesson.goals);
      }
    } catch (e) {
      debugPrint('Background DB persistence error: $e');
    }
  }

  // ── On-Device TTS ───────────────────────────────────────────────────────────

  Future<void> _speakTts(String text) async {
    if (state.isPlaying) {
      await _tts.stop();
    }
    state = state.copyWith(isPlaying: true);
    await _tts.speak(text);
  }

  /// Sends only uncompleted goals to DeepSeek for evaluation.
  /// Merges results cumulatively — once achieved, never unmarked.
  Future<void> _evaluateGoalsWithAi(List<ScenarioGoalItem> goals) async {
    try {
      final uncompleted = goals
          .where((g) => state.goalEvaluationResults[g.id] != true)
          .toList();
      if (uncompleted.isEmpty) return;

      final conversationText = state.messages
          .map((m) => '${m.sender == 'user' ? 'Student' : 'Tutor'}: ${m.text}')
          .join('\n');

      final goalItems = uncompleted.map((g) => {
            'id': g.id,
            'text': g.text,
          }).toList();

      final results = await _repository.evaluateGoals(conversationText, goalItems);

      if (results.isNotEmpty) {
        final merged = Map<String, bool>.from(state.goalEvaluationResults);
        for (final e in results.entries) {
          if (e.value) {
            merged[e.key] = true;
            if (_userId != null && state.activeScenarioId != null) {
              final goalObj = goals.firstWhere(
                (g) => g.id == e.key,
                orElse: () => ScenarioGoalItem(id: e.key, text: 'Meta ${e.key}', keywords: []),
              );
              _repository.saveCompletedGoal(_userId!, state.activeScenarioId!, _conversationId, e.key, goalObj.text);
            }
          }
        }
        state = state.copyWith(goalEvaluationResults: merged);
      }
    } catch (e) {
      debugPrint('Goal evaluation failed (non-blocking): $e');
    }
  }

  Future<void> playTtsVoice(String text) async {
    await _speakTts(text);
  }

  Future<void> stopTts() async {
    await _tts.stop();
    state = state.copyWith(isPlaying: false);
  }

  /// End the conversation session — persists final data and refreshes dashboard.
  Future<void> endSession({int practiceMinutes = 1}) async {
    if (_userId != null) {
      try {
        final repo = _ref.read(dashboardRepositoryProvider);
        await repo.logPracticeSession(_userId!, practiceMinutes);
      } catch (_) {}
      try {
        _ref.invalidate(userProgressProvider);
        _ref.invalidate(userAchievementsProvider);
        _ref.invalidate(recommendedLessonsProvider);
        // Also increment the refresh trigger for non-autoDispose safety
        _ref.read(dashboardRefreshProvider.notifier).state++;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _tts.stop();
    super.dispose();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────────────────────────────────────

final conversationStateProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  final repo = ref.watch(conversationRepositoryProvider);
  return ConversationNotifier(repo, ref);
});

final micModeHoldToTalkProvider = StateProvider<bool>((ref) => false);
