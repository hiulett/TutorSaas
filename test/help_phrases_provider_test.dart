import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/help_phrase.dart';
import 'package:tutorsaas/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:tutorsaas/features/conversation/presentation/providers/help_phrases_provider.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

/// P-34b (#119): las frases salen del catálogo real o de `scenario_phrases`;
/// nunca se inventan.
class _FakePhraseRepository implements ConversationRepository {
  _FakePhraseRepository(this.phrases);

  final List<HelpPhrase> phrases;
  int calls = 0;
  String? lastScenario;

  @override
  Future<List<HelpPhrase>> loadScenarioPhrases(
    String scenarioId, {
    int limit = 3,
  }) async {
    calls++;
    lastScenario = scenarioId;
    return phrases.take(limit).toList(growable: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('chat libre (sin escenario) no inventa frases', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final phrases = await container.read(helpPhrasesProvider(null).future);
    expect(phrases, isEmpty);
  });

  test('usa usefulPhrases del catálogo de la lección', () async {
    final lesson = LessonCatalog.catalog.firstWhere(
      (l) => l.usefulPhrases.isNotEmpty,
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final phrases = await container.read(helpPhrasesProvider(lesson.id).future);

    expect(phrases, isNotEmpty);
    expect(phrases.length, lessThanOrEqualTo(3));
    expect(phrases.first.origin, HelpPhraseOrigin.lesson);
    expect(phrases.first.id, lesson.usefulPhrases.first.id);
  });

  test('cae a scenario_phrases cuando la lección no trae frases', () async {
    const scenarioId = '11111111-1111-1111-1111-111111111111';
    final repo = _FakePhraseRepository(const [
      HelpPhrase(
        id: 'db-1',
        text: 'Can you repeat that?',
        origin: HelpPhraseOrigin.scenario,
      ),
      HelpPhrase(
        id: 'db-2',
        text: 'How do you say...?',
        origin: HelpPhraseOrigin.scenario,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [conversationRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final phrases = await container.read(
      helpPhrasesProvider(scenarioId).future,
    );

    expect(repo.calls, 1);
    expect(repo.lastScenario, scenarioId);
    expect(phrases.map((p) => p.id), ['db-1', 'db-2']);
    expect(phrases.first.origin, HelpPhraseOrigin.scenario);
  });
}
