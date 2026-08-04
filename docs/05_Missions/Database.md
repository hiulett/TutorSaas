# Fase 5 — Database

> Esquema de DB del Sistema de Misiones (migración `20260730_mission_engine.sql`).

## Tablas

| Tabla | Uso | Columnas clave |
|---|---|---|
| `mission_templates` | Plantillas reutilizables | mission_type, objective_type, target_value, xp/gem_reward, item_reward, min/max_cefr_level, cooldown_hours, is_active |
| `mission_instances` | Misiones del jugador | user_id, template_id, status CHECK(active/completed/failed/expired/cancelled), current_value, is_reward_claimed, expires_at, UNIQUE(user_id, template_id, mission_type) |
| `secret_missions` | Misiones IA | trigger_data JSONB, is_completed, expires_at (+24h) |
| `emergency_missions` | Emergencias globales | starts_at/expires_at, recompensas altas |
| `global_events` | Eventos temporales | event_type, reward_data JSONB |
| `player_event_progress` | Progreso en eventos | UNIQUE(user_id, event_id) |
| `guild_collaborative_missions` | Misiones de gremio | current_value global, is_reward_claimed |
| `reward_history` | Registro de recompensas | source_type, xp/gems_earned, item_code |

## Índices
- `mission_instances(user_id, status)`
- `secret_missions(user_id, is_completed)`
- `emergency_missions(is_active, expires_at)`
- `global_events(is_active, expires_at)`
- `reward_history(user_id, claimed_at)`

## RLS
- Lectura autenticada: templates, emergencias, eventos, gremio.
- Propio usuario: instances (SELECT/INSERT/UPDATE), secretas (SELECT), player_event_progress,
  reward_history.

## Realtime
- `mission_instances`, `emergency_missions`, `global_events` en `supabase_realtime`.

## Observaciones
- ⚠️ Verificar que `users` exista antes (FK en mission_instances).
- ⚠️ Confirmar RPC `add_xp` y `add_gems` existan en el esquema (usados por claimReward).
- Sin función SQL de rotación diaria (pendiente edge function/cron).
