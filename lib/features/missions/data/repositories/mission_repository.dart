import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../../domain/models/mission_models.dart';
import '../../domain/repositories/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  final SupabaseClient _client;
  
  // Max misiones activas por jugador
  static const int maxActiveMissions = 10;
  // Max misiones del pool del gremio activas simultáneas (cuota propia)
  static const int maxActiveGuildQuests = 3;
  // Max misiones secretas activas simultáneas (reutiliza slots)
  static const int maxSecretMissions = 3;
  // Días para considerar una misión como "muy antigua" y eliminarla
  static const int oldMissionDays = 14;

  MissionRepositoryImpl(this._client);

  // ── Cleanup ────────────────────────────────────────────────────────────

  /// Elimina misiones antiguas para evitar saturación de la DB.
  /// Se llama antes de crear misiones nuevas.
  Future<void> cleanupOldMissions(String userId) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: oldMissionDays)).toIso8601String();

      // Eliminar instancias completadas muy antiguas (libera espacio)
      await _client
          .from('mission_instances')
          .delete()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .lt('completed_at', cutoff);

      // Eliminar instancias expiradas (nunca reclamadas)
      await _client
          .from('mission_instances')
          .delete()
          .eq('user_id', userId)
          .eq('status', 'expired');

      // Eliminar secret missions vencidas o completadas (recicla espacio)
      await _client
          .from('secret_missions')
          .delete()
          .eq('user_id', userId)
          .eq('is_completed', true);

      await _client
          .from('secret_missions')
          .delete()
          .eq('user_id', userId)
          .lt('expires_at', DateTime.now().toIso8601String());

      // Eliminar reward history antiguo
      await _client
          .from('reward_history')
          .delete()
          .eq('user_id', userId)
          .lt('claimed_at', cutoff);

      // Mantener solo las últimas 50 entradas
      final allRewards = await _client
          .from('reward_history')
          .select('id')
          .eq('user_id', userId)
          .order('claimed_at', ascending: false);

      if ((allRewards as List).length > 50) {
        final toDelete = allRewards.skip(50).map((r) => r['id'] as String).toList();
        for (final id in toDelete) {
          await _client.from('reward_history').delete().eq('id', id);
        }
      }
    } catch (_) {}
  }

  /// Verifica cuotas y hace cleanup antes de aceptar nueva misión.
  Future<bool> canAcceptMission(String userId, String missionType) async {
    await cleanupOldMissions(userId);

    final active = await getActiveMissions(userId);
    if (active.length >= maxActiveMissions) return false;

    // Para misiones secretas: reutilizar slots
    if (missionType == 'secret') {
      final secretCount = active.where((m) => m.missionType == 'secret').length;
      if (secretCount >= maxSecretMissions) return false;
    }

    return true;
  }

  // ── Templates ──────────────────────────────────────────────────────────

  Future<List<MissionTemplate>> getTemplates({String? type, String? cefrLevel}) async {
    try {
      var query = _client.from('mission_templates').select().eq('is_active', true);
      if (type != null) query = query.eq('mission_type', type);
      if (cefrLevel != null) {
        query = query.or('min_cefr_level.is.null,min_cefr_level.lte.$cefrLevel');
      }
      final data = await query.order('created_at');
      return (data as List).map((m) => MissionTemplate.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Instances ──────────────────────────────────────────────────────────

  Future<List<MissionInstance>> getActiveMissions(String userId) async {
    try {
      final data = await _client
          .from('mission_instances')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('started_at', ascending: false);
      return (data as List).map((m) => MissionInstance.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<MissionInstance>> getCompletedMissions(String userId, {int limit = 20}) async {
    try {
      final data = await _client
          .from('mission_instances')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .eq('is_reward_claimed', false)
          .order('completed_at', ascending: false)
          .limit(limit);
      return (data as List).map((m) => MissionInstance.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<MissionInstance?> acceptMission(String userId, MissionTemplate template) async {
    if (!(await canAcceptMission(userId, template.missionType))) return null;
    try {
      final data = await _client.from('mission_instances').insert({
        'user_id': userId,
        'template_id': template.id,
        'mission_type': template.missionType,
        'title': template.title,
        'description': template.description,
        'objective_type': template.objectiveType,
        'target_value': template.targetValue,
        'xp_reward': template.xpReward,
        'gem_reward': template.gemReward,
        'item_reward': template.itemReward,
        'status': 'active',
      }).select().single();
      return MissionInstance.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  /// Incrementa el progreso de una misión en [delta] unidades.
  /// Marca `completed` solo cuando se alcanza el target; de lo contrario
  /// persiste el progreso parcial en vivo (T-402).
  Future<bool> updateProgress(String instanceId, {int delta = 1}) async {
    try {
      final instance = await _client
          .from('mission_instances')
          .select('current_value, target_value, status, user_id, quest_id')
          .eq('id', instanceId)
          .maybeSingle();
      if (instance == null) return false;

      final current = (instance['current_value'] as num?)?.toInt() ?? 0;
      final target = (instance['target_value'] as num?)?.toInt() ?? 1;
      final next = (current + delta).clamp(0, target);
      final isDone = next >= target;
      final isAlreadyDone = instance['status'] == 'completed';

      await _client.from('mission_instances').update({
        'current_value': next,
        'status': isDone ? 'completed' : 'active',
        if (isDone && !isAlreadyDone) 'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', instanceId);

      // Si es una misión del pool del gremio y se acaba de completar,
      // regístrala en player_completed_quests (historial / ocultar del pool).
      if (isDone && !isAlreadyDone) {
        final questId = instance['quest_id'] as String?;
        final userId = instance['user_id'] as String?;
        if (questId != null && userId != null) {
          await markGuildQuestCompleted(userId, questId);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> claimReward(String instanceId, String userId) async {
    try {
      final instance = await _client
          .from('mission_instances')
          .select()
          .eq('id', instanceId)
          .maybeSingle();
      if (instance == null) return false;

      final baseXp = (instance['xp_reward'] as num?)?.toInt() ?? 0;
      final baseGems = (instance['gem_reward'] as num?)?.toInt() ?? 0;
      final multiplier = (instance['reward_multiplier'] as num?)?.toInt() ?? 1;
      final xp = baseXp * multiplier;
      final gems = baseGems * multiplier;

      // Mark as claimed
      await _client.from('mission_instances').update({
        'is_reward_claimed': true,
        'reward_multiplier': multiplier,
      }).eq('id', instanceId);

      // Add XP
      if (xp > 0) {
        await _client.rpc('add_xp', params: {'p_user_id': userId, 'p_amount': xp});
      }

      // Add gems
      if (gems > 0) {
        await _client.rpc('add_gems', params: {'p_user_id': userId, 'p_amount': gems});
      }

      // Record history
      await _client.from('reward_history').insert({
        'user_id': userId,
        'source_type': 'mission',
        'source_id': instanceId,
        'xp_earned': xp,
        'gems_earned': gems,
        'item_code': instance['item_reward'],
      });

      return true;
    } catch (_) {
      return false;
    }
  }

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
  }) async {
    try {
      final inventoryItem = await _client
          .from('player_inventory')
          .select('id, item_code')
          .eq('user_id', userId)
          .eq('item_code', itemCode)
          .maybeSingle();
      if (inventoryItem == null) return false;

      if (itemCode == 'mod_llave_ruta_secreta') {
        await createSecretMission(userId, {
          'title': 'Ruta Secreta del Oráculo',
          'description': 'El Oráculo te reveló un camino oculto. Complétalo para obtener su favor.',
          'objective_type': 'practice_session',
          'target_value': 1,
          'xp_reward': 150,
          'gem_reward': 30,
        });
      } else {
        final mission = await _client
            .from('mission_instances')
            .select('target_value')
            .eq('id', instanceId)
            .eq('user_id', userId)
            .maybeSingle();
        if (mission == null) return false;

        final target = (mission['target_value'] as num?)?.toInt() ?? 1;
        final Map<String, dynamic> update = {};

        switch (itemCode) {
          case 'mod_recompensa_x2':
            update['reward_multiplier'] = 2;
          case 'mod_piedra_facilidad':
            update['target_value'] = (target * 0.5).ceil();
          case 'mod_piedra_desafio':
            update['target_value'] = (target * 1.5).ceil();
            update['reward_multiplier'] = 2;
        }

        update['applied_modifier_code'] = itemCode;
        await _client.from('mission_instances').update(update).eq('id', instanceId);
      }

      // Consumir el item
      await _client.from('player_inventory').delete().eq('id', inventoryItem['id']);

      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Secret Missions ────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSecretMissions(String userId) async {
    try {
      final data = await _client
          .from('secret_missions')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> createSecretMission(String userId, Map<String, dynamic> missionData) async {
    try {
      // Reutilizar slots: si ya hay maxSecretMissions, sobreescribir la más antigua
      final existing = await _client
          .from('secret_missions')
          .select('id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final existingList = existing as List;
      if (existingList.length >= maxSecretMissions) {
        // Sobrescribir la más antigua
        final oldestId = existingList.first['id'] as String;
        await _client.from('secret_missions').update({
          'title': missionData['title'] ?? 'Misión Secreta',
          'description': missionData['description'] ?? '',
          'objective_type': missionData['objective_type'] ?? 'practice_session',
          'target_value': missionData['target_value'] ?? 1,
          'xp_reward': missionData['xp_reward'] ?? 100,
          'gem_reward': missionData['gem_reward'] ?? 10,
          'trigger_data': missionData['trigger_data'] ?? {},
          'is_completed': false,
          'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        }).eq('id', oldestId);
      } else {
        // Insertar nueva
        await _client.from('secret_missions').insert({
          'user_id': userId,
          'trigger_data': missionData['trigger_data'] ?? {},
          'title': missionData['title'] ?? 'Misión Secreta',
          'description': missionData['description'] ?? '',
          'objective_type': missionData['objective_type'] ?? 'practice_session',
          'target_value': missionData['target_value'] ?? 1,
          'xp_reward': missionData['xp_reward'] ?? 100,
          'gem_reward': missionData['gem_reward'] ?? 10,
        });
      }
    } catch (_) {}
  }

  // ── Emergency Missions ─────────────────────────────────────────────────

  Future<List<EmergencyMission>> getActiveEmergencies() async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _client
          .from('emergency_missions')
          .select()
          .eq('is_active', true)
          .gte('expires_at', now)
          .lte('starts_at', now)
          .order('created_at');
      return (data as List).map((m) => EmergencyMission.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Reward History ─────────────────────────────────────────────────────

  Future<List<RewardHistory>> getRecentRewards(String userId, {int limit = 20}) async {
    try {
      final data = await _client
          .from('reward_history')
          .select()
          .eq('user_id', userId)
          .order('claimed_at', ascending: false)
          .limit(limit);
      return (data as List).map((r) => RewardHistory.fromMap(r)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Batch Generation ───────────────────────────────────────────────────

  /// Genera misiones diarias para el usuario.
  /// Primero hace cleanup, luego asigna hasta completar el máximo permitido.
  Future<void> generateDailyMissions(String userId) async {
    await cleanupOldMissions(userId);

    final active = await getActiveMissions(userId);
    final activeTypes = active.map((m) => m.templateId).toSet();
    final slotsLeft = maxActiveMissions - active.length;

    if (slotsLeft <= 0) return;

    final templates = await getTemplates(type: 'daily');
    int assigned = 0;

    for (final tpl in templates) {
      if (assigned >= slotsLeft) break;
      if (!activeTypes.contains(tpl.id)) {
        final recent = active.where((m) => m.templateId == tpl.id).toList();
        if (recent.isEmpty) {
          await acceptMission(userId, tpl);
          assigned++;
        }
      }
    }
  }

  /// Elimina TODAS las misiones de un usuario excepto las activas actuales
  /// Útil para reset completo o cuando se necesita espacio urgente.
  Future<void> purgeAllOldMissions(String userId) async {
    try {
      await _client
          .from('mission_instances')
          .delete()
          .eq('user_id', userId)
          .neq('status', 'active');

      await _client
          .from('secret_missions')
          .delete()
          .eq('user_id', userId);

      await _client
          .from('reward_history')
          .delete()
          .eq('user_id', userId)
          .lt('claimed_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String());
    } catch (_) {}
  }

  // ── Guild Missions (colaborativas) ───────────────────────────────────────

  /// Pool de misiones del gremio (guild_quest_pool) activas.
  Future<List<GuildQuest>> getGuildQuestPool({
    int? languageId,
    String? excludeCompletedFor,
    int? limit,
  }) async {
    try {
      var query = _client
          .from('guild_quest_pool')
          .select()
          .eq('is_active', true);
      if (languageId != null) {
        query = query.eq('language_id', languageId);
      }
      if (excludeCompletedFor != null) {
        final done = await _client
            .from('player_completed_quests')
            .select('quest_id')
            .eq('user_id', excludeCompletedFor);
        final doneIds = (done as List).map((r) => r['quest_id']).toList();
        if (doneIds.isNotEmpty) {
          query = query.not('id', 'in', doneIds);
        }
      }
      final ordered = query.order('game_rank').order('quest_type');
      final data = limit != null
          ? await ordered.limit(limit!)
          : await ordered;
      return (data as List).map((m) => GuildQuest.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Misiones del pool ya completadas por el usuario (historial).
  Future<List<GuildQuest>> getCompletedGuildQuests(String userId, {int? languageId}) async {
    try {
      var query = _client
          .from('player_completed_quests')
          .select('quest_id')
          .eq('user_id', userId);
      final done = await query;
      final doneIds = (done as List).map((r) => r['quest_id'] as String).toList();
      if (doneIds.isEmpty) return [];

      var pool = _client
          .from('guild_quest_pool')
          .select()
          .inFilter('id', doneIds)
          .eq('is_active', true);
      if (languageId != null) {
        pool = pool.eq('language_id', languageId);
      }
      final data = await pool.order('game_rank').order('quest_type');
      return (data as List).map((m) => GuildQuest.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Obtiene una misión del pool del gremio por su id (para la pantalla de detalle).
  Future<GuildQuest?> getGuildQuestById(String questId) async {
    try {
      final data = await _client
          .from('guild_quest_pool')
          .select()
          .eq('id', questId)
          .eq('is_active', true)
          .maybeSingle();
      if (data == null) return null;
      return GuildQuest.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  /// Registra una misión del pool como completada (idempotente).
  Future<void> markGuildQuestCompleted(String userId, String questId) async {
    try {
      await _client.from('player_completed_quests').upsert(
        {
          'user_id': userId,
          'quest_id': questId,
          'completed_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id, quest_id',
      );
    } catch (_) {}
  }

  /// Acepta una misión del pool del gremio → mission_instance activa.
  /// Valida el rango del aventurero (gate) y la cuota de misiones del gremio.
  Future<MissionInstance?> acceptGuildQuest({
    required String userId,
    required String questId,
    required String playerRank,
  }) async {
    try {
      final quest = await _client
          .from('guild_quest_pool')
          .select()
          .eq('id', questId)
          .eq('is_active', true)
          .maybeSingle();
      if (quest == null) return null;
      final gq = GuildQuest.fromMap(quest);

      // Gate de rango: no se pueden aceptar misiones de rango superior al suyo.
      if (!CefrRank.canAcceptRank(playerRank, gq.gameRank)) return null;

      // Cuota ESPECÍFICA del gremio: máximo 3 misiones del pool activas a la
      // vez. NO compite con las misiones diarias automáticas (máx 10 globales).
      final guildActive = await _client
          .from('mission_instances')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'active')
          .not('quest_id', 'is', null);
      if ((guildActive as List).length >= maxActiveGuildQuests) return null;

      final data = await _client.from('mission_instances').insert({
        'user_id': userId,
        'quest_id': gq.id,
        'mission_type': gq.questType,
        'title': gq.title,
        'description': gq.description,
        'objective_type': gq.objectiveType,
        'target_value': gq.targetValue,
        'xp_reward': gq.xpReward,
        'gem_reward': gq.gemReward,
        'item_reward': gq.itemReward,
        'status': 'active',
      }).select().single();
      return MissionInstance.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  /// Misiones colaborativas del gremio activas en la ventana temporal.
  Future<List<GuildMission>> getActiveGuildMissions() async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _client
          .from('guild_collaborative_missions')
          .select()
          .eq('is_reward_claimed', false)
          .gte('expires_at', now)
          .lte('starts_at', now)
          .order('created_at');
      return (data as List).map((m) => GuildMission.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Incrementa el progreso colectivo de una misión del gremio.
  Future<bool> updateGuildMissionProgress(String missionId, int delta) async {
    try {
      final mission = await _client
          .from('guild_collaborative_missions')
          .select('current_value, target_value')
          .eq('id', missionId)
          .maybeSingle();
      if (mission == null) return false;

      final current = (mission['current_value'] as num?)?.toInt() ?? 0;
      final target = (mission['target_value'] as num?)?.toInt() ?? 1;
      final next = (current + delta).clamp(0, target);

      await _client
          .from('guild_collaborative_missions')
          .update({'current_value': next})
          .eq('id', missionId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Raid cooperativa semanal: la misión colaborativa vigente más reciente.
  Future<Map<String, dynamic>?> getWeeklyRaid() async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _client
          .from('guild_collaborative_missions')
          .select()
          .gt('expires_at', now)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('getWeeklyRaid error: $e');
      return null;
    }
  }

  /// Suma [amount] al progreso colectivo de la raid (best-effort, no bloquea).
  Future<void> contributeToWeeklyRaid(String missionId, int amount) async {
    try {
      final mission = await _client
          .from('guild_collaborative_missions')
          .select('current_value')
          .eq('id', missionId)
          .maybeSingle();
      if (mission == null) return;

      final current = (mission['current_value'] as num?)?.toInt() ?? 0;
      await _client
          .from('guild_collaborative_missions')
          .update({'current_value': current + amount})
          .eq('id', missionId);
    } catch (e) {
      debugPrint('contributeToWeeklyRaid error: $e');
    }
  }

  // ── Global Events ────────────────────────────────────────────────────────

  /// Eventos globales activos (ventana de tiempo).
  Future<List<GlobalEvent>> getActiveGlobalEvents() async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await _client
          .from('global_events')
          .select()
          .eq('is_active', true)
          .gte('expires_at', now)
          .lte('starts_at', now)
          .order('created_at');
      return (data as List).map((m) => GlobalEvent.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Progreso del jugador en un evento global.
  Future<Map<String, dynamic>?> getEventProgress(String userId, String eventId) async {
    try {
      final data = await _client
          .from('player_event_progress')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();
      return data == null ? null : Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }
}
