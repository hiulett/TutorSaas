/// Cálculo centralizado de progreso de lecciones (Fase 3 auditoría).
///
/// Fuente única de datos: `completedLessonsProvider` (fila por conversación en
/// `conversations`, con `scenario_id, score, fluency_score, created_at`).
/// Helper puro — sin widgets ni dependencias de Flutter.
class ProgressUtils {
  const ProgressUtils._();

  /// Progreso de una lección concreta.
  ///
  /// Devuelve 0.0 si no hay conversación completada para [lessonId]; si existe,
  /// devuelve el score normalizado (`score/100`), o `fluency_score/100`, o 0.5
  /// como valor neutro cuando no hay puntuación guardada.
  static double lessonProgress(
    List<Map<String, dynamic>> completedLessons,
    String lessonId,
  ) {
    final item = _findLesson(completedLessons, lessonId);
    if (item == null) return 0.0;

    final score = item['score'];
    if (score is num) return (score / 100.0).clamp(0.0, 1.0).toDouble();

    final fluency = item['fluency_score'];
    if (fluency is num) return (fluency / 100.0).clamp(0.0, 1.0).toDouble();

    return 0.5;
  }

  /// Existe una fila en `conversations` con ese `scenario_id`.
  static bool isLessonCompleted(
    List<Map<String, dynamic>> completedLessons,
    String lessonId,
  ) {
    return _findLesson(completedLessons, lessonId) != null;
  }

  /// Completadas / total para un conjunto de lecciones (p. ej. una etapa CEFR).
  static double stageProgress(
    List<Map<String, dynamic>> completedLessons,
    List<String> lessonIds,
  ) {
    if (lessonIds.isEmpty) return 0.0;
    final completed = lessonIds
        .where((id) => isLessonCompleted(completedLessons, id))
        .length;
    return (completed / lessonIds.length).clamp(0.0, 1.0).toDouble();
  }

  /// Progreso global sobre todas las lecciones del catálogo.
  static double overallProgress(
    List<Map<String, dynamic>> completedLessons,
    List<String> allLessonIds,
  ) {
    return stageProgress(completedLessons, allLessonIds);
  }

  static Map<String, dynamic>? _findLesson(
    List<Map<String, dynamic>> completedLessons,
    String lessonId,
  ) {
    for (final item in completedLessons) {
      if (item['scenario_id'] == lessonId || item['id'] == lessonId) {
        return item;
      }
    }
    return null;
  }
}
