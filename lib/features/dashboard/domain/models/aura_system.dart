import '../../../onboarding/domain/models/cefr_rank.dart';
import '../../data/models/lesson_catalog.dart';
import 'mission_progress_service.dart';

/// Estado del Aura del cazador (System HUD).
///
/// El Aura es un poder que el aventurero acumula al desarrollar habilidades.
/// No se tiene desde el principio: para convertirse en Usuario del Aura hay
/// que superar la Etapa Básica (A1 + A2) o ser acreditado por el Oráculo.
enum AuraState {
  /// Aún no despierta: debe superar la Etapa Básica (A1 + A2).
  locked,

  /// Usuario del Aura: el poder acumula con el desarrollo de habilidades.
  awakened,
}

/// Tiers de poder del Aura (crecen a medida que se desarrollan habilidades).
enum AuraTier { latente, revelada, abierta, dominante, abisal }

/// Resultado completo del estado del Aura para la UI.
class AuraSnapshot {
  final AuraState state;
  final AuraTier tier;
  final double power;

  /// Aura XP acumulada (FASE B): mérito SIN tope. Solo crece con la actividad.
  final int auraXp;

  /// Nombre del título de prestigio actual (ladder universal, ej. "Duque").
  final String? prestigeTitleName;

  final double basicStageProgress;
  final int basicObjectivesDone;
  final int basicObjectivesTotal;

  /// `true` si el `game_rank` almacenado no corresponde al nivel CEFR
  /// (inconsistencia de datos detectada por validación cruzada).
  final bool hasRankMismatch;

  const AuraSnapshot({
    required this.state,
    required this.tier,
    required this.power,
    required this.basicStageProgress,
    required this.basicObjectivesDone,
    required this.basicObjectivesTotal,
    this.auraXp = 0,
    this.prestigeTitleName,
    this.hasRankMismatch = false,
  });

  bool get isAwakened => state == AuraState.awakened;
}

/// Servicio puro de desbloqueo y acumulación del Aura.
///
/// Helper sin widgets ni dependencias de Flutter. Fuentes de verdad:
/// - Progreso de la ruta básica: `user_scenario_goals` (objetivos
///   PRE-A1 + A1 + A2).
/// - Acreditación del Oráculo: nivel CEFR ≥ B1.
/// - Poder acumulado: radar de habilidades (fluidez, vocabulario, fonética,
///   gramática, metas) + racha + nivel CEFR (el rango se deriva del CEFR).
class AuraSystem {
  const AuraSystem._();

  /// Orden canónico CEFR (fuente única en [CefrRank.cefrOrder]).
  static List<String> get _cefrOrder => CefrRank.cefrOrder;

  /// Índice máximo de la escala de rangos del gremio (F..SSS).
  static const int _maxRankIndex = 8;

  /// ¿El cazador ya demostró dominio de los niveles básicos?
  ///
  /// Acreditación del Oráculo: clasificado ≥ B1. Se usa SOLO el nivel CEFR
  /// como fuente de verdad; `game_rank` puede quedar inconsistente con el CEFR
  /// (p. ej. rango 'C' con CEFR A1) y no debe despertar el Aura por sí solo.
  static bool accreditationLevelMet(String? cefr) {
    final cefrIdx = _cefrOrder.indexOf((cefr ?? '').trim().toUpperCase());
    return cefrIdx >= _cefrOrder.indexOf('B1');
  }

  /// Rango canónico que corresponde a un nivel CEFR (derivación oficial).
  static String expectedRank(String? cefr) {
    return CefrRank.gameRankFromCefr(cefr ?? '');
  }

  /// ¿El rango almacenado del jugador es inconsistente con su nivel CEFR?
  ///
  /// Solo juzga cuando el CEFR es conocido; si el rango es nulo/vacío no se
  /// considera inconsistencia (p. ej. perfiles sin colocación).
  static bool hasRankMismatch(String? cefr, String? gameRank) {
    final cleanCefr = (cefr ?? '').trim().toUpperCase();
    if (!_cefrOrder.contains(cleanCefr)) return false;
    final expected = expectedRank(cleanCefr);
    final actual = (gameRank ?? '').trim().toUpperCase();
    return actual.isNotEmpty && actual != expected;
  }

  /// Progreso real de la Etapa Básica (PRE-A1 + A1 + A2): objetivos completados
  /// vs totales, a partir de las filas de `user_scenario_goals`.
  static ({int done, int total}) basicStageCounts(
    List<Map<String, dynamic>> goalRows,
  ) {
    var done = 0;
    var total = 0;
    for (final lesson in LessonCatalog.catalog) {
      final level = lesson.level.toUpperCase();
      if (level == 'PRE-A1' || level == 'A1' || level == 'A2') {
        done += MissionProgressService.completedGoalsForScenario(goalRows, lesson.id);
        total += lesson.goals.length;
      }
    }
    return (done: done, total: total);
  }

  /// ¿La Etapa Básica está 100% completada?
  static bool isBasicStageComplete(int done, int total) =>
      total > 0 && done >= total;

  /// Poder acumulado del Aura (0.0–1.0) a partir del radar de habilidades
  /// (valores 0–100), la racha diaria y el nivel CEFR.
  ///
  /// El factor de rango se deriva del CEFR (validación cruzada): un
  /// `game_rank` inconsistente en BD no puede inflar el poder del Aura.
  static double computePower({
    required Map<String, double> radar,
    required int streak,
    required String cefr,
  }) {
    final fluency = (radar['fluency'] ?? 0).clamp(0.0, 100.0) / 100.0;
    final vocab = (radar['vocab'] ?? 0).clamp(0.0, 100.0) / 100.0;
    final phonetics = (radar['phonetics'] ?? 0).clamp(0.0, 100.0) / 100.0;
    final grammar = (radar['grammar'] ?? 0).clamp(0.0, 100.0) / 100.0;
    final goals = (radar['goals'] ?? 0).clamp(0.0, 100.0) / 100.0;
    final streakFactor = (streak / 30).clamp(0.0, 1.0);
    final rankIdx = CefrRank.rankIndex(expectedRank(cefr));
    final rankFactor = rankIdx < 0
        ? 0.0
        : (rankIdx / _maxRankIndex).clamp(0.0, 1.0);

    return (fluency * 0.25 +
            vocab * 0.25 +
            phonetics * 0.20 +
            grammar * 0.10 +
            goals * 0.10 +
            streakFactor * 0.05 +
            rankFactor * 0.05)
        .clamp(0.0, 1.0);
  }

  /// Tier de poder correspondiente a [power] (0.0–1.0).
  static AuraTier tierFor(double power) {
    if (power < 0.25) return AuraTier.latente;
    if (power < 0.45) return AuraTier.revelada;
    if (power < 0.65) return AuraTier.abierta;
    if (power < 0.85) return AuraTier.dominante;
    return AuraTier.abisal;
  }
}
