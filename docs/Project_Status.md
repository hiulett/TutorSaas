# Project_Status — TutorSaas / Dungeon of English

> Fecha de corte: 2026-07-30 · **Fases 2–6 implementadas** (27/27 tareas del backlog completadas).

## Resumen ejecutivo

- **Compilación**: ✅ `flutter build apk --debug` OK. `flutter analyze`: 60 issues (infos/warnings), **0 errores**.
- **Tests**: ✅ **13/13** (`overflow_test` arreglado — T-001).
- **Repo**: UN SOLO commit (`8c1ef25`). Todo el trabajo de features está sin commitear.
  ⚠️ **PROHIBIDO** `git checkout`/`git restore` sobre Dart (regla AGENTS.md).
- **Graphify**: actualizado (4113 nodos / 4879 aristas) — fuente de arquitectura.
- **DB live (TutorSaas `sipiumfdpvnszthykyog`)**: read-only para DDL vía MCP; migraciones aplicadas por el usuario vía SQL Editor (RPCs economía, columnas idioma, mission engine 8 tablas + 29 plantillas).
- **Backlog**: `docs/BACKLOG.md` (27 tareas) · seguimiento visual `docs/TASK_BOARD.md` — **26/27 completadas**.

## Estado por fase (implementación)

| Fase | Estado | Tareas completadas |
|---|---|---|
| 2 — User Experience | ✅ Implementada | T-100 l10n en MaterialApp, T-101 persistir idioma, T-102 columnas idioma, T-103 Oracle conversacional, T-104 país (pendiente T-105 i18n strings) |
| 3 — Dashboard | ✅ Implementada | T-200 HUD central, T-201 mapa de mazmorras, T-202 Hunter Status refinado, T-203 accesos rápidos |
| 4 — Conversations | ✅ Implementada | T-300 header Oráculo (SSS), T-301 barra SegmentedBar, T-302 FloatingReward, T-303 tácticas |
| 5 — Missions | ✅ Implementada | T-400 repo gremio, T-401 repo eventos, T-402 progresión parcial, T-403 Mission Board en dashboard, T-404 rotación (SQL fn + edge fn local + lazy) |
| 6 — Economy | ✅ Implementada | T-500 fix claimDailyReward, T-501 inventario, T-502 battle pass, T-503 daily rewards modal, T-504 oro/fragmentos, T-505 loot, T-506 invocaciones↔IA, T-507 balance |
| Transversal | ✅ | T-001 fix overflow_test, T-002 fix voice room no-UUID |

## Archivos nuevos (Fase 2–6)
- `lib/features/onboarding/presentation/screens/oracle_conversation_screen.dart` + `providers/oracle_providers.dart`
- `lib/features/dashboard/presentation/widgets/hunter_hud_header.dart` + `screens/dungeon_map_screen.dart`
- `lib/features/economy/presentation/screens/{inventory,battle_pass}_screen.dart` + `widgets/daily_reward_modal.dart`
- `lib/features/conversation/domain/models/conversation_state.dart` (campos nuevos)
- `supabase/functions/missions-cron/index.ts` (edge function local)
- Migraciones SQL editor: `20260730_SQL_EDITOR_pendientes.sql`, `20260730_phase2_country_code.sql`, `20260730_economy_gold_fragments.sql`, `20260730_economy_balance.sql`, `20260730_mission_rotation.sql`

## Estado de DB live (verificado 2026-07-30)

| Objeto | Estado live |
|---|---|
| Tablas de economía (`player_inventory`, `player_daily_state`, `player_streaks`, `guild_quest_pool`, `player_completed_quests`, `guild_battle_pass`, `player_pergaminos`, `cosmetic_catalog`) | ✅ Existen |
| `oracle_questions` | ✅ Existe (7 preguntas) |
| Columnas `player_class`, `guild_role`, `total_gems`, `total_gold`, `equipped_title_code`, `last_active_date` en `user_language_profiles` | ✅ Existen |
| RPCs `add_xp`, `add_gems`, `spend_gems`, `increment_pergaminos_max` | ❌ **FALTAN** (script SQL Editor Parte B) |
| Columnas `ui_language`, `learning_language`, `ai_explanations_native` en `user_settings` | ❌ **FALTAN** (script SQL Editor Parte A) |
| Mission Engine (8 tablas + seed) | ❌ **FALTA** (script SQL Editor Parte C) |

## Estado por fase

| Fase | Carpeta docs | Estado | Implementación |
|---|---|---|---|
| 1 (base) | `00_…`–`06_…` + `adr/` | Analizada | Parcial (widgets core creados) |
| 2 — User Experience | `02_User_Experience/` | Documentada + Backlog | Pendiente: T-100..T-105 (l10n, idioma, Oracle, i18n) |
| 3 — Dashboard | `03_Dashboard/` | Documentada + Backlog | HunterStatus implementada; pendiente T-200..T-203 |
| 4 — Conversations | `04_Conversations/` | Documentada + Backlog | Core conversacional + tactics; pendiente T-300..T-303 |
| 5 — Missions | `05_Missions/` | Documentada + Backlog | Motor ~80% en código; DB pendiente (SQL Editor); pendiente T-400..T-404 |
| 6 — Economy | `06_Economy/` | Documentada + Backlog | Repo+shop; RPCs pendientes en DB; pendiente T-500..T-507 |
| 6 — Economy | `06_Economy/` | Documentada | Repo+shop; pendiente battle pass, inventario UI, oro, drops, integración IA |

## Métricas

- `flutter analyze`: 58 issues (infos/warnings tolerados, 0 errores).
- `flutter test`: 5 archivos; 1 test falla (preexistente).
- Módulos con interfaz abstracta: economía (`EconomyRepository`). Misiones usa repo concreto.
- Backlog: `docs/BACKLOG.md` (27 tareas) + seguimiento visual `docs/TASK_BOARD.md`.

## Riesgos principales

1. **R1**: Un solo commit + trabajo sin commitear → riesgo de pérdida total ante `checkout`/`clean`.
2. **R2**: Graphify refrescado (commit `c2fd749e`) — mantener `graphify update .` tras cambios.
3. **R3**: DB live read-only para DDL; migraciones pendientes (RPCs, idioma, mission engine)
   aplicables solo vía SQL Editor → script `20260730_SQL_EDITOR_pendientes.sql`.

## Siguientes pasos

1. Asegurar el trabajo (commit/backup) — P0.
2. Aplicar migraciones pendientes vía SQL Editor (script maestro) — P0 (T-000).
3. Implementar Fase 2 (T-100 l10n + T-101 idioma) — luego 3→4→5→6 según `Epic_Roadmap.md`.
