/// P-33 (#118): vocabulario curado por el LLM.
///
/// El modelo propone hasta [VocabularyCurationValidator.maxItemsPerSession]
/// palabras por sesión. Este archivo contiene la parte **pura** del filtro
/// (sin red ni base de datos) para poder probarla en `flutter test`.
///
/// El servidor repite las mismas validaciones en el RPC
/// `curate_session_vocabulary`; aquí se descarta la basura antes de gastar una
/// llamada a la RPC, pero la autoridad final es Postgres.
library;

/// Categorías gramaticales aceptadas. Se guardan en inglés en el payload y se
/// muestran con la etiqueta española (igual que las filas históricas).
enum VocabularyPartOfSpeech {
  noun('noun', 'Sustantivo'),
  verb('verb', 'Verbo'),
  adjective('adjective', 'Adjetivo'),
  adverb('adverb', 'Adverbio'),
  preposition('preposition', 'Preposición'),
  pronoun('pronoun', 'Pronombre'),
  conjunction('conjunction', 'Conjunción'),
  interjection('interjection', 'Interjección'),
  phrase('phrase', 'Frase');

  const VocabularyPartOfSpeech(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static VocabularyPartOfSpeech? fromApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    for (final item in VocabularyPartOfSpeech.values) {
      if (item.apiValue == normalized ||
          item.label.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

/// Una palabra validada, lista para enviarse al RPC o pintarse en el resumen.
class CuratedVocabularyItem {
  const CuratedVocabularyItem({
    required this.word,
    required this.translation,
    required this.partOfSpeech,
    required this.cefr,
    this.example = '',
  });

  final String word;
  final String translation;
  final VocabularyPartOfSpeech partOfSpeech;
  final String cefr;
  final String example;

  /// Payload que espera `curate_session_vocabulary(p_items)`.
  Map<String, dynamic> toPayload() => {
        'word': word,
        'translation': translation,
        'part_of_speech': partOfSpeech.apiValue,
        'cefr': cefr,
        if (example.isNotEmpty) 'example': example,
      };

  /// Item que devuelve el RPC (ya con la etiqueta en español).
  factory CuratedVocabularyItem.fromServer(Map<String, dynamic> json) {
    final code = (json['part_of_speech_code'] ?? json['part_of_speech'] ?? '')
        .toString();
    return CuratedVocabularyItem(
      word: (json['word'] ?? '').toString(),
      translation: (json['translation'] ?? '').toString(),
      partOfSpeech:
          VocabularyPartOfSpeech.fromApi(code) ?? VocabularyPartOfSpeech.noun,
      cefr: (json['cefr'] ?? '').toString().toUpperCase(),
      example: (json['example'] ?? '').toString(),
    );
  }

  /// Forma que consume la UI del resumen (Map, como `sessionResult`).
  Map<String, dynamic> toDisplayJson() => {
        'word': word,
        'translation': translation,
        'part_of_speech': partOfSpeech.label,
        'cefr': cefr,
        if (example.isNotEmpty) 'example': example,
      };
}

/// Resultado del filtro: lo aceptado, cuánto se descartó y el motivo cuando no
/// queda nada (se usa para registrar la sesión omitida).
class VocabularyCurationResult {
  const VocabularyCurationResult({
    required this.accepted,
    required this.rejected,
    this.reason,
  });

  final List<CuratedVocabularyItem> accepted;
  final int rejected;
  final String? reason;

  bool get isEmpty => accepted.isEmpty;
}

/// Validación y deduplicación determinista del vocabulario propuesto.
class VocabularyCurationValidator {
  const VocabularyCurationValidator._();

  /// Tope por sesión (criterio P-33 y límite del RPC).
  static const int maxItemsPerSession = 8;

  /// Escala CEFR cerrada.
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  /// Palabras de función: no aportan significado léxico y no se programan.
  /// Debe coincidir con `public.is_vocabulary_stopword`.
  static const Set<String> stopwords = {
    'a',
    'an',
    'the',
    'and',
    'or',
    'but',
    'if',
    'then',
    'than',
    'so',
    'because',
    'as',
    'of',
    'at',
    'by',
    'for',
    'with',
    'about',
    'into',
    'through',
    'during',
    'before',
    'after',
    'above',
    'below',
    'to',
    'from',
    'up',
    'down',
    'in',
    'out',
    'on',
    'off',
    'over',
    'under',
    'again',
    'further',
    'once',
    'here',
    'there',
    'when',
    'where',
    'why',
    'how',
    'all',
    'any',
    'both',
    'each',
    'few',
    'more',
    'most',
    'other',
    'some',
    'such',
    'no',
    'nor',
    'not',
    'only',
    'own',
    'same',
    'too',
    'very',
    'can',
    'will',
    'just',
    'should',
    'now',
    'i',
    'me',
    'my',
    'myself',
    'we',
    'our',
    'ours',
    'ourselves',
    'you',
    'your',
    'yours',
    'yourself',
    'yourselves',
    'he',
    'him',
    'his',
    'himself',
    'she',
    'her',
    'hers',
    'herself',
    'it',
    'its',
    'itself',
    'they',
    'them',
    'their',
    'theirs',
    'themselves',
    'what',
    'which',
    'who',
    'whom',
    'this',
    'that',
    'these',
    'those',
    'am',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'being',
    'have',
    'has',
    'had',
    'having',
    'do',
    'does',
    'did',
    'doing',
    'would',
    'could',
    'shall',
    'may',
    'might',
    'must',
    'ought',
    'im',
    'ive',
    'dont',
    'doesnt',
    'didnt',
    'cant',
    'wont',
    'isnt',
    'arent',
    'wasnt',
    'werent',
    'yeah',
    'yes',
    'okay',
    'ok',
    'uh',
    'um',
    'hmm',
    'oh',
    'ah',
    'well',
    'really',
    'actually',
    'maybe',
    'please',
    'thanks',
    'thank',
    'hello',
    'hi',
    'hey',
    'bye',
    'goodbye',
  };

  static final RegExp _wordShape = RegExp(r"^[a-z][a-z'-]{1,31}$");
  static final RegExp _hasVowel = RegExp(r'[aeiouy]');
  static final RegExp _fourRepeated = RegExp(r'(.)\1\1\1');

  /// Minúsculas, sin espacios sobrantes. El resto de la validación asume esta
  /// forma canónica.
  static String canonicalize(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Filtra y deduplica la lista cruda del modelo.
  ///
  /// [transcript] son las líneas del alumno: una palabra que no aparezca ahí
  /// se considera alucinación o error de STT y se descarta.
  /// [alreadyKnown] evita gastar un hueco en palabras que el alumno ya tiene.
  static VocabularyCurationResult sanitize(
    dynamic raw, {
    required String transcript,
    Set<String> alreadyKnown = const {},
    int maxItems = maxItemsPerSession,
  }) {
    if (raw is! List) {
      return const VocabularyCurationResult(
        accepted: [],
        rejected: 0,
        reason: 'invalid_shape',
      );
    }

    final known = alreadyKnown.map(canonicalize).toSet();
    final seen = <String>{};
    final accepted = <CuratedVocabularyItem>[];
    var rejected = 0;
    String? lastReason;

    for (final entry in raw) {
      if (accepted.length >= maxItems) {
        rejected++;
        lastReason = 'max_items';
        continue;
      }
      if (entry is! Map) {
        rejected++;
        lastReason = 'invalid_item';
        continue;
      }

      final rawWord = (entry['word'] ?? '').toString();
      final word = canonicalize(rawWord);
      final translation = (entry['translation'] ?? '').toString().trim();
      final pos = VocabularyPartOfSpeech.fromApi(
        (entry['part_of_speech'] ?? '').toString(),
      );
      final cefr = (entry['cefr'] ?? '').toString().trim().toUpperCase();
      var example = (entry['example'] ?? '').toString().trim();

      final reason = _rejectReason(
        word: word,
        translation: translation,
        partOfSpeech: pos,
        cefr: cefr,
        transcript: transcript,
        known: known,
        seen: seen,
      );
      if (reason != null) {
        rejected++;
        lastReason = reason;
        continue;
      }

      if (example.length > 300) {
        example = example.substring(0, 300);
      }
      if (example.isNotEmpty && !_containsWord(example, word)) {
        // Un ejemplo que no usa la palabra no aporta evidencia.
        example = '';
      }

      seen.add(word);
      accepted.add(
        CuratedVocabularyItem(
          word: word,
          translation: translation,
          partOfSpeech: pos!,
          cefr: cefr,
          example: example,
        ),
      );
    }

    return VocabularyCurationResult(
      accepted: accepted,
      rejected: rejected,
      reason: accepted.isEmpty ? (lastReason ?? 'no_valid_items') : null,
    );
  }

  static String? _rejectReason({
    required String word,
    required String translation,
    required VocabularyPartOfSpeech? partOfSpeech,
    required String cefr,
    required String transcript,
    required Set<String> known,
    required Set<String> seen,
  }) {
    if (!_wordShape.hasMatch(word)) return 'invalid_word';
    if (!_hasVowel.hasMatch(word) || _fourRepeated.hasMatch(word)) {
      return 'stt_artifact';
    }
    if (stopwords.contains(word)) return 'stopword';
    if (known.contains(word)) return 'already_known';
    if (seen.contains(word)) return 'duplicate';
    if (!_containsWord(transcript, word)) return 'not_in_transcript';
    // Los nombres propios y la basura de STT solo aparecen en mayúscula.
    if (!_containsWord(transcript, word, caseSensitive: true)) {
      return 'not_lowercase_in_transcript';
    }
    if (translation.isEmpty ||
        translation.length > 80 ||
        translation.contains('\n') ||
        translation.contains('\r') ||
        translation.toLowerCase() == word ||
        !RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(translation)) {
      return 'invalid_translation';
    }
    if (partOfSpeech == null) return 'invalid_part_of_speech';
    if (!cefrLevels.contains(cefr)) return 'invalid_cefr';
    return null;
  }

  static bool _containsWord(
    String text,
    String word, {
    bool caseSensitive = false,
  }) {
    final pattern = '(^|[^A-Za-z])${RegExp.escape(word)}([^A-Za-z]|\$)';
    return RegExp(pattern, caseSensitive: caseSensitive).hasMatch(text);
  }
}
