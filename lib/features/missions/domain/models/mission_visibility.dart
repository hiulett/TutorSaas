import 'mission_models.dart';

/// Reglas puras de visibilidad y alcanzabilidad de misiones (issue #109 · P-24).
///
/// Objetivos del rediseño:
/// - Solo se muestran misiones **diarias** y **semanales**; secretas, eventos,
///   gremio y `secondary` quedan ocultas hasta que exista un flujo real.
/// - El progreso solo lo escribe el servidor (triggers sobre `messages`,
///   `session_reward_ledger` y `user_vocabulary` → `advance_missions_for_user`).
///   Una misión cuyo `objective_type` no tenga trigger se marca no disponible.
/// - Se marcan como no alcanzables las plantillas cuyo `target_value` supera el
///   techo medido para su objetivo, en vez de mostrar barras eternas en 0 %.
///
/// Los techos salen de la distribución real (auditoría 29-oct-2026):
/// - `session_reward_ledger`: 2 filas, 5 y 7 minutos (p50 5,5 min).
/// - `messages` (sender_role = 'user'): 11,3 turnos de media por conversación.
/// - `user_vocabulary`: 10,6 palabras por usuario.
/// - `session_reward_ledger`: 2 sesiones por usuario como máximo histórico.
/// - `mission_instances`: los targets 24-25 min / 20 palabras no tienen
///   ninguna instancia completada (0/59), mientras que 10 min diarios sí
///   (1/59). Por eso el techo diario de voz es 10 y el semanal 15.
///
/// Este archivo es espejo de la vista SQL `mission_templates_reachability`
/// (migración `20261029*_mission_redesign_observability.sql`). Si cambian los
/// techos, hay que actualizar ambos.
class MissionVisibility {
  const MissionVisibility._();

  /// Tipos que la UI muestra hoy (pestañas Diarias / Semanales).
  static const Set<String> visibleTypes = {'daily', 'weekly'};

  /// Objetivos que el servidor avanza por trigger. Cualquier otro valor
  /// (p. ej. una plantilla nueva de contenido sin trigger) no es alcanzable.
  static const Set<String> autoTrackedObjectives = {
    'speak_minutes',
    'conversation_turns',
    'vocab_words',
    'sessions',
    'practice_session',
  };

  /// Techo de `target_value` por objetivo para misiones diarias.
  static const Map<String, int> dailyCaps = {
    'speak_minutes': 10,
    'conversation_turns': 5,
    'vocab_words': 5,
    'sessions': 1,
    'practice_session': 1,
  };

  /// Techo de `target_value` por objetivo para misiones semanales.
  static const Map<String, int> weeklyCaps = {
    'speak_minutes': 15,
    'conversation_turns': 15,
    'vocab_words': 10,
    'sessions': 3,
    'practice_session': 3,
  };

  /// Tipos ocultos en la UI hasta que exista flujo (secretas, eventos, gremio).
  static const Set<String> hiddenTypes = {
    'secondary',
    'secret',
    'emergency',
    'guild',
    'collaborative',
    'event',
  };

  static bool isTypeVisible(String missionType) =>
      visibleTypes.contains(missionType);

  static bool isAutoTracked(String objectiveType) =>
      autoTrackedObjectives.contains(objectiveType);

  /// Techo aplicable a [objectiveType] en [missionType].
  /// Devuelve `null` si el objetivo no está soportado por el servidor.
  static int? capFor({
    required String objectiveType,
    required String missionType,
  }) {
    if (!isAutoTracked(objectiveType)) return null;
    final caps = missionType == 'weekly' ? weeklyCaps : dailyCaps;
    return caps[objectiveType];
  }

  /// `true` si la misión puede completarse con el motor actual del servidor.
  static bool isReachable({
    required String missionType,
    required String objectiveType,
    required int targetValue,
  }) {
    if (!isTypeVisible(missionType)) return false;
    final cap = capFor(objectiveType: objectiveType, missionType: missionType);
    if (cap == null) return false;
    if (targetValue <= 0) return false;
    return targetValue <= cap;
  }

  /// Igual que [isReachable] para una instancia concreta.
  ///
  /// Una misión ya completada o reclamada nunca se marca como no disponible,
  /// aunque su target supere el techo actual: el jugador ya la cumplió.
  static bool isReachableInstance(MissionInstance mission) {
    if (mission.isCompleted || mission.isRewardClaimed) return true;
    return isReachable(
      missionType: mission.missionType,
      objectiveType: mission.objectiveType,
      targetValue: mission.targetValue,
    );
  }

  /// Motivo por el que una misión no se puede cumplir, o `null` si es
  /// alcanzable. Lo usa la UI para explicar la etiqueta "no disponible".
  static String? unavailableReason(MissionInstance mission) {
    if (mission.isCompleted || mission.isRewardClaimed) return null;
    if (!isTypeVisible(mission.missionType)) return 'hidden_type';
    if (!isAutoTracked(mission.objectiveType)) return 'untracked_objective';
    if (mission.targetValue <= 0) return 'invalid_target';
    if (!isReachableInstance(mission)) return 'target_too_high';
    return null;
  }

  /// Instancias de [type] que la UI puede listar (alcanzables o no), en orden
  /// estable: primero las reclamables, luego por progreso descendente.
  static List<MissionInstance> byType(
    List<MissionInstance> missions, {
    required String type,
  }) {
    if (!isTypeVisible(type)) return const [];
    final filtered = missions
        .where((m) => m.missionType == type && !m.isExpired)
        .toList();
    filtered.sort(compareForDisplay);
    return filtered;
  }

  /// Orden de presentación: reclamable > completada > progreso > id.
  static int compareForDisplay(MissionInstance a, MissionInstance b) {
    final aClaimable = a.isCompleted && !a.isRewardClaimed;
    final bClaimable = b.isCompleted && !b.isRewardClaimed;
    if (aClaimable != bClaimable) return aClaimable ? -1 : 1;

    final aDone = a.isCompleted || a.progress >= 1.0;
    final bDone = b.isCompleted || b.progress >= 1.0;
    if (aDone != bDone) return aDone ? -1 : 1;

    final byProgress = b.progress.compareTo(a.progress);
    if (byProgress != 0) return byProgress;

    final byTarget = a.targetValue.compareTo(b.targetValue);
    if (byTarget != 0) return byTarget;
    return a.id.compareTo(b.id);
  }
}
