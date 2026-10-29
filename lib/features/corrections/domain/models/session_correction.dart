// P-29 — Corrección explícita y registro de errores.
//
// Lógica pura (sin Flutter ni Supabase) para poder probarse con `flutter test`:
// - tipos acotados de error,
// - validación tolerante del JSON que devuelve la evaluación de metas,
// - política de visibilidad según `user_settings.correction_level`,
// - agrupación por tipo y recurrencia para la pantalla «Mis errores».

/// Tipos acotados de corrección. Cualquier otro valor del modelo se descarta
/// (el turno nunca se bloquea por un JSON inválido).
///
/// `typo_stt` existe para no penalizar errores de transcripción de voz.
enum CorrectionType {
  grammar('grammar'),
  vocabulary('vocabulary'),
  wordChoice('word_choice'),
  pronunciationHint('pronunciation_hint'),
  typoStt('typo_stt');

  const CorrectionType(this.wireName);

  /// Valor persistido en `public.corrections.error_type`.
  final String wireName;

  /// Devuelve `null` si el valor no pertenece al conjunto acotado.
  static CorrectionType? fromWire(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final type in CorrectionType.values) {
      if (type.wireName == normalized) return type;
    }
    return null;
  }
}

/// Límites duros aplicados en cliente. El prompt pide como máximo 3, pero el
/// modelo puede desviarse; aquí se recorta sin romper el turno.
const int maxCorrectionsPerTurn = 3;
const int maxCorrectionTextLength = 240;
const int maxCorrectionExplanationLength = 320;

/// Una corrección concreta de un turno.
class TurnCorrection {
  const TurnCorrection({
    required this.original,
    required this.corrected,
    required this.type,
    this.explanation = '',
    this.messageText = '',
    this.turnRef,
  });

  /// Fragmento tal como lo dijo/escribió el alumno.
  final String original;

  /// Versión corregida.
  final String corrected;

  final CorrectionType type;

  /// Explicación breve (puede venir vacía).
  final String explanation;

  /// Mensaje del usuario al que se ancla el chip en la conversación.
  final String messageText;

  /// Identificador del turno; sirve para deduplicar en base de datos.
  final String? turnRef;

  /// Clave de deduplicación dentro del mismo turno.
  String get dedupeKey =>
      '${type.wireName}|${normalizeCorrectionText(original)}';

  TurnCorrection copyWith({String? messageText, String? turnRef}) {
    return TurnCorrection(
      original: original,
      corrected: corrected,
      type: type,
      explanation: explanation,
      messageText: messageText ?? this.messageText,
      turnRef: turnRef ?? this.turnRef,
    );
  }
}

/// Resultado de validar el bloque `corrections` del JSON del modelo.
class CorrectionParseResult {
  const CorrectionParseResult({
    this.corrections = const [],
    this.discarded = 0,
  });

  final List<TurnCorrection> corrections;

  /// Elementos rechazados (tipo desconocido, vacíos, duplicados o de más).
  final int discarded;

  bool get isEmpty => corrections.isEmpty;
}

/// Normaliza un texto para comparar/deduplicar: minúsculas, espacios
/// colapsados y sin puntuación final.
String normalizeCorrectionText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[.,!?;:\s]+$'), '')
      .trim();
}

/// Valida el bloque `corrections` devuelto por `goal_eval`.
///
/// Acepta cualquier `dynamic` (el modelo puede devolver basura): lo que no
/// cumpla el esquema se descarta y cuenta en [CorrectionParseResult.discarded].
CorrectionParseResult parseCorrections(
  Object? raw, {
  String messageText = '',
  String? turnRef,
}) {
  if (raw == null) return const CorrectionParseResult();
  if (raw is! List) {
    return const CorrectionParseResult(discarded: 1);
  }

  final seen = <String>{};
  final accepted = <TurnCorrection>[];
  var discarded = 0;

  for (final item in raw) {
    if (accepted.length >= maxCorrectionsPerTurn) {
      discarded++;
      continue;
    }
    final parsed = _parseOne(item, messageText: messageText, turnRef: turnRef);
    if (parsed == null) {
      discarded++;
      continue;
    }
    if (!seen.add(parsed.dedupeKey)) {
      discarded++;
      continue;
    }
    accepted.add(parsed);
  }

  return CorrectionParseResult(corrections: accepted, discarded: discarded);
}

