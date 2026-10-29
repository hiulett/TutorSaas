import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutorsaas/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:tutorsaas/features/onboarding/data/mini_conversation_store.dart';
import 'package:tutorsaas/features/onboarding/domain/models/mini_conversation_script.dart';
import 'package:tutorsaas/features/onboarding/presentation/providers/mini_conversation_providers.dart';
import 'package:tutorsaas/features/onboarding/presentation/screens/mini_conversation_screen.dart';
import 'package:tutorsaas/l10n/app_localizations.dart';

/// P-25 (#110): lógica pura de la mini-conversación de valor.
class _FakeConversationRepository implements ConversationRepository {
  _FakeConversationRepository({
    this.chunks = const ['Sure! A coffee coming right up.'],
    this.answerFails = false,
    this.transcription = 'A coffee, please',
    this.transcriptionFails = false,
  });

  final List<String> chunks;
  final bool answerFails;
  final String transcription;
  final bool transcriptionFails;

  int streamCalls = 0;
  int transcribeCalls = 0;
  String? lastActionCode;
  List<Map<String, String>>? lastHistory;

  @override
  Stream<String> getTutorResponseStream(
    List<Map<String, String>> history, {
    String actionCode = 'free_chat_turn',
    String? conversationId,
  }) async* {
    streamCalls++;
    lastActionCode = actionCode;
    lastHistory = history;
    if (answerFails) throw Exception('offline');
    for (final chunk in chunks) {
      yield chunk;
    }
  }

