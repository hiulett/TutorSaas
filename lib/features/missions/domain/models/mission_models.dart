import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MissionTemplate {
  final String id;
  final String missionType;
  final String title;
  final String description;
  final String objectiveType;
  final int targetValue;
  final int xpReward;
  final int gemReward;
  final String? itemReward;
  final String? minCefrLevel;
  final String? maxCefrLevel;
  final bool isActive;
  final int cooldownHours;

  const MissionTemplate({
    required this.id,
    required this.missionType,
    required this.title,
    this.description = '',
    required this.objectiveType,
    this.targetValue = 1,
    this.xpReward = 50,
    this.gemReward = 0,
    this.itemReward,
    this.minCefrLevel,
    this.maxCefrLevel,
    this.isActive = true,
    this.cooldownHours = 0,
  });

  factory MissionTemplate.fromMap(Map<String, dynamic> m) => MissionTemplate(
    id: m['id'] as String? ?? '',
    missionType: m['mission_type'] as String? ?? 'daily',
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    objectiveType: m['objective_type'] as String? ?? 'speak_minutes',
    targetValue: (m['target_value'] as num?)?.toInt() ?? 1,
    xpReward: (m['xp_reward'] as num?)?.toInt() ?? 50,
    gemReward: (m['gem_reward'] as num?)?.toInt() ?? 0,
    itemReward: m['item_reward'] as String?,
    minCefrLevel: m['min_cefr_level'] as String?,
    maxCefrLevel: m['max_cefr_level'] as String?,
    isActive: m['is_active'] as bool? ?? true,
    cooldownHours: (m['cooldown_hours'] as num?)?.toInt() ?? 0,
  );
}

class MissionInstance {
  final String id;
  final String userId;
  final String? templateId;

  /// ID de la misión del pool del gremio que originó esta instancia
  /// (guild_quest_pool.id). Null si la misión no viene del pool.
  final String? questId;
  final String missionType;
  final String title;
  final String description;
  final String objectiveType;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final int gemReward;
  final String? itemReward;
  final String status;
  final bool isRewardClaimed;
  final DateTime? expiresAt;
  final DateTime startedAt;
  final DateTime? completedAt;

  const MissionInstance({
    required this.id,
    required this.userId,
    this.templateId,
    this.questId,
    required this.missionType,
    required this.title,
    this.description = '',
    required this.objectiveType,
    this.targetValue = 1,
    this.currentValue = 0,
    this.xpReward = 50,
    this.gemReward = 0,
    this.itemReward,
    this.status = 'active',
    this.isRewardClaimed = false,
    this.expiresAt,
    required this.startedAt,
    this.completedAt,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory MissionInstance.fromMap(Map<String, dynamic> m) => MissionInstance(
    id: m['id'] as String? ?? '',
    userId: m['user_id'] as String? ?? '',
    templateId: m['template_id'] as String?,
    questId: m['quest_id'] as String?,
    missionType: m['mission_type'] as String? ?? 'daily',
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    objectiveType: m['objective_type'] as String? ?? 'speak_minutes',
    targetValue: (m['target_value'] as num?)?.toInt() ?? 1,
    currentValue: (m['current_value'] as num?)?.toInt() ?? 0,
    xpReward: (m['xp_reward'] as num?)?.toInt() ?? 50,
    gemReward: (m['gem_reward'] as num?)?.toInt() ?? 0,
    itemReward: m['item_reward'] as String?,
    status: m['status'] as String? ?? 'active',
    isRewardClaimed: m['is_reward_claimed'] as bool? ?? false,
    expiresAt: m['expires_at'] != null ? DateTime.parse(m['expires_at'] as String) : null,
    startedAt: m['started_at'] != null ? DateTime.parse(m['started_at'] as String) : DateTime.now(),
    completedAt: m['completed_at'] != null ? DateTime.parse(m['completed_at'] as String) : null,
  );

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'template_id': templateId,
    'mission_type': missionType,
    'title': title,
    'description': description,
    'objective_type': objectiveType,
    'target_value': targetValue,
    'current_value': currentValue,
    'xp_reward': xpReward,
    'gem_reward': gemReward,
    'item_reward': itemReward,
    'status': status,
  };
}

class EmergencyMission {
  final String id;
  final String title;
  final String description;
  final String objectiveType;
  final int targetValue;
  final int xpReward;
  final int gemReward;
  final String? itemReward;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool isActive;

