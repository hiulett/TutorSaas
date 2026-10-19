import '../models/mission_models.dart';

/// Contrato del repositorio de misiones.
abstract class MissionRepository {
  // ── Cleanup ────────────────────────────────────────────────────────────

  /// Elimina misiones antiguas para evitar saturación de la DB.
  /// Se llama antes de crear misiones nuevas.
  Future<void> cleanupOldMissions(String userId);

  /// Verifica cuotas y hace cleanup antes de aceptar nueva misión.
  Future<bool> canAcceptMission(String userId, String missionType);

  // ── Templates ──────────────────────────────────────────────────────────

  Future<List<MissionTemplate>> getTemplates({String? type, String? cefrLevel});

  // ── Instances ──────────────────────────────────────────────────────────

  Future<List<MissionInstance>> getActiveMissions(String userId);

  Future<List<MissionInstance>> getCompletedMissions(String userId, {int limit = 20});

  Future<MissionInstance?> acceptMission(String userId, MissionTemplate template);

  /// Incrementa el progreso de una misión en [delta] unidades.
  /// Marca `completed` solo cuando se alcanza el target; de lo contrario
  /// persiste el progreso parcial en vivo (T-402).
  Future<bool> updateProgress(String instanceId, {int delta = 1});

  /// Issue #5: avanza **todas** las misiones activas del usuario cuyo
  /// `objective_type` coincide. Usa la RPC `advance_my_missions`, que toma el
  /// usuario de la sesión (auth.uid()) y no puede escribir misiones ajenas.
  Future<void> advanceMissions(String objectiveType, {int delta = 1});

  Future<bool> claimReward(String instanceId, String userId);

  /// Aplica un item `mission_modifier` a una misión activa (Fase 9 · MM-03).
  /// Códigos soportados:
  ///   mod_recompensa_x2      → reward_multiplier = 2
  ///   mod_piedra_facilidad   → target_value = ceil(target * 0.5)
  ///   mod_piedra_desafio     → target_value = ceil(target * 1.5), reward_multiplier = 2
  ///   mod_llave_ruta_secreta → crea una misión secreta nueva
  /// Consume el item del inventario del jugador al aplicarlo.
  Future<bool> applyMissionModifier({
    required String userId,
    required String instanceId,
    required String itemCode,
  });

  // ── Secret Missions ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSecretMissions(String userId);

  Future<void> createSecretMission(String userId, Map<String, dynamic> missionData);

  // ── Emergency Missions ─────────────────────────────────────────────────

  Future<List<EmergencyMission>> getActiveEmergencies();

  // ── Reward History ─────────────────────────────────────────────────────

  Future<List<RewardHistory>> getRecentRewards(String userId, {int limit = 20});

  // ── Batch Generation ───────────────────────────────────────────────────

  /// Genera misiones diarias para el usuario.
  /// Primero hace cleanup, luego asigna hasta completar el máximo permitido.
  Future<void> generateDailyMissions(String userId);

  /// Elimina TODAS las misiones de un usuario excepto las activas actuales
  /// Útil para reset completo o cuando se necesita espacio urgente.
  Future<void> purgeAllOldMissions(String userId);

  // ── Guild Missions (colaborativas) ───────────────────────────────────────

  /// Pool de misiones del gremio (guild_quest_pool) activas.
  ///
  /// Filtra por [languageId] (1=en, 2=fr, 3=de, 4=it) cuando se indica y, si
  /// [excludeCompletedFor] no es null, excluye las misiones que el usuario ya
  /// completó (registradas en `player_completed_quests`). [limit] recorta a
  /// las primeras N (p.ej. mostrar solo 3).
  Future<List<GuildQuest>> getGuildQuestPool({
    int? languageId,
    String? excludeCompletedFor,
    int? limit,
  });

  /// Misiones del pool ya completadas por el usuario (`player_completed_quests`),
  /// unidas con `guild_quest_pool` para mostrar el historial (filtro "cumplidas").
  Future<List<GuildQuest>> getCompletedGuildQuests(String userId, {int? languageId});

  /// Obtiene una misión del pool del gremio por su id (para la pantalla de detalle).
  Future<GuildQuest?> getGuildQuestById(String questId);

  /// Registra una misión del pool como completada por el usuario.
  /// Idempotente: si ya existe la fila, no duplica.
  Future<void> markGuildQuestCompleted(String userId, String questId);

  /// Acepta una misión del pool del gremio, creando una `mission_instance`
  /// activa para el jugador. Valida que el rango del aventurero sea suficiente
  /// ([playerRank]) para el rango requerido de la misión. Devuelve null si la
  /// misión no existe, el rango no es suficiente o la cuota está llena.
  Future<MissionInstance?> acceptGuildQuest({
    required String userId,
    required String questId,
    required String playerRank,
  });

  /// Misiones colaborativas del gremio activas en la ventana temporal.
  Future<List<GuildMission>> getActiveGuildMissions();

  /// Incrementa el progreso colectivo de una misión del gremio.
  Future<bool> updateGuildMissionProgress(String missionId, int delta);

  /// Raid semanal: la misión colaborativa activa más reciente
  /// (expires_at > now). Devuelve null si no hay raid vigente.
  Future<Map<String, dynamic>?> getWeeklyRaid();

  /// Suma [amount] al progreso colectivo de la raid semanal (best-effort).
  Future<void> contributeToWeeklyRaid(String missionId, int amount);

  // ── Global Events ────────────────────────────────────────────────────────

  /// Eventos globales activos (ventana de tiempo).
  Future<List<GlobalEvent>> getActiveGlobalEvents();

  /// Progreso del jugador en un evento global.
  Future<Map<String, dynamic>?> getEventProgress(String userId, String eventId);
}
