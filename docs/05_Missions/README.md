# Fase 5 — Sistema de Misiones

> Estado: **Documentación** (análisis y plan). Sin cambios de código en esta fase.
> Carpetas de referencia: `lib/features/missions/`, `supabase/migrations/20260730_mission_engine.sql`.

## Resumen

Motor de misiones completo: principales, recomendadas, IA/secretas, gremio, temporales,
diarias, emergencia. Persistencia en DB, rotación, timers, Mission Board e integración
con la economía.

## Estado actual

- **Modelos** (`mission_models.dart`): `MissionTemplate`, `MissionInstance`, `EmergencyMission`,
  `RewardHistory` + helpers (`missionScenarioContext`, `missionTypeIcon`, `missionTypeColor`).
- **Repositorio** (`mission_repository.dart`, 358 líneas): cleanup, cuotas (max 10 activas /
  3 secretas), templates, instancias, secretas, emergencias, rewards, generación diaria,
  purge total.
- **Providers** (`mission_providers.dart`): `activeMissions`, `completedMissions`,
  `dailyTemplates`, `secretMissions`, `emergencyMissions`, `recentRewards`.
- **Widget**: `mission_board_widget.dart` (usa `SegmentedBar`).
- **DB**: migración `20260730_mission_engine.sql` — 8 tablas + seed (~30 plantillas) + índices
  + RLS + Realtime.

## Documentos

| Documento | Contenido |
|---|---|
| [Analysis.md](Analysis.md) | Análisis del motor de misiones |
| [Implementation_Plan.md](Implementation_Plan.md) | Plan de implementación |
| [Architecture.md](Architecture.md) | Arquitectura del sistema de misiones |
| [Database.md](Database.md) | Esquema de DB de misiones |
| [Tasks.md](Tasks.md) | Tareas y estado |
| [QA_Report.md](QA_Report.md) | Reporte de QA |
| [Recovery.md](Recovery.md) | Recuperación/regresiones |
| [Known_Issues.md](Known_Issues.md) | Problemas conocidos |
| [Change_Log.md](Change_Log.md) | Registro de cambios |