TurnCorrection? _parseOne(
  Object? item, {
  required String messageText,
  required String? turnRef,
}) {
  if (item is! Map) return null;

  final original = _cleanText(item['original'], maxCorrectionTextLength);
  final corrected = _cleanText(item['corrected'], maxCorrectionTextLength);
  if (original == null || corrected == null) return null;
  // Sin cambio real no hay corrección que mostrar.
  if (normalizeCorrectionText(original) == normalizeCorrectionText(corrected)) {
    return null;
  }
  final type = CorrectionType.fromWire(item['type']);
  if (type == null) return null;

  final explanation =
      _cleanText(item['explanation'], maxCorrectionExplanationLength) ?? '';

  return TurnCorrection(
    original: original,
    corrected: corrected,
    type: type,
    explanation: explanation,
    messageText: messageText,
    turnRef: turnRef,
  );
}

String? _cleanText(Object? value, int maxLength) {
  if (value is! String) return null;
  var text = value.trim();
  if (text.length >= 2 &&
      ((text.startsWith('"') && text.endsWith('"')) ||
          (text.startsWith('«') && text.endsWith('»')))) {
    text = text.substring(1, text.length - 1).trim();
  }
  if (text.isEmpty) return null;
  if (text.length > maxLength) {
    text = text.substring(0, maxLength).trimRight();
  }
  return text;
}

// ─────────────────────────────────────────────────────────────────────────────
// Política de visibilidad por `user_settings.correction_level`
// ─────────────────────────────────────────────────────────────────────────────

/// Valores admitidos por `user_settings.correction_level`.
const Set<String> supportedCorrectionLevels = {
  'important_only',
  'short',
  'moderate',
  'detailed',
  'teacher',
};

/// Un valor desconocido cae a `short` (el default de la tabla).
String normalizeCorrectionLevel(String? level) {
  final normalized = level?.trim().toLowerCase();
  if (normalized != null && supportedCorrectionLevels.contains(normalized)) {
    return normalized;
  }
  return 'short';
}

/// Cuántas correcciones se muestran en el chip de la conversación.
int maxVisibleCorrections(String level) {
  switch (normalizeCorrectionLevel(level)) {
    case 'important_only':
    case 'short':
      return 1;
    case 'moderate':
      return 2;
    default:
      return maxCorrectionsPerTurn;
  }
}

/// Solo los niveles explícitos muestran explicación; el resto mantiene el chip
/// discreto para no interrumpir la conversación.
bool showsCorrectionExplanation(String level) {
  final normalized = normalizeCorrectionLevel(level);
  return normalized == 'moderate' ||
      normalized == 'detailed' ||
      normalized == 'teacher';
}

