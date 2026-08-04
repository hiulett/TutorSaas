# Fase 5 — Implementation_Plan

> Plan de implementación (PRIORIZADO). Sin implementación realizada aún — documentación.

## Objetivo

Completar el sistema de misiones: cubrir todos los tipos, rotación/timers, Mission Board
integrado y persistencia total en DB.

## Pasos

### 5.1 Misiones del gremio (P0)
1. Repositorio para `guild_collaborative_missions` (get activas, progreso global, claim).
2. Provider + UI en el social hall.

### 5.2 Eventos globales y player_event_progress (P0)
1. Repositorio para `global_events` + progreso del jugador.
2. Provider + indicador de evento en dashboard.

### 5.3 Progresión parcial (P1)
1. `updateProgress` debe soportar progresión incremental (current_value + delta) en vez de
   solo saltar a completed.

### 5.4 Mission Board integrado (P1)
1. Verificar `mission_board_widget` y conectarlo al dashboard (tab MAZMORRAS).
2. Filtros por tipo (diarias/secretas/emergencia/gremio).

### 5.5 Rotación y timers (P1)
1. Edge function/cron para `generateDailyMissions` diario y rotación de emergencias.
2. Timers locales para expiración visible.

### 5.6 Integración con economía (P2)
1. Claim → `add_xp`/`add_gems` (ya existe) y sincronizar con inventario de items.

## Criterios de terminación

- `flutter analyze` 0 errores; `flutter test` verde.
- Todos los tipos de misión navegables y persistidos.
- Claim de recompensas integrado con economía (RPC add_xp/add_gems).
