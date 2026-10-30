/// P-40a (#220) — Ruta recomendada del alumno.
///
/// La calcula y la persiste el servidor (`refresh_recommended_path`) a partir
/// del nivel real, los intereses, los errores recurrentes y las lecciones
/// superadas. El cliente solo la ordena para la Ruta: no decide el contenido ni
/// llama a ningún modelo (coste de IA = 0).
///
/// Cada paso apunta a un escenario de `public.scenarios` (uuid) y, cuando el
/// contenido existe también en el catálogo Dart, trae `lesson_key` para que la
/// UI pueda abrir la lección sin depender de los dos currículos.
enum RecommendedPathReason {
  /// El escenario toca un interés declarado por el alumno.
  interest,

  /// El escenario trabaja palabras de sus errores recurrentes (P-29).
  recurringError,

  /// Ya está superado: cierra la ruta como repaso.
  review,

  /// Siguiente paso pendiente sin señal adicional.
  next,
}

class RecommendedPathStep {
  const RecommendedPathStep({
    required this.scenarioId,
    required this.title,
    required this.level,
    required this.position,
    required this.reason,
    this.lessonKey,
    this.category = '',
    this.estimatedMinutes = 15,
  });

  /// `scenarios.id` (uuid). Puede venir vacío en los niveles donde el catálogo
  /// Dart y `scenarios` divergen (B2/C1); en ese caso manda `lessonKey`.
  final String scenarioId;

  /// Id del catálogo Dart equivalente, si el contenido está mapeado.
  final String? lessonKey;

  final String title;
  final String level;
  final String category;
  final int estimatedMinutes;

  /// Posición 1..N calculada por el servidor (determinista).
  final int position;

  final RecommendedPathReason reason;

  /// Clave con la que la Ruta reconoce la lección: primero `lesson_key`, luego
  /// el id del escenario. El catálogo Dart usa ids de texto, así que sin
  /// `lesson_key` no habría puente.
  String get key {
    final lesson = lessonKey?.trim() ?? '';
    return lesson.isNotEmpty ? lesson : scenarioId;
  }

  static RecommendedPathStep? fromMap(Map<String, dynamic> raw) {
    final scenarioId = raw['scenario_id']?.toString().trim() ?? '';
    final title = raw['title']?.toString().trim() ?? '';
    final lessonKey = raw['lesson_key']?.toString().trim() ?? '';
    // Los niveles donde el catálogo Dart y `scenarios` divergen (B2/C1) llegan
    // sin uuid: la lección existe en el catálogo y la Ruta la abre por
    // `lesson_key`. Basta con una de las dos claves.
    if (title.isEmpty || (scenarioId.isEmpty && lessonKey.isEmpty)) {
      return null;
    }
    return RecommendedPathStep(
      scenarioId: scenarioId,
      lessonKey: lessonKey.isEmpty ? null : lessonKey,
      title: title,
      level: raw['level']?.toString().trim().toUpperCase() ?? '',
      category: raw['category']?.toString().trim() ?? '',
      estimatedMinutes: (raw['estimated_minutes'] as num?)?.toInt() ?? 15,
      position: (raw['position'] as num?)?.toInt() ?? 0,
      reason: _reasonFromCode(raw['reason']?.toString()),
    );
  }

  /// Normaliza la respuesta jsonb de la RPC. Tolera listas de mapas dinámicos,
  /// descarta filas incompletas y ordena por `position` (nunca por el orden de
  /// llegada de PostgREST).
  static List<RecommendedPathStep> listFromRpc(Object? raw) {
    if (raw is! List) return const [];
    final steps = <RecommendedPathStep>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final step = fromMap(Map<String, dynamic>.from(item));
      if (step != null) steps.add(step);
    }
    steps.sort((a, b) {
      final byPosition = a.position.compareTo(b.position);
      if (byPosition != 0) return byPosition;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return List<RecommendedPathStep>.unmodifiable(steps);
  }

  static RecommendedPathReason _reasonFromCode(String? code) {
    switch (code?.trim().toLowerCase()) {
      case 'interest':
        return RecommendedPathReason.interest;
      case 'recurring_error':
        return RecommendedPathReason.recurringError;
      case 'review':
        return RecommendedPathReason.review;
      default:
        return RecommendedPathReason.next;
    }
  }
}