  const EmergencyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.objectiveType,
    this.targetValue = 1,
    this.xpReward = 200,
    this.gemReward = 50,
    this.itemReward,
    required this.startsAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory EmergencyMission.fromMap(Map<String, dynamic> m) => EmergencyMission(
    id: m['id'] as String? ?? '',
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    objectiveType: m['objective_type'] as String? ?? 'practice_session',
    targetValue: (m['target_value'] as num?)?.toInt() ?? 1,
    xpReward: (m['xp_reward'] as num?)?.toInt() ?? 200,
    gemReward: (m['gem_reward'] as num?)?.toInt() ?? 50,
    itemReward: m['item_reward'] as String?,
    startsAt: m['starts_at'] != null ? DateTime.parse(m['starts_at'] as String) : DateTime.now(),
    expiresAt: m['expires_at'] != null ? DateTime.parse(m['expires_at'] as String) : DateTime.now(),
    isActive: m['is_active'] as bool? ?? true,
  );
}

/// Misión colaborativa del gremio (progreso global compartido).
class GuildMission {
  final String id;
  final String title;
  final String description;
  final String objectiveType;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final int gemReward;
  final String? itemReward;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool isRewardClaimed;

  const GuildMission({
    required this.id,
    required this.title,
    this.description = '',
    required this.objectiveType,
    this.targetValue = 1,
    this.currentValue = 0,
    this.xpReward = 500,
    this.gemReward = 100,
    this.itemReward,
    required this.startsAt,
    required this.expiresAt,
    this.isRewardClaimed = false,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentValue >= targetValue;
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  factory GuildMission.fromMap(Map<String, dynamic> m) => GuildMission(
    id: m['id'] as String? ?? '',
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    objectiveType: m['objective_type'] as String? ?? 'speak_minutes',
    targetValue: (m['target_value'] as num?)?.toInt() ?? 1,
    currentValue: (m['current_value'] as num?)?.toInt() ?? 0,
    xpReward: (m['xp_reward'] as num?)?.toInt() ?? 500,
    gemReward: (m['gem_reward'] as num?)?.toInt() ?? 100,
    itemReward: m['item_reward'] as String?,
    startsAt: m['starts_at'] != null ? DateTime.parse(m['starts_at'] as String) : DateTime.now(),
    expiresAt: m['expires_at'] != null ? DateTime.parse(m['expires_at'] as String) : DateTime.now(),
    isRewardClaimed: m['is_reward_claimed'] as bool? ?? false,
  );
}

/// Misión del pool de misiones del gremio (tabla guild_quest_pool).
class GuildQuest {
  final String id;
  final String questType;
  final String title;
  final String description;
  final String objectiveType;
  final int targetValue;
  final int xpReward;
  final int gemReward;
  final String? itemReward;
  final String? minCefrLevel;
  final String? maxCefrLevel;

  /// Rango mínimo del gremio requerido para aceptar la misión (E, D, C, B, A, S...).
  final String? gameRank;

  /// Categoría de la misión (combate, magia, velocidad, apoyo, supervivencia...).
  final String? category;

  /// Idioma del contenido (1=en, 2=fr, 3=de, 4=it). Null en datos legacy.
  final int? languageId;

  final bool isActive;

  const GuildQuest({
    required this.id,
    required this.questType,
    required this.title,
    this.description = '',
    required this.objectiveType,
    this.targetValue = 10,
    this.xpReward = 50,
    this.gemReward = 0,
    this.itemReward,
    this.minCefrLevel,
    this.maxCefrLevel,
    this.gameRank,
    this.category,
    this.languageId,
    this.isActive = true,
  });

  factory GuildQuest.fromMap(Map<String, dynamic> m) => GuildQuest(
    id: m['id'] as String? ?? '',
    questType: m['quest_type'] as String? ?? 'daily',
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    objectiveType: m['objective_type'] as String? ?? 'speak_minutes',
    targetValue: (m['target_value'] as num?)?.toInt() ?? 10,
    xpReward: (m['xp_reward'] as num?)?.toInt() ?? 50,
    gemReward: (m['gem_reward'] as num?)?.toInt() ?? 0,
    itemReward: m['item_reward'] as String?,
    minCefrLevel: m['min_cefr_level'] as String?,
    maxCefrLevel: m['max_cefr_level'] as String?,
    gameRank: m['game_rank'] as String?,
    category: m['category'] as String?,
    languageId: (m['language_id'] as num?)?.toInt(),
    isActive: m['is_active'] as bool? ?? true,
  );
}

/// Evento global temporal con progreso del jugador.
class GlobalEvent {  final String id;
  final String title;
  final String description;
  final String eventType;
  final DateTime startsAt;
  final DateTime expiresAt;
  final Map<String, dynamic> rewardData;
  final bool isActive;

  const GlobalEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.eventType,
    required this.startsAt,
    required this.expiresAt,
    this.rewardData = const {},
    this.isActive = true,
  });

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get isRunning => !isExpired && startsAt.isBefore(DateTime.now());

