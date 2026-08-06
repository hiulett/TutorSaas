import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/i18n/language_settings.dart';
import '../../data/repositories/mission_repository.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/models/mission_models.dart';

/// Fecha en formato YYYY-MM-DD (zona local) para claves de determinismo diario.
String _dateKey(DateTime date) {
  final d = date.toLocal();
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$month-$day';
}

/// Índice estable de la misión diaria: hash simple de "$userId-$fecha"
/// sobre el catálogo, de modo que el mismo día siempre seleccione la misma misión.
int _dailySeedIndex(String userId, String dateKey, int catalogLength) {
  if (catalogLength <= 0) return 0;
  var sum = 0;
  for (final unit in '$userId-$dateKey'.codeUnits) {
    sum += unit;
  }
  return sum % catalogLength;
}

/// Catálogo local fijo de eventos semanales (sin depender de la DB).
/// Se rota cada semana usando el número de semana ISO del año.
const List<Map<String, String>> _weeklyEvents = [
  {
    'name': 'SEMANA DEL VOCABULARIO',
    'bonus_desc': 'Bonus de XP en misiones de vocabulario',
    'icon_emoji': '📚',
  },
  {
    'name': 'SEMANA DE LA FLUIDEZ',
    'bonus_desc': 'Bonus en precisión y fluidez al hablar',
    'icon_emoji': '🎯',
  },
  {
    'name': 'SEMANA DE LA RAFAGA',
    'bonus_desc': 'Bonus en racha diaria y sesiones consecutivas',
    'icon_emoji': '⚡',
  },
  {
    'name': 'SEMANA DEL GREMIO',
    'bonus_desc': 'Bonus en misiones colaborativas del gremio',
    'icon_emoji': '🤝',
  },
  {
    'name': 'SEMANA DEL DRAGÓN',
    'bonus_desc': 'Jefe de vocabulario con recompensas especiales',
    'icon_emoji': '🐉',
  },
];

/// Número de semana ISO 8601 del año para [date] (1..53), calculado en UTC
/// para evitar desfases por horario de verano. El jueves de la semana define
/// el año de referencia, y la semana 1 es la que contiene el 4 de enero.
int _isoWeekNumber(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final thursday = DateTime.utc(d.year, d.month, d.day + (DateTime.thursday - d.weekday));
  final jan4 = DateTime.utc(thursday.year, 1, 4);
  final week1Start = jan4.add(Duration(days: 1 - jan4.weekday));
  return thursday.difference(week1Start).inDays ~/ 7 + 1;
}

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MissionRepositoryImpl(client);
});

final activeMissionsProvider = FutureProvider.autoDispose<List<MissionInstance>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(missionRepositoryProvider);
  final missions = await repo.getActiveMissions(user.id);

  // MIS-02 · Determinismo por día: si hoy ya existe una misión diaria
  // (activa o completada), se respeta su estado y NO se regenera.
  final today = _dateKey(DateTime.now());
  final dailyToday = missions
      .where((m) => m.missionType == 'daily' && _dateKey(m.startedAt) == today)
      .toList();
  if (dailyToday.isNotEmpty) return missions;

  final completedToday = await repo.getCompletedMissions(user.id);
  final hasCompletedDailyToday = completedToday.any(
    (m) => m.missionType == 'daily' && _dateKey(m.completedAt ?? m.startedAt) == today,
  );
  if (hasCompletedDailyToday) return missions;

  // Generación determinista: una única misión diaria por (userId, fecha).
  final templates = await repo.getTemplates(type: 'daily');
  if (templates.isEmpty) {
    // Fallback legacy (catálogo vacío o DB no disponible).
    await repo.generateDailyMissions(user.id);
    return repo.getActiveMissions(user.id);
  }
  final dailyTemplate = templates[_dailySeedIndex(user.id, today, templates.length)];
  final created = await repo.acceptMission(user.id, dailyTemplate);
  if (created != null) return [...missions, created];
  return repo.getActiveMissions(user.id);
});

final completedMissionsProvider = FutureProvider.autoDispose<List<MissionInstance>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getCompletedMissions(user.id);
});

final dailyTemplatesProvider = FutureProvider.autoDispose<List<MissionTemplate>>((ref) async {
  return ref.watch(missionRepositoryProvider).getTemplates(type: 'daily');
});

final secretMissionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getSecretMissions(user.id);
});

final emergencyMissionsProvider = FutureProvider.autoDispose<List<EmergencyMission>>((ref) async {
  return ref.watch(missionRepositoryProvider).getActiveEmergencies();
});

final recentRewardsProvider = FutureProvider.autoDispose<List<RewardHistory>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getRecentRewards(user.id);
});

final guildMissionsProvider = FutureProvider.autoDispose<List<GuildMission>>((ref) async {
  return ref.watch(missionRepositoryProvider).getActiveGuildMissions();
});

final guildQuestPoolProvider = FutureProvider.autoDispose<List<GuildQuest>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final langSettings = ref.watch(userLanguageProvider);
  final langId = _languageCodeToId(langSettings.learningLanguage);
  // Excluye las ya completadas por el usuario y muestra solo 3 (rotación):
  // al completarse se ocultan y aparecen las siguientes.
  return ref.watch(missionRepositoryProvider).getGuildQuestPool(
        languageId: langId,
        excludeCompletedFor: user.id,
        limit: 3,
      );
});

/// Misiones del pool completadas por el usuario (filtro "cumplidas").
final completedGuildQuestsProvider = FutureProvider.autoDispose<List<GuildQuest>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final langSettings = ref.watch(userLanguageProvider);
  final langId = _languageCodeToId(langSettings.learningLanguage);
  return ref.watch(missionRepositoryProvider).getCompletedGuildQuests(user.id, languageId: langId);
});

/// Mapea el código de idioma de aprendizaje de la app (en/fr/de/it) al
/// language_id de la BD (1..4). Fallback a 1 (en).
int _languageCodeToId(String code) {
  switch (code.toLowerCase()) {
    case 'fr':
      return 2;
    case 'de':
      return 3;
    case 'it':
      return 4;
    default:
      return 1;
  }
}

final globalEventsProvider = FutureProvider.autoDispose<List<GlobalEvent>>((ref) async {
  return ref.watch(missionRepositoryProvider).getActiveGlobalEvents();
});

/// Evento semanal en curso, estable por semana ISO: `semana % 5` rota el
/// catálogo local cada semana. No toca la DB.
final weeklyEventProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final week = _isoWeekNumber(DateTime.now());
  return _weeklyEvents[week % _weeklyEvents.length];
});

/// Vista derivada del evento semanal expuesta como un objeto Map simple
/// {name, bonus_desc, icon_emoji} para consumo directo del UI.
final weeklyEventDetailsProvider = weeklyEventProvider.select((e) => e);

/// Raid cooperativa semanal (boss de vocabulario) con progreso colectivo.
/// Usa la misión colaborativa vigente en la DB; si no existe, presenta el
/// evento semanal (weeklyEventProvider) como raid por defecto.
final weeklyRaidProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final raid = await ref.watch(missionRepositoryProvider).getWeeklyRaid();
  if (raid != null) return raid;

  final event = await ref.watch(weeklyEventProvider.future);
  return {
    'title': 'RAID: ${event['name']}',
    'description': event['bonus_desc'],
    'current_value': 0,
    'target_value': 100,
    'reward_type': 'gems',
    'reward_amount': 50,
  };
});
