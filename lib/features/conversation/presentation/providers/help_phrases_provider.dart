import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/data/models/lesson_catalog.dart';
import '../../domain/models/help_phrase.dart';
import 'conversation_providers.dart';

/// P-34b (#119): hasta 3 frases tocables para desbloquear al alumno.
///
/// Orden de fuentes:
/// 1. `LessonData.usefulPhrases` (catálogo Dart, datos reales de la lección).
/// 2. `scenario_phrases` (BD) si la lección no trae frases.
/// 3. Lista vacía: la UI muestra un estado vacío honesto, sin inventar frases.
final helpPhrasesProvider = FutureProvider.autoDispose
    .family<List<HelpPhrase>, String?>((ref, scenarioId) async {
      if (scenarioId == null || scenarioId.trim().isEmpty) {
        return const <HelpPhrase>[];
      }

      // Un id UUID es un escenario de BD: `scenario_phrases` manda.
      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(scenarioId);
      if (isUuid) {
        final fromDb = await ref
            .read(conversationRepositoryProvider)
            .loadScenarioPhrases(scenarioId, limit: 3);
        if (fromDb.isNotEmpty) return fromDb;
      }

      final lesson = LessonCatalog.getLessonById(scenarioId);
      final lessonPhrases = lesson?.usefulPhrases ?? const <UsefulPhraseItem>[];
      if (lessonPhrases.isNotEmpty) {
        return lessonPhrases
            .take(3)
            .map(
              (p) => HelpPhrase(
                id: p.id,
                text: p.phrase,
                translation: p.translation,
                origin: HelpPhraseOrigin.lesson,
              ),
            )
            .toList(growable: false);
      }

      return const <HelpPhrase>[];
    });
