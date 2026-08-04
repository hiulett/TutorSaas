# Fase 5 — Tasks

> Lista de tareas y estado. ⬜ pendiente · 🔄 en curso · ✅ completado · ❌ bloqueado

## P0 — Gremio
- ⬜ Repositorio para `guild_collaborative_missions`.
- ⬜ Provider + UI en social hall.

## P0 — Eventos globales
- ⬜ Repositorio para `global_events` + `player_event_progress`.
- ⬜ Provider + indicador de evento.

## P1 — Progresión
- ✅ CRUD básico (accept/update/claim).
- ⬜ Progresión parcial incremental en `updateProgress`.

## P1 — Mission Board
- ✅ `mission_board_widget` (usa SegmentedBar).
- ⬜ Verificar integración con dashboard (tab MAZMORRAS).
- ⬜ Filtros por tipo.

## P1 — Rotación/timers
- ⬜ Edge function/cron para `generateDailyMissions` y rotación de emergencias.
- ⬜ Timers locales de expiración.

## P2 — Economía
- ✅ Claim → `add_xp`/`add_gems` (RPC) + reward_history.
- ⬜ Sincronizar item_reward con inventario (Fase 6).

## QA
- ⬜ `flutter analyze` 0 errores; `flutter test` verde.
- ⬜ Verificación de RPCs `add_xp`/`add_gems` en DB.