  factory GlobalEvent.fromMap(Map<String, dynamic> m) => GlobalEvent(
    id: m['id'] as String? ?? '',
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    eventType: m['event_type'] as String? ?? '',
    startsAt: m['starts_at'] != null ? DateTime.parse(m['starts_at'] as String) : DateTime.now(),
    expiresAt: m['expires_at'] != null ? DateTime.parse(m['expires_at'] as String) : DateTime.now(),
    rewardData: Map<String, dynamic>.from(m['reward_data'] as Map? ?? const {}),
    isActive: m['is_active'] as bool? ?? true,
  );
}

class RewardHistory {
  final String id;
  final String sourceType;
  final int xpEarned;
  final int gemsEarned;
  final String? itemCode;
  final DateTime claimedAt;

  const RewardHistory({
    required this.id,
    required this.sourceType,
    this.xpEarned = 0,
    this.gemsEarned = 0,
    this.itemCode,
    required this.claimedAt,
  });

  factory RewardHistory.fromMap(Map<String, dynamic> m) => RewardHistory(
    id: m['id'] as String? ?? '',
    sourceType: m['source_type'] as String? ?? '',
    xpEarned: (m['xp_earned'] as num?)?.toInt() ?? 0,
    gemsEarned: (m['gems_earned'] as num?)?.toInt() ?? 0,
    itemCode: m['item_code'] as String?,
    claimedAt: m['claimed_at'] != null ? DateTime.parse(m['claimed_at'] as String) : DateTime.now(),
  );
}

/// Returns a real-world scenario context for a mission based on its title/type
/// This ensures every mission is grounded in practical, real-life English usage.
String missionScenarioContext(String missionType, String title) {
  // Map common mission keywords to real-world scenarios
  if (title.contains('Café') || title.contains('Coffee') || title.contains('Restaurant') || title.contains('Comida') || title.contains('Food')) {
    return 'Estás en un café/restaurante en un país de habla inglesa. Necesitas ordenar comida y hacer pequeña conversación con el mesero.';
  }
  if (title.contains('Dirección') || title.contains('Directions') || title.contains('Viaje') || title.contains('Travel') || title.contains('Aeropuerto') || title.contains('Airport')) {
    return 'Estás viajando por un país de habla inglesa. Necesitas pedir indicaciones, comprar boletos o hacer check-in.';
  }
  if (title.contains('Entrevista') || title.contains('Interview') || title.contains('Trabajo') || title.contains('Job') || title.contains('Negocio') || title.contains('Business')) {
    return 'Estás en un entorno profesional. Necesitas causar una buena impresión y comunicar tus ideas claramente.';
  }
  if (title.contains('Teléfono') || title.contains('Phone') || title.contains('Llamada') || title.contains('Call')) {
    return 'Necesitas hacer una llamada telefónica. No puedes ver a la persona, así que tu pronunciación debe ser clara.';
  }
  if (title.contains('Médico') || title.contains('Doctor') || title.contains('Hospital') || title.contains('Health') || title.contains('Salud')) {
    return 'Estás en una consulta médica. Necesitas describir tus síntomas y entender las indicaciones del doctor.';
  }
  if (title.contains('Debate') || title.contains('Debate') || title.contains('Opinión') || title.contains('Opinion') || title.contains('Discutir') || title.contains('Discuss')) {
    return 'Estás participando en una discusión grupal. Necesitas expresar tu opinión y responder a otros puntos de vista.';
  }
  if (title.contains('Presentación') || title.contains('Presentation') || title.contains('Hablar en público') || title.contains('Public')) {
    return 'Estás dando una presentación frente a una audiencia. Necesitas hablar con claridad y confianza.';
  }
  if (title.contains('Social') || title.contains('Fiesta') || title.contains('Party') || title.contains('Amigos') || title.contains('Friends') || title.contains('Conocer')) {
    return 'Estás en un evento social con hablantes nativos de inglés. Necesitas hacer small talk y conectar con nuevas personas.';
  }
  // Default: práctica general de conversación
  return 'Estás en una situación cotidiana donde necesitas comunicarte en inglés. Relájate y habla naturalmente.';
}

/// Icons for mission types
String missionTypeIcon(String type) {
  switch (type) {
    case 'daily': return '📅';
    case 'weekly': return '📆';
    case 'secondary': return '📋';
    case 'secret': return '🔮';
    case 'emergency': return '⚡';
    case 'guild': return '🏰';
    case 'collaborative': return '👥';
    case 'event': return '🌍';
    default: return '📜';
  }
}

/// Color for mission types
Color missionTypeColor(String type) {
  switch (type) {
    case 'daily': return AppColors.manaCyan;
    case 'weekly': return AppColors.royalGold;
    case 'secondary': return AppColors.emeraldGreen;
    case 'secret': return AppColors.runeViolet;
    case 'emergency': return AppColors.crimsonRed;
    case 'guild': return AppColors.guildAmber;
    case 'collaborative': return AppColors.collabBlue;
    case 'event': return AppColors.manaCyan;
    default: return AppColors.manaCyan;
  }
}
