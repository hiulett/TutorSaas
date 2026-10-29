import 'dart:convert';

import '../../../corrections/domain/models/turn_correction.dart';
import 'goal_evaluation_result.dart';

/// Parser tolerante de la respuesta de `goal_eval` (lógica pura, testeable).
///
/// Acepta:
/// - el formato nuevo `{"goals": {...}, "corrections": [...]}`,
/// - el formato antiguo plano `{"g1": true, "g2": false}`,
/// - la clave `errors` como alias de `corrections`,
/// - bloques ```json ... ``` alrededor del JSON,
/// - prosa antes/después del objeto JSON,
/// - booleanos serializados como texto (`"true"` / `"false"`),
/// - JSON truncado: rescata solo los pares `id: true|false` completos.
///
/// Cualquier cosa que no cumpla el esquema se descarta: el turno nunca se
/// bloquea por una respuesta inválida del modelo. El parser NO decide si una
/// meta pertenece a la lección; eso lo hace [GoalEvaluationResult.goalsForCatalog]
/// antes de persistir (regla P-39).
GoalEvaluationResult parseGoalEvaluation(String raw) {
  final cleaned = _stripCodeFence(raw).trim();
  if (cleaned.isEmpty) return GoalEvaluationResult.empty;

  final candidate = _extractJsonObject(cleaned);
  final decoded = _decodeMap(candidate) ?? _decodeMap(_repairJson(candidate));

  if (decoded == null) {
    final salvaged = _salvageGoals(candidate);
    if (salvaged.isEmpty) return GoalEvaluationResult.empty;
    return GoalEvaluationResult(goals: salvaged, succeeded: true);
  }

  final goals = _extractGoals(decoded);

  // Un `goals` que existe pero no es un objeto es un esquema roto: la
  // evaluación se considera fallida para que se reintente.
  final malformedGoals =
      decoded.containsKey('goals') && decoded['goals'] is! Map;

  final correctionsRaw = decoded['corrections'] ?? decoded['errors'];
  final parsedCorrections = parseCorrections(correctionsRaw);

  return GoalEvaluationResult(
    goals: goals,
    corrections: parsedCorrections.corrections,
    discardedCorrections: parsedCorrections.discarded,
    // El JSON era legible y el esquema de metas era válido: la evaluación se
    // hizo y no hay que reintentarla, aunque no trajera metas en true.
    succeeded: !malformedGoals,
  );
}

/// Devuelve `null` si el valor no es `true`/`false` (booleano o su forma
/// textual). Los números (`1`/`0`) no cuentan como evidencia.
bool? _goalValue(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    var normalized = value.trim().toLowerCase();
    if (normalized.length >= 2 &&
        normalized.startsWith('"') &&
        normalized.endsWith('"')) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }
    switch (normalized) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
  }
  return null;
}

Map<String, bool> _extractGoals(Map<String, dynamic> decoded) {
  final goalsValue = decoded['goals'];
  final Map raw = goalsValue is Map ? goalsValue : decoded;

  final goals = <String, bool>{};
  for (final entry in raw.entries) {
    final id = entry.key.toString().trim();
    if (id.isEmpty) continue;
    // Las claves del sobre no son ids de meta.
    if (id == 'goals' || id == 'corrections' || id == 'errors') continue;
    final value = _goalValue(entry.value);
    if (value != null) goals[id] = value;
  }
  return goals;
}

Map<String, dynamic>? _decodeMap(String text) {
  if (text.isEmpty) return null;
  try {
    final decoded = jsonDecode(text);
    if (decoded is! Map) return null;
    return {
      for (final entry in decoded.entries) entry.key.toString(): entry.value,
    };
  } catch (_) {
    return null;
  }
}

String _stripCodeFence(String raw) {
  var trimmed = raw.replaceFirst('\uFEFF', '').trim();
  if (!trimmed.startsWith('```')) return trimmed;
  final firstLineBreak = trimmed.indexOf('\n');
  if (firstLineBreak < 0) return trimmed;
  trimmed = trimmed.substring(firstLineBreak + 1);
  final closing = trimmed.lastIndexOf('```');
  if (closing >= 0) trimmed = trimmed.substring(0, closing);
  return trimmed.trim();
}

/// Recorta prosa alrededor del objeto JSON. Si está truncado, devuelve desde
/// la primera `{` para que el rescate pueda intentarlo.
String _extractJsonObject(String text) {
  final start = text.indexOf('{');
  if (start < 0) return text;
  final end = text.lastIndexOf('}');
  if (end <= start) return text.substring(start);
  return text.substring(start, end + 1);
}

/// Arregla el error más común del modelo: comas antes de `}` o `]`.
String _repairJson(String text) {
  if (text.isEmpty) return text;
  return text.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
}

/// Rescata pares `"id": true` / `"id": "false"` de un JSON truncado.
///
/// Solo acepta booleanos completos y explícitos; un valor cortado (`"g2": fal`)
/// se ignora en lugar de adivinarse.
Map<String, bool> _salvageGoals(String text) {
  if (text.isEmpty) return const {};
  final goals = <String, bool>{};

  final goalsKey = RegExp(r'"goals"\s*:\s*\{').firstMatch(text);
  var scope = goalsKey == null ? text : text.substring(goalsKey.end);
  if (goalsKey != null) {
    // No rescatar booleanos que vivan en `corrections`/`errors`.
    final tail = RegExp(r'"(?:corrections|errors)"\s*:').firstMatch(scope);
    if (tail != null) scope = scope.substring(0, tail.start);
  }

  final pair = RegExp(
    r'"([^"\\]{1,128})"\s*:\s*(true|false|"true"|"false")',
    caseSensitive: false,
  );
  for (final match in pair.allMatches(scope)) {
    final id = match.group(1)?.trim() ?? '';
    final value = _goalValue(match.group(2));
    if (id.isNotEmpty && value != null) goals[id] = value;
  }
  return goals;
}
