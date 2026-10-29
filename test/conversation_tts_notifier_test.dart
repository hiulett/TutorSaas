import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutorsaas/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:tutorsaas/features/dashboard/presentation/providers/dashboard_providers.dart';

/// P-34a/c (#119): el notifier aplica y expone las preferencias de voz sin
/// depender del plugin nativo (tests) ni de Supabase (invitado).
class _FakeConversationRepository implements ConversationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(
          _FakeConversationRepository(),
        ),
        currentUserProvider.overrideWithValue(null),
        correctionLevelProvider.overrideWithValue('moderate'),
      ],
    );
  }

  test('setTtsSpeed normaliza al valor soportado', () async {
    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(conversationStateProvider.notifier);

    await notifier.setTtsSpeed(2.0);
    expect(container.read(conversationStateProvider).ttsSpeed, 1.25);

    await notifier.setTtsSpeed(0.8);
    expect(container.read(conversationStateProvider).ttsSpeed, 0.75);
  });

  test(
    'setTutorVoice guarda la voz elegida y permite volver al sistema',
    () async {
      final container = buildContainer();
      addTearDown(container.dispose);
      final notifier = container.read(conversationStateProvider.notifier);

      await notifier.setTutorVoice('en-us-x-iol');
      expect(
        container.read(conversationStateProvider).tutorVoiceId,
        'en-us-x-iol',
      );

      await notifier.setTutorVoice('   ');
      expect(container.read(conversationStateProvider).tutorVoiceId, isNull);
    },
  );

  test('pauseTts deja el estado en no hablando', () async {
    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(conversationStateProvider.notifier);

    await notifier.pauseTts();
    expect(container.read(conversationStateProvider).isPlaying, isFalse);
  });

  test('loadAvailableVoices devuelve vacío si el plugin no existe', () async {
    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(conversationStateProvider.notifier);

    expect(await notifier.loadAvailableVoices(), isEmpty);
  });
}
