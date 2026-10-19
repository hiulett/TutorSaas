# Fase 5 — Known_Issues

> Problemas conocidos del Sistema de Misiones.

## Funcionalidad

| # | Issue | Impacto |
|---|---|---|
| K5-1 | `guild_collaborative_missions` y `global_events` sin repositorio/UI en Flutter | Tipos de misión presentes en DB pero inaccesibles desde la app |
| K5-2 | `updateProgress` marca `completed` directamente, sin progresión parcial | El jugador no ve progreso incremental en vivo |
| K5-3 | Rotación/timers dependen de cron/edge function no implementada | Las misiones diarias/emergencias no se generan automáticamente |
| K5-4 | `mission_board_widget` integración con dashboard sin verificar | El board puede no estar visible |

## DB

| # | Issue | Impacto |
|---|---|---|
| K5-5 | RPC `add_xp`/`add_gems` y FK `users` — verificar contra el live | claimReward puede fallar silenciosamente |
| K5-6 | `UNIQUE(user_id, template_id, mission_type)` puede impedir re-petición tras cooldown | Rotación diaria limitada |

## QA / Tests

| # | Issue | Impacto |
|---|---|---|
| K5-7 | Sin test dedicado del motor de misiones | Riesgo de regresión no detectada |
