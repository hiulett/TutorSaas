import '../../../onboarding/domain/models/cefr_rank.dart';
import '../../data/models/lesson_catalog.dart';
import 'mission_progress_service.dart';

/// Estado de desbloqueo de una lección en la Ruta por Etapas.
enum LessonUnlockState {
  /// El jugador superó la lección (≥ [LessonUnlockService.passThreshold] de
  /// sus metas en `user_scenario_goals`).
  completedByPlayer,

  /// Desbloqueada automáticamente por el nivel demostrado en el Oráculo
  /// (niveles CEFR anteriores al asignado).
  unlockedByOracle,

  /// Primera lección disponible del nivel actual del usuario.
  nextAvailable,

  /// Bloqueada (niveles superiores o lecciones posteriores del nivel actual).
  locked,
}

/// Servicio centralizado de desbloqueo de lecciones por nivel CEFR.
///
/// Regla: si el usuario fue clasificado en nivel N (por el Oráculo), demuestra
/// dominio de todos los niveles anteriores → quedan desbloqueadas. Del nivel
/// actual solo la primera lección disponible; el resto secuencial. Los niveles
/// superiores quedan bloqueados.
///
/// Una lección se considera "superada" (desbloquea la siguiente) al alcanzar el
/// [passThreshold] (70%) de sus metas; la maestría (100%) puede completarse
/// después volviendo a la lección.
///
/// Helper puro — sin widgets ni dependencias de Flutter. Fuente única: la
/// evaluación del Oráculo (nivel CEFR persistido) + `user_scenario_goals`.
class LessonUnlockService {
  const LessonUnlockService._();

  /// Umbral de metas (0..1) para considerar una lección superada.
  static const double passThreshold = 0.75;

  /// Regla de superación de una lección (issue #17).
  ///
  /// Se supera cuando:
  ///  - se completan todas las metas, o
  ///  - con 4 metas o menos, falla como máximo una, o
  ///  - se alcanza [passThreshold] del total (lecciones largas).
  ///
  /// El umbral anterior (0.80) exigía el 100 % en lecciones de 3–4 metas y
  /// dejaba al alumno bloqueado con 3/4 (75 %).
  static bool meetsThreshold(int completed, int total) {
    if (total <= 0) return true;
    if (completed >= total) return true;
    if (total <= 4 && completed >= total - 1) return true;
    return (completed / total) >= passThreshold;
  }

  /// Índice canónico del nivel; -1 si no se reconoce.
  /// Orden CEFR centralizado en [CefrRank.cefrOrder].
  static int _levelIndex(String level) {
    return CefrRank.cefrOrder.indexOf(level.trim().toUpperCase());
  }

  /// Ratio de metas completadas de una lección (0..1) desde las filas de
  /// `user_scenario_goals`. Una lección sin metas se considera superada.
  static double completionRatio(
    List<Map<String, dynamic>> goalRows,
    LessonData lesson,
  ) {
    if (lesson.goals.isEmpty) return 1.0;
    final done = MissionProgressService.completedGoalsForScenario(goalRows, lesson.id);
    return (done / lesson.goals.length).clamp(0.0, 1.0);
  }

  /// ¿La lección está "superada"? (≥ [passThreshold] de sus metas).
  static bool _isCompleted(
    List<Map<String, dynamic>> goalRows,
    LessonData lesson,
  ) {
    if (lesson.goals.isEmpty) return true;
    final done =
        MissionProgressService.completedGoalsForScenario(goalRows, lesson.id);
    return meetsThreshold(done, lesson.goals.length);
  }

  /// Clasifica el estado de una lección según el nivel del usuario.
  static LessonUnlockState classify({
    required LessonData lesson,
    required String userCefr,
    required List<Map<String, dynamic>> goalRows,
    required List<LessonData> catalog,
  }) {
    if (_isCompleted(goalRows, lesson)) {
      return LessonUnlockState.completedByPlayer;
    }

    final userIdx = _levelIndex(userCefr);
    final lessonIdx = _levelIndex(lesson.level);
    if (userIdx < 0 || lessonIdx < 0) {
      // Nivel desconocido: comportamiento conservador (secuencial global).
      return _sequentialFallback(lesson, catalog, goalRows);
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
    // deben estar superadas para desbloquear la actual.
    final lessonCatalogIdx = catalog.indexWhere((l) => l.id == lesson.id);
    final priorSameLevel = <LessonData>[];
    for (int i = 0; i < lessonCatalogIdx; i++) {
      final l = catalog[i];
      if (_levelIndex(l.level) == lessonIdx) {
        priorSameLevel.add(l);
      }
    }
    final allPriorCompleted = priorSameLevel.every(
      (l) => _isCompleted(goalRows, l),
    );
    return allPriorCompleted
        ? LessonUnlockState.nextAvailable
        : LessonUnlockState.locked;
  }

  /// Fallback secuencial global (usado si el nivel no se reconoce).
  static LessonUnlockState _sequentialFallback(
    LessonData lesson,
    List<LessonData> catalog,
    List<Map<String, dynamic>> goalRows,
  ) {
    final index = catalog.indexWhere((l) => l.id == lesson.id);
    if (index <= 0) return LessonUnlockState.nextAvailable;
    final prior = catalog[index - 1];
    return _isCompleted(goalRows, prior)
        ? LessonUnlockState.nextAvailable
        : LessonUnlockState.locked;
  }
}
