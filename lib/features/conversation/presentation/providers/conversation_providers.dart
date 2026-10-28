import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../domain/models/ai_stream_exception.dart';
import '../../domain/models/conversation_message.dart';
import '../../domain/models/conversation_state.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';
import '../../../dashboard/data/models/hunter_skill_titles.dart';
import '../../../dashboard/domain/services/lesson_generator_service.dart';
import '../../../dashboard/domain/models/lesson_unlock_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../../core/ai/placement_ai.dart';
import '../../../../core/i18n/language_settings.dart';
import '../../../../core/utils/text_diff_utils.dart';
import '../../../../core/services/retention_analytics.dart';
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

/// Issue #76: resultado de la última visita a una escena.
/// Se usa para que el mundo «recuerde» el intento anterior (chip en la
/// conversación) sin volver a llamar al modelo.
final scenarioProgressProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, scenarioId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  try {
    final res = await ref
        .watch(supabaseClientProvider)
        .from('scenario_progress')
        .select('last_outcome, attempts, unlocked_next, best_ratio')
        .eq('user_id', user.id)
        .eq('scenario_id', scenarioId)
        .maybeSingle();
    return res == null ? null : Map<String, dynamic>.from(res as Map);
  } catch (e) {
    debugPrint('scenario_progress read failed: $e');
    return null;
  }
});

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
  bool _ttsReady = false;
  bool _ttsSuppressed = false;

  bool _hasProcessedThisTurn = false;
  String? _conversationId;
  String? _userId;
  DateTime? _recordingStartTimestamp;
  int? _assessmentStart;
  String? _assessmentId;
  int _turnCounter = 0;
  DateTime? _lastOracleQuestionAt;

  /// Idempotencia del cierre de sesión: garantiza que `endSession` se ejecute
  /// una sola vez aunque la salida ocurra por varias vías (pop, back, go, dispose).
  bool _sessionFinalized = false;
  Map<String, dynamic>? _lastSessionResult;
  String? _lastUserText;
  String? _lastActionCode;
  String? _turnRef;
  bool _oracleEvalCharged = false;

  ConversationNotifier(this._repository, this._ref)
      : super(ConversationState.initial()) {
    _initTts();
  }

  // ── Session Init ────────────────────────────────────────────────────────────

  Future<void> initSession({String? scenarioId, String? scenarioTitle}) async {
    final user = _ref.read(currentUserProvider);
    _userId = user?.id ?? 'guest_user';
    _sessionFinalized = false; // nueva sesión → se permite cerrar de nuevo

    // Reset completo del estado: nunca debe heredar flags de una sesión previa
    // (p.ej. isOracleEvaluation=true de la Evaluación del Oráculo del onboarding).
    state = ConversationState.initial();
    // Nueva sesión → se permite narrar de nuevo (se cancela la supresión previa).
    _ttsSuppressed = false;

    // Fetch latest scenario fields from Supabase DB to sync any edits saved from web_admin.
    // Issue #1: las lecciones usan claves del catálogo Dart (texto) contra
    // `scenarios.id`, que es UUID. Consultar con una clave de texto lanzaba
    // 22P02 dentro de un try/catch vacío: una petición perdida en cada apertura.
    final bool scenarioIdIsUuid = scenarioId != null &&
        RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
            .hasMatch(scenarioId);
    if (scenarioIdIsUuid || (scenarioTitle != null && scenarioTitle.isNotEmpty)) {
      try {
        final client = Supabase.instance.client;
        var query = client.from('scenarios').select('*');
        if (scenarioIdIsUuid) {
          query = query.eq('id', scenarioId);
        } else {
          query = query.ilike('title', '%$scenarioTitle%');
        }
        final res = await query.maybeSingle();
        if (res != null) {
          final uiLang = _ref.read(userLanguageProvider).uiLanguage;
          LessonCatalog.updateCatalogFromMap(res, locale: uiLang);
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

    // Issue #35: evento de inicio de sesión (estaba documentado pero nunca se
    // emitía). Best-effort: no bloquea ni falla el flujo.
    unawaited(RetentionAnalytics.instance.track(
      _userId!,
      'session_start',
      properties: {
        'scenario_id': scenarioId ?? '',
        'oracle': false,
      },
    ));

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
          // Si la conversación sigue en el arranque (solo el saludo del tutor,
          // sin turnos del usuario), se narra para que el Oráculo salude al
          // reanudar una conversación aún vacía.
          final hasUserTurns = savedMessages.any(
            (m) => m.sender == 'user' && m.text.trim().isNotEmpty,
          );
          if (!hasUserTurns) {
            final opening = savedMessages.first.text.trim();
            if (opening.isNotEmpty) await _speakTts(opening);
          }
        } else if (lesson != null) {
          // First time (or broken history): set initial assistant message,
          // graded to the mission's CEFR level (from the catalog).
          final opening = lesson.initialAssistantMessage;
          state = state.copyWith(messages: [
            ConversationMessage(sender: 'tutor', text: opening),
          ]);
          _repository.saveMessage(_conversationId!, 'assistant', opening);
          // Narra el primer mensaje del Oráculo NPC al abrir el chat.
          await _speakTts(opening);
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
        final opening = lesson.initialAssistantMessage;
        state = state.copyWith(messages: [
          ConversationMessage(sender: 'tutor', text: opening),
        ]);
        await _speakTts(opening);
      } else {
        const opening = 'Hello! How can I help you practice today?';
        state = state.copyWith(messages: const [
          ConversationMessage(sender: 'tutor', text: opening),
        ]);
        await _speakTts(opening);
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
    _sessionFinalized = false; // evaluación nueva → cerrar permitido

    final target = (targetLanguage?.isNotEmpty ?? false)
        ? targetLanguage!
        : _ref.read(userLanguageProvider).learningLanguage;
    // Fallback del nativo: primero el explícito, luego el guardado en BD
    // (users.native_language, seteado en el onboarding), nunca el idioma de UI.
    final storedNative = (_ref.read(userProfileProvider).value ?? const {})['native_language'] as String?;
    final native = (nativeLanguage?.isNotEmpty ?? false)
        ? nativeLanguage!
        : ((storedNative?.isNotEmpty ?? false) ? storedNative! : 'es');

    // Nueva sesión del Oráculo → se permite narrar de nuevo.
    _ttsSuppressed = false;

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
    try {
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
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
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

      if (_userId != null && !_userId!.startsWith('guest_')) {
        try {
          final economyRepo = _ref.read(economyRepositoryProvider);
          final mana = await economyRepo.getManaState(_userId!);
          final remaining = (mana['remaining'] as num?)?.toInt() ?? 0;
          if (remaining <= 0) {
            state = state.copyWith(
              isRecording: false,
              isProcessing: false,
              errorMessage: 'SIN MANÁ: adquiere una porción o espera la renovación de tu plan para continuar.',
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
            // No bloquea el turno: el tracking de audio es best-effort.
            unawaited(_repository.trackAiAudioTime(_userId!, durationSec));
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

        var transcription = await _repository.transcribeAudio(audioPath);
        if (transcription.trim().isEmpty) {
          // Reintento único de recuperación: Groq a veces devuelve vacío en
          // clips muy cortos por un fallo transitorio del proveedor.
          debugPrint('Groq STT: empty result, retrying once...');
          transcription = await _repository.transcribeAudio(audioPath);
        }

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
      _ref.read(conversationErrorProvider.notifier).state = ConversationErrorState(
        message: 'No pudimos transcribir tu audio. Reintenta el audio o escribe tu respuesta.',
        kind: AiErrorKind.stt,
        canRetry: false,
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
      final stream = _repository.getTutorResponseStream(
        historyList,
        actionCode: 'oracle_turn',
        conversationId: _conversationId,
      );
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

      // 4b. Registrar el turno sin bloquear la narración (best-effort DB).
      if (userText.isNotEmpty) {
        unawaited(_recordOracleTurn(
          userText: userText,
          oracleResponse: fullOracleResponse,
        ));
      }

      // 5. Evaluate completion: the Oracle signals the end of the exam with
      //    the [EVALUATION_COMPLETE] marker, then the classifier runs.
      if (fullOracleResponse.contains('[EVALUATION_COMPLETE]')) {
        // Extraer el resultado declarado por el Oráculo (lo que el usuario vio).
        String? declaredCefr;
        String? declaredRank;
        final resultMatch = RegExp(r'\[RESULT:CEFR=(PRE-A1|[ABC][12]),RANK=([A-Z]+)\]')
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
  /// Issue #25: vuelca las puntuaciones del evaluador a `oracle_turns` (las lee
  /// el radar del dashboard) y a `speech_dna_metrics` (claridad fonética).
  Future<void> _persistSkillScores(Map<String, dynamic> ai) async {
    final userId = _userId;
    if (userId == null || userId.startsWith('guest_')) return;

    final scores = (ai['scores'] as Map?)?.cast<String, dynamic>();
    if (scores == null || scores.isEmpty) return;

    int? v(String key) => (scores[key] as num?)?.toInt();

    final pron = v('pronunciation');
    final fluency = v('fluency') ?? v('speaking');
    final grammar = v('grammar');
    final vocab = v('vocabulary');
    final comprehension = v('listening');
    final naturalness = v('naturalness') ?? v('sentence_structure');

    final row = <String, dynamic>{
      if (pron != null) 'pronunciation_score': pron,
      if (fluency != null) 'fluency_score': fluency,
      if (grammar != null) 'grammar_score': grammar,
      if (vocab != null) 'vocabulary_score': vocab,
      if (comprehension != null) 'comprehension_score': comprehension,
      if (naturalness != null) 'naturalness_score': naturalness,
    };
    if (row.isEmpty) return;

    try {
      final client = Supabase.instance.client;
      final assessment = await client
          .from('oracle_assessments')
          .select('id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (assessment == null) return;

      final turn = await client
          .from('oracle_turns')
          .select('id')
          .eq('assessment_id', assessment['id'])
          .order('turn_order', ascending: false)
          .limit(1)
          .maybeSingle();
      if (turn == null) return;

      await client.from('oracle_turns').update(row).eq('id', turn['id']);

      if (pron != null) {
        await client.from('speech_dna_metrics').upsert({
          'user_id': userId,
          'phonetic_clarity_score': pron,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }
    } catch (e) {
      debugPrint('Oracle skill scores failed (non-blocking): $e');
    }
  }

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
  ///
  /// Si el usuario ya tiene un nivel asignado (no es placement inicial), la
  /// evaluación es de PROMOCIÓN: arranca en el nivel actual y evalúa subir o
  /// mantener (nunca baja). Se inyecta el contexto del historial (skills radar,
  /// debilidades) para evaluar "en base a lo aprendido".
  List<Map<String, String>> _buildOracleHistory() {
    final target = state.oracleTargetLanguage;
    final native = state.oracleNativeLanguage;

    // Nivel actual del usuario (placement previo o asignado en onboarding).
    final currentLevel =
        (_ref.read(userProgressProvider).value?['level_code'] as String?) ?? '';
    // Promoción = el usuario ya tiene un nivel asignado (re-evaluación para
    // subir); placement inicial = sin nivel previo.
    final isPromotion = currentLevel.isNotEmpty;

    // Contexto del historial para la evaluación contextual (skills + debilidades).
    final radar = _ref.read(skillsRadarProvider).value ?? const {};
    final profile = _ref.read(userProfileProvider).value ?? const {};
    final weaknesses = (profile['placement_weaknesses'] as List?) ?? const [];

    final startingLine = isPromotion
        ? 'PROGRESSION RULES:\n- Start at the student CURRENT level ($currentLevel). Assess whether they have IMPROVED enough to move UP one band. If they perform at or below their current level, keep them at $currentLevel (NEVER assign a lower level).'
        : 'PROGRESSION RULES:\n- Start at A1. After each answer, silently assess it.';

    final contextLine = isPromotion
        ? 'STUDENT CONTEXT (use to focus the exam on their known gaps):\n'
              '- Current level: $currentLevel\n'
              '- Skill radar: ${radar.isNotEmpty ? radar.toString() : "unknown"}\n'
              '- Known weaknesses: ${weaknesses.isNotEmpty ? weaknesses.toString() : "none recorded"}\n'
              'Focus questions on their weakest skills to confirm real improvement.\n'
        : '';

    final systemPrompt = '''
You are the Oracle of the Guild, an ancient and wise being that examines young adventurers with a natural spoken conversation. You are conducting an ${isPromotion ? 'PROMOTION EXAM' : 'ORAL PLACEMENT EXAM'} in $target for a student whose native language is $native. The exam must feel like a pleasant chat with a guild mentor, never like a form or a test.

OPENING (FIRST TURN ONLY):
${isPromotion
  ? 'Say a warm, mystical greeting, acknowledge they have trained and return to be re-assessed at level $currentLevel, then ask if they are ready.'
  : 'Say exactly this warm greeting, then ask if they are ready:\n"Hello! Welcome to the Adventurer\'s Guild. My name is Oracle. Before assigning your first missions I\'d like to know you a little better. Don\'t worry — this isn\'t an exam, just speak naturally. Are you ready?"'}

CONVERSATION RULES:
- Always speak ONLY in $target. Never use $native (except one short hint if the student is completely stuck).
- Be warm, friendly and encouraging. Never make the student feel judged.
- Adapt dynamically: ask follow-ups related to the previous answer, clarify, deepen, or change topic naturally. Never read a fixed list.
- Keep each turn short (1-2 sentences plus one question).
- Do NOT correct or teach during the exam. You are assessing, not tutoring.

$contextLine
CEFR PROGRESSION (ask ~5 questions per band, adapting to the student's level):
- PRE-A1 (single words, minimal vocabulary, no sentences): say hello, your name, yes/no, numbers, colors. One-word answers are perfectly acceptable.
- A1 (basic vocabulary): name, where from, age, likes, family.
- A2 (simple sentences, past simple, more vocabulary): daily routine, what did you do yesterday, family, favorite food, hometown.
- B1 (opinions, narrations, everyday topics): a difficult situation you solved, free time, dream vacation, ideal job, opinion about learning languages.
- B2 (structured thought, argumentation): pros and cons of remote work, a memorable experience, an important decision, convince someone to visit your country, important skills today.
- C1 (complex language, connectors, abstraction): impact of AI, technology in education, an ethical dilemma, compare two cultures, what makes a good leader.
- C2 (fully natural, advanced, abstract): freedom vs responsibility, culture shapes identity, globalization effects, success: effort vs opportunity, society in 50 years.

$startingLine
- Move to the NEXT band only when the student answers well (roughly 3 of the last 5 with sufficient fluency and comprehension).
- If the student can ONLY produce isolated words (one-word answers), cannot form even a basic A1 sentence, or clearly struggles on 2 consecutive questions in the current band, STOP: the student's level is the last band they dominated. If they never dominate A1, assign PRE-A1.
- Never advance just because you reached a count of questions — advance based on ability.

METRICS TO TRACK SILENTLY (never mention them to the student): pronunciation, fluency, grammar, vocabulary, listening comprehension, ability to keep the conversation going, naturalness, correctness, language complexity, confidence, response time, coherence between questions and answers.

ENDING:
- Once you have determined the final level (either by climbing to C2 or by the student struggling on 2 consecutive questions), close the exam.
- Your FINAL message must:
  1. Congratulate the student in an immersive, mystical tone and state the assigned CEFR level and Guild rank (use the scale F, E, D, C, B, A, S, SS, SSS where PRE-A1=F, A1=E, A2=D, B1=C, B2=B, C1=A, C2=S).
  2. Say a short mystical closing line in $target.
  3. End with EXACTLY this machine-readable token on its own line, with NO extra text after it:
[EVALUATION_COMPLETE][RESULT:CEFR=B1,RANK=C]
  (replace B1/C with the real assigned level/rank — for example PRE-A1/F, A1/E, A2/D, B2/B, C1/A, C2/S)
- Never use either token before the final message.''';

    // Ventana fija de contexto: enviar todo el historial hace crecer los
    // tokens de entrada con cada turno y dispara la latencia del primer token
    // de DeepSeek. Se conservan los últimos 24 mensajes (≈12 turnos), que dan
    // contexto suficiente para la progresión adaptativa del examen.
    const int maxContextMessages = 24;
    final contextMessages = state.messages
        .where((m) => m.text.trim().isNotEmpty)
        .toList();
    final window = contextMessages.length > maxContextMessages
        ? contextMessages.sublist(contextMessages.length - maxContextMessages)
        : contextMessages;

    return [
      {'role': 'system', 'content': systemPrompt},
      ...window.map((m) => {
            'role': m.sender == 'user' ? 'user' : 'assistant',
            'content': _stripControlTokens(m.text),
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

      // Issue #47: el cierre del examen se cobra una sola vez (oracle_eval=30).
      // Los turnos intermedios ya se cobraron como oracle_turn (15).
      if (!_oracleEvalCharged &&
          _userId != null &&
          !_userId!.startsWith('guest_')) {
        _oracleEvalCharged = true;
        try {
          final economyRepo = _ref.read(economyRepositoryProvider);
          final charge = await economyRepo.consumeMana(_userId!, 'oracle_eval');
          if (charge['success'] == true) {
            _applyOptimisticManaDeduction('oracle_eval', charge);
            _ref.invalidate(manaStateProvider);
          }
        } catch (_) {}
      }

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

      // Issue #25: persistir las 6 dimensiones que lee el radar de habilidades.
      // Hasta ahora solo se guardaba `partial_score`, así que el radar mostraba
      // ceros en pronunciación, gramática, vocabulario, comprensión y naturalidad.
      unawaited(_persistSkillScores(ai));

      final validCefrs = const ['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
      final aiCefr = _stringField(ai, 'cefr_level', '').toUpperCase();
      final aiRank = _stringField(ai, 'game_rank', '').toUpperCase();

      // Prioridad: lo declarado por el Oráculo > evaluación IA > fallback A1/E.
      String cefrLevel = (declaredCefr != null && validCefrs.contains(declaredCefr))
          ? declaredCefr
          : (validCefrs.contains(aiCefr) ? aiCefr : 'A1');
      // Issue #14: el rango declarado por el modelo se valida contra la escala
      // cerrada. Un valor arbitrario (p. ej. RANK=ZZ) se descarta.
      const validRanks = ['F', 'E', 'D', 'C', 'B', 'A', 'S', 'SS', 'SSS'];
      String gameRank = (declaredRank != null && validRanks.contains(declaredRank))
          ? declaredRank
          : (validRanks.contains(aiRank)
              ? aiRank
              : CefrRank.gameRankFromCefr(cefrLevel));

      // Modo PROMOCIÓN: nunca baja de nivel. Si el Oráculo evalúa un nivel
      // inferior al actual, se mantiene el nivel actual (la experiencia nunca
      // castiga; el skill_radar refleja el deterioro real).
      final currentLevel =
          (_ref.read(userProgressProvider).value?['level_code'] as String?) ?? '';
      if (currentLevel.isNotEmpty && currentLevel != cefrLevel) {
        final currentIdx = validCefrs.indexOf(currentLevel);
        final evalIdx = validCefrs.indexOf(cefrLevel);
        final isPromotion = currentLevel.isNotEmpty;
        if (isPromotion && currentIdx >= 0 && evalIdx >= 0 && evalIdx < currentIdx) {
          cefrLevel = currentLevel;
          gameRank = CefrRank.gameRankFromCefr(cefrLevel);
        }
      }

      // Validación cruzada: si el rango declarado no es coherente con el CEFR
      // (marcador mal formado), se deriva del CEFR elegido.
      if (!validRanks.contains(gameRank)) {
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

  /// Issue #31: ventana deslizante de contexto para el chat de rol. Enviar el
  /// historial completo hacía crecer el coste y la latencia en cada turno.
  static const int maxChatContextMessages = 24;

  List<ConversationMessage> _chatWindow() {
    final withText =
        state.messages.where((m) => m.text.trim().isNotEmpty).toList();
    if (withText.length <= maxChatContextMessages) return withText;
    return withText.sublist(withText.length - maxChatContextMessages);
  }

  /// Issue #14: evita que el alumno inyecte el marcador de control del examen
  /// del Oráculo a través de su propio mensaje.
  static String _stripControlTokens(String text) {
    return text
        .replaceAll(
            RegExp(r'\[EVALUATION_COMPLETE\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[RESULT:[^\]]*\]', caseSensitive: false), '')
        .trim();
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

  /// Descuento optimista del maná en la barra: aplica el costo sobre el valor
  /// cacheado de `manaStateProvider` para que la barra baje al instante, sin
  /// esperar el refresh en segundo plano del CachedFutureController.
  void _applyOptimisticManaDeduction(String actionCode, Map<String, dynamic> result) {
    try {
      final controller = _ref.read(manaStateProvider.notifier);
      final current = controller.state.value;
      if (current == null) return;

      // Costo real devuelto por el RPC (fallback: según action code).
      final cost = (result['cost'] as num?)?.toInt() ?? _actionCost(actionCode);

      // Para free: descontar del límite diario (la barra muestra el maná de hoy).
      // Para pago: descontar del saldo mensual.
      final isFree = current['is_free'] as bool? ?? true;
      final Map<String, dynamic> updated = Map<String, dynamic>.from(current);
      if (isFree) {
        final dailyRemaining = (current['daily_remaining'] as num?)?.toInt() ?? 0;
        final dailyUsed = (current['daily_used'] as num?)?.toInt() ?? 0;
        updated['daily_remaining'] = (dailyRemaining - cost).clamp(0, 1 << 31);
        updated['daily_used'] = dailyUsed + cost;
      } else {
        final remaining = (current['remaining'] as num?)?.toInt() ?? 0;
        final used = (current['used'] as num?)?.toInt() ?? 0;
        updated['remaining'] = (remaining - cost).clamp(0, 1 << 31);
        updated['used'] = used + cost;
      }
      controller.state = AsyncValue.data(updated);
    } catch (_) {}
  }

  /// Costo por defecto de una acción si el RPC no lo devolvió.
  int _actionCost(String actionCode) {
    switch (actionCode) {
      case 'oracle_turn':
        return 15;
      case 'oracle_eval':
        return 30;
      case 'dungeon_turn':
        return 12;
      case 'free_chat_turn':
      default:
        return 8;
    }
  }

  // ── Process Transcription / Text → LLM → Supabase → TTS ────────────────────

  Future<void> _processTranscription(String userText, {bool chargeMana = true, bool reuseUserMessage = false}) async {
    if (_hasProcessedThisTurn) return;
    _hasProcessedThisTurn = true;
    _lastUserText = userText;

    // Consumo de Maná (FASE B): TODA acción de IA cuesta maná. El costo se lee
    // de la BD (ai_action_costs) y lo debita el RPC consume_mana (server-side).
    if (chargeMana && _userId != null && !_userId!.startsWith('guest_')) {
      // Issue #47: el turno del Oráculo cuesta `oracle_turn` (15). El cierre
      // del examen cobra `oracle_eval` (30) una sola vez en el finalize.
      final actionCode = state.isOracleEvaluation
          ? 'oracle_turn'
          : (state.activeScenarioId != null ? 'dungeon_turn' : 'free_chat_turn');
      _lastActionCode = actionCode;
      _turnRef =
          '${_conversationId ?? state.activeScenarioId ?? 'session'}_${DateTime.now().millisecondsSinceEpoch}';
      try {
        final economyRepo = _ref.read(economyRepositoryProvider);
        final result = await economyRepo.consumeMana(_userId!, actionCode);
        final ok = result['success'] as bool? ?? false;
        if (!ok) {
          state = state.copyWith(
            isProcessing: false,
            errorMessage: 'SIN MANÁ: adquiere una porción o espera la renovación de tu plan para continuar.',
          );
          _ref.read(conversationErrorProvider.notifier).state = const ConversationErrorState(
            message: 'Te quedaste sin maná. Recarga o espera la renovación de tu plan.',
            kind: AiErrorKind.quota,
            canRetry: false,
          );
          return;
        }
        // Consumo optimista: descuenta el costo localmente para feedback
        // inmediato en la barra, además del refresh en segundo plano.
        _applyOptimisticManaDeduction(actionCode, result);
        _ref.invalidate(manaStateProvider);
      } catch (_) {}
    }

    // Modo Oráculo: la evaluación conversacional solo conduce la entrevista.
    if (state.isOracleEvaluation) {
      await _runOracleTurn(userText: userText);
      return;
    }

    try {
      if (!reuseUserMessage) {
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

        // Issue #5: cada turno del jugador cuenta para las misiones de
        // `conversation_turns`. Best-effort: no bloquea la conversación.
        // El trigger de `messages` avanza `conversation_turns` en servidor.

        // Save user message to Supabase (only persisted lessons)
        if (_conversationId != null) {
          await _repository.saveMessage(_conversationId!, 'user', userText);
        }
      } else {
        state = state.copyWith(
          messages: state.messages.where((m) => m.text.isNotEmpty).toList(),
          currentTranscribingText: '',
        );
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
        ..._chatWindow().map((m) => {
              'role': m.sender == 'user' ? 'user' : 'assistant',
              'content': _stripControlTokens(m.text),
            }),
      ];

      // 3. Add typing indicator placeholder for tutor
      const tutorPlaceholder = ConversationMessage(sender: 'tutor', text: '');
      state = state.copyWith(messages: [...state.messages, tutorPlaceholder]);

      // 4. Stream DeepSeek response
      final stream = _repository.getTutorResponseStream(
        historyList,
        actionCode: _lastActionCode ?? 'free_chat_turn',
        conversationId: _conversationId,
      );
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
      _ref.read(conversationErrorProvider.notifier).state = null;

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
      // Un fallo de IA NUNCA es un mensaje del tutor: se quita el placeholder
      // vacio, no se narra por TTS y no se persiste en `messages`.
      final msgs = List<ConversationMessage>.from(state.messages);
      if (msgs.isNotEmpty && msgs.last.sender == 'tutor' && msgs.last.text.isEmpty) {
        msgs.removeLast();
      }
      final err = e is AiStreamException
          ? e
          : const AiStreamException(
              AiErrorKind.unknown,
              'Error al procesar la respuesta. Intenta de nuevo.',
            );

      // P-06: si el turno fallo tras reintentos, se devuelve el mana cobrado.
      var errorText = err.message;
      final refundable = chargeMana &&
          _lastActionCode != null &&
          _turnRef != null &&
          _userId != null &&
          !_userId!.startsWith('guest_') &&
          (err.kind == AiErrorKind.network ||
              err.kind == AiErrorKind.timeout ||
              err.kind == AiErrorKind.provider);
      if (refundable) {
        final refund = await _ref
            .read(economyRepositoryProvider)
            .refundFailedTurn(turnRef: _turnRef!, actionCode: _lastActionCode!);
        if (refund['ok'] == true && refund['already_refunded'] != true) {
          errorText = '$errorText No se descontó maná por este intento.';
          _ref.invalidate(manaStateProvider);
        }
      }

      _hasProcessedThisTurn = false;
      state = state.copyWith(
        isProcessing: false,
        messages: msgs,
        errorMessage: errorText,
      );
      _ref.read(conversationErrorProvider.notifier).state = ConversationErrorState(
        message: errorText,
        kind: err.kind,
        canRetry: _lastUserText != null && _lastUserText!.isNotEmpty,
      );
      unawaited(RetentionAnalytics.instance.track(
        _userId ?? 'anon',
        'ai_error',
        properties: {
          'endpoint': 'chat',
          'code': err.code,
          'retries': err.retries,
          'refunded': refundable,
        },
      ));
    }
  }

  /// Reintenta el ultimo turno sin volver a cobrar mana.
  Future<void> retryLastTurn() async {
    final text = _lastUserText;
    if (text == null || text.isEmpty) return;
    _ref.read(conversationErrorProvider.notifier).state = null;
    await _processTranscription(text, chargeMana: false, reuseUserMessage: true);
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
    // Si el usuario ya salió de la pantalla (TTS suprimido), no narrar aunque
    // un turno de la IA termine después de la salida.
    if (_ttsSuppressed) return;
    try {
      // Asegura que el motor TTS esté inicializado antes del primer speak
      // (evita que la primera narración del chat se pierda por una carrera).
      if (!_ttsReady) await _initTts();
      if (state.isPlaying) {
        await _tts.stop();
      }
      // Re-check tras los awaits: la salida pudo ocurrir mientras se esperaba
      // la inicialización del motor TTS.
      if (_ttsSuppressed) return;
      state = state.copyWith(isPlaying: true);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed (non-blocking): $e');
      state = state.copyWith(isPlaying: false);
    }
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

  Future<void> stopTts({bool suppress = false}) async {
    if (suppress) _ttsSuppressed = true;
    await _tts.stop();
    state = state.copyWith(isPlaying: false);
  }

  /// End the conversation session — persists final data and refreshes dashboard.
  Future<Map<String, dynamic>?> endSession({int practiceMinutes = 1}) async {
    if (_sessionFinalized) {
      return _lastSessionResult; // idempotente: una sola persistencia
    }
    Map<String, dynamic>? rewards;
    String? rewardSessionId;
    _sessionFinalized = true;
    if (_userId != null) {
      try {
        final repo = _ref.read(dashboardRepositoryProvider);
        await repo.logPracticeSession(_userId!, practiceMinutes);
      } catch (_) {}

      // Issue #5: cerrar sesión avanza las misiones de sesión y de minutos
      // hablados. Antes de este cambio, `advance_missions_for_user` no tenía
      // ningún llamador: las 533 instancias se quedaban en `active` para siempre.
      // Las misiones las avanza el servidor (triggers de mensajes, ledger de
      // sesión y vocabulario). No se duplica desde el cliente (issue #93).

      // Registro de superación de la lección (lesson_progress):
      //  - passed si cumple ≥80% de metas (LessonUnlockService.passThreshold).
      //  - failed si no; permite reintentar gastando maná.
      final scenarioId = state.activeScenarioId;
      if (scenarioId != null && !state.isOracleEvaluation) {
        try {
          final lesson = LessonCatalog.getLessonById(scenarioId);
          final evaluated = state.goalEvaluationResults.length;
          final totalGoals = lesson?.goals.length ?? evaluated;
          final completedGoals =
              state.goalEvaluationResults.values.where((v) => v).length;
          // Issue #18: sin evaluación no se puede afirmar que la lección se
          // superó. Antes, una evaluación vacía daba ratio 1.0 => "passed".
          if (evaluated > 0 && totalGoals > 0) {
            final status = LessonUnlockService.meetsThreshold(
              completedGoals,
              totalGoals,
            )
                ? 'passed'
                : 'failed';
            await Supabase.instance.client.from('lesson_progress').insert({
              'user_id': _userId,
              'lesson_id': scenarioId,
              'status': status,
              'completed_at': DateTime.now().toIso8601String(),
            });

            // Issue #76: el resultado queda en el mundo (consecuencia).
            // Fallo → el NPC lo recuerda; éxito → desbloquea la siguiente.
            unawaited(Supabase.instance.client.rpc(
              'record_scenario_outcome',
              params: {
                'p_scenario_id': scenarioId,
                'p_completed': completedGoals,
                'p_total': totalGoals,
              },
            ).then((_) => _ref.invalidate(scenarioProgressProvider)));
          }
        } catch (_) {}
      }

      // Router pedagógico: si la lección NO se superó (<80% de metas), se
      // genera/reutiliza una SUB MISIÓN de refuerzo para el skill más débil
      // (vía lesson-generator, que debita 100 maná server-side). El resultado
      // se inyecta al catálogo para que el mapa la muestre como mazmorra oculta.
      if (scenarioId != null && !state.isOracleEvaluation) {
        try {
          final lesson = LessonCatalog.getLessonById(scenarioId);
          final evaluated = state.goalEvaluationResults.length;
          final totalGoals = lesson?.goals.length ?? evaluated;
          final completedGoals =
              state.goalEvaluationResults.values.where((v) => v).length;
          final ratio = totalGoals > 0 ? completedGoals / totalGoals : 1.0;
          if (evaluated > 0 && ratio < LessonUnlockService.passThreshold) {
            final radar = await _ref.read(skillsRadarProvider.future);
            final skill = LessonGeneratorService.weakestSkill(radar);
            final level = (_ref.read(userProgressProvider).value?['level_code'] as String?) ?? 'A1';
            // Issue #81: la lección de refuerzo se dirige al objetivo que el
            // alumno NO cumplió, no a una categoría genérica.
            final failedGoals = (lesson?.goals ?? const [])
                .where((g) => state.goalEvaluationResults[g.id] == false)
                .map((g) => g.text)
                .take(2)
                .join('; ');
            final sub = await LessonGeneratorService.ensureLessonForWeakness(
              skillFocus: skill,
              level: level.toUpperCase(),
              weakness: failedGoals.isNotEmpty ? failedGoals : skill,
              parentId: scenarioId,
            );
            if (sub != null) {
              // Inyecta la sub misión al catálogo local para que el mapa la muestre.
              LessonCatalog.updateCatalogFromMap(sub);
              _ref.invalidate(recommendedLessonsProvider);
            }
          }
        } catch (_) {}
      }

      // Loot/drops (FASE B): las sesiones otorgan ITEMS (fragmentos, oro) y
      // AURA (mérito sin tope). NUNCA otorgan maná ni gemas de maná.
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
          final sessionId = _conversationId ??
              '${state.activeScenarioId ?? 'session'}_${DateTime.now().millisecondsSinceEpoch}';
          rewardSessionId = sessionId;
          // Issue #3/#4: importes calculados y aplicados en servidor
          // (idempotente por sessionId). El cliente ya no elige cuánto gana.
          rewards = await economyRepo.applySessionRewards(
            userId: _userId!,
            sessionId: sessionId,
            objectives: completedGoals,
            minutes: practiceMinutes,
            levelCode: levelCode,
          );
          _ref.invalidate(fragmentBalanceProvider);
          _ref.invalidate(goldBalanceProvider);

          // Aura: mérito ilimitado. El RPC aplica el factor_radar (radar
          // pondera la ganancia pero nunca topa el total) e idempotencia por sesión.
          try {
            final radar = await _ref.read(skillsRadarProvider.future);
            await economyRepo.addAuraXp(
                _userId!, sessionId, radar, completedGoals, levelBonus);
            _ref.invalidate(auraXpProvider);
          } catch (_) {}
        }
        // Racha y minutos: una sola fuente de verdad en servidor (issue #88).
        final streakSessionId = rewardSessionId ??
            _conversationId ??
            '${state.activeScenarioId ?? 'session'}_${DateTime.now().millisecondsSinceEpoch}';
        if (streakSessionId.isNotEmpty) {
          final streakRes = await economyRepo.registerPractice(
            sessionId: streakSessionId,
            minutes: practiceMinutes,
            objectives: completedGoals,
            tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
          );
          if (streakRes['ok'] == true) {
            _ref.invalidate(userProgressProvider);
          }
        }
      } catch (_) {}

      // Sincronizar títulos de habilidad ganados por desempeño conversacional
      // (incluye el score de carisma evaluado por IA de esta sesión).
      try {
        final userTexts = state.messages
            .where((m) => m.sender == 'user')
            .map((m) => m.text)
            .where((t) => t.trim().isNotEmpty)
            .toList();
        int carisma = 0;
        if (userTexts.isNotEmpty) {
          carisma = await _repository.evaluateCarismaScore(userTexts);
        }
        final titleRepo = _ref.read(dashboardRepositoryProvider);
        final newlyEarned = await titleRepo.syncEarnedTitles(
          _userId!,
          carisma: carisma.toDouble(),
        );
        if (newlyEarned.isNotEmpty) {
          final titles = newlyEarned
              .map((c) => HunterSkillTitleCatalog.forCode(c))
              .whereType<SkillTitle>()
              .toList();
          _ref.read(newEarnedTitlesProvider.notifier).state = titles;
        }
        _ref.invalidate(earnedTitlesProvider);
      } catch (_) {}

      try {
        // Issue #35: cierre de sesión con volumen real de actividad.
        final turns = state.messages.where((m) => m.sender == 'user').length;
        final completed =
            state.goalEvaluationResults.values.where((v) => v).length;
        unawaited(RetentionAnalytics.instance.track(
          _userId!,
          'session_end',
          properties: {
            'turns': turns,
            'goals_completed': completed,
            'goals_total': state.goalEvaluationResults.length,
            'oracle': state.isOracleEvaluation,
          },
        ));
      } catch (_) {}
      try {
        _ref.invalidate(userProgressProvider);
        _ref.invalidate(userAchievementsProvider);
        _ref.invalidate(recommendedLessonsProvider);
        // El maná se consumió por turno durante la sesión: forzar el refresco
        // de la barra al volver al dashboard (evita mostrar el saldo viejo).
        _ref.invalidate(manaStateProvider);
        // Also increment the refresh trigger for non-autoDispose safety
        _ref.read(dashboardRefreshProvider.notifier).state++;
      } catch (_) {}
    }

    final completedGoals =
        state.goalEvaluationResults.values.where((v) => v).length;
    final result = <String, dynamic>{
      'xp': (rewards?['xp'] as num?)?.toInt() ?? 0,
      'gold': (rewards?['gold'] as num?)?.toInt() ?? 0,
      'fragments': (rewards?['fragments'] as num?)?.toInt() ?? 0,
      'duplicated': rewards?['duplicated'] ?? false,
      'reward_applied': rewards != null,
      'objectives': completedGoals,
      'goals_total': state.goalEvaluationResults.length,
      'minutes': practiceMinutes,
      'turns': state.messages.where((m) => m.sender == 'user').length,
      'is_oracle': state.isOracleEvaluation,
      'scenario_id': state.activeScenarioId,
      'session_id': rewardSessionId,
    };
    _lastSessionResult = result;
    return result;
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

class ConversationErrorState {
  final String message;
  final AiErrorKind kind;
  final bool canRetry;

  const ConversationErrorState({
    required this.message,
    required this.kind,
    this.canRetry = false,
  });
}

final conversationErrorProvider =
    StateProvider<ConversationErrorState?>((ref) => null);

final sessionResultProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

final conversationStateProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  final repo = ref.watch(conversationRepositoryProvider);
  return ConversationNotifier(repo, ref);
});

final micModeHoldToTalkProvider = StateProvider<bool>((ref) => false);
