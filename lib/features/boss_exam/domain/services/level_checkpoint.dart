/// P-43 (#128) — mini-chequeo periódico del nivel.
///
/// El servidor (`boss_exam_status`) cuenta las lecciones superadas desde el
/// último reto del jefe (o desde el placement inicial) y marca `check_due`
/// cuando se alcanza el intervalo. Estas reglas son la copia pura que usa la
/// UI para decidir si muestra el aviso y cuánto falta; la fuente de verdad del
/// nivel sigue siendo el servidor.
class LevelCheckpoint {
  const LevelCheckpoint._();

  /// Cada cuántas lecciones superadas se propone revisar el nivel.
  static const int interval = 10;

  /// `true` cuando toca proponer el examen del jefe.
  static bool isDue(int lessonsSinceLastCheck) =>
      lessonsSinceLastCheck >= interval;

  /// Lecciones que faltan para el próximo aviso. `0` si ya toca.
  static int remaining(int lessonsSinceLastCheck) {
    if (isDue(lessonsSinceLastCheck)) return 0;
    final safe = lessonsSinceLastCheck < 0 ? 0 : lessonsSinceLastCheck;
    return interval - safe;
  }

  /// Progreso 0..1 hacia el próximo aviso, para la barra del banner.
  static double progress(int lessonsSinceLastCheck) {
    if (isDue(lessonsSinceLastCheck)) return 1;
    final safe = lessonsSinceLastCheck < 0 ? 0 : lessonsSinceLastCheck;
    return (safe / interval).clamp(0.0, 1.0);
  }
}
