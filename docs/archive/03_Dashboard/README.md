# Fase 3 — Dashboard del Aventurero

> Estado: **Documentación** (análisis y plan). Sin cambios de código en esta fase.
> Carpetas de referencia: `lib/features/dashboard/`, `lib/core/widgets/`, `PlantillaHtml/hunter_control_center_dashboard/`.

## Resumen

Dashboard definitivo, unificación Dashboard + Guild, Hunter Status, HUD, estadísticas,
navegación, accesos rápidos e indicadores visuales según las PlantillasHTML.

## Estado actual

- **DashboardScreen** (2018 líneas) con 4 tabs: MAZMORRAS / GUILD / ESTADO / CONFIG.
- **HunterStatusScreen** (`/hunter-status`, 316 líneas): stats STR/INT/DEX/LUK, pool de
  puntos, títulos equipados, guardado en `users.bio`, RpgAvatar, GlassCard.
- **Widgets del dashboard**: `ai_pick_hero_card`, `completed_lessons_history_list`,
  `daily_quests_widget`, `league_leaderboard_widget`, `learning_path_roadmap`,
  `lesson_preview_sheet`, `next_recommended_lesson_hero`, `recommended_lessons_hub`,
  `status_window_modal`.
- **Core widgets**: `GlassCard`, `SegmentedBar`, `AnimatedCounter`, `FloatingReward`,
  `QuestCard`, `SystemWindow`, `RpgAvatar`, `CyberManhwaBackground`, `ManaMeterWidget`.

## Documentos

| Documento | Contenido |
|---|---|
| [Analysis.md](Analysis.md) | Análisis del dashboard y estado del cazador |
| [Implementation_Plan.md](Implementation_Plan.md) | Plan de implementación |
| [Architecture.md](Architecture.md) | Arquitectura del módulo dashboard |
| [Database.md](Database.md) | Esquema y datos del dashboard |
| [Tasks.md](Tasks.md) | Tareas y estado |
| [QA_Report.md](QA_Report.md) | Reporte de QA |
| [Recovery.md](Recovery.md) | Recuperación/regresiones |
| [Known_Issues.md](Known_Issues.md) | Problemas conocidos |
| [Change_Log.md](Change_Log.md) | Registro de cambios |
