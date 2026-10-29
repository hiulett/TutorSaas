// P-42 (#127) — Lógica pura de la lección de refuerzo.
//
// Sin Flutter ni Supabase para poder probarse con `flutter test`. El servicio
// (`lesson_generator_service.dart`) solo aporta la E/S; todas las decisiones
// (qué skill reforzar, con qué evidencia y cómo interpretar la respuesta)
// viven aquí.
import '../../../corrections/domain/models/turn_correction.dart';

/// Valores admitidos por `scenarios.skill_focus` (y por el edge function).
const Set<String> remedialSkillFocuses = {
  'fluency',
  'vocab',
  'phonetics',
  'grammar',
  'goals',
};

/// Ejes del radar que NO son `skill_focus` y antes rompían la generación
/// (400 por `skill_focus inválido`, hallazgo H-42).
///
/// `comprehension` y `naturalness` solo existen con datos del Oráculo; sin
/// ellos valen 0 y ganaban siempre el "skill más débil". Se excluyen del
/// cálculo en lugar de mapearlos, para no reforzar un eje sin medición.
const Set<String> nonRemediableRadarAxes = {'comprehension', 'naturalness'};

/// Traduce un eje del radar a un `skill_focus` aceptado. `null` si no aplica.
String? skillFocusForRadarAxis(String axis) {
  final key = axis.trim().toLowerCase();
  if (remedialSkillFocuses.contains(key)) return key;
  // Solo los cinco ejes canónicos deciden el refuerzo.
  return null;
}

/// Skill a reforzar según el radar: el `skill_focus` válido con menor score.
///
/// Los ejes no mapeables (comprehension/naturalness) y cualquier clave
/// desconocida se ignoran. Sin datos utilizables devuelve `grammar`
/// (el skill con más superficie de error en producción).
String weakestSkillFromRadar(Map<String, double> radar) {
  final scores = <String, double>{};
  for (final entry in radar.entries) {
    final skill = skillFocusForRadarAxis(entry.key);
    if (skill == null) continue;
    final previous = scores[skill];
    if (previous == null || entry.value < previous) {
      scores[skill] = entry.value;
    }
  }
  if (scores.isEmpty) return 'grammar';
  final ordered = scores.entries.toList()
    ..sort((a, b) {
      final byScore = a.value.compareTo(b.value);
      if (byScore != 0) return byScore;
      // Empate: orden alfabético para que el resultado sea determinista.
      return a.key.compareTo(b.key);
    });
  return ordered.first.key;
}

/// `skill_focus` que corresponde a un tipo de corrección (P-29).
///
/// `typo_stt` devuelve `null`: son errores de transcripción de voz, no del
/// alumno, y no deben dirigir una lección.
String? skillFocusForCorrectionType(CorrectionType type) {
  switch (type) {
    case CorrectionType.grammar:
      return 'grammar';
    case CorrectionType.vocabulary:
    case CorrectionType.wordChoice:
      return 'vocab';
    case CorrectionType.pronunciationHint:
      return 'phonetics';
    case CorrectionType.typoStt:
      return null;
  }
}

/// Plan de refuerzo: qué se practica y con qué evidencia.
class RemedialPlan {
  const RemedialPlan({
    required this.skillFocus,
    required this.weakness,
    required this.fromRecurringErrors,
    required this.failedGoals,
  });

  final String skillFocus;

  /// Texto que recibe el modelo como debilidad concreta.
  final String weakness;

  /// `true` si el skill sale de errores reales, no del radar.
  final bool fromRecurringErrors;

  final List<String> failedGoals;
}

