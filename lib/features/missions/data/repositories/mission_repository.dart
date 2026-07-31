import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/mission_models.dart';

class MissionRepository {
  final SupabaseClient _client;
  
  // Max misiones activas por jugador
  static const int maxActiveMissions = 10;
  // Max misiones secretas activas simultáneas (reutiliza slots)
  static const int maxSecretMissions = 3;
  // Días para considerar una misión como "muy antigua" y eliminarla
  static const int oldMissionDays = 14;

  MissionRepository(this._client);

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

  Future<bool> updateProgress(String instanceId, int newValue) async {
    try {
      await _client.from('mission_instances').update({
        'current_value': newValue,
        'status': 'completed', // mark completed when progress reaches target
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', instanceId);
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

      final xp = (instance['xp_reward'] as num?)?.toInt() ?? 0;
      final gems = (instance['gem_reward'] as num?)?.toInt() ?? 0;

      // Mark as claimed
      await _client.from('mission_instances').update({
        'is_reward_claimed': true,
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
}
