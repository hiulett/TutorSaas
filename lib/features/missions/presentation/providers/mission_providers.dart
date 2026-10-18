import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/repositories/mission_repository.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/models/mission_models.dart';

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

final completedMissionsProvider = FutureProvider.autoDispose<List<MissionInstance>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(missionRepositoryProvider).getCompletedMissions(user.id);
});

/// Misiones diarias activas del usuario (mission_instances con mission_type='daily').
/// Se conecta a la DB real; se invalida al reclamar una recompensa.
final dailyMissionsProvider = FutureProvider.autoDispose<List<MissionInstance>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  ref.watch(dashboardRefreshProvider);
  final missions = await ref.watch(missionRepositoryProvider).getActiveMissions(user.id);
  return missions.where((m) => m.missionType == 'daily').toList();
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