  @override
  Future<String> transcribeAudio(String audioPath) async {
    transcribeCalls++;
    if (transcriptionFails) throw Exception('stt down');
    return transcription;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MiniConversationNotifier _notifier(
  _FakeConversationRepository repository, {
  MiniConversationStore store = const MiniConversationStore(),
  String userId = 'user-1',
}) {
  return MiniConversationNotifier(
    repository: repository,
    store: store,
    userId: userId,
    nativeLanguage: 'es',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MiniConversationScript', () {
    test('tope de turnos: 2 y completo a partir del segundo', () {
      expect(MiniConversationScript.maxUserTurns, 2);
      expect(MiniConversationScript.isComplete(0), isFalse);
      expect(MiniConversationScript.isComplete(1), isFalse);
      expect(MiniConversationScript.isComplete(2), isTrue);
      expect(MiniConversationScript.remainingTurns(0), 2);
      expect(MiniConversationScript.remainingTurns(5), 0);
    });

    test('usa una acción gratuita del proxy, no una de ai_action_costs', () {
      // `consume_mana` rechaza cost_mana <= 0 y `mini_conversation_turn` no
      // existe en `ai_action_costs`: la única vía sin cobrar maná es la lista
      // FREE_ACTIONS del llm-proxy.
      expect(MiniConversationScript.actionCode, 'guild_chat');
    });

    test('el prompt cierra la escena en el último turno', () {
      final open = MiniConversationScript.systemPrompt(
        nativeLanguage: 'es',
        closingTurn: false,
      );
      final closing = MiniConversationScript.systemPrompt(
        nativeLanguage: 'es',
        closingTurn: true,
      );

      expect(open, contains('ONLY in English'));
      expect(open, contains('one simple follow-up question'));
      expect(closing, contains('LAST TURN'));
      expect(closing, isNot(contains('one simple follow-up question')));
      expect(open, isNot(closing));
    });

    test('el historial mapea roles y descarta turnos vacíos', () {
      final history = MiniConversationScript.buildHistory(
        systemPrompt: 'system',
        turns: const [
          MiniConversationTurn(fromUser: false, text: 'Hi!'),
          MiniConversationTurn(fromUser: true, text: '  '),
          MiniConversationTurn(fromUser: true, text: ' A coffee '),
        ],
      );

      expect(history, hasLength(3));
      expect(history.first, {'role': 'system', 'content': 'system'});
      expect(history[1], {'role': 'assistant', 'content': 'Hi!'});
      expect(history[2], {'role': 'user', 'content': 'A coffee'});
    });
  });

  group('MiniConversationStore', () {
    test('la marca es por usuario y no se repite', () async {
      const store = MiniConversationStore();

      expect(await store.wasSeen('user-a'), isFalse);
      await store.markSeen('user-a');

      expect(await store.wasSeen('user-a'), isTrue);
      expect(await store.wasSeen('user-b'), isFalse);
    });

    test('sin sesión la clave es anonymous', () {
      const store = MiniConversationStore();
      expect(store.keyFor(''), 'mini_conversation_seen_v1_anonymous');
      expect(store.keyFor('user-a'), 'mini_conversation_seen_v1_user-a');
    });
  });

  group('MiniConversationNotifier', () {
    test('start pinta el saludo fijo una sola vez', () {
      final notifier = _notifier(_FakeConversationRepository());

      notifier.start();
      notifier.start();

      expect(notifier.state.turns, hasLength(1));
      expect(
        notifier.state.turns.single.text,
        MiniConversationScript.openingLine,
      );
    });

    test(
      'el primer turno usa la acción gratuita y no completa la escena',
      () async {
        final repo = _FakeConversationRepository(
          chunks: const ['A coffee?', ' Sure!'],
        );
        final notifier = _notifier(repo)..start();

        await notifier.replyText('A coffee, please');

        expect(repo.streamCalls, 1);
        expect(repo.lastActionCode, 'guild_chat');
        expect(notifier.state.userTurns, 1);
        expect(notifier.state.isComplete, isFalse);
        expect(notifier.state.isSending, isFalse);

        // Historial: system + saludo fijo + respuesta del jugador.
        expect(repo.lastHistory, hasLength(3));
        expect(repo.lastHistory!.last, {
          'role': 'user',
          'content': 'A coffee, please',
        });

        final tutorTurns = notifier.state.turns
            .where((turn) => !turn.fromUser)
            .toList();
        expect(tutorTurns.last.text, 'A coffee? Sure!');
      },
    );

    test(
      'el segundo turno cierra la escena y marca la prueba como vista',
      () async {
        final repo = _FakeConversationRepository();
        const store = MiniConversationStore();
        final notifier = _notifier(repo, store: store)..start();

        await notifier.replyText('A coffee, please');
        await notifier.replyText('Thanks!');

        expect(repo.streamCalls, 2);
        expect(notifier.state.userTurns, 2);
        expect(notifier.state.isComplete, isTrue);
        expect(notifier.state.failure, isNull);
        expect(await store.wasSeen('user-1'), isTrue);

        // El prompt del último turno prohíbe preguntar.
        expect(repo.lastHistory!.first['content'], contains('LAST TURN'));
      },
    );

    test('no admite un tercer turno', () async {
      final repo = _FakeConversationRepository();
      final notifier = _notifier(repo)..start();

      await notifier.replyText('One');
      await notifier.replyText('Two');
      await notifier.replyText('Three');

      expect(repo.streamCalls, 2);
      expect(notifier.state.userTurns, 2);
      expect(notifier.state.turns.where((t) => t.fromUser), hasLength(2));
    });

    test('texto vacío no llama al modelo', () async {
      final repo = _FakeConversationRepository();
      final notifier = _notifier(repo)..start();

      await notifier.replyText('   ');

      expect(repo.streamCalls, 0);
      expect(notifier.state.userTurns, 0);
    });

    test('un fallo del modelo no lanza y ofrece continuar', () async {
      final repo = _FakeConversationRepository(answerFails: true);
      final notifier = _notifier(repo)..start();

      await notifier.replyText('A coffee, please');

      expect(notifier.state.failure, MiniConversationFailure.unavailable);
      expect(notifier.state.isComplete, isTrue);
      expect(notifier.state.isSending, isFalse);
      expect(notifier.state.canReply, isFalse);
      expect(notifier.state.userTurns, 1);
    });

    test('la respuesta por voz reutiliza la transcripción del proxy', () async {
      final repo = _FakeConversationRepository(
        transcription: 'Could I have a tea?',
      );
      final notifier = _notifier(repo)..start();

      final result = await notifier.replyWithVoice('/tmp/audio.m4a');

      expect(result, MiniVoiceResult.ok);
      expect(repo.transcribeCalls, 1);
      expect(repo.lastHistory!.last, {
        'role': 'user',
        'content': 'Could I have a tea?',
      });
    });

    test('voz sin habla no gasta un turno', () async {
      final repo = _FakeConversationRepository(transcription: '  ');
      final notifier = _notifier(repo)..start();

      final result = await notifier.replyWithVoice('/tmp/audio.m4a');

      expect(result, MiniVoiceResult.empty);
      expect(repo.streamCalls, 0);
      expect(notifier.state.userTurns, 0);
    });

    test('un STT caído no rompe la escena', () async {
      final repo = _FakeConversationRepository(transcriptionFails: true);
      final notifier = _notifier(repo)..start();

      final result = await notifier.replyWithVoice('/tmp/audio.m4a');

      expect(result, MiniVoiceResult.error);
      expect(notifier.state.failure, isNull);
      expect(notifier.state.canReply, isTrue);
    });

    test('finish marca la prueba como vista', () async {
      const store = MiniConversationStore();
      final notifier = _notifier(_FakeConversationRepository(), store: store)
        ..start();

      await notifier.finish(skipped: true);

      expect(await store.wasSeen('user-1'), isTrue);
    });
  });

  group('MiniConversationScreen', () {
    testWidgets('pinta el saludo y el contador de turnos', (tester) async {
      final repo = _FakeConversationRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationRepositoryProvider.overrideWithValue(repo),
            currentUserProvider.overrideWithValue(null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const MiniConversationScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Order a coffee'), findsOneWidget);
      expect(find.text(MiniConversationScript.openingLine), findsOneWidget);
      expect(find.text('Reply 1 of 2'), findsOneWidget);
      expect(find.text('SKIP FOR NOW'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