/// Construye el plan de refuerzo o `null` si no hay evidencia suficiente.
///
/// Evidencia = errores recurrentes reales (P-29) **o** objetivos fallados en
/// la sesión. Sin ninguna de las dos no se genera lección (ni se cobra maná).
RemedialPlan? buildRemedialPlan({
  required Map<String, double> radar,
  required List<CorrectionGroup> recurringErrors,
  required List<String> failedGoals,
  int maxGoals = 2,
  int maxErrors = 2,
}) {
  final recurring = recurringErrors
      .where((g) => g.isRecurring)
      .where((g) => skillFocusForCorrectionType(g.type) != null)
      .toList();
  final goals = failedGoals
      .map((g) => g.trim())
      .where((g) => g.isNotEmpty)
      .take(maxGoals)
      .toList();

  if (recurring.isEmpty && goals.isEmpty) return null;

  // El skill lo decide el error real dominante (lista ya ordenada por
  // recurrencia); el radar solo es el desempate cuando no hay errores.
  final skill = recurring.isEmpty
      ? weakestSkillFromRadar(radar)
      : (skillFocusForCorrectionType(recurring.first.type) ??
            weakestSkillFromRadar(radar));

  final parts = <String>[
    ...goals.map((g) => 'objective not met: $g'),
    ...recurring
        .take(maxErrors)
        .map(
          (g) =>
              '${g.type.wireName}: "${g.original}" → "${g.corrected}" '
              '(${g.occurrences}x)',
        ),
  ];

  return RemedialPlan(
    skillFocus: skill,
    weakness: parts.join('; '),
    fromRecurringErrors: recurring.isNotEmpty,
    failedGoals: goals,
  );
}

/// Estado de la lección de refuerzo tal como lo ve la UI.
enum RemedialLessonStatus {
  /// Generada por el modelo en esta llamada.
  generated,

  /// Ya existía una equivalente; no costó maná.
  reused,

  /// El alumno no tiene errores recurrentes ni objetivos fallados.
  noEvidence,

  /// Saldo insuficiente (402).
  insufficientMana,

  /// El modelo o la inserción fallaron (maná reembolsado).
  failed,
}

/// Resultado tipado de `lesson-generator` para pintar carga/error/vacío sin
/// dejar la pantalla en blanco.
class RemedialLessonResult {
  const RemedialLessonResult({
    required this.status,
    this.scenarioId,
    this.scenarioTitle,
    this.cost = 0,
    this.detail = '',
  });

  final RemedialLessonStatus status;
  final String? scenarioId;
  final String? scenarioTitle;

  /// Maná cobrado (0 si se reutilizó o no se generó).
  final int cost;

  /// Código/diagnóstico para logs; nunca se muestra crudo al usuario.
  final String detail;

  bool get isPlayable =>
      status == RemedialLessonStatus.generated ||
      status == RemedialLessonStatus.reused;

  bool get isRetryable => status == RemedialLessonStatus.failed;

  /// Interpreta la respuesta 200 del edge function.
  static RemedialLessonResult fromResponse(Map<String, dynamic>? data) {
    if (data == null) {
      return const RemedialLessonResult(
        status: RemedialLessonStatus.failed,
        detail: 'empty response',
      );
    }
    final scenario = data['scenario'];
    final scenarioMap = scenario is Map
        ? Map<String, dynamic>.from(scenario)
        : null;
    final id = scenarioMap?['id']?.toString();
    if (data['success'] != true || id == null || id.isEmpty) {
      return RemedialLessonResult(
        status: RemedialLessonStatus.failed,
        detail: 'malformed response: ${data['error'] ?? 'no scenario'}',
      );
    }
    return RemedialLessonResult(
      status: data['reused'] == true
          ? RemedialLessonStatus.reused
          : RemedialLessonStatus.generated,
      scenarioId: id,
      scenarioTitle: scenarioMap?['title']?.toString(),
      cost: (data['cost'] as num?)?.toInt() ?? 0,
    );
  }

  /// Interpreta un fallo del edge function (código HTTP + `error` del body).
  static RemedialLessonResult fromFailure({int? status, String? code}) {
    final error = (code ?? '').trim().toLowerCase();
    if (status == 422 || error == 'no_evidence') {
      return const RemedialLessonResult(
        status: RemedialLessonStatus.noEvidence,
        detail: 'no_evidence',
      );
    }
    if (status == 402 || error == 'insufficient_mana') {
      return const RemedialLessonResult(
        status: RemedialLessonStatus.insufficientMana,
        detail: 'insufficient_mana',
      );
    }
    return RemedialLessonResult(
      status: RemedialLessonStatus.failed,
      detail: '${status ?? '?'}:${error.isEmpty ? 'unknown' : error}',
    );
  }
}
