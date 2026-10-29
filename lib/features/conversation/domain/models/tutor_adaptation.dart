/// P-40 (#125) — Ajuste de dificultad DENTRO del nivel CEFR.
///
/// El escenario sigue teniendo un `difficulty_level` fijo (el del catálogo),
/// pero el tutor deja de tratarlo como una constante: si el alumno encadena
/// fallos simplifica y ofrece pistas; si acierta con soltura sube el listón.
///
/// El ajuste es puramente léxico (va en el system prompt) y **no** añade
/// llamadas al modelo: se calcula con las correcciones y las metas que el turno
/// de chat ya evaluó.
library;

/// Dirección del ajuste para el próximo turno.
enum TutorDifficultyAdjustment {
  /// El alumno encadena fallos: frases cortas, una idea por turno y pistas.
  simplify,

  /// Sin señal suficiente: se mantiene el nivel del escenario.
  steady,

  /// El alumno acierta con soltura: vocabulario y estructura un paso por encima.
  stretch,
}

/// Señal de un turno ya respondido. No genera coste: se deriva de las
/// correcciones del turno y de las metas que se acaban de evaluar.
class TutorTurnOutcome {
  const TutorTurnOutcome({
    required this.corrections,
    required this.wordCount,
    this.goalsCompleted = 0,
  });

  /// Correcciones devueltas por la evaluación del turno (`goal_eval` o
  /// `correction_turn`). Cero significa "no se detectó error".
  final int corrections;

  /// Palabras que escribió/dijo el alumno.
  final int wordCount;

  /// Metas del escenario que se completaron en este turno.
  final int goalsCompleted;

  /// Fallo: hubo al menos una corrección.
  bool get isStruggle => corrections > 0;

  /// Éxito: turno limpio y con sustancia (meta cumplida o frase desarrollada).
  bool get isSuccess =>
      corrections == 0 && (goalsCompleted > 0 || wordCount >= 6);
}

/// Contador de rachas de acierto/fallo por sesión.
///
/// Reglas (deterministas y testeables):
/// * un turno con correcciones suma a `struggleStreak` y pone `successStreak` a 0;
/// * un turno limpio y sustancioso suma a `successStreak` y pone `struggleStreak`
///   a 0;
/// * un turno neutro (limpio pero muy corto, p. ej. "yes") no mueve ninguna racha:
///   responder con monosílabos no debe premiar ni castigar.
class TutorAdaptationTracker {
  /// Fallos consecutivos que disparan la simplificación.
  static const int struggleThreshold = 2;

  /// Aciertos consecutivos que disparan la subida de complejidad.
  static const int stretchThreshold = 3;

  int _struggleStreak = 0;
  int _successStreak = 0;

  int get struggleStreak => _struggleStreak;
  int get successStreak => _successStreak;

  /// Dirección del ajuste con las rachas actuales.
  TutorDifficultyAdjustment get adjustment {
    if (_struggleStreak >= struggleThreshold) {
      return TutorDifficultyAdjustment.simplify;
    }
    if (_successStreak >= stretchThreshold) {
      return TutorDifficultyAdjustment.stretch;
    }
    return TutorDifficultyAdjustment.steady;
  }

  /// Registra el resultado de un turno y devuelve el ajuste resultante.
  TutorDifficultyAdjustment record(TutorTurnOutcome outcome) {
    if (outcome.isStruggle) {
      _struggleStreak++;
      _successStreak = 0;
    } else if (outcome.isSuccess) {
      _successStreak++;
      _struggleStreak = 0;
    }
    return adjustment;
  }

  void reset() {
    _struggleStreak = 0;
    _successStreak = 0;
  }
}
