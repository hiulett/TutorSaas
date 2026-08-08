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
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../../core/ai/placement_ai.dart';
import '../../../../core/i18n/language_settings.dart';
import '../../../../core/utils/text_diff_utils.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';

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
  DateTime? _recordingStartTimestamp;
  int? _assessmentStart;
  String? _assessmentId;
  int _turnCounter = 0;
  DateTime? _lastOracleQuestionAt;

  ConversationNotifier(this._repository, this._ref)
      : super(ConversationState.initial()) {
    _initTts();
  }

  // ── Session Init ────────────────────────────────────────────────────────────

  Future<void> initSession({String? scenarioId, String? scenarioTitle}) async {
    final user = _ref.read(currentUserProvider);
    _userId = user?.id ?? 'guest_user';

    // Reset completo del estado: nunca debe heredar flags de una sesión previa
    // (p.ej. isOracleEvaluation=true de la Evaluación del Oráculo del onboarding).
    state = ConversationState.initial();

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
        // Garantiza que el tutor inicia la conversación: solo reutiliza los
        // mensajes guardados si existe al menos un mensaje de tutor con texto
        // (evita chats vacíos por esquemas/cache viejos).
        final hasTutorMessage = savedMessages.any((m) => m.sender == 'tutor' && m.text.trim().isNotEmpty);
        if (savedMessages.isNotEmpty && hasTutorMessage) {
          state = state.copyWith(messages: savedMessages);
        } else if (lesson != null) {
          // First time (or broken history): set initial assistant message,
          // graded to the mission's CEFR level (from the catalog).
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

  // ── Oracle Evaluation Init ──────────────────────────────────────────────────

  /// Inicializa el examen conversacional del Oráculo (onboarding Paso 4).
  ///
  /// Reutiliza el mismo pipeline de voz (record→Groq STT→DeepSeek SSE→flutter_tts)
  /// y la misma UI del chat. La IA conduce la conversación como examinador oral:
  /// arranca en A1, sube la dificultad de forma adaptativa y al reunir evidencia
  /// suficiente cierra con `[EVALUATION_COMPLETE]`, que dispara la clasificación.
  Future<void> initOracleSession({
    String? targetLanguage,
    String? nativeLanguage,
  }) async {
    final user = _ref.read(currentUserProvider);
    _userId = user?.id ?? 'guest_user';

    final target = (targetLanguage?.isNotEmpty ?? false)
        ? targetLanguage!
        : _ref.read(userLanguageProvider).learningLanguage;
    final native = (nativeLanguage?.isNotEmpty ?? false)
        ? nativeLanguage!
        : _ref.read(userLanguageProvider).uiLanguage;

    state = ConversationState.initial().copyWith(
      isOracleEvaluation: true,
      oracleTargetLanguage: target,
      oracleNativeLanguage: native,
      activeScenarioId: 'oracle-evaluation',
      activeScenarioName: 'ORÁCULO',
    );
    _conversationId = null;
    _assessmentStart = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _turnCounter = 0;
    _assessmentId = null;
    _ref.read(activeConversationIdProvider.notifier).state = null;

    // Crea la sesión de evaluación en oracle_assessments para poder registrar
    // turnos (oracle_turns) durante la conversación.
    if (_userId != null && !_userId!.startsWith('guest_')) {
      try {
        final client = Supabase.instance.client;
        final row = await client.from('oracle_assessments').insert({
          'user_id': _userId,
          'cefr_level': 'A1',
          'game_rank': 'E',
          'target_language': target,
          'native_language': native,
          'ai_model': 'deepseek-v4-flash',
          'prompt_version': 'v2',
        }).select('id').single();
        _assessmentId = row['id'] as String?;
      } catch (e) {
        debugPrint('Oracle assessment session create failed: $e');
      }
    }

    // Persistencia de la conversación reutilizando la tabla `conversations`.
    try {
      final conv = await _repository.getOrCreateConversation(
        _userId!,
        scenarioId: 'oracle-evaluation',
      );
      _conversationId = conv['id'] as String?;
      _ref.read(activeConversationIdProvider.notifier).state = _conversationId;
    } catch (_) {}

    // El Oráculo inicia la conversación automáticamente.
    await _runOracleTurn(userText: '');
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

      if (_userId != null &&
          !_userId!.startsWith('guest_') &&
          !state.isOracleEvaluation) {
        try {
          final quota = await _repository.checkAiAudioQuota(_userId!);
          final isAllowed = quota['is_allowed'] as bool? ?? true;
          if (!isAllowed) {
            state = state.copyWith(
              isRecording: false,
              isProcessing: false,
              errorMessage: 'Has agotado tu límite de audio mensual. Adquiere el plan Premium para continuar.',
            );
            return;
          }
        } catch (_) {}
      }

      final tempDir = await getTemporaryDirectory();
      final recordingPath =
          '${tempDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

      _recordingStartTimestamp = DateTime.now();
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

      final recordingStart = _recordingStartTimestamp;
      if (recordingStart != null) {
        final durationSec = DateTime.now().difference(recordingStart).inSeconds;
        if (_userId != null && !_userId!.startsWith('guest_') && durationSec > 0) {
          try {
            await _repository.trackAiAudioTime(_userId!, durationSec);
          } catch (_) {}
        }
      }

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

  /// Guarda la táctica conversacional elegida por el jugador.
  void selectTactic(String tactic) {
    state = state.copyWith(selectedTactic: tactic);
  }

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

  // ── Oracle Evaluation Turn (onboarding Step 4) ──────────────────────────────

  /// Conduce un turno del examen oral del Oráculo.
  ///
  /// [userText] vacío = apertura: el Oráculo inicia la conversación con el
  /// saludo y la primera pregunta. En cualquier otro turno el Oráculo analiza
  /// la respuesta del jugador y decide la siguiente pregunta de forma
  /// adaptativa (sube/baja la dificultad CEFR, hace seguimiento, cambia de
  /// tema) reutilizando el mismo stream SSE de DeepSeek.
  Future<void> _runOracleTurn({required String userText}) async {
    try {
      // 1. Append user message (skip for the opening turn).
      if (userText.isNotEmpty) {
        state = state.copyWith(
          messages: [
            ...state.messages.where((m) => m.text.isNotEmpty),
            ConversationMessage(sender: 'user', text: userText),
          ],
          currentTranscribingText: '',
          isProcessing: true,
        );
        if (_conversationId != null) {
          await _repository.saveMessage(_conversationId!, 'user', userText);
        }
      }

      // 2. Build the Oracle examiner system prompt + history.
      final historyList = _buildOracleHistory();

      // 3. Add typing placeholder for the Oracle.
      final oraclePlaceholder = ConversationMessage(sender: 'tutor', text: '');
      state = state.copyWith(
        messages: [
          ...state.messages.where((m) => m.text.isNotEmpty),
          oraclePlaceholder,
        ],
        isProcessing: true,
      );

      // 4. Stream DeepSeek response.
      final stream = _repository.getTutorResponseStream(historyList);
      String fullOracleResponse = '';

      await for (final chunk in stream) {
        fullOracleResponse += chunk;
        final updatedMessages = List<ConversationMessage>.from(state.messages);
        updatedMessages[updatedMessages.length - 1] = ConversationMessage(
          sender: 'tutor',
          text: fullOracleResponse,
        );
        state = state.copyWith(messages: updatedMessages);
      }

      state = state.copyWith(isProcessing: false);
      _hasProcessedThisTurn = false;

      // 4b. Registrar el turno (respuesta del usuario + pregunta del Oráculo).
      if (userText.isNotEmpty) {
        await _recordOracleTurn(
          userText: userText,
          oracleResponse: fullOracleResponse,
        );
      }

      // 5. Evaluate completion: the Oracle signals the end of the exam with
      //    the [EVALUATION_COMPLETE] marker, then the classifier runs.
      if (fullOracleResponse.contains('[EVALUATION_COMPLETE]')) {
        // Extraer el resultado declarado por el Oráculo (lo que el usuario vio).
        String? declaredCefr;
        String? declaredRank;
        final resultMatch = RegExp(r'\[RESULT:CEFR=([ABC][12]),RANK=([A-Z]+)\]')
            .firstMatch(fullOracleResponse);
        if (resultMatch != null) {
          declaredCefr = resultMatch.group(1)?.toUpperCase();
          declaredRank = resultMatch.group(2)?.toUpperCase();
        }

        final cleaned = fullOracleResponse
            .replaceAll('[EVALUATION_COMPLETE]', '')
            .replaceAll(RegExp(r'\[RESULT:[^\]]*\]'), '')
            .trim();
        if (cleaned.isNotEmpty) {
          final updatedMessages = List<ConversationMessage>.from(state.messages);
          updatedMessages[updatedMessages.length - 1] =
              ConversationMessage(sender: 'tutor', text: cleaned);
          state = state.copyWith(messages: updatedMessages);
          if (_conversationId != null) {
            await _repository.saveMessage(_conversationId!, 'assistant', cleaned);
          }
        }
        await _finalizeOracleEvaluation(
          declaredCefr: declaredCefr,
          declaredRank: declaredRank,
        );
        return;
      }

      // 6. Otherwise speak the question and persist.
      if (fullOracleResponse.isNotEmpty) {
        _lastOracleQuestionAt = DateTime.now();
        _speakTts(fullOracleResponse);
      }
      if (_conversationId != null && fullOracleResponse.isNotEmpty) {
        await _repository.saveMessage(
            _conversationId!, 'assistant', fullOracleResponse);
      }
    } catch (e) {
      debugPrint('Oracle turn error: $e');
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Error al procesar la respuesta. Intenta de nuevo.',
      );
    }
  }

  /// Registra un turno de la evaluación en `oracle_turns` (best-effort).
  /// Guarda la pregunta del Oráculo, la respuesta del usuario, el tiempo de
  /// respuesta y una evaluación parcial simple basada en la longitud de la
  /// respuesta (la evaluación fina la hace la IA al cerrar).
  Future<void> _recordOracleTurn({
    required String userText,
    required String oracleResponse,
  }) async {
    if (_assessmentId == null) return;
    try {
      final question = state.messages
          .where((m) => m.sender == 'tutor' && m.text.isNotEmpty)
          .lastOrNull
          ?.text;
      // Pregunta real = la respuesta del Oráculo inmediatamente anterior a la
      // respuesta del usuario actual (no la placeholder).
      final prevTutor = state.messages
          .where((m) => m.sender == 'tutor' && m.text.isNotEmpty && m.text != oracleResponse)
          .lastOrNull
          ?.text;

      final responseTime = _lastOracleQuestionAt != null
          ? DateTime.now().difference(_lastOracleQuestionAt!).inMilliseconds / 1000.0
          : null;
      final wordCount = userText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      // Heurística parcial: 0-100 según longitud y variedad de la respuesta.
      final partial = (wordCount * 6).clamp(0, 100);

      _turnCounter++;
      final client = Supabase.instance.client;
      await client.from('oracle_turns').insert({
        'assessment_id': _assessmentId,
        'turn_order': _turnCounter,
        'cefr_level': 'A1', // nivel real lo fija la IA en el cierre; provisional
        'question_text': prevTutor ?? question ?? '',
        'answer_transcript': userText,
        'response_time_sec': responseTime,
        'partial_score': partial,
      });
    } catch (e) {
      debugPrint('Oracle turn record failed (non-blocking): $e');
    }
  }

  /// Construye el historial de mensajes para el examinador Oráculo, con el
  /// system prompt de examen oral adaptativo CEFR (A1→C2) — v2.
  List<Map<String, String>> _buildOracleHistory() {
    final target = state.oracleTargetLanguage;
    final native = state.oracleNativeLanguage;
    final systemPrompt = '''
You are the Oracle of the Guild, an ancient and wise being that examines young adventurers with a natural spoken conversation. You are conducting an ORAL PLACEMENT EXAM in $target for a student whose native language is $native. The exam must feel like a pleasant chat with a guild mentor, never like a form or a test.

OPENING (FIRST TURN ONLY):
Say exactly this warm greeting, then ask if they are ready:
"Hello! Welcome to the Adventurer's Guild. My name is Oracle. Before assigning your first missions I'd like to know you a little better. Don't worry — this isn't an exam, just speak naturally. Are you ready?"

CONVERSATION RULES:
- Always speak ONLY in $target. Never use $native (except one short hint if the student is completely stuck).
- Be warm, friendly and encouraging. Never make the student feel judged.
- Adapt dynamically: ask follow-ups related to the previous answer, clarify, deepen, or change topic naturally. Never read a fixed list.
- Keep each turn short (1-2 sentences plus one question).
- Do NOT correct or teach during the exam. You are assessing, not tutoring.

CEFR PROGRESSION (ask ~5 questions per band, adapting to the student's level):
- A1 (basic vocabulary): name, where from, age, likes, family.
- A2 (simple sentences, past simple, more vocabulary): daily routine, what did you do yesterday, family, favorite food, hometown.
- B1 (opinions, narrations, everyday topics): a difficult situation you solved, free time, dream vacation, ideal job, opinion about learning languages.
- B2 (structured thought, argumentation): pros and cons of remote work, a memorable experience, an important decision, convince someone to visit your country, important skills today.
- C1 (complex language, connectors, abstraction): impact of AI, technology in education, an ethical dilemma, compare two cultures, what makes a good leader.
- C2 (fully natural, advanced, abstract): freedom vs responsibility, culture shapes identity, globalization effects, success: effort vs opportunity, society in 50 years.

PROGRESSION RULES:
- Start at A1. After each answer, silently assess it.
- Move to the NEXT band only when the student answers well (roughly 3 of the last 5 with sufficient fluency and comprehension).
- If the student gives very short answers (1-2 words), repeats errors, or clearly struggles on 2 consecutive questions in the current band, STOP: the student's level is the last band they dominated. Do NOT push to a higher band they cannot handle.
- Never advance just because you reached a count of questions — advance based on ability.

METRICS TO TRACK SILENTLY (never mention them to the student): pronunciation, fluency, grammar, vocabulary, listening comprehension, ability to keep the conversation going, naturalness, correctness, language complexity, confidence, response time, coherence between questions and answers.

ENDING:
- Once you have determined the final level (either by climbing to C2 or by the student struggling on 2 consecutive questions), close the exam.
- Your FINAL message must:
  1. Congratulate the student in an immersive, mystical tone and state the assigned CEFR level and Guild rank (use the scale E, D, C, B, A, S, SS, SSS where A1=E, A2=D, B1=C, B2=B, C1=A, C2=S).
  2. Say a short mystical closing line in $target.
  3. End with EXACTLY this machine-readable token on its own line, with NO extra text after it:
[EVALUATION_COMPLETE][RESULT:CEFR=B1,RANK=C]
  (replace B1/C with the real assigned level/rank — for example A1/E, A2/D, B2/B, C1/A, C2/S)
- Never use either token before the final message.''';

    return [
      {'role': 'system', 'content': systemPrompt},
      ...state.messages.map((m) => {
            'role': m.sender == 'user' ? 'user' : 'assistant',
            'content': m.text,
          }),
    ];
  }

  /// Clasifica el resultado del examen. Usa como fuente PRINCIPAL el nivel y
  /// rango que el propio Oráculo declaró en su mensaje final
  /// ([RESULT:CEFR=..,RANK=..]) — lo que el usuario vio en la conversación.
  /// `PlacementAiEvaluator` se usa solo como respaldo si faltan o son inválidos.
  Future<void> _finalizeOracleEvaluation({
    String? declaredCefr,
    String? declaredRank,
  }) async {
    try {
      state = state.copyWith(isProcessing: true, oracleEvaluating: true);

      final answers = state.messages
          .where((m) => m.sender == 'user')
          .map((m) => m.text)
          .where((t) => t.trim().isNotEmpty)
          .toList();

      Map<String, dynamic> ai = const {};
      try {
        // Reutiliza el mismo Dio del chat (misma autenticación DeepSeek).
        final dio = _ref.read(conversationDioProvider);
        ai = await PlacementAiEvaluator.evaluatePlacement(answers, dio: dio);
      } catch (_) {}

      final validCefrs = const ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
      final aiCefr = _stringField(ai, 'cefr_level', '').toUpperCase();
      final aiRank = _stringField(ai, 'game_rank', '').toUpperCase();

      // Prioridad: lo declarado por el Oráculo > evaluación IA > fallback A1/E.
      String cefrLevel = (declaredCefr != null && validCefrs.contains(declaredCefr))
          ? declaredCefr
          : (validCefrs.contains(aiCefr) ? aiCefr : 'A1');
      String gameRank = (declaredRank != null && declaredRank.isNotEmpty)
          ? declaredRank
          : (aiRank.isNotEmpty ? aiRank : CefrRank.gameRankFromCefr(cefrLevel));

      // Validación cruzada: si el rango declarado no es coherente con el CEFR
      // (marcador mal formado), se deriva del CEFR elegido.
      if (declaredRank == null || declaredRank.isEmpty) {
        gameRank = CefrRank.gameRankFromCefr(cefrLevel);
      }

      final explanation = _stringField(
        ai,
        'explanation',
        'El Oráculo ha hablado. Nivel $cefrLevel desbloqueado.',
      );
      final strengths = _stringListField(ai, 'strengths');
      final weaknesses = _stringListField(ai, 'weaknesses');
      final recommendedFocus = _stringField(ai, 'recommended_focus', '');

      final result = <String, dynamic>{
        'cefrLevel': cefrLevel,
        'gameRank': gameRank,
        'scores': ai['scores'] ?? const <String, dynamic>{},
        'strengths': strengths,
        'weaknesses': weaknesses,
        'explanation': explanation,
        'recommendedFocus': recommendedFocus,
        'answers': answers,
      };

      // Persistencia en user_language_profiles (columnas de onboarding_revamp).
      if (_userId != null && !_userId!.startsWith('guest_')) {
        await _persistOracleAssessment(
          userId: _userId!,
          cefrLevel: cefrLevel,
          gameRank: gameRank,
          scores: result['scores'],
          strengths: strengths,
          weaknesses: weaknesses,
          explanation: explanation,
          recommendedFocus: recommendedFocus,
          answers: answers,
        );
      }

      // Mensaje épico del Oráculo con el resultado, narrado con su voz.
      final closing = _buildOracleClosingMessage(
        cefrLevel: cefrLevel,
        gameRank: gameRank,
      );

      final updatedMessages = [
        ...state.messages.where((m) => m.text.isNotEmpty),
        ConversationMessage(sender: 'tutor', text: closing),
      ];
      if (_conversationId != null) {
        try {
          await _repository.saveMessage(_conversationId!, 'assistant', closing);
        } catch (_) {}
      }

      state = state.copyWith(
        messages: updatedMessages,
        isProcessing: false,
        oracleEvaluating: false,
        oracleFinished: true,
        oracleResult: result,
      );

      // Narrar el resultado con la voz del Oráculo.
      _speakTts(closing);
    } catch (e) {
      debugPrint('Oracle evaluation finalize error: $e');
      state = state.copyWith(isProcessing: false, oracleEvaluating: false);
    }
  }

  /// Construye el mensaje épico y breve de cierre del Oráculo con el resultado.
  String _buildOracleClosingMessage({
    required String cefrLevel,
    required String gameRank,
  }) {
    // Mensaje corto y directo: nivel + rango, sin extender.
    return 'Excellent. Your communication level is $cefrLevel. '
        'You will begin as a Rank $gameRank Adventurer. '
        'Welcome to the Guild.';
  }

  /// Upsert de la clasificación del Oráculo. Silencioso si la BD aún no tiene
  /// las columnas o la tabla (read-only project): no rompe el flujo.
  Future<void> _persistOracleAssessment({
    required String userId,
    required String cefrLevel,
    required String gameRank,
    required dynamic scores,
    required List<String> strengths,
    required List<String> weaknesses,
    required String explanation,
    required String recommendedFocus,
    required List<String> answers,
  }) async {
    try {
      final client = Supabase.instance.client;
      int cefrId = 1;
      try {
        final row = await client
            .from('cefr_levels')
            .select('id')
            .eq('code', cefrLevel)
            .maybeSingle();
        if (row != null) cefrId = row['id'] as int;
      } catch (_) {}

      await client.from('user_language_profiles').upsert({
        'user_id': userId,
        'language_id': 1,
        'cefr_level_id': cefrId,
        'game_rank': gameRank,
        'placement_scores': scores,
        'placement_strengths': strengths,
        'placement_weaknesses': weaknesses,
        'placement_explanation': explanation,
        if (recommendedFocus.isNotEmpty)
          'placement_recommended_focus': recommendedFocus,
        'placement_assessed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, language_id');
    } catch (_) {}

    try {
      final client = Supabase.instance.client;
      final Map<String, dynamic> scoresMap =
          scores is Map ? Map<String, dynamic>.from(scores) : const {};
      int _score(String key) =>
          (scoresMap[key] as num?)?.toInt() ?? 0;

      final payload = <String, dynamic>{
        'cefr_level': cefrLevel,
        'game_rank': gameRank,
        'target_language': state.oracleTargetLanguage,
        'native_language': state.oracleNativeLanguage,
        'scores': scores,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'explanation': explanation,
        'ai_model': 'deepseek-v4-flash',
        'prompt_version': 'v2',
        'stopped_at_cefr': cefrLevel,
        'duration_seconds': _assessmentDurationSeconds,
        if (_score('pronunciation') > 0) 'scores_pronunciation': _score('pronunciation'),
        if (_score('fluency') > 0) 'scores_fluency': _score('fluency'),
        if (_score('grammar') > 0) 'scores_grammar': _score('grammar'),
        if (_score('vocabulary') > 0) 'scores_vocabulary': _score('vocabulary'),
        if (_score('listening') > 0) 'scores_comprehension': _score('listening'),
        if (_score('naturalness') > 0) 'scores_naturalness': _score('naturalness'),
        if (recommendedFocus.isNotEmpty)
          'recommended_focus': recommendedFocus,
        'answers': answers,
      };

      if (_assessmentId != null) {
        // Actualiza la sesión creada en initOracleSession (guarda los turns).
        await client
            .from('oracle_assessments')
            .update(payload)
            .eq('id', _assessmentId!);
      } else {
        // Fallback: si no había sesión previa, inserta una.
        await client.from('oracle_assessments').insert({
          'user_id': userId,
          ...payload,
        });
      }
    } catch (_) {}
  }

  int get _assessmentDurationSeconds {
    final start = _assessmentStart;
    if (start == null) return 0;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 - start;
  }

  String _stringField(Map<String, dynamic> map, String key, String fallback) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is num) return value.toString();
    return fallback;
  }

  List<String> _stringListField(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is List) {
      return value.whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    }
    return const [];
  }

  // ── Process Transcription / Text → LLM → Supabase → TTS ────────────────────

  Future<void> _processTranscription(String userText) async {
    if (_hasProcessedThisTurn) return;
    _hasProcessedThisTurn = true;

    // Modo Oráculo: la evaluación conversacional no consume invocaciones del
    // Núcleo Arcano ni aplica correcciones de tutor — solo conduce la entrevista.
    if (state.isOracleEvaluation) {
      await _runOracleTurn(userText: userText);
      return;
    }

    // Núcleo Arcano: las invocaciones limitan los turnos de IA (T-506).
    if (_userId != null) {
      try {
        final economyRepo = _ref.read(economyRepositoryProvider);
        final canInvoke = await economyRepo.canInvoke(_userId!);
        if (!canInvoke) {
          state = state.copyWith(
            isProcessing: false,
            errorMessage: 'NÚCLEO ARCANO AGOTADO. VISITA LA TIENDA PARA RECARGAR.',
          );
          return;
        }
        await economyRepo.useInvocation(_userId!);
      } catch (_) {}
    }

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
            final double similarity = TextDiffUtils.calculateSimilarity(phrase.phrase, userText);
            if (similarity >= 50.0) {
              await _repository.saveCompletedPhrase(
                userId,
                state.activeScenarioId!,
                conversationId,
                phrase.id,
                phrase.phrase,
                accuracy: similarity.round(),
              );
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

      // Ventana móvil (IA-03): evaluar solo la porción más reciente de la
      // conversación para acotar el costo de tokens.
      final recent = state.messages.length > 12
          ? state.messages.sublist(state.messages.length - 12)
          : state.messages;

      final conversationText = recent
          .map((m) => '${m.sender == 'user' ? 'Student' : 'Tutor'}: ${m.text}')
          .join('\n');

      final goalItems = uncompleted.map((g) => {
            'id': g.id,
            'text': g.text,
          }).toList();

      final results = await _repository.evaluateGoals(conversationText, goalItems);

      if (results.isNotEmpty) {
        final merged = Map<String, bool>.from(state.goalEvaluationResults);
        int newlyCompleted = 0;
        for (final e in results.entries) {
          if (e.value) {
            if (merged[e.key] != true) newlyCompleted++;
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
        state = state.copyWith(
          goalEvaluationResults: merged,
          newGoalsCompleted: state.newGoalsCompleted + newlyCompleted,
        );
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

      // Loot/drops (T-505) + balance (T-507): escalado por nivel CEFR.
      try {
        final economyRepo = _ref.read(economyRepositoryProvider);
        final completedGoals = state.goalEvaluationResults.values.where((v) => v).length;
        if (completedGoals > 0) {
          // Bonus por nivel: A1=0, A2=1, B1=2, B2=3, C1=4, C2=5
          final levelCode = (_ref.read(userProgressProvider).value?['level_code'] as String?) ?? 'A1';
          final levelBonus = switch (levelCode.toUpperCase()) {
            'A2' => 1,
            'B1' => 2,
            'B2' => 3,
            'C1' => 4,
            'C2' => 5,
            _ => 0,
          };
          final fragments = completedGoals * (5 + levelBonus);
          final gems = completedGoals * (2 + levelBonus);
          await economyRepo.addFragments(_userId!, fragments);
          await economyRepo.addGems(_userId!, gems);

          // Bonus de stats RPG (STR/INT/DEX/LUK → XP real):
          // cada punto por encima de la base (5) suma XP por meta completada.
          final profile = _ref.read(userProfileProvider).value;
          final str = (profile?['str_stat'] as num?)?.toInt() ?? 5;
          final intt = (profile?['int_stat'] as num?)?.toInt() ?? 5;
          final dex = (profile?['dex_stat'] as num?)?.toInt() ?? 5;
          final luk = (profile?['luk_stat'] as num?)?.toInt() ?? 5;
          final statBonus = ((str - 5) + (intt - 5) + (dex - 5) + (luk - 5)) * completedGoals;
          if (statBonus > 0) {
            final client = Supabase.instance.client;
            await client.rpc('add_xp', params: {
              'p_user_id': _userId,
              'p_amount': statBonus,
            });
          }
        }
        await economyRepo.updateStreak(_userId!);
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
