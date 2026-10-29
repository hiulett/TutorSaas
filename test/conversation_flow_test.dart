import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutorsaas/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:tutorsaas/features/dashboard/presentation/providers/dashboard_providers.dart';

/// Flujo de conversacion con repositorio falso (P-18 / #103).
class _FakeConversationRepository implements ConversationRepository {
  int streamCalls = 0;
  String? lastActionCode;
  String? lastConversationId;

  @override
  Stream<String> getTutorResponseStream(
    List<Map<String, String>> history, {
    String actionCode = 'free_chat_turn',
    String? conversationId,
  }) async* {
    streamCalls++;
    lastActionCode = actionCode;
    lastConversationId = conversationId;
    yield 'Hello';
    yield ' there';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'sendTextMessage acumula los chunks en un solo mensaje del tutor',
    () async {
      final repo = _FakeConversationRepository();
      final container = ProviderContainer(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(repo),
          currentUserProvider.overrideWithValue(null),
          correctionLevelProvider.overrideWithValue('moderate'),
        ],
      );
  
      final notifier = container.read(conversationStateProvider.notifier);
      await notifier.sendTextMessage('Hi');

      final state = container.read(conversationStateProvider);
      expect(repo.streamCalls, 1);
      expect(state.isProcessing, isFalse);

      final tutor = state.messages.where((m) => m.sender == 'tutor').toList();
      expect(tutor, hasLength(1), reason: 'un placeholder, no uno por chunk');
      expect(tutor.single.text, 'Hello there');

      final user = state.messages.where((m) => m.sender == 'user').toList();
      expect(user.single.text, 'Hi');
    },
  );

  test('un texto vacio no llama al modelo', () async {
    final repo = _FakeConversationRepository();
    final container = ProviderContainer(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(repo),
        currentUserProvider.overrideWithValue(null),
        correctionLevelProvider.overrideWithValue('moderate'),
      ],
    );

    final notifier = container.read(conversationStateProvider.notifier);
    await notifier.sendTextMessage('   ');

    expect(repo.streamCalls, 0);
    expect(container.read(conversationStateProvider).messages, isEmpty);
  });
}