/// Filtra y recorta lo que se pinta bajo la burbuja del usuario.
///
/// `important_only` se limita a errores de gramática (los que más rompen la
/// comprensión); no se puede detectar severidad real sin una señal del modelo.
List<TurnCorrection> correctionsForLevel(
  List<TurnCorrection> corrections,
  String level,
) {
  final normalized = normalizeCorrectionLevel(level);
  final filtered = normalized == 'important_only'
      ? corrections.where((c) => c.type == CorrectionType.grammar)
      : corrections;
  return filtered.take(maxVisibleCorrections(normalized)).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Registro y recurrencia (pantalla «Mis errores», misiones y prompt del tutor)
// ─────────────────────────────────────────────────────────────────────────────

/// Una fila persistida de `public.corrections`.
class CorrectionRecord {
  const CorrectionRecord({
    required this.type,
    required this.original,
    required this.corrected,
    this.explanation = '',
    this.createdAt,
  });

  final CorrectionType type;
  final String original;
  final String corrected;
  final String explanation;
  final DateTime? createdAt;
}

/// Correcciones agrupadas por tipo + forma corregida.
class CorrectionGroup {
  const CorrectionGroup({
    required this.type,
    required this.original,
    required this.corrected,
    required this.occurrences,
    this.explanation = '',
    this.lastSeenAt,
  });

  final CorrectionType type;
  final String original;
  final String corrected;
  final int occurrences;
  final String explanation;
  final DateTime? lastSeenAt;

  bool get isRecurring => occurrences >= recurringErrorThreshold;
}

/// A partir de 2 repeticiones un error se considera recurrente.
const int recurringErrorThreshold = 2;

/// Agrupa por tipo y forma corregida, contando recurrencia.
///
/// Orden: más repetidos primero; a igualdad, alfabético (determinista y
/// testeable).
List<CorrectionGroup> groupCorrections(Iterable<CorrectionRecord> records) {
  final groups = <String, CorrectionGroup>{};

  for (final record in records) {
    final key =
        '${record.type.wireName}|${normalizeCorrectionText(record.corrected)}';
    final existing = groups[key];
    if (existing == null) {
      groups[key] = CorrectionGroup(
        type: record.type,
        original: record.original,
        corrected: record.corrected,
        occurrences: 1,
        explanation: record.explanation,
        lastSeenAt: record.createdAt,
      );
      continue;
    }

    final incomingAt = record.createdAt;
    final existingAt = existing.lastSeenAt;
    final isNewer =
        incomingAt != null &&
        (existingAt == null || incomingAt.isAfter(existingAt));

    groups[key] = CorrectionGroup(
      type: existing.type,
      original: isNewer ? record.original : existing.original,
      corrected: existing.corrected,
      occurrences: existing.occurrences + 1,
      explanation: isNewer && record.explanation.isNotEmpty
          ? record.explanation
          : existing.explanation,
      lastSeenAt: isNewer ? incomingAt : existingAt,
    );
  }

  final result = groups.values.toList()
    ..sort((a, b) {
      final byOccurrences = b.occurrences.compareTo(a.occurrences);
      if (byOccurrences != 0) return byOccurrences;
      return a.corrected.toLowerCase().compareTo(b.corrected.toLowerCase());
    });
  return result;
}

/// Secciones de la pantalla «Mis errores», en el orden del enum y sin tipos
/// vacíos.
Map<CorrectionType, List<CorrectionGroup>> groupCorrectionsByType(
  List<CorrectionGroup> groups,
) {
  final result = <CorrectionType, List<CorrectionGroup>>{};
  for (final type in CorrectionType.values) {
    final items = groups.where((g) => g.type == type).toList();
    if (items.isNotEmpty) result[type] = items;
  }
  return result;
}

/// Contexto compacto en inglés para el system prompt del tutor.
///
/// Devuelve cadena vacía si no hay errores recurrentes.
String buildTutorRecurringErrorsHint(
  List<CorrectionGroup> groups, {
  int limit = 3,
}) {
  final top = groups.where((g) => g.isRecurring).take(limit).toList();
  if (top.isEmpty) return '';
  final items = top
      .map(
        (g) =>
            '"${g.original}" → "${g.corrected}" (${g.type.wireName}, ${g.occurrences}x)',
      )
      .join('; ');
  return 'The student keeps making these mistakes: $items. '
      'Do not lecture them, but naturally reuse the correct forms and invite '
      'them to use them.';
}

/// Texto que se añade a la debilidad de la sub-misión de refuerzo.
String buildMissionFocusFromErrors(
  List<CorrectionGroup> groups, {
  int limit = 2,
}) {
  final top = groups.where((g) => g.isRecurring).take(limit).toList();
  if (top.isEmpty) return '';
  return top
      .map(
        (g) =>
            '${g.type.wireName}: "${g.original}" → "${g.corrected}" (${g.occurrences}x)',
      )
      .join('; ');
}
