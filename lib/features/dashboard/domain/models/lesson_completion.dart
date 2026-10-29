/// Fuente única del criterio de "lección completada" (P-38 · issue #123).
///
/// Antes de este helper convivían tres reglas distintas:
///  - `LessonUnlockService.meetsThreshold` (75 % con tolerancia de una meta en
///    lecciones de 4 metas o menos) para la Ruta y `lesson_progress`;
///  - `goalsDone >= totalGoals` (100 %) en el dashboard, que además decidía las
///    estrellas;
///  - `record_scenario_outcome` (100 % en servidor), que marcaba
///    `scenario_progress.unlocked_next`.
///
/// Ahora todas las señales (desbloqueo, halo y estrellas) se derivan de esta
/// clase. El servidor replica la misma regla en la función SQL
/// `public.lesson_completion_passed(completed, total)`; cualquier cambio de
/// umbral debe hacerse en ambos sitios.
///
/// Regla canónica:
///  - sin metas → superada;
///  - todas las metas → superada;
///  - 4 metas o menos y como máximo una fallada → superada;
///  - en el resto, [passThreshold] (75 %) del total.
///
/// Helper puro — sin widgets ni dependencias de Flutter.
class LessonCompletion {
  const LessonCompletion._();

  /// Umbral de metas (0..1) para superar una lección larga.
  static const double passThreshold = 0.75;

  /// Tamaño máximo de lección que admite una meta fallada.
  static const int shortLessonMaxGoals = 4;

  /// Ratio de metas completadas (0..1). Sin metas devuelve 0 para que la UI
  /// pueda distinguir "sin datos"; para decidir superación usa [isPassed].
  static double ratio(int completed, int total) {
    if (total <= 0) return 0.0;
    return (completed / total).clamp(0.0, 1.0).toDouble();
  }

  /// ¿La lección se supera con [completed] de [total] metas?
  static bool isPassed(int completed, int total) {
    if (total <= 0) return true;
    final done = completed.clamp(0, total);
    if (done >= total) return true;
    if (total <= shortLessonMaxGoals && done >= total - 1) return true;
    return (done / total) >= passThreshold;
  }

  /// ¿La lección alcanzó el 100 % de sus metas (maestría)?
  static bool isMastered(int completed, int total) {
    if (total <= 0) return true;
    return completed >= total;
  }

  /// Estrellas (0–3) de una lección.
  ///
  /// - 0 si no se supera ([isPassed]).
  /// - 1 si se supera.
  /// - 2 si además se usó al menos la mitad de las frases.
  /// - 3 si se usaron todas las frases.
  ///
  /// Sin frases declaradas no se puede premiar su uso: la lección se queda en
  /// 1 estrella.
  static int stars({
    required int completed,
    required int total,
    required int phrasesUsed,
    required int phrasesTotal,
  }) {
    if (!isPassed(completed, total)) return 0;
    if (phrasesTotal <= 0) return 1;
    if (phrasesUsed >= phrasesTotal) return 3;
    if (phrasesUsed >= (phrasesTotal / 2).ceil()) return 2;
    return 1;
  }
}
