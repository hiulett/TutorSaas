import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutorsaas/features/conversation/data/repositories/tutor_personalization_repository.dart';
import 'package:tutorsaas/features/conversation/domain/models/tutor_personalization.dart';
import 'package:tutorsaas/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:tutorsaas/features/dashboard/domain/repositories/dashboard_repository.dart';
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

  // P-40 (#125): el perfil del alumno llega de verdad al system prompt del
  // turno que consume DeepSeek (no solo se guarda en la BD).
  test('el system prompt incluye el perfil personalizado del alumno', () async {
    final repo = _CapturingConversationRepository();
    final container = ProviderContainer(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(repo),
        currentUserProvider.overrideWithValue(
          User.fromJson({
            'id': 'user-p40',
            'aud': 'authenticated',
            'created_at': '2026-01-01T00:00:00Z',
          }),
        ),
        dashboardRepositoryProvider.overrideWithValue(
          _FakeDashboardRepository(),
        ),
        tutorPersonalizationRepositoryProvider.overrideWithValue(
          _FakePersonalizationRepository(
            const TutorPersonalization(
              interests: ['travel', 'technology'],
              motivation: 'career',
              cefrLevel: 'B1',
              correctionLevel: 'moderate',
              tutorPersonality: 'professional',
              tutorPromptInstructions: 'Revisa el past simple en cada turno.',
              completedLessons: 3,
              isReviewSession: true,
              reviewPhrases: ['Could I have the bill, please?'],
            ),
          ),
        ),
      ],
    );

    final notifier = container.read(conversationStateProvider.notifier);
    await notifier.initSession();
    await notifier.sendTextMessage('I go to London yesterday');

    final system = repo.lastSystemPrompt;
    expect(system, isNotNull);
    expect(system, contains('interests: travel, technology'));
    expect(system, contains('motivation: career'));
    expect(system, contains('CEFR level B1'));
    expect(system, contains('CORRECTION MODE (moderate)'));
    expect(system, contains('Tone: professional'));
    expect(
      system,
      contains('STUDENT-SPECIFIC TUTOR INSTRUCTIONS: Revisa el past simple'),
    );
    // Cada 3 lecciones superadas se activa el repaso acumulativo (P-40).
    expect(system, contains('CUMULATIVE REVIEW'));
    expect(system, contains('Could I have the bill, please?'));
  });
}

/// Devuelve el `history` completo para poder inspeccionar el system prompt.
class _CapturingConversationRepository extends _FakeConversationRepository {
  String? lastSystemPrompt;

  @override
  Stream<String> getTutorResponseStream(
    List<Map<String, String>> history, {
    String actionCode = 'free_chat_turn',
    String? conversationId,
  }) async* {
    lastSystemPrompt = history.firstWhere(
      (m) => m['role'] == 'system',
    )['content'];
    yield 'Nice try!';
  }
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Map<String, dynamic>> getUserSettings(String userId) async => {};
}

class _FakePersonalizationRepository extends TutorPersonalizationRepository {
  _FakePersonalizationRepository(this._profile)
    : super(_UnusedSupabaseClient());

  final TutorPersonalization _profile;

  @override
  Future<TutorPersonalization> load(
    String? userId, {
    String? currentScenarioId,
  }) async => _profile;
}

class _UnusedSupabaseClient extends Fake implements SupabaseClient {}
