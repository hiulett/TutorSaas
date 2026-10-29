import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_taxonomy.dart';
import '../../../../core/i18n/language_settings.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../conversation/domain/repositories/conversation_repository.dart';
import '../../../conversation/presentation/providers/conversation_providers.dart';
import '../../data/mini_conversation_store.dart';
import '../../domain/models/mini_conversation_script.dart';

/// Resultado de un intento de responder con voz.
enum MiniVoiceResult { ok, empty, error, ignored }

/// Motivo por el que la escena no pudo continuar. La UI lo traduce.
enum MiniConversationFailure { unavailable }

final miniConversationStoreProvider = Provider<MiniConversationStore>(
  (ref) => const MiniConversationStore(),
);

/// Estado de la mini-conversación (P-25 / #110).
class MiniConversationState {
  const MiniConversationState({
    this.turns = const [],
    this.userTurns = 0,
    this.isSending = false,
    this.isComplete = false,
    this.failure,
  });

  final List<MiniConversationTurn> turns;
  final int userTurns;
  final bool isSending;
  final bool isComplete;

  /// No nulo cuando el modelo o la red fallaron: la escena termina sin
  /// bloquear el onboarding.
  final MiniConversationFailure? failure;

  bool get canReply =>
      !isSending &&
      !isComplete &&
      failure == null &&
      userTurns < MiniConversationScript.maxUserTurns;

  int get remainingTurns => MiniConversationScript.remainingTurns(userTurns);

  MiniConversationState copyWith({
    List<MiniConversationTurn>? turns,
    int? userTurns,
    bool? isSending,
    bool? isComplete,
    MiniConversationFailure? failure,
  }) {
    return MiniConversationState(
      turns: turns ?? this.turns,
      userTurns: userTurns ?? this.userTurns,
      isSending: isSending ?? this.isSending,
      isComplete: isComplete ?? this.isComplete,
      failure: failure ?? this.failure,
    );
  }
}

final miniConversationProvider =
    StateNotifierProvider.autoDispose<
      MiniConversationNotifier,
      MiniConversationState
    >((ref) {
      final repository = ref.watch(conversationRepositoryProvider);
      final store = ref.watch(miniConversationStoreProvider);
      // `read`: el idioma nativo se congela al abrir la escena; un cambio de
      // ajustes a mitad de conversación no debe recrear el notifier.
      final nativeLanguage = ref.read(userLanguageProvider).uiLanguage;
      final userId = ref.read(currentUserProvider)?.id ?? '';
      return MiniConversationNotifier(
        repository: repository,
        store: store,
        userId: userId,
        nativeLanguage: nativeLanguage,
      );
    });

/// Conduce la escena: 2 respuestas como máximo, sin persistencia y sin maná.
///
/// Nunca lanza: cualquier fallo del modelo/red deja `failure` puesto y la UI
/// ofrece continuar al reino.
class MiniConversationNotifier extends StateNotifier<MiniConversationState> {
  MiniConversationNotifier({
    required ConversationRepository repository,
    required MiniConversationStore store,
    required String userId,
    required String nativeLanguage,
  }) : _repository = repository,
       _store = store,
       _userId = userId,
       _nativeLanguage = nativeLanguage,
       super(const MiniConversationState());

  final ConversationRepository _repository;
  final MiniConversationStore _store;
  final String _userId;
  final String _nativeLanguage;

  bool _seenMarked = false;
  bool _completedTracked = false;

  /// Pinta el saludo fijo de Mira. Idempotente: llamarlo dos veces no duplica.
  void start() {
    if (state.turns.isNotEmpty) return;
    state = state.copyWith(
      turns: const [
        MiniConversationTurn(
          fromUser: false,
          text: MiniConversationScript.openingLine,
        ),
      ],
    );
    _track(AnalyticsEvent.miniConversationStarted, {
      'max_turns': MiniConversationScript.maxUserTurns,
    });
  }

  /// Envía una respuesta de texto del jugador y transmite la del tutor.
  Future<void> replyText(String text) => _reply(text, input: 'text');

