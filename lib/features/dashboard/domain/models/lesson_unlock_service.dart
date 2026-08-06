import '../../data/models/lesson_catalog.dart';

/// Estado de desbloqueo de una lección en la Ruta por Etapas.
enum LessonUnlockState {
  /// El jugador completó la lección (fila en `conversations`).
  completedByPlayer,

  /// Desbloqueada automáticamente por el nivel demostrado en el Oráculo
  /// (niveles CEFR anteriores al asignado).
  unlockedByOracle,

  /// Primera lección disponible del nivel actual del usuario.
  nextAvailable,

  /// Bloqueada (niveles superiores o lecciones posteriores del nivel actual).
  locked,
}

/// Resultado del desbloqueo de una lección concreta.
class LessonUnlock {
  final LessonUnlockState state;

  const LessonUnlock(this.state);
}

/// Servicio centralizado de desbloqueo de lecciones por nivel CEFR.
///
/// Regla: si el usuario fue clasificado en nivel N (por el Oráculo), demuestra
/// dominio de todos los niveles anteriores → quedan desbloqueadas. Del nivel
/// actual solo la primera lección disponible; el resto secuencial. Los niveles
/// superiores quedan bloqueados.
///
/// Helper puro — sin widgets ni dependencias de Flutter. Fuente única: la
/// evaluación del Oráculo (nivel CEFR persistido) + historial de `conversations`.
class LessonUnlockService {
  const LessonUnlockService._();

  static const List<String> _order = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  /// Índice canónico del nivel; -1 si no se reconoce.
  static int _levelIndex(String level) {
    final idx = _order.indexOf(level.trim().toUpperCase());
    return idx;
  }

  /// ¿Existe una fila en el historial para esta lección?
  static bool _isCompleted(
    List<Map<String, dynamic>> completedLessons,
    String lessonId,
  ) {
    for (final item in completedLessons) {
      if (item['scenario_id'] == lessonId || item['id'] == lessonId) {
        return true;
      }
    }
    return false;
  }

  /// Clasifica el estado de una lección según el nivel del usuario.
  static LessonUnlockState classify({
    required LessonData lesson,
    required String userCefr,
    required List<Map<String, dynamic>> completedLessons,
    required List<LessonData> catalog,
  }) {
    if (_isCompleted(completedLessons, lesson.id)) {
      return LessonUnlockState.completedByPlayer;
    }

    final userIdx = _levelIndex(userCefr);
    final lessonIdx = _levelIndex(lesson.level);
    if (userIdx < 0 || lessonIdx < 0) {
      // Nivel desconocido: comportamiento conservador (secuencial global).
      return _sequentialFallback(lesson, catalog, completedLessons);
    }

    // Niveles anteriores al asignado → desbloqueadas por el Oráculo.
    if (lessonIdx < userIdx) {
      return LessonUnlockState.unlockedByOracle;
    }

    // Niveles superiores → bloqueadas.
    if (lessonIdx > userIdx) {
      return LessonUnlockState.locked;
    }

    // Nivel actual: la primera lección no completada del nivel está disponible.
    // Solo las lecciones del MISMO nivel que aparecen ANTES en el catálogo
    // deben estar completadas para desbloquear la actual.
    final lessonCatalogIdx = catalog.indexWhere((l) => l.id == lesson.id);
    final priorSameLevel = <LessonData>[];
    for (int i = 0; i < lessonCatalogIdx; i++) {
      final l = catalog[i];
      if (_levelIndex(l.level) == lessonIdx) {
        priorSameLevel.add(l);
      }
    }
    final allPriorCompleted = priorSameLevel.every(
      (l) => _isCompleted(completedLessons, l.id),
    );
    return allPriorCompleted
        ? LessonUnlockState.nextAvailable
        : LessonUnlockState.locked;
  }

  /// Fallback secuencial global (usado si el nivel no se reconoce).
  static LessonUnlockState _sequentialFallback(
    LessonData lesson,
    List<LessonData> catalog,
    List<Map<String, dynamic>> completedLessons,
  ) {
    final index = catalog.indexWhere((l) => l.id == lesson.id);
    if (index <= 0) return LessonUnlockState.nextAvailable;
    final prior = catalog[index - 1];
    return _isCompleted(completedLessons, prior.id)
        ? LessonUnlockState.nextAvailable
        : LessonUnlockState.locked;
  }
}
