import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/vocabulary/domain/models/curated_vocabulary.dart';

/// P-33 (#118): el filtro puro que se aplica antes de llamar al RPC.
/// El servidor repite estas reglas; aquí se fija el contrato.
void main() {
  Map<String, dynamic> item({
    required String word,
    String translation = 'traducción',
    String pos = 'noun',
    String cefr = 'B1',
    String example = '',
  }) =>
      {
        'word': word,
        'translation': translation,
        'part_of_speech': pos,
        'cefr': cefr,
        if (example.isNotEmpty) 'example': example,
      };

  group('VocabularyCurationValidator.sanitize', () {
    test('acepta palabras de contenido y normaliza a minúsculas', () {
      final result = VocabularyCurationValidator.sanitize(
        [
          item(word: 'Museum', translation: 'museo', cefr: 'A2'),
          item(
            word: 'curator',
            translation: 'curador',
            cefr: 'B2',
            example: 'The curator explained the exhibit.',
          ),
        ],
        transcript: 'The museum was great. The curator explained the exhibit.',
      );

      expect(result.accepted, hasLength(2));
      expect(result.accepted.first.word, 'museum');
      expect(result.accepted.first.cefr, 'A2');
      expect(result.accepted.last.partOfSpeech, VocabularyPartOfSpeech.noun);
      expect(result.rejected, 0);
      expect(result.isEmpty, isFalse);
    });

    test('descarta stopwords', () {
      final result = VocabularyCurationValidator.sanitize([
        item(word: 'the', translation: 'el', cefr: 'A1'),
      ], transcript: 'the museum');

      expect(result.accepted, isEmpty);
      expect(result.reason, 'stopword');
    });

    test('descarta alucinaciones que no están en la transcripción', () {
      final result = VocabularyCurationValidator.sanitize([
        item(word: 'quantum'),
      ], transcript: 'I visited a museum yesterday.');

      expect(result.accepted, isEmpty);
      expect(result.reason, 'not_in_transcript');
      expect(result.rejected, 1);
    });

    test('descarta nombres propios que solo aparecen en mayúscula', () {
      final result = VocabularyCurationValidator.sanitize([
        item(word: 'alberto', translation: 'Alberto'),
      ], transcript: 'Alberto said the museum was closed.');

      expect(result.accepted, isEmpty);
      expect(result.reason, 'not_lowercase_in_transcript');
    });

    test('descarta traducciones vacías, con salto de línea o iguales', () {
      for (final translation in ['', 'curator', 'dos\nlíneas']) {
        final result = VocabularyCurationValidator.sanitize([
          item(word: 'curator', translation: translation),
        ], transcript: 'the curator arrived');
        expect(result.accepted, isEmpty, reason: translation);
        expect(result.reason, 'invalid_translation', reason: translation);
      }
    });

    test('deduplica variantes de mayúsculas', () {
      final result = VocabularyCurationValidator.sanitize([
        item(word: 'museum', translation: 'museo'),
        item(word: 'Museum', translation: 'museo'),
        item(word: 'museum', translation: 'museo'),
      ], transcript: 'the museum');

      expect(result.accepted, hasLength(1));
      expect(result.rejected, 2);
    });

    test('aplica el tope de 8 por sesión', () {
      final words = [
        'museum',
        'curator',
        'postcard',
        'ancient',
        'bought',
        'exhibit',
        'coins',
        'gallery',
        'sculpture',
        'ticket',
      ];
      final result = VocabularyCurationValidator.sanitize(
        words.map((word) => item(word: word, example: 'I saw $word.')).toList(),
        transcript: words.join(' '),
      );

      expect(result.accepted, hasLength(8));
      expect(result.rejected, 2);
      expect(result.reason, isNull);
    });

    test('respeta CEFR cerrado y categoría gramatical', () {
      final badCefr = VocabularyCurationValidator.sanitize([
        item(word: 'museum', cefr: 'Z9'),
      ], transcript: 'the museum');
      expect(badCefr.accepted, isEmpty);
      expect(badCefr.reason, 'invalid_cefr');

      final badPos = VocabularyCurationValidator.sanitize([
        item(word: 'museum', pos: 'article'),
      ], transcript: 'the museum');
      expect(badPos.accepted, isEmpty);
      expect(badPos.reason, 'invalid_part_of_speech');
    });

    test('descarta artefactos de STT y formas no canónicas', () {
      for (final word in ['aaaa', '1234', 'ice cream', 'museum2']) {
        final result = VocabularyCurationValidator.sanitize([
          item(word: word),
        ], transcript: 'aaa $word 1234 ice cream museum2');
        expect(result.accepted, isEmpty, reason: word);
      }
    });

    test('un ejemplo que no usa la palabra se elimina, no la invalida', () {
      final result = VocabularyCurationValidator.sanitize([
        item(word: 'museum', example: 'Totally unrelated sentence.'),
      ], transcript: 'the museum');

      expect(result.accepted, hasLength(1));
      expect(result.accepted.single.example, isEmpty);
    });

    test('no repite palabras que el alumno ya tiene', () {
      final result = VocabularyCurationValidator.sanitize(
        [item(word: 'museum')],
        transcript: 'the museum',
        alreadyKnown: {'Museum'},
      );

      expect(result.accepted, isEmpty);
      expect(result.reason, 'already_known');
    });

    test('una respuesta que no es lista no rompe el cierre', () {
      final result = VocabularyCurationValidator.sanitize(
        'not-a-list',
        transcript: 'the museum',
      );

      expect(result.accepted, isEmpty);
      expect(result.reason, 'invalid_shape');
    });
  });

  group('CuratedVocabularyItem', () {
    test('payload usa código de categoría y omite ejemplo vacío', () {
      const item = CuratedVocabularyItem(
        word: 'museum',
        translation: 'museo',
        partOfSpeech: VocabularyPartOfSpeech.noun,
        cefr: 'A2',
      );

      expect(item.toPayload()['part_of_speech'], 'noun');
      expect(item.toPayload().containsKey('example'), isFalse);
    });

    test('fromServer acepta la etiqueta española como respaldo', () {
      final item = CuratedVocabularyItem.fromServer({
        'word': 'curator',
        'translation': 'curador',
        'part_of_speech': 'Sustantivo',
        'cefr': 'b2',
      });

      expect(item.partOfSpeech, VocabularyPartOfSpeech.noun);
      expect(item.cefr, 'B2');
    });
  });
}