  /// Transcribe un audio con el mismo pipeline del chat (llm-proxy `/transcribe`)
  /// y lo envía como respuesta. No modifica el pipeline: solo lo consume.
  Future<MiniVoiceResult> replyWithVoice(String audioPath) async {
    if (!state.canReply) return MiniVoiceResult.ignored;
    try {
      final transcription = (await _repository.transcribeAudio(
        audioPath,
      )).trim();
      if (!mounted) return MiniVoiceResult.ignored;
      if (transcription.isEmpty) return MiniVoiceResult.empty;
      await _reply(transcription, input: 'voice');
      // Un fallo del modelo ya se pinta en la tarjeta de cierre; aquí solo
      // importa si se pudo transcribir.
      return MiniVoiceResult.ok;
    } catch (e) {
      debugPrint('MiniConversation: STT falló: $e');
      return MiniVoiceResult.error;
    }
  }

  Future<void> _reply(String text, {required String input}) async {
    if (!mounted) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty || !state.canReply) return;

    final withUser = [
      ...state.turns,
      MiniConversationTurn(fromUser: true, text: trimmed),
    ];
    final userTurns = state.userTurns + 1;
    final closingTurn = MiniConversationScript.isComplete(userTurns);

    state = state.copyWith(
      turns: withUser,
      userTurns: userTurns,
      isSending: true,
    );
    _track(AnalyticsEvent.miniConversationTurn, {
      'turn': userTurns,
      'input': input,
    });

    final history = MiniConversationScript.buildHistory(
      systemPrompt: MiniConversationScript.systemPrompt(
        nativeLanguage: _nativeLanguage,
        closingTurn: closingTurn,
      ),
      turns: withUser,
    );

    final buffer = StringBuffer();
    try {
      // Tope de espera: la prueba de valor no puede dejar al jugador mirando
      // un spinner. Sin primer token en 20 s se salta la escena.
      final stream = _repository
          .getTutorResponseStream(
            history,
            actionCode: MiniConversationScript.actionCode,
          )
          .timeout(const Duration(seconds: 20));
      await for (final chunk in stream) {
        if (!mounted) return;
        buffer.write(chunk);
        state = state.copyWith(
          turns: [
            ...withUser,
            MiniConversationTurn(fromUser: false, text: buffer.toString()),
          ],
          isSending: true,
        );
      }

      if (!mounted) return;
      final answer = buffer.toString().trim();
      if (answer.isEmpty) {
        debugPrint('MiniConversation: respuesta vacía del tutor');
        _fail();
        return;
      }

      state = state.copyWith(
        turns: [
          ...withUser,
          MiniConversationTurn(fromUser: false, text: answer),
        ],
        isSending: false,
        isComplete: closingTurn,
      );

      if (closingTurn) {
        await _markSeen();
        if (!_completedTracked) {
          _completedTracked = true;
          _track(AnalyticsEvent.miniConversationCompleted, {
            'turns': userTurns,
          });
        }
      }
    } catch (e) {
      // Sin red o con el modelo caído: se salta limpiamente, nunca bloquea.
      debugPrint('MiniConversation: turno fallido: $e');
      _fail();
    }
  }

  void _fail() {
    if (!mounted) return;
    state = state.copyWith(
      isSending: false,
      isComplete: true,
      failure: MiniConversationFailure.unavailable,
    );
    _track(AnalyticsEvent.miniConversationSkipped, {'reason': 'model_error'});
  }

  /// Cierra la escena (botón «continuar» o «saltar») y recuerda que ya se vio.
  Future<void> finish({required bool skipped}) async {
    if (skipped && !state.isComplete) {
      _track(AnalyticsEvent.miniConversationSkipped, {'reason': 'user'});
    }
    await _markSeen();
  }

  Future<void> _markSeen() async {
    if (_seenMarked) return;
    _seenMarked = true;
    await _store.markSeen(_userId);
  }

  /// Analítica best-effort: sin sesión no se escribe nada.
  void _track(String event, [Map<String, dynamic>? properties]) {
    if (_userId.trim().isEmpty) return;
    try {
      unawaited(
        RetentionAnalytics.instance.track(
          _userId,
          event,
          properties: properties,
        ),
      );
    } catch (e) {
      debugPrint('MiniConversation: analítica ($event) no disponible: $e');
    }
  }
}
