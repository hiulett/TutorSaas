# Fase 6 — Database

> Esquema de DB de la Economía (migración `20260730_economy_and_ia_system.sql`).

## Tablas

| Tabla | Uso |
|---|---|
| `player_inventory` | Items del jugador (UNIQUE user_id+item_code) |
| `cosmetic_catalog` | Catálogo de la tienda (23 items, rarity, price_gems) |
| `player_daily_state` | Invocaciones/pergaminos diarios (UNIQUE user_id+date) |
| `player_streaks` | Rachas (UNIQUE user_id) |
| `guild_quest_pool` | Pool de misiones del gremio (13 quests) |
| `player_completed_quests` | Misiones completadas (UNIQUE user_id+quest_id) |
| `guild_battle_pass` | Battle pass (UNIQUE user_id+season) |
| `player_pergaminos` | Contenido offline (JSONB) |

## Columnas añadidas a `user_language_profiles`
- `player_class` (default 'warrior')
- `guild_role` (default 'member')
- `total_gems` (default 0)
- `total_gold` (default 100)
- `last_active_date`

## Columnas añadidas a `chat_rooms`
- `moderator_type` ('ai'|'creator'|'assigned')
- `assigned_moderator_id`
- `description`, `updated_at`

## RLS
- Propio usuario: inventory, daily_state (S/I/U), streaks, completed_quests, battle_pass, pergaminos.
- Autenticados lectura: guild_quest_pool, cosmetic_catalog.

## Realtime
- `player_daily_state`, `player_streaks`, `guild_battle_pass`.

## Observaciones
- ⚠️ RPCs requeridos: `add_gems`, `spend_gems`, `increment_pergaminos_max` — verificar en el
  esquema live.
- ⚠️ `player_completed_quests.quest_id` es VARCHAR pero apunta a `guild_quest_pool.id` (UUID):
  inconsistencia de tipos a revisar.
- `total_gold` sin triggers/uso — pendiente.
