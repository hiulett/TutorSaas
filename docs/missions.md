# Misiones — Dungeon of English

> Documento maestro de misiones. Sincronizado: 2026-07-30 (Fases 5, 7, 9).

## Arquitectura
- **Motor**: `lib/features/missions/` (models, repo, providers, widgets).
- **DB**: 8 tablas (`mission_templates`, `mission_instances`, `secret_missions`, `emergency_missions`, `global_events`, `player_event_progress`, `guild_collaborative_missions`, `reward_history`) + `guild_quest_pool`.

## Tipos de misión
| Tipo | Tabla | Estado |
|---|---|---|
| Diarias/semanales | mission_templates/instances | ✅ seed 29 plantillas |
| Secretas (IA) | secret_missions | ✅ repo |
| Emergencias | emergency_missions | ✅ repo + provider |
| Colaborativas (gremio) | guild_collaborative_missions | ✅ repo T-400 |
| Eventos globales | global_events + player_event_progress | ✅ repo T-401 |
| Pool del gremio | guild_quest_pool | ✅ quest board G-C |

## Flujo
- **Rotación**: `rotate_daily_missions()` (SQL, edge function `missions-cron` local, generación lazy en cliente).
- **Progresión**: `updateProgress(delta)` incremental (T-402) — no salta a completed.
- **Recompensas**: `claimReward` respeta `reward_multiplier` (MM-02); añade XP/gemas + history.
- **Modificadores** (Fase 9): `applyMissionModifier` — recompensa x2, facilidad (target/2), desafío (target×1.5 + x2), llave de ruta secreta.

## UI
- Mission Board en dashboard (T-403) con SegmentedBar.
- Guild Quest Board en el Gran Salón (G-C) con filtros.

## Economía asociada
- XP → `add_xp` · Gemas → `add_gems` · Fragmentos → `add_fragments` (loot conversaciones).
- Cuotas: 10 misiones activas, 3 secretas.
