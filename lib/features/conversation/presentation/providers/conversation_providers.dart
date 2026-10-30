import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../data/repositories/tutor_personalization_repository.dart';
import '../../domain/models/ai_stream_exception.dart';
import '../../domain/models/goal_evaluation_gate.dart';
import '../../domain/models/correction_turn_policy.dart';
import '../../domain/models/conversation_message.dart';
import '../../domain/models/conversation_state.dart';
import '../../domain/models/tutor_adaptation.dart';
import '../../domain/models/scenario_band.dart';
import '../../domain/models/tutor_personalization.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/services/tutor_prompt_builder.dart';
import '../../../corrections/domain/models/turn_correction.dart';
import '../../../corrections/domain/models/correction_turn_result.dart';
import '../../../corrections/presentation/providers/corrections_providers.dart';
import '../../../vocabulary/domain/models/curated_vocabulary.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/domain/models/session_learned_summary.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';
import '../../../dashboard/data/models/hunter_skill_titles.dart';
import '../../../dashboard/domain/services/lesson_generator_service.dart';
import '../../../dashboard/domain/models/remedial_lesson.dart';
import '../../../dashboard/domain/models/lesson_completion.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../boss_exam/domain/models/boss_exam_rubric.dart';
import '../../../boss_exam/domain/services/boss_exam_rules.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../onboarding/data/placement_service.dart';
import '../../../onboarding/domain/models/placement_outcome.dart';
import '../../../../core/i18n/language_settings.dart';
import '../../../../core/utils/text_diff_utils.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../../core/analytics/analytics_taxonomy.dart';
import '../../domain/models/tts_preferences.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────────────────────────────────────

final conversationDioProvider = Provider<Dio>((ref) => Dio());

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final dio = ref.watch(conversationDioProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return ConversationRepositoryImpl(dio, supabase);
});

/// P-40 (#125): perfil que personaliza al tutor (intereses, nivel real,
/// instrucciones del perfil de IA y repaso acumulativo).
final tutorPersonalizationRepositoryProvider =
    Provider<TutorPersonalizationRepository>((ref) {
      return TutorPersonalizationRepository(ref.watch(supabaseClientProvider));
    });

final activeConversationIdProvider = StateProvider<String?>((ref) => null);
final activeScenarioIdProvider = StateProvider<String?>((ref) => null);

/// Issue #76: resultado de la última visita a una escena.
/// Se usa para que el mundo «recuerde» el intento anterior (chip en la
/// conversación) sin volver a llamar al modelo.
final scenarioProgressProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, scenarioId) async {
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

  /// P-34c (#119): preferencias de voz activas en esta sesión.
  double _ttsSpeed = TtsPreferences.defaultSpeed;
  String? _tutorVoiceId;

  /// P-34g (#119): inicio del turno para medir latencia hasta el primer chunk.
  DateTime? _turnStartedAt;
  bool _turnLatencyTracked = false;

  bool _hasProcessedThisTurn = false;
  String? _conversationId;
  String? _userId;
  DateTime? _recordingStartTimestamp;
  int? _assessmentStart;
  String? _assessmentId;
  int _turnCounter = 0;
  DateTime? _lastOracleQuestionAt;

  // P-31 (#116): reglas del "jefe de mazmorra" (examen de promoción).
  // Tope duro de turnos y timeout: sin ellos el examen podía quedarse abierto
  // para siempre si el modelo no emitía el marcador de cierre.
  int _oracleUserTurns = 0;
  bool _oraclePromotion = false;
  DateTime? _oracleStartedAt;
  Timer? _oracleCloseTimer;
  bool _oracleFinalizing = false;

  /// Idempotencia del cierre de sesión: garantiza que `endSession` se ejecute
  /// una sola vez aunque la salida ocurra por varias vías (pop, back, go, dispose).
  bool _sessionFinalized = false;
  Map<String, dynamic>? _lastSessionResult;

  /// P-28: inicio real de la práctica. Se envía al resumen para acotar la
  /// ventana de `get_session_learned_summary` (la fila de `conversations` se
  /// reutiliza por escenario, así que `started_at` no marca esta sesión).
  DateTime? _sessionStartedAt;
  String? _lastUserText;
  bool _goalsEvaluatedForLastTurn = false;

  /// P-39: si `goal_eval` falló (red, HTTP o respuesta ilegible), el siguiente
  /// turno reintenta aunque el mensaje no pase el gate de coste.
  bool _goalEvaluationPendingRetry = false;
  String? _lastActionCode;

  /// P-29: `turn_ref` del turno en curso, para deduplicar correcciones.
  String? _correctionTurnRef;

  /// P-29-b (#193): presupuesto de evaluaciones de corrección en la sesión
  /// (chat libre). Cuenta también los intentos fallidos: el tope acota el
  /// gasto de IA, no los aciertos.
  int _correctionEvaluations = 0;

  /// P-29-b: tras un `402 no_mana` no se vuelve a pedir en esta sesión.
  bool _correctionsSkippedForMana = false;

  /// Errores recurrentes del alumno (vista `user_recurring_errors`).
  /// Alimentan el prompt del tutor y la misión de refuerzo.
  List<CorrectionGroup> _recurringErrors = const [];

  /// P-40 (#125): perfil de personalización leído al abrir la sesión.
  TutorPersonalization _personalization = TutorPersonalization.empty;
  Future<void>? _personalizationFuture;
  bool _personalizationLoaded = false;

  /// P-40: ajuste de dificultad dentro del nivel (rachas de acierto/fallo).
  final TutorAdaptationTracker _adaptation = TutorAdaptationTracker();

  /// P-40b (#221): nivel real del alumno al abrir la sesión.
  ///
  /// Se usa para el saludo inicial (antes de que cargue el perfil de
  /// personalización) y como respaldo del prompt. Nunca se inventa: si no hay
  /// dato, la banda del escenario se queda como está.
  String? _sessionLearnerLevel;

  /// P-40: señales del turno en curso. Se reinician al empezar cada turno y se
  /// consumen al terminar la persistencia en segundo plano (sin IA extra).
  int _turnNumber = 0;
  int _correctionsThisTurn = 0;
  int _goalsCompletedThisTurn = 0;

  ConversationNotifier(this._repository, this._ref)
    : super(ConversationState.initial()) {
    _initTts();
  }

  /// Analítica best-effort. Nunca lanza (tests sin Supabase, invitados).
  void _track(String event, {Map<String, dynamic>? properties}) {
    final userId = _userId;
    if (userId == null || userId.isEmpty || userId.startsWith('guest_')) {
      return;
    }
    try {
      unawaited(
        RetentionAnalytics.instance.track(
          userId,
          event,
          properties: properties,
        ),
      );
    } catch (e) {
      debugPrint('Analytics ($event) no disponible: $e');
    }
  }

  /// P-34g (#119): latencia hasta el primer chunk de la respuesta.
  void _trackTurnLatency() {
    if (_turnLatencyTracked) return;
    final startedAt = _turnStartedAt;
    if (startedAt == null) return;
    _turnLatencyTracked = true;
    _track(
      AnalyticsEvent.conversationTurnLatency,
      properties: {
        'ms': DateTime.now().difference(startedAt).inMilliseconds,
        'action': _lastActionCode ?? 'free_chat_turn',
      },
    );
  }

  // ── Session Init ────────────────────────────────────────────────────────────

  Future<void> initSession({String? scenarioId, String? scenarioTitle}) async {
    final user = _ref.read(currentUserProvider);
    _userId = user?.id ?? 'guest_user';
    _sessionFinalized = false; // nueva sesión → se permite cerrar de nuevo
    _sessionStartedAt = DateTime.now();
    _goalsEvaluatedForLastTurn = false;
    _goalEvaluationPendingRetry = false;

    // Reset completo del estado: nunca debe heredar flags de una sesión previa
    // (p.ej. isOracleEvaluation=true de la Evaluación del Oráculo del onboarding).
    state = ConversationState.initial();
    // Nueva sesión → se permite narrar de nuevo (se cancela la supresión previa).
    _ttsSuppressed = false;
    // P-29: los chips de corrección de la sesión anterior no se heredan y el
    // contexto de errores recurrentes se refresca al abrir la conversación.
    _correctionTurnRef = null;
    _correctionEvaluations = 0;
    _correctionsSkippedForMana = false;
    _recurringErrors = const [];
    _ref.read(sessionCorrectionsProvider.notifier).clear();
    unawaited(_loadRecurringErrors());
    // P-40 (#125): cada sesión arranca con rachas limpias y el perfil del
    // alumno releído (pudo cambiar de intereses o de nivel desde la anterior).
    _adaptation.reset();
    _turnNumber = 0;
    // P-40b (#221): el nivel real del alumno manda sobre la banda fija del
    // escenario. Se lee del progreso ya cargado por el dashboard; si no está,
    // la banda del escenario se queda como está (sin inventar nivel).
    _sessionLearnerLevel = _readLearnerLevel();
    _correctionsThisTurn = 0;
    _goalsCompletedThisTurn = 0;
    unawaited(_loadTutorPersonalization(scenarioId: scenarioId));

    // P-34c (#119): velocidad y voz del tutor antes del primer _speakTts.
    await _loadTtsPreferences();

    // Fetch latest scenario fields from Supabase DB to sync any edits saved from web_admin.
    // Issue #1: las lecciones usan claves del catálogo Dart (texto) contra
    // `scenarios.id`, que es UUID. Consultar con una clave de texto lanzaba
    // 22P02 dentro de un try/catch vacío: una petición perdida en cada apertura.
    final bool scenarioIdIsUuid =
        scenarioId != null &&
        RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(scenarioId);
    if (scenarioIdIsUuid ||
        (scenarioTitle != null && scenarioTitle.isNotEmpty)) {
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
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:136',
          e,
          stackTrace: st,
        );
      }
    }

    final lesson = LessonCatalog.getLessonById(
      scenarioId,
      title: scenarioTitle,
    );
    final openingMessage = lesson == null ? null : _openingForLearner(lesson);

    state = state.copyWith(
      activeScenarioId: scenarioId,
      activeScenarioName:
          scenarioTitle ?? lesson?.title ?? 'Práctica de Conversación',
    );

    // Issue #35: evento de inicio de sesión (estaba documentado pero nunca se
    // emitía). Best-effort: no bloquea ni falla el flujo. El try evita que un
    // cliente de analítica no inicializado (tests, arranque degradado) tumbe la
    // apertura de la conversación.
    try {
      unawaited(
        RetentionAnalytics.instance.track(
          _userId!,
          AnalyticsEvent.sessionStart,
          properties: {'scenario_id': scenarioId ?? '', 'oracle': false},
        ),
      );
    } catch (e) {
      debugPrint('Analytics (session_start) no disponible: $e');
    }

    // 1. For recommended lessons (with scenarioId), persist to Supabase
    if (scenarioId != null && scenarioId.isNotEmpty) {
      final convData = await _repository.getOrCreateConversation(
        _userId!,
        scenarioId: scenarioId,
      );
      _conversationId = convData['id'] as String?;
      _ref.read(activeConversationIdProvider.notifier).state = _conversationId;

      // 2. If resuming, load historical messages from Supabase
      if (_conversationId != null) {
        final savedMessages = await _repository.loadConversationMessages(
          _conversationId!,
        );
        // Garantiza que el tutor inicia la conversación: solo reutiliza los
        // mensajes guardados si existe al menos un mensaje de tutor con texto
        // (evita chats vacíos por esquemas/cache viejos).
        final hasTutorMessage = savedMessages.any(
          (m) => m.sender == 'tutor' && m.text.trim().isNotEmpty,
        );
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
          final opening = openingMessage ?? lesson.initialAssistantMessage;
          state = state.copyWith(
            messages: [ConversationMessage(sender: 'tutor', text: opening)],
          );
          _repository.saveMessage(_conversationId!, 'assistant', opening);
          // Narra el primer mensaje del Oráculo NPC al abrir el chat.
          await _speakTts(opening);
        }
      }

      // Restore previously completed goals from Supabase DB
      final savedGoals = await _repository.loadCompletedGoals(
        _userId!,
        scenarioId,
      );
      if (savedGoals.isNotEmpty) {
        state = state.copyWith(goalEvaluationResults: savedGoals);
      }
    } else {
      // Free practice — no DB persistence
      _conversationId = null;
      _ref.read(activeConversationIdProvider.notifier).state = null;

      if (lesson != null) {
        final opening = openingMessage ?? lesson.initialAssistantMessage;
        state = state.copyWith(
          messages: [ConversationMessage(sender: 'tutor', text: opening)],
        );
        await _speakTts(opening);
      } else {
        const opening = 'Hello! How can I help you practice today?';
        state = state.copyWith(
          messages: const [ConversationMessage(sender: 'tutor', text: opening)],
        );
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
    bool promotion = false,
  }) async {
    final user = _ref.read(currentUserProvider);
    _userId = user?.id ?? 'guest_user';
    _sessionFinalized = false; // evaluación nueva → cerrar permitido
    _sessionStartedAt = DateTime.now();

    final target = (targetLanguage?.isNotEmpty ?? false)
        ? targetLanguage!
        : _ref.read(userLanguageProvider).learningLanguage;
    // Fallback del nativo: primero el explícito, luego el guardado en BD
    // (users.native_language, seteado en el onboarding), nunca el idioma de UI.
    final storedNative =
        (_ref.read(userProfileProvider).value ?? const {})['native_language']
            as String?;
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
    // P-40: el examen no usa el ajuste de dificultad por rachas; el Oráculo
    // tiene su propia progresión CEFR.
    _adaptation.reset();
    _correctionsThisTurn = 0;
    _goalsCompletedThisTurn = 0;
    _conversationId = null;
    _assessmentStart = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _turnCounter = 0;
    _assessmentId = null;

    // P-31 (#116): el examen es el jefe de mazmorra solo cuando se entra desde
    // la Ruta (`mode=promotion`). No se deduce del nivel: `handle_new_user()`
    // crea un perfil con A1 por defecto sin evaluar, así que "tiene nivel" no
    // distingue placement inicial de promoción.
    _oraclePromotion = promotion;
    _oracleUserTurns = 0;
    _oracleStartedAt = DateTime.now();
    _oracleFinalizing = false;
    _oracleCloseTimer?.cancel();
    if (_oraclePromotion) {
      _oracleCloseTimer = Timer(BossExamRules.timeLimit, () {
        unawaited(_forceCloseOracleExam());
      });
    }
    _ref.read(activeConversationIdProvider.notifier).state = null;

    // P-34c (#119): preferencias de voz antes de la primera pregunta.
    await _loadTtsPreferences();

    // Crea la sesión de evaluación en oracle_assessments para poder registrar
    // turnos (oracle_turns) durante la conversación.
    if (_userId != null && !_userId!.startsWith('guest_')) {
      try {
        final client = Supabase.instance.client;
        final row = await client
            .from('oracle_assessments')
            .insert({
              'user_id': _userId,
              'cefr_level': 'A1',
              'game_rank': 'E',
              'target_language': target,
              'native_language': native,
              'ai_model': 'deepseek-v4-flash',
              'prompt_version': 'v2',
            })
            .select('id')
            .single();
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
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/conversation/presentation/providers/conversation_providers.dart:294',
        e,
        stackTrace: st,
      );
    }

    // El Oráculo inicia la conversación automáticamente.
    await _runOracleTurn(userText: '');
  }

  // ── TTS Init ────────────────────────────────────────────────────────────────

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(TtsPreferences.speechRateFor(_ttsSpeed));
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.05);
      final voice = _tutorVoiceId;
      if (voice != null && voice.isNotEmpty) {
        await _tts.setVoice({'name': voice, 'locale': 'en-US'});
      }
      _tts.setCompletionHandler(() {
        state = state.copyWith(isPlaying: false);
      });
      _tts.setErrorHandler((msg) {
        state = state.copyWith(isPlaying: false);
      });
      _ttsReady = true;
    } catch (e) {
      debugPrint('TTS init failed (non-blocking): $e');
      _ttsReady = false;
    }
  }

  /// P-34c (#119): carga `tts_speed` y `tutor_voice_id` de `user_settings`.
  ///
  /// Best-effort: si la lectura falla se mantienen los valores por defecto y la
  /// conversación continúa. Los invitados no tienen fila en `user_settings`.
  Future<void> _loadTtsPreferences() async {
    _ttsSpeed = TtsPreferences.defaultSpeed;
    _tutorVoiceId = null;

    final userId = _userId;
    if (userId != null && !userId.startsWith('guest_')) {
      try {
        final data = await _ref
            .read(dashboardRepositoryProvider)
            .getUserSettings(userId);
        if (data.isNotEmpty) {
          _ttsSpeed = TtsPreferences.normalizeSpeed(
            (data['tts_speed'] as num?)?.toDouble(),
          );
          final storedVoice = (data['tutor_voice_id'] as String?)?.trim();
          _tutorVoiceId = (storedVoice == null || storedVoice.isEmpty)
              ? null
              : storedVoice;
        }
      } catch (e, st) {
        debugPrint('No se pudieron leer las preferencias de voz: $e');
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:load_tts_prefs',
          e,
          stackTrace: st,
        );
      }
    }

    state = state.copyWith(ttsSpeed: _ttsSpeed, tutorVoiceId: _tutorVoiceId);
    await _applyTtsConfig();
  }

  /// Aplica velocidad y voz al motor. No bloquea ni rompe el pipeline.
  Future<void> _applyTtsConfig() async {
    try {
      if (!_ttsReady) await _initTts();
      if (!_ttsReady) return;
      await _tts.setSpeechRate(TtsPreferences.speechRateFor(_ttsSpeed));
      final voice = _tutorVoiceId;
      if (voice != null && voice.isNotEmpty) {
        await _tts.setVoice({'name': voice, 'locale': 'en-US'});
      }
    } catch (e) {
      debugPrint('TTS config failed (non-blocking): $e');
    }
  }

  /// P-34c (#119): cambia la velocidad y la persiste en `user_settings`.
  Future<void> setTtsSpeed(double speed) async {
    final normalized = TtsPreferences.normalizeSpeed(speed);
    _ttsSpeed = normalized;
    state = state.copyWith(ttsSpeed: normalized);
    await _applyTtsConfig();
    await _persistTtsPreference('tts_speed', normalized);
    _track(AnalyticsEvent.ttsSpeedChanged, properties: {'speed': normalized});
  }

  /// P-34c (#119): cambia la voz del tutor (`null` = voz del sistema).
  Future<void> setTutorVoice(String? voiceName) async {
    final normalized = (voiceName == null || voiceName.trim().isEmpty)
        ? null
        : voiceName.trim();
    _tutorVoiceId = normalized;
    state = state.copyWith(tutorVoiceId: normalized);
    await _applyTtsConfig();
    await _persistTtsPreference('tutor_voice_id', normalized);
    _track(
      AnalyticsEvent.ttsVoiceChanged,
      properties: {'voice': normalized ?? 'system'},
    );
  }

  /// Voces instaladas del motor TTS que hablan inglés.
  ///
  /// Si el plugin no está disponible (tests) devuelve lista vacía; la UI
  /// ofrece entonces la voz por defecto y un mensaje accionable.
  Future<List<Map<String, String>>> loadAvailableVoices() async {
    try {
      if (!_ttsReady) await _initTts();
      if (!_ttsReady) return const [];
      final raw = await _tts.getVoices;
      final voices = <Map<String, String>>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final name = item['name']?.toString().trim() ?? '';
          final locale = item['locale']?.toString().trim() ?? '';
          if (name.isEmpty) continue;
          if (!locale.toLowerCase().startsWith('en')) continue;
          voices.add({'name': name, 'locale': locale});
        }
      }
      voices.sort((a, b) => a['name']!.compareTo(b['name']!));
      return voices;
    } catch (e) {
      debugPrint('No se pudieron listar las voces TTS: $e');
      return const [];
    }
  }

  Future<void> _persistTtsPreference(String key, Object? value) async {
    final userId = _userId;
    if (userId == null || userId.startsWith('guest_')) return;
    try {
      await _ref.read(dashboardRepositoryProvider).updateUserSettings(userId, {
        key: value,
      });
    } catch (e, st) {
      debugPrint('No se pudo guardar $key en user_settings: $e');
      ErrorTracker.logSilent(
        'lib/features/conversation/presentation/providers/conversation_providers.dart:persist_tts_pref',
        e,
        stackTrace: st,
      );
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
        // P-34e (#119): la pantalla muestra una tarjeta con "Ir a ajustes".
        // No se usa `errorMessage` para no disparar dos avisos a la vez.
        state = state.copyWith(
          isRecording: false,
          isProcessing: false,
          micPermissionDenied: true,
          errorMessage: null,
        );
        _track(
          AnalyticsEvent.micPermissionDenied,
          properties: {'surface': 'conversation'},
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
              errorMessage:
                  'SIN MANÁ: adquiere una porción o espera la renovación de tu plan para continuar.',
            );
            return;
          }
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/conversation/presentation/providers/conversation_providers.dart:352',
            e,
            stackTrace: st,
          );
        }
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
        micPermissionDenied: false,
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
        if (_userId != null &&
            !_userId!.startsWith('guest_') &&
            durationSec > 0) {
          try {
            // No bloquea el turno: el tracking de audio es best-effort.
            unawaited(_repository.trackAiAudioTime(_userId!, durationSec));
          } catch (e, st) {
            ErrorTracker.logSilent(
              'lib/features/conversation/presentation/providers/conversation_providers.dart:405',
              e,
              stackTrace: st,
            );
          }
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
            errorMessage:
                'No se detectó voz en el audio. Intenta hablar más cerca del micrófono.',
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
        userMsg =
            'Error de conexión con Groq STT ($code). Revisa tu internet o la API Key.';
      }
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        currentTranscribingText: '',
        errorMessage: userMsg,
      );
      _ref
          .read(conversationErrorProvider.notifier)
          .state = ConversationErrorState(
        message:
            'No pudimos transcribir tu audio. Reintenta el audio o escribe tu respuesta.',
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
      await stopTts();
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
        _oracleUserTurns++;
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
      _ref.invalidate(manaStateProvider);

      // 4b. Registrar el turno sin bloquear la narración (best-effort DB).
      if (userText.isNotEmpty) {
        unawaited(
          _recordOracleTurn(
            userText: userText,
            oracleResponse: fullOracleResponse,
          ),
        );
      }

      // 5. Evaluate completion: the Oracle signals the end of the exam with
      //    the [EVALUATION_COMPLETE] marker, then the classifier runs.
      if (fullOracleResponse.contains('[EVALUATION_COMPLETE]')) {
        // Extraer el resultado declarado por el Oráculo (lo que el usuario vio).
        String? declaredCefr;
        String? declaredRank;
        final resultMatch = RegExp(
          r'\[RESULT:CEFR=(PRE-A1|[ABC][12]),RANK=([A-Z]+)\]',
        ).firstMatch(fullOracleResponse);
        if (resultMatch != null) {
          declaredCefr = resultMatch.group(1)?.toUpperCase();
          declaredRank = resultMatch.group(2)?.toUpperCase();
        }

        final cleaned = fullOracleResponse
            .replaceAll('[EVALUATION_COMPLETE]', '')
            .replaceAll(RegExp(r'\[RESULT:[^\]]*\]'), '')
            .trim();
        if (cleaned.isNotEmpty) {
          final updatedMessages = List<ConversationMessage>.from(
            state.messages,
          );
          updatedMessages[updatedMessages.length - 1] = ConversationMessage(
            sender: 'tutor',
            text: cleaned,
          );
          state = state.copyWith(messages: updatedMessages);
          if (_conversationId != null) {
            await _repository.saveMessage(
              _conversationId!,
              'assistant',
              cleaned,
            );
          }
        }
        await _finalizeOracleEvaluation(
          declaredCefr: declaredCefr,
          declaredRank: declaredRank,
        );
        return;
      }

      // 5b. P-31 (#116): tope duro de turnos o de tiempo. Al alcanzarlo se
      // cierra el examen con la evidencia disponible; el servidor decide con
      // las respuestas que haya (sin depender del marcador del modelo).
      if (_oraclePromotion &&
          BossExamRules.shouldForceClose(
            turns: _oracleUserTurns,
            elapsed: _oracleElapsed,
          )) {
        await _finalizeOracleEvaluation(forced: true);
        return;
      }

      // 6. Otherwise speak the question and persist.
      if (fullOracleResponse.isNotEmpty) {
        _lastOracleQuestionAt = DateTime.now();
        _speakTts(fullOracleResponse);
      }
      if (_conversationId != null && fullOracleResponse.isNotEmpty) {
        await _repository.saveMessage(
          _conversationId!,
          'assistant',
          fullOracleResponse,
        );
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
          .where(
            (m) =>
                m.sender == 'tutor' &&
                m.text.isNotEmpty &&
                m.text != oracleResponse,
          )
          .lastOrNull
          ?.text;

      final responseTime = _lastOracleQuestionAt != null
          ? DateTime.now().difference(_lastOracleQuestionAt!).inMilliseconds /
                1000.0
          : null;
      final wordCount = userText
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;
      // Heurística parcial: 0-100 según longitud y variedad de la respuesta.
      final partial = (wordCount * 6).clamp(0, 100);

      _turnCounter++;
      final client = Supabase.instance.client;
      await client.from('oracle_turns').insert({
        'assessment_id': _assessmentId,
        'turn_order': _turnCounter,
        'cefr_level':
            'A1', // nivel real lo fija la IA en el cierre; provisional
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
    // P-31 (#116): promoción = se entró al jefe desde la Ruta. El perfil
    // recién creado trae A1 por defecto sin evaluar, así que el nivel solo no
    // distingue placement inicial de promoción.
    final isPromotion = _oraclePromotion;

    // Contexto del historial para la evaluación contextual (skills + debilidades).
    final radar = _ref.read(skillsRadarProvider).value ?? const {};
    final profile = _ref.read(userProfileProvider).value ?? const {};
    final weaknesses = (profile['placement_weaknesses'] as List?) ?? const [];

    final startingLine = isPromotion
        ? 'PROGRESSION RULES:\n- Start at the student CURRENT level ($currentLevel). Assess whether they have IMPROVED enough to move UP one band. If they perform at or below their current level, keep them at $currentLevel (NEVER assign a lower level).\n- This is a BOSS EXAM: you have at most ${BossExamRules.maxTurns} student answers. Aim to close by answer 7. If the limit is reached the exam closes automatically with what was said.\n- The promotion gate is a fixed rubric: average of your 6 scored dimensions (listening, fluency, grammar, vocabulary, pronunciation, naturalness) must be >= ${BossExamRubric.passAverage} and no dimension below ${BossExamRubric.minDimension}. Score honestly against the CEFR band you are testing.'
        : 'PROGRESSION RULES:\n- Start at A1. After each answer, silently assess it.';

    final contextLine = isPromotion
        ? 'STUDENT CONTEXT (use to focus the exam on their known gaps):\n'
              '- Current level: $currentLevel\n'
              '- Skill radar: ${radar.isNotEmpty ? radar.toString() : "unknown"}\n'
              '- Known weaknesses: ${weaknesses.isNotEmpty ? weaknesses.toString() : "none recorded"}\n'
              'Focus questions on their weakest skills to confirm real improvement.\n'
        : '';

    final systemPrompt =
        '''
You are the Oracle of the Guild, an ancient and wise being that examines young adventurers with a natural spoken conversation. You are conducting an ${isPromotion ? 'PROMOTION EXAM' : 'ORAL PLACEMENT EXAM'} in $target for a student whose native language is $native. The exam must feel like a pleasant chat with a guild mentor, never like a form or a test.

OPENING (FIRST TURN ONLY):
${isPromotion ? 'Say a warm, mystical greeting, acknowledge they have trained and return to be re-assessed at level $currentLevel, then ask if they are ready.' : 'Say exactly this warm greeting, then ask if they are ready:\n"Hello! Welcome to the Adventurer\'s Guild. My name is Oracle. Before assigning your first missions I\'d like to know you a little better. Don\'t worry — this isn\'t an exam, just speak naturally. Are you ready?"'}

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
      ...window.map(
        (m) => {
          'role': m.sender == 'user' ? 'user' : 'assistant',
          'content': _stripControlTokens(m.text),
        },
      ),
    ];
  }

  /// Cierra el examen del Oráculo.
  ///
  /// #73: el nivel y el rango los decide `evaluate-placement` en el servidor.
  /// El marcador `[RESULT:CEFR=..,RANK=..]` que declaró el Oráculo se envía
  /// solo como pista: el servidor la acepta si está a ±1 banda de su propia
  /// evaluación y nunca permite bajar de nivel en modo promoción.
  ///
  /// P-31 (#116): en promoción el cierre puede forzarse por tope de turnos o
  /// por tiempo ([forced]). La evaluación usa las respuestas disponibles y el
  /// servidor aplica la rúbrica y el cooldown.
  Future<void> _finalizeOracleEvaluation({
    String? declaredCefr,
    String? declaredRank,
    bool forced = false,
  }) async {
    if (_oracleFinalizing || state.oracleFinished) return;
    _oracleFinalizing = true;
    _oracleCloseTimer?.cancel();
    _oracleCloseTimer = null;
    final mode = _oraclePromotion ? 'boss' : 'placement';

    try {
      state = state.copyWith(isProcessing: true, oracleEvaluating: true);

      // P-07: `oracle_eval` lo cobra el proxy al recibir la evaluacion.

      final answers = state.messages
          .where((m) => m.sender == 'user')
          .map((m) => m.text)
          .where((t) => t.trim().isNotEmpty)
          .toList();

      // P-31: sin evidencia mínima no se llama al servidor (no se cobra maná
      // ni se consume el cooldown). El intento no cuenta.
      if (mode == 'boss' && !BossExamRules.hasEnoughEvidence(answers.length)) {
        const message =
            'El Oráculo necesita al menos ${BossExamRules.minAnswers} '
            'respuestas para juzgar el examen. Este intento no cuenta.';
        state = state.copyWith(
          isProcessing: false,
          oracleEvaluating: false,
          oracleFinished: true,
          errorMessage: message,
        );
        _ref
            .read(conversationErrorProvider.notifier)
            .state = ConversationErrorState(
          message: message,
          kind: AiErrorKind.provider,
          canRetry: true,
        );
        return;
      }

      // #73: el nivel lo calcula y lo persiste el servidor
      // (`evaluate-placement`). El cliente solo envía la transcripción y la
      // pista que el Oráculo declaró en la conversación; el servidor valida la
      // escala cerrada, aplica el modo promoción (nunca baja) y escribe con
      // service role. Ningún nivel se decide ya en Dart.
      final PlacementOutcome outcome;
      try {
        outcome = await _ref
            .read(placementServiceProvider)
            .evaluate(
              answers: answers,
              declaredCefr: declaredCefr,
              declaredRank: declaredRank,
              mode: mode,
              forced: forced,
            );
      } on PlacementException catch (e) {
        debugPrint('Oracle placement error: ${e.message}');
        // El examen sigue abierto para poder reintentar el cierre (la ruta
        // también permite salir sin perder lo dicho).
        _oracleFinalizing = false;
        state = state.copyWith(
          isProcessing: false,
          oracleEvaluating: false,
          errorMessage: e.message,
        );
        _ref
            .read(conversationErrorProvider.notifier)
            .state = ConversationErrorState(
          message: e.message,
          kind: e.quota ? AiErrorKind.quota : AiErrorKind.provider,
          canRetry: true,
        );
        return;
      }
      _ref.invalidate(manaStateProvider);

      // Issue #25: persistir las 6 dimensiones que lee el radar de habilidades.
      unawaited(_persistSkillScores({'scores': outcome.scores}));

      final cefrLevel = outcome.cefrLevel;
      final gameRank = outcome.gameRank;

      final explanation = outcome.explanation.isNotEmpty
          ? outcome.explanation
          : 'El Oráculo ha hablado. Nivel $cefrLevel desbloqueado.';
      final strengths = outcome.strengths;
      final weaknesses = outcome.weaknesses;
      final recommendedFocus = outcome.recommendedFocus;

      final result = <String, dynamic>{
        // Claves del contrato con `evaluate-placement` (P-31 / #116).
        'cefr_level': cefrLevel,
        'game_rank': gameRank,
        'previous_cefr_level': outcome.previousCefrLevel,
        'promoted': outcome.promoted,
        'decision': outcome.decision,
        'reason_code': outcome.reasonCode,
        'rubric': outcome.rubric,
        'next_attempt_at': outcome.nextAttemptAt?.toIso8601String(),
        'forced': forced || outcome.forced,
        'turns': outcome.turns > 0 ? outcome.turns : answers.length,
        'mode': outcome.mode.isNotEmpty ? outcome.mode : mode,
        'scores': outcome.scores,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'explanation': explanation,
        'recommended_focus': recommendedFocus,
        // Compatibilidad con consumidores anteriores del mapa.
        'cefrLevel': cefrLevel,
        'gameRank': gameRank,
        'recommendedFocus': recommendedFocus,
        'answers': answers,
      };

      // Persistencia del registro del examen (el nivel ya lo escribió el
      // servidor en `user_language_profiles`).
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

      // El nivel vive en `user_language_profiles`: refrescar lo que leen el
      // dashboard y el radar para mostrar el resultado recién asignado.
      _ref.invalidate(userProgressProvider);
      _ref.invalidate(userProfileProvider);
      _ref.invalidate(manaStateProvider);

      // Mensaje épico del Oráculo con el resultado, narrado con su voz.
      final closing = _buildOracleClosingMessage(
        cefrLevel: cefrLevel,
        gameRank: gameRank,
        // El "mantienes nivel" solo tiene sentido en el jefe; en el placement
        // inicial el mensaje es de bienvenida.
        verdict: _oraclePromotion
            ? ((result['decision'] as String?) ?? '')
            : '',
      );

      final updatedMessages = [
        ...state.messages.where((m) => m.text.isNotEmpty),
        ConversationMessage(sender: 'tutor', text: closing),
      ];
      if (_conversationId != null) {
        try {
          await _repository.saveMessage(_conversationId!, 'assistant', closing);
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/conversation/presentation/providers/conversation_providers.dart:931',
            e,
            stackTrace: st,
          );
        }
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
      _oracleFinalizing = false;
      state = state.copyWith(isProcessing: false, oracleEvaluating: false);
    }
  }

  /// Tiempo transcurrido desde la apertura del examen (P-31 / #116).
  Duration get _oracleElapsed {
    final start = _oracleStartedAt;
    if (start == null) return Duration.zero;
    return DateTime.now().difference(start);
  }

  /// Cierre por tiempo agotado (P-31 / #116).
  ///
  /// Usa las respuestas que haya; si no llega al mínimo, el servidor no
  /// evalúa y la UI lo explica en vez de dejar el examen colgado.
  Future<void> _forceCloseOracleExam() async {
    if (!_oraclePromotion || _oracleFinalizing || state.oracleFinished) return;
    debugPrint(
      'Oracle boss exam timed out after ${_oracleElapsed.inSeconds}s '
      '(${_oracleUserTurns} respuestas); se fuerza el cierre.',
    );
    await _finalizeOracleEvaluation(forced: true);
  }

  /// Construye el mensaje épico y breve de cierre del Oráculo con el resultado.
  String _buildOracleClosingMessage({
    required String cefrLevel,
    required String gameRank,
    String verdict = '',
  }) {
    if (verdict == 'maintained') {
      return 'Your level remains $cefrLevel, Rank $gameRank. '
          'The dungeon remembers your effort: sharpen your weakest skills '
          'and return.';
    }
    // Mensaje corto y directo: nivel + rango, sin extender.
    return 'Excellent. Your communication level is $cefrLevel. '
        'You will begin as a Rank $gameRank Adventurer. '
        'Welcome to the Guild.';
  }

  /// Registra el examen del Oráculo en `oracle_assessments`.
  ///
  /// El nivel y el rango ya los escribió el servidor en
  /// `user_language_profiles` (#73); aquí solo se guarda el histórico del
  /// examen (puntuaciones, fortalezas, explicación y transcripción).
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
      final Map<String, dynamic> scoresMap = scores is Map
          ? Map<String, dynamic>.from(scores)
          : const {};
      int _score(String key) => (scoresMap[key] as num?)?.toInt() ?? 0;

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
        if (_score('pronunciation') > 0)
          'scores_pronunciation': _score('pronunciation'),
        if (_score('fluency') > 0) 'scores_fluency': _score('fluency'),
        if (_score('grammar') > 0) 'scores_grammar': _score('grammar'),
        if (_score('vocabulary') > 0) 'scores_vocabulary': _score('vocabulary'),
        if (_score('listening') > 0)
          'scores_comprehension': _score('listening'),
        if (_score('naturalness') > 0)
          'scores_naturalness': _score('naturalness'),
        if (recommendedFocus.isNotEmpty) 'recommended_focus': recommendedFocus,
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
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/conversation/presentation/providers/conversation_providers.dart:1045',
        e,
        stackTrace: st,
      );
    }
  }

  int get _assessmentDurationSeconds {
    final start = _assessmentStart;
    if (start == null) return 0;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 - start;
  }

  /// Issue #31: ventana deslizante de contexto para el chat de rol. Enviar el
  /// historial completo hacía crecer el coste y la latencia en cada turno.
  static const int maxChatContextMessages = 24;

  /// P-41: presupuesto de contexto por caracteres (ademas del tope de
  /// mensajes). 24 mensajes largos cuestan mas que 24 cortos; recortar por
  /// longitud reduce tokens de entrada sin tocar el resto del flujo.
  static const int maxChatContextChars = 6000;

  List<ConversationMessage> _chatWindow() {
    final withText = state.messages
        .where((m) => m.text.trim().isNotEmpty)
        .toList();
    if (withText.length <= maxChatContextMessages) return withText;

    final selected = <ConversationMessage>[];
    var totalChars = 0;
    for (final message in withText.reversed) {
      if (selected.length >= maxChatContextMessages) break;
      final length = message.text.length;
      // Conserva siempre los ultimos 4 mensajes (contexto inmediato).
      if (selected.length >= 4 && totalChars + length > maxChatContextChars) {
        break;
      }
      totalChars += length;
      selected.add(message);
    }
    return selected.reversed.toList();
  }

  /// Issue #14: evita que el alumno inyecte el marcador de control del examen
  /// del Oráculo a través de su propio mensaje.
  static String _stripControlTokens(String text) {
    return text
        .replaceAll(
          RegExp(r'\[EVALUATION_COMPLETE\]', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\[RESULT:[^\]]*\]', caseSensitive: false), '')
        .trim();
  }

  // ── Process Transcription / Text → LLM → Supabase → TTS ────────────────────

  Future<void> _processTranscription(
    String userText, {
    bool reuseUserMessage = false,
  }) async {
    if (_hasProcessedThisTurn) return;
    _hasProcessedThisTurn = true;
    _lastUserText = userText;
    // P-40 (#125): señales del turno para el ajuste de dificultad. Se reinician
    // aquí y se consumen al cerrar la persistencia en segundo plano.
    _turnNumber++;
    final int turnNumber = _turnNumber;
    _correctionsThisTurn = 0;
    _goalsCompletedThisTurn = 0;
    // P-34g (#119): desde aquí hasta el primer chunk se mide la latencia que
    // alimenta el indicador "Pensando…" y el evento de analítica.
    _turnStartedAt = DateTime.now();
    _turnLatencyTracked = false;
    // P-29: identificador del turno para deduplicar correcciones en servidor.
    _correctionTurnRef =
        '${_conversationId ?? state.activeScenarioId ?? 'session'}_${DateTime.now().millisecondsSinceEpoch}';

    // P-07 (#92): el cobro de maná vive en el servidor (llm-proxy). Aquí solo
    // se calcula el código de acción para el registro de uso y el cobro remoto.
    _lastActionCode = state.isOracleEvaluation
        ? 'oracle_turn'
        : (state.activeScenarioId != null ? 'dungeon_turn' : 'free_chat_turn');

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
          messages: [
            ...state.messages.where((m) => m.text.isNotEmpty),
            userMessage,
          ],
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

      // 2. Build system instructions and history for DeepSeek.
      //
      // P-40 (#125): el prompt se compone con el perfil real del alumno
      // (intereses, estilo, instrucciones del perfil de IA, errores
      // recurrentes, metas pendientes, objetivo y frases útiles del escenario,
      // repaso acumulativo y el ajuste de dificultad del turno). No añade
      // ninguna llamada al modelo: viaja en este mismo turno de chat.
      final lesson =
          state.activeScenarioId != null && state.activeScenarioId!.isNotEmpty
          ? LessonCatalog.getLessonById(state.activeScenarioId)
          : null;

      final personalization = await _ensureTutorPersonalization();
      // P-40b (#221): la banda efectiva se resuelve con el nivel real y las
      // rachas del turno; el escenario aporta contenido, no la exigencia.
      final bandPlan = ScenarioBand.plan(
        learnerLevel: _learnerLevel(personalization),
        scenarioLevel: lesson?.level ?? '',
        adaptation: _adaptation.adjustment,
        totalGoals: lesson?.goals.length ?? 0,
      );
      final List<ScenarioGoalItem> lessonGoals = lesson == null
          ? const <ScenarioGoalItem>[]
          : bandPlan.goalBudget > 0
          ? lesson.goals.take(bandPlan.goalBudget).toList(growable: false)
          : lesson.goals;
      final pendingGoals = lessonGoals
          .where((g) => state.goalEvaluationResults[g.id] != true)
          .map((g) => g.text)
          .toList(growable: false);

      final List<Map<String, String>> historyList = [
        {
          'role': 'system',
          'content': TutorPromptBuilder.build(
            TutorPromptInput(
              correctionLevel: personalization.correctionLevel.isNotEmpty
                  ? personalization.correctionLevel
                  : _ref.read(correctionLevelProvider),
              cefrLevel: bandPlan.effectiveLevel.isNotEmpty
                  ? bandPlan.effectiveLevel
                  : (lesson?.level ?? personalization.cefrLevel),
              scenarioLevel: lesson?.level ?? '',
              tutorPersonality: personalization.tutorPersonality,
              correctionStyle: personalization.correctionStyle,
              interests: personalization.allInterests,
              motivation: personalization.motivation,
              tutorPromptInstructions: personalization.tutorPromptInstructions,
              pedagogicalSummary: personalization.pedagogicalSummary,
              assistantRole: lesson?.assistantRole,
              userRole: lesson?.userRole,
              scenarioContext: lesson?.scenarioContext,
              mainObjective: lesson?.mainObjective,
              pendingGoals: pendingGoals,
              usefulPhrases:
                  lesson?.usefulPhrases
                      .map((p) => p.phrase)
                      .toList(growable: false) ??
                  const <String>[],
              recurringErrors: _recurringErrors,
              reviewPhrases: personalization.reviewPhrases,
              adaptation: _adaptation.adjustment,
              struggleStreak: _adaptation.struggleStreak,
              successStreak: _adaptation.successStreak,
            ),
          ),
        },
        ..._chatWindow().map(
          (m) => {
            'role': m.sender == 'user' ? 'user' : 'assistant',
            'content': _stripControlTokens(m.text),
          },
        ),
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
        _trackTurnLatency();
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
      _ref.invalidate(manaStateProvider);

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
        turnNumber: turnNumber,
      );
    } catch (e) {
      debugPrint('Conversation error: $e');
      // Un fallo de IA NUNCA es un mensaje del tutor: se quita el placeholder
      // vacio, no se narra por TTS y no se persiste en `messages`.
      final msgs = List<ConversationMessage>.from(state.messages);
      if (msgs.isNotEmpty &&
          msgs.last.sender == 'tutor' &&
          msgs.last.text.isEmpty) {
        msgs.removeLast();
      }
      final err = e is AiStreamException
          ? e
          : const AiStreamException(
              AiErrorKind.unknown,
              'Error al procesar la respuesta. Intenta de nuevo.',
            );

      // P-07: el reembolso de un turno fallido lo hace el proxy (service role).
      final errorText = err.message;

      _hasProcessedThisTurn = false;
      state = state.copyWith(
        isProcessing: false,
        messages: msgs,
        errorMessage: errorText,
      );
      _ref
          .read(conversationErrorProvider.notifier)
          .state = ConversationErrorState(
        message: errorText,
        kind: err.kind,
        canRetry: _lastUserText != null && _lastUserText!.isNotEmpty,
      );
      // Utiliza `_track` para no insertar eventos con un `user_id` inválido
      // (`user_id` es uuid y NOT NULL): sin sesión no hay nada que medir.
      _track(
        AnalyticsEvent.aiError,
        properties: {
          'endpoint': 'chat',
          'code': err.code,
          'retries': err.retries,
          // P-07: el reembolso lo decide el proxy; el cliente no lo sabe.
          'refunded': false,
        },
      );
    }
  }

  /// Reintenta el ultimo turno. El proxy vuelve a cobrar y reembolsa si falla.
  Future<void> retryLastTurn() async {
    final text = _lastUserText;
    if (text == null || text.isEmpty) return;
    _ref.read(conversationErrorProvider.notifier).state = null;
    await _processTranscription(text, reuseUserMessage: true);
  }

  void _asyncSaveAndAnalyzeSession({
    required String? conversationId,
    required String fullTutorResponse,
    required String? userId,
    required String userText,
    required LessonData? lesson,
    int turnNumber = 0,
  }) async {
    try {
      if (conversationId != null && fullTutorResponse.isNotEmpty) {
        await _repository.saveMessage(
          conversationId,
          'assistant',
          fullTutorResponse,
        );
      }

      if (userId != null && userText.isNotEmpty) {
        final wordCount = userText.trim().split(RegExp(r'\s+')).length;
        final int estimatedWpm = ((wordCount / 4.0) * 60).round().clamp(
          50,
          200,
        );
        const double latencySec = 1.8;
        _repository.logFluencyMetrics(
          userId,
          state.activeScenarioId,
          latencySec,
          estimatedWpm,
        );

        if (lesson != null && lesson.usefulPhrases.isNotEmpty) {
          for (final phrase in lesson.usefulPhrases) {
            final double similarity = TextDiffUtils.calculateSimilarity(
              phrase.phrase,
              userText,
            );
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

      // P-33 (#118): el vocabulario ya NO se extrae por turno (el regex metía
      // basura de STT 6 veces por sesión). Se cura UNA vez al cerrar la sesión
      // en `endSession` → `curateSessionVocabulary`.

      var goalEvalRanThisTurn = false;
      if (lesson != null && lesson.goals.isNotEmpty) {
        // P-39: solo las metas pendientes pueden activar la evaluación. Si ya
        // están todas, no se gasta una llamada al cerrar ni en el turno.
        final pendingGoals = lesson.goals
            .where((g) => state.goalEvaluationResults[g.id] != true)
            .toList();
        if (pendingGoals.isEmpty) {
          _goalsEvaluatedForLastTurn = true;
          _goalEvaluationPendingRetry = false;
        } else {
          // P-41: una llamada de IA solo si la respuesta aporta senal. P-39:
          // un fallo previo fuerza el reintento con el historial acumulado.
          final lastUser = state.messages.lastWhere(
            (m) => m.sender == 'user',
            orElse: () => ConversationMessage(sender: 'user', text: ''),
          );
          final hasSignal = GoalEvaluationGate.shouldEvaluate(
            lastUserMessage: lastUser.text,
            goalTexts: pendingGoals.map((g) => g.text).toList(),
            goalKeywords: pendingGoals.expand((g) => g.keywords).toList(),
          );
          _goalsEvaluatedForLastTurn = _goalEvaluationPendingRetry || hasSignal;
          if (_goalsEvaluatedForLastTurn) {
            goalEvalRanThisTurn = true;
            final succeeded = await _evaluateGoalsWithAi(lesson.goals);
            _goalsEvaluatedForLastTurn = succeeded;
            _goalEvaluationPendingRetry = !succeeded;
          }
        }
      }

      // P-29-b (#193): si este turno no lanzó `goal_eval`, no hay respuesta que
      // traiga correcciones (chat libre, lección sin metas o metas ya
      // cumplidas). Se piden aparte con el gate y el presupuesto de sesión; si
      // el proxy devuelve 402 no se pide más y el chat sigue igual.
      await _maybeRequestTurnCorrections(
        messageText: userText,
        goalEvalRanThisTurn: goalEvalRanThisTurn,
      );
    } catch (e) {
      debugPrint('Background DB persistence error: $e');
    } finally {
      // P-40 (#125): con las correcciones y las metas ya evaluadas, se cierra
      // el turno para el ajuste de dificultad. No hay llamada extra al modelo.
      _recordTurnAdaptation(turnNumber: turnNumber, userText: userText);
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
  ///
  /// P-29: la misma respuesta trae las correcciones del turno
  /// (`GoalEvaluationResult.corrections`); no hay ninguna llamada extra.
  ///
  /// P-39: devuelve `true` solo si la evaluación se completó. Un `false` deja
  /// `_goalEvaluationPendingRetry` activo para reintentar en el turno
  /// siguiente y en el cierre de sesión.
  Future<bool> _evaluateGoalsWithAi(List<ScenarioGoalItem> goals) async {
    try {
      final uncompleted = goals
          .where((g) => state.goalEvaluationResults[g.id] != true)
          .toList();
      if (uncompleted.isEmpty) return true;

      // Ventana móvil (IA-03): evaluar solo la porción más reciente de la
      // conversación para acotar el costo de tokens.
      final conversationText = _recentConversationText();

      final goalItems = uncompleted
          .map((g) => {'id': g.id, 'text': g.text})
          .toList();

      final evaluation = await _repository.evaluateGoals(
        conversationText,
        goalItems,
      );

      // P-29: correcciones del turno (chip + registro en `corrections`).
      _handleTurnCorrections(evaluation.corrections);

      if (!evaluation.succeeded) {
        debugPrint(
          'Goal evaluation failed: el proxy no devolvió un JSON legible; '
          'se reintentará en el siguiente turno.',
        );
        return false;
      }

      // P-39: doble defensa del catálogo. El repositorio ya filtró los ids,
      // pero nunca se marca una meta si el id no está en `goals`.
      final knownGoalIds = goals.map((g) => g.id).toSet();
      final results = evaluation.goalsForCatalog(knownGoalIds);
      if (results.isNotEmpty) {
        final merged = Map<String, bool>.from(state.goalEvaluationResults);
        int newlyCompleted = 0;
        for (final e in results.entries) {
          if (!e.value) continue;
          final goalIndex = goals.indexWhere((g) => g.id == e.key);
          if (goalIndex < 0) continue;
          if (merged[e.key] != true) newlyCompleted++;
          merged[e.key] = true;
          if (_userId != null && state.activeScenarioId != null) {
            _repository.saveCompletedGoal(
              _userId!,
              state.activeScenarioId!,
              _conversationId,
              e.key,
              goals[goalIndex].text,
            );
          }
        }
        state = state.copyWith(
          goalEvaluationResults: merged,
          newGoalsCompleted: state.newGoalsCompleted + newlyCompleted,
        );
        // P-40 (#125): señal de éxito del turno.
        _goalsCompletedThisTurn += newlyCompleted;
      }
      return true;
    } catch (e) {
      debugPrint('Goal evaluation failed (non-blocking): $e');
      return false;
    }
  }

  /// Ventana móvil (IA-03) de la conversación enviada al modelo: los últimos
  /// 12 mensajes con texto, en formato `Student:`/`Tutor:`.
  String _recentConversationText({int maxMessages = 12}) {
    final recent = state.messages.length > maxMessages
        ? state.messages.sublist(state.messages.length - maxMessages)
        : state.messages;
    return recent
        .map((m) => '${m.sender == 'user' ? 'Student' : 'Tutor'}: ${m.text}')
        .join('\n');
  }

  /// P-29-b (#193): pide las correcciones del turno cuando no hubo `goal_eval`.
  ///
  /// Best-effort y sin bloquear: un fallo, un JSON ilegible o un 402 dejan la
  /// conversación exactamente igual (sin chip y sin error visible). El coste
  /// lo acota [CorrectionTurnPolicy] (gate de longitud + tope por sesión) y el
  /// maná lo cobra `llm-proxy` con `action_code = correction_turn`.
  Future<void> _maybeRequestTurnCorrections({
    required String messageText,
    required bool goalEvalRanThisTurn,
  }) async {
    final userId = _userId;
    if (userId == null || userId.startsWith('guest_')) return;
    if (state.isOracleEvaluation || messageText.trim().isEmpty) return;

    final level = _ref.read(correctionLevelProvider);
    final shouldRequest = CorrectionTurnPolicy.shouldRequest(
      correctionLevel: level,
      lastUserMessage: messageText,
      evaluationsThisSession: _correctionEvaluations,
      goalsEvaluatedThisTurn: goalEvalRanThisTurn,
      skippedForMana: _correctionsSkippedForMana,
    );
    if (!shouldRequest) return;

    final result = await _repository.evaluateTurnCorrections(
      _recentConversationText(),
      conversationId: _conversationId,
    );

    switch (result.outcome) {
      case CorrectionTurnOutcome.noMana:
        // Plan gratuito sin maná: se deja de pedir en esta sesión. El turno ya
        // está respondido, así que el 402 no rompe nada.
        _correctionsSkippedForMana = true;
        debugPrint('correction_turn: sin maná, correcciones desactivadas');
      case CorrectionTurnOutcome.ok:
      case CorrectionTurnOutcome.failed:
        // Los intentos fallidos también consumen presupuesto: el tope acota el
        // gasto de IA por sesión, no solo las evaluaciones con éxito.
        _correctionEvaluations++;
    }

    _handleTurnCorrections(result.corrections, messageText: messageText);

    unawaited(
      RetentionAnalytics.instance.track(
        userId,
        AnalyticsEvent.correctionEval,
        properties: {
          'action': 'correction_turn',
          'result': switch (result.outcome) {
            CorrectionTurnOutcome.ok => 'ok',
            CorrectionTurnOutcome.noMana => 'no_mana',
            CorrectionTurnOutcome.failed => 'failed',
          },
          'count': result.corrections.length,
          'evals': _correctionEvaluations,
          'level': normalizeCorrectionLevel(level),
        },
      ),
    );
  }

  /// P-29: pinta el chip bajo la burbuja del último mensaje y registra las
  /// correcciones en `public.corrections` (best-effort, sin bloquear el turno).
  ///
  /// [messageText] ancla el chip al turno evaluado aunque el alumno ya haya
  /// enviado otro mensaje mientras la evaluación corría en segundo plano.
  void _handleTurnCorrections(
    List<TurnCorrection> corrections, {
    String? messageText,
  }) {
    if (corrections.isEmpty) return;
    // P-40 (#125): señal de fallo para el ajuste de dificultad del próximo
    // turno (sin coste: usa las correcciones que el turno ya evaluó).
    _correctionsThisTurn += corrections.length;
    final target = messageText ?? _lastUserText;
    if (target == null || target.isEmpty) return;

    _ref
        .read(sessionCorrectionsProvider.notifier)
        .addForMessage(target, corrections);

    final userId = _userId;
    final turnRef = _correctionTurnRef;
    if (userId == null || userId.startsWith('guest_') || turnRef == null)
      return;

    unawaited(
      _ref
          .read(correctionsRepositoryProvider)
          .saveCorrections(
            userId: userId,
            turnRef: turnRef,
            corrections: corrections,
            conversationId: _conversationId,
          ),
    );
  }

  /// Carga los errores recurrentes del alumno (vista `user_recurring_errors`).
  /// Alimentan el prompt del tutor y la misión de refuerzo.
  Future<void> _loadRecurringErrors() async {
    final userId = _userId;
    if (userId == null || userId.startsWith('guest_')) return;
    try {
      _recurringErrors = await _ref
          .read(correctionsRepositoryProvider)
          .loadRecurringErrors(limit: 3);
    } catch (e) {
      debugPrint('No se pudieron cargar los errores recurrentes: $e');
    }
  }

  /// P-40b (#221): nivel real del alumno para resolver la banda del escenario.
  ///
  /// Prefiere el perfil de personalización (recién leído en el turno); si aún
  /// no cargó, usa el nivel que el dashboard ya tiene en memoria.
  String _learnerLevel(TutorPersonalization personalization) {
    final fromProfile = personalization.cefrLevel.trim();
    if (fromProfile.isNotEmpty) return fromProfile;
    return _sessionLearnerLevel ?? '';
  }

  /// Nivel mostrado por el dashboard al abrir la sesión, sin lanzar consultas.
  String _readLearnerLevel() {
    try {
      final level = _ref.read(userProgressProvider).value?['level_code'];
      return (level as String?)?.trim() ?? '';
    } catch (e) {
      debugPrint('No se pudo leer el nivel real del alumno: $e');
      return '';
    }
  }

  /// Saludo inicial en la banda efectiva cuando el escenario queda por encima
  /// del alumno. No genera contenido: reutiliza el catálogo por nivel.
  String _openingForLearner(LessonData lesson) {
    final plan = ScenarioBand.plan(
      learnerLevel: _sessionLearnerLevel ?? '',
      scenarioLevel: lesson.level,
    );
    if (!plan.changesBand || plan.effectiveLevel.isEmpty) {
      return lesson.initialAssistantMessage;
    }
    return LessonCatalog.levelAppropriateOpening(
      plan.effectiveLevel,
      lesson.title,
    );
  }

  /// P-40 (#125): lee el perfil del alumno sin bloquear la apertura del chat.
  ///
  /// El primer turno espera la lectura con [_ensureTutorPersonalization]; el
  /// saludo inicial no, para no retrasar la narración. Invitados y sesiones del
  /// Oráculo no pagan estas consultas.
  Future<void> _loadTutorPersonalization({String? scenarioId}) {
    final userId = _userId;
    _personalization = TutorPersonalization.empty;
    _personalizationLoaded = false;
    if (userId == null || userId.startsWith('guest_')) {
      _personalizationLoaded = true;
      _personalizationFuture = Future<void>.value();
      return _personalizationFuture!;
    }
    final future = _ref
        .read(tutorPersonalizationRepositoryProvider)
        .load(userId, currentScenarioId: scenarioId)
        .then<void>((value) {
          _personalization = value;
          _personalizationLoaded = true;
        })
        .catchError((Object e) {
          debugPrint('No se pudo cargar la personalización del tutor: $e');
        });
    _personalizationFuture = future;
    return future;
  }

  /// Garantiza el perfil antes de construir el prompt (solo la primera vez).
  Future<TutorPersonalization> _ensureTutorPersonalization() async {
    final pending = _personalizationFuture;
    if (!_personalizationLoaded && pending != null) {
      await pending;
    }
    return _personalization;
  }

  /// P-40: convierte las señales del turno en una racha de acierto/fallo.
  ///
  /// Corre al terminar la persistencia del turno (donde ya se conocen las
  /// correcciones y las metas cumplidas). Si el alumno ya envió otro turno
  /// mientras tanto, no se mezclan señales.
  void _recordTurnAdaptation({
    required int turnNumber,
    required String userText,
  }) {
    if (turnNumber != _turnNumber) return;
    final wordCount = userText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    _adaptation.record(
      TutorTurnOutcome(
        corrections: _correctionsThisTurn,
        wordCount: wordCount,
        goalsCompleted: _goalsCompletedThisTurn,
      ),
    );
  }

  Future<void> playTtsVoice(String text) async {
    await _speakTts(text);
  }

  Future<void> stopTts({bool suppress = false}) async {
    if (suppress) _ttsSuppressed = true;
    try {
      await _tts.stop();
    } catch (e) {
      // El motor TTS puede no existir (tests, dispositivo sin motor): el
      // estado debe quedar en "no hablando" igualmente.
      debugPrint('TTS stop failed (non-blocking): $e');
    }
    state = state.copyWith(isPlaying: false);
  }

  /// P-34a (#119): el usuario pulsa "Detener" mientras el tutor narra.
  Future<void> pauseTts() async {
    await stopTts();
    _track(AnalyticsEvent.ttsStopped, properties: {'source': 'button'});
  }

  /// End the conversation session — persists final data and refreshes dashboard.
  Future<Map<String, dynamic>?> endSession({int practiceMinutes = 1}) async {
    if (_sessionFinalized) {
      return _lastSessionResult; // idempotente: una sola persistencia
    }
    Map<String, dynamic>? rewards;
    String? rewardSessionId;
    var newWords = <CuratedVocabularyItem>[];
    _sessionFinalized = true;
    // P-41: si el ultimo turno se salto por el gate de coste, evaluar las
    // metas al cerrar para no perder objetivos.
    if (!_goalsEvaluatedForLastTurn &&
        !state.isOracleEvaluation &&
        _userId != null &&
        !_userId!.startsWith('guest_')) {
      try {
        final scenarioId = state.activeScenarioId;
        final lesson = scenarioId == null
            ? null
            : LessonCatalog.getLessonById(scenarioId);
        if (lesson != null && lesson.goals.isNotEmpty) {
          final pendingGoals = lesson.goals
              .where((g) => state.goalEvaluationResults[g.id] != true)
              .toList();
          if (pendingGoals.isNotEmpty) {
            await _evaluateGoalsWithAi(
              lesson.goals,
            ).timeout(const Duration(seconds: 12));
          }
        }
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:goal_eval_close',
          e,
          stackTrace: st,
        );
      }
    }
    if (_userId != null) {
      try {
        final repo = _ref.read(dashboardRepositoryProvider);
        await repo.logPracticeSession(_userId!, practiceMinutes);
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:1443',
          e,
          stackTrace: st,
        );
      }

      // P-33 (#118): curaduría de vocabulario UNA vez por sesión (no por
      // turno). El modelo propone ≤8 palabras y el RPC valida, deduplica y
      // programa el primer repaso. Un fallo no bloquea el cierre.
      try {
        final convId = _conversationId;
        if (convId != null &&
            !_userId!.startsWith('guest_') &&
            !state.isOracleEvaluation &&
            state.messages.any((m) => m.sender == 'user')) {
          newWords = await _repository.curateSessionVocabulary(
            _userId!,
            convId,
            state.messages,
          );
          if (newWords.isNotEmpty) {
            _ref.invalidate(learnedVocabularyProvider);
            _ref.invalidate(dueVocabularyProvider);
          }
        }
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:1604',
          e,
          stackTrace: st,
        );
      }

      // Issue #5: cerrar sesión avanza las misiones de sesión y de minutos
      // hablados. Antes de este cambio, `advance_missions_for_user` no tenía
      // ningún llamador: las 533 instancias se quedaban en `active` para siempre.
      // Las misiones las avanza el servidor (triggers de mensajes, ledger de
      // sesión y vocabulario). No se duplica desde el cliente (issue #93).

      // Registro de superación de la lección (lesson_progress):
      //  - passed si cumple la regla única `LessonCompletion.isPassed`.
      //  - failed si no; permite reintentar gastando maná.
      final scenarioId = state.activeScenarioId;
      if (scenarioId != null && !state.isOracleEvaluation) {
        try {
          final lesson = LessonCatalog.getLessonById(scenarioId);
          final evaluated = state.goalEvaluationResults.length;
          final totalGoals = lesson?.goals.length ?? evaluated;
          final completedGoals = state.goalEvaluationResults.values
              .where((v) => v)
              .length;
          // Issue #18: sin evaluación no se puede afirmar que la lección se
          // superó. Antes, una evaluación vacía daba ratio 1.0 => "passed".
          if (evaluated > 0 && totalGoals > 0) {
            final status = LessonCompletion.isPassed(completedGoals, totalGoals)
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
            unawaited(
              Supabase.instance.client
                  .rpc(
                    'record_scenario_outcome',
                    params: {
                      'p_scenario_id': scenarioId,
                      'p_completed': completedGoals,
                      'p_total': totalGoals,
                    },
                  )
                  .then((_) => _ref.invalidate(scenarioProgressProvider)),
            );
          }
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/conversation/presentation/providers/conversation_providers.dart:1489',
            e,
            stackTrace: st,
          );
        }
      }

      // P-42 (#127) — Refuerzo con evidencia real. Si la lección no se superó
      // (<80% de metas) se construye un plan con los errores recurrentes
      // (P-29) y los objetivos fallados. Sin evidencia no se genera ni se
      // cobra nada, y la UI lo explica en el resumen de sesión.
      if (scenarioId != null && !state.isOracleEvaluation) {
        _ref.read(remedialLessonProvider.notifier).state = null;
        try {
          final lesson = LessonCatalog.getLessonById(scenarioId);
          final evaluated = state.goalEvaluationResults.length;
          final totalGoals = lesson?.goals.length ?? evaluated;
          final completedGoals = state.goalEvaluationResults.values
              .where((v) => v)
              .length;
          if (evaluated > 0 &&
              !LessonCompletion.isPassed(completedGoals, totalGoals)) {
            final radar = await _ref.read(skillsRadarProvider.future);
            // Los errores de esta misma sesión ya están en `corrections`:
            // se releen para que el refuerzo use la evidencia más reciente.
            await _loadRecurringErrors();
            final failedGoals = (lesson?.goals ?? const [])
                .where((g) => state.goalEvaluationResults[g.id] == false)
                .map((g) => g.text)
                .toList();
            final plan = buildRemedialPlan(
              radar: radar,
              recurringErrors: _recurringErrors,
              failedGoals: failedGoals,
            );
            // P-40b (#221): el refuerzo se genera una banda por debajo del
            // nivel real (el alumno acaba de fallar). No añade ninguna llamada:
            // es la misma invocación de P-42 con la banda adyacente.
            final realLevel =
                (_ref.read(userProgressProvider).value?['level_code']
                    as String?) ??
                'A1';
            final level = ScenarioBand.remedialLevel(realLevel);

            final result = plan == null
                ? const RemedialLessonResult(
                    status: RemedialLessonStatus.noEvidence,
                    detail:
                        'sin evidencia (ni errores recurrentes ni metas falladas)',
                  )
                : await LessonGeneratorService.ensureRemedialLesson(
                    plan: plan,
                    level: level,
                    parentId: scenarioId,
                  );

            _ref.read(remedialLessonProvider.notifier).state = result;
            _ref
                .read(remedialRetryContextProvider.notifier)
                .state = plan == null
                ? null
                : (plan: plan, level: level, parentId: scenarioId);
            if (result.isPlayable) {
              _ref.invalidate(recommendedLessonsProvider);
              // El maná se cobra server-side: refresca la barra al volver.
              _ref.invalidate(manaStateProvider);
            }
          }
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/conversation/presentation/providers/conversation_providers.dart:remedial',
            e,
            stackTrace: st,
          );
          _ref
              .read(remedialLessonProvider.notifier)
              .state = RemedialLessonResult(
            status: RemedialLessonStatus.failed,
            detail: e.toString(),
          );
        }
      }

      // Loot/drops (FASE B): las sesiones otorgan ITEMS (fragmentos, oro) y
      // AURA (mérito sin tope). NUNCA otorgan maná ni gemas de maná.
      try {
        final economyRepo = _ref.read(economyRepositoryProvider);
        final completedGoals = state.goalEvaluationResults.values
            .where((v) => v)
            .length;
        final sessionId = _conversationId;
        if (sessionId != null) {
          rewardSessionId = sessionId;
          // #4: el servidor calcula objetivos y minutos desde la conversación
          // y el ledger de metas; el cliente ya no envía importes.
          rewards = await economyRepo.closeSession(sessionId);
          _ref.invalidate(fragmentBalanceProvider);
          _ref.invalidate(goldBalanceProvider);

          // Aura: mérito ilimitado. El RPC aplica el factor_radar (radar
          // pondera la ganancia pero nunca topa el total) e idempotencia por sesión.
          try {
            final radar = await _ref.read(skillsRadarProvider.future);
            final levelCode =
                (_ref.read(userProgressProvider).value?['level_code']
                    as String?) ??
                'A1';
            final levelBonus = switch (levelCode.toUpperCase()) {
              'A2' => 1,
              'B1' => 2,
              'B2' => 3,
              'C1' => 4,
              'C2' => 5,
              _ => 0,
            };
            await economyRepo.addAuraXp(
              _userId!,
              sessionId,
              radar,
              completedGoals,
              levelBonus,
            );
            _ref.invalidate(auraXpProvider);
          } catch (e, st) {
            ErrorTracker.logSilent(
              'lib/features/conversation/presentation/providers/conversation_providers.dart:1568',
              e,
              stackTrace: st,
            );
          }
        }
        // Racha y minutos: una sola fuente de verdad en servidor (issue #88).
        final streakSessionId =
            rewardSessionId ??
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
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:1585',
          e,
          stackTrace: st,
        );
      }

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
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:1612',
          e,
          stackTrace: st,
        );
      }

      try {
        // Issue #35: cierre de sesión con volumen real de actividad.
        final turns = state.messages.where((m) => m.sender == 'user').length;
        final completed = state.goalEvaluationResults.values
            .where((v) => v)
            .length;
        unawaited(
          RetentionAnalytics.instance.track(
            _userId!,
            AnalyticsEvent.sessionEnd,
            properties: {
              'turns': turns,
              'goals_completed': completed,
              'goals_total': state.goalEvaluationResults.length,
              'oracle': state.isOracleEvaluation,
            },
          ),
        );
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:1629',
          e,
          stackTrace: st,
        );
      }
      try {
        _ref.invalidate(userProgressProvider);
        _ref.invalidate(userAchievementsProvider);
        _ref.invalidate(recommendedLessonsProvider);
        // El maná se consumió por turno durante la sesión: forzar el refresco
        // de la barra al volver al dashboard (evita mostrar el saldo viejo).
        _ref.invalidate(manaStateProvider);
        // Also increment the refresh trigger for non-autoDispose safety
        _ref.read(dashboardRefreshProvider.notifier).state++;
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:1639',
          e,
          stackTrace: st,
        );
      }
    }

    final completedGoals = state.goalEvaluationResults.values
        .where((v) => v)
        .length;
    // P-28: el total de metas sale del catálogo curricular, no del número
    // de metas evaluadas (que puede ser menor y falsear el "3/3").
    final sessionLesson = LessonCatalog.getLessonById(
      state.activeScenarioId,
      title: state.activeScenarioName,
    );
    final result = <String, dynamic>{
      'xp': (rewards?['xp'] as num?)?.toInt() ?? 0,
      'gold': (rewards?['gold'] as num?)?.toInt() ?? 0,
      'fragments': (rewards?['fragments'] as num?)?.toInt() ?? 0,
      'duplicated': rewards?['duplicated'] ?? false,
      'reward_applied': rewards != null,
      'objectives': completedGoals,
      'goals_total':
          sessionLesson?.goals.length ?? state.goalEvaluationResults.length,
      'minutes': practiceMinutes,
      'turns': state.messages.where((m) => m.sender == 'user').length,
      'is_oracle': state.isOracleEvaluation,
      'scenario_id': state.activeScenarioId,
      'session_id': rewardSessionId,
      'started_at': _sessionStartedAt?.toUtc().toIso8601String(),
      // P-33 (#118): palabras nuevas validadas y programadas para repaso.
      'new_words': newWords.map((item) => item.toDisplayJson()).toList(),
    };
    _lastSessionResult = result;
    return result;
  }

  @override
  void dispose() {
    _oracleCloseTimer?.cancel();
    _oracleCloseTimer = null;
    unawaited(_disposePlugins());
    super.dispose();
  }

  /// Cierra los plugins nativos sin romper el árbol de providers cuando no
  /// existen (tests) o el motor falla.
  Future<void> _disposePlugins() async {
    try {
      await _audioRecorder.dispose();
    } catch (e) {
      debugPrint('Record dispose failed (non-blocking): $e');
    }
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS dispose failed (non-blocking): $e');
    }
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

final conversationErrorProvider = StateProvider<ConversationErrorState?>(
  (ref) => null,
);

/// P-28: recompensa de la sesión confirmada en servidor.
///
/// Es `AsyncValue` para que el resumen distinga "confirmando", "lista" y
/// "error accionable". Reintentar es seguro: `close_session` es idempotente
/// por conversación (ledger `session_reward_ledger`) y devuelve los importes
/// ya acreditados.
class SessionRewardNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  SessionRewardNotifier(this._ref)
    : super(const AsyncValue<Map<String, dynamic>?>.data(null));

  final Ref _ref;

  /// Publica el resultado real del cierre de sesión.
  void confirm(Map<String, dynamic>? result) {
    state = AsyncValue<Map<String, dynamic>?>.data(result);
  }

  /// Repite el cierre cuando no se pudo confirmar la recompensa (red, timeout).
  Future<void> retry() async {
    final current = state.valueOrNull;
    final sessionId = current?['session_id'] as String?;
    if (current == null || sessionId == null || sessionId.isEmpty) {
      state = AsyncValue<Map<String, dynamic>?>.error(
        StateError(
          'No hay una sesión registrada que confirmar. Cierra la conversación '
          'desde la pantalla de práctica para generar la recompensa.',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue<Map<String, dynamic>?>.loading();
    try {
      final rewards = await _ref
          .read(economyRepositoryProvider)
          .closeSession(sessionId);
      _ref.invalidate(fragmentBalanceProvider);
      _ref.invalidate(goldBalanceProvider);
      _ref.invalidate(userProgressProvider);
      state = AsyncValue<Map<String, dynamic>?>.data({
        ...current,
        'xp': (rewards['xp'] as num?)?.toInt() ?? 0,
        'gold': (rewards['gold'] as num?)?.toInt() ?? 0,
        'fragments': (rewards['fragments'] as num?)?.toInt() ?? 0,
        'duplicated': rewards['duplicated'] ?? false,
        'reward_applied': rewards['success'] == true,
      });
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/conversation/presentation/providers/conversation_providers.dart:1899',
        e,
        stackTrace: st,
      );
      state = AsyncValue<Map<String, dynamic>?>.error(e, st);
    }
  }
}

final sessionResultProvider =
    StateNotifierProvider<
      SessionRewardNotifier,
      AsyncValue<Map<String, dynamic>?>
    >((ref) => SessionRewardNotifier(ref));

/// P-42 (#127): resultado de la lección de refuerzo de la última sesión.
///
/// `null` = aún no se intentó (o la sesión se superó). La pantalla de resumen
/// lo pinta para que el jugador entre a la lección o entienda por qué no se
/// generó.
final remedialLessonProvider = StateProvider<RemedialLessonResult?>(
  (ref) => null,
);

/// Contexto del último intento de refuerzo, para reintentar desde el resumen
/// sin volver a evaluar la conversación.
final remedialRetryContextProvider =
    StateProvider<({RemedialPlan plan, String level, String? parentId})?>(
      (ref) => null,
    );

/// P-28: "Qué aprendiste" de una sesión, leído de la base de datos.
///
/// Una sola RPC agrega palabras nuevas/repasadas, correcciones, metas y foco
/// recomendado. La ventana la aporta el cliente porque la fila de
/// `conversations` se reutiliza por escenario. Si falla, el resumen muestra
/// el error con opción de reintentar (nunca cifras inventadas).
final sessionLearnedSummaryProvider = FutureProvider.autoDispose
    .family<LearnedSummaryData, ({String conversationId, DateTime since})>((
      ref,
      args,
    ) async {
      try {
        final res = await ref
            .watch(supabaseClientProvider)
            .rpc(
              'get_session_learned_summary',
              params: {
                'p_conversation_id': args.conversationId,
                'p_since': args.since.toUtc().toIso8601String(),
              },
            );
        return LearnedSummaryData.fromRpc(res);
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/providers/conversation_providers.dart:1943',
          e,
          stackTrace: st,
        );
        rethrow;
      }
    });

final conversationStateProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
      final repo = ref.watch(conversationRepositoryProvider);
      return ConversationNotifier(repo, ref);
    });

final micModeHoldToTalkProvider = StateProvider<bool>((ref) => false);
