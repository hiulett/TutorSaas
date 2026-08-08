# 06 — Impacto en base de datos (Database Impact)

## Sin cambios de esquema
La refactorización del Tablón **no requiere** cambios en la BD. Reutiliza las tablas existentes:

| Tabla | Rol | Cambio |
|---|---|---|
| `guild_quest_pool` | Catálogo de misiones (48 × 4 idiomas) | Ninguno |
| `mission_instances` | Misiones activas del jugador | Ninguno |
| `player_completed_quests` | Historial de cumplidas | Ninguno |
| `users` / `user_language_profiles` | Rango/idioma del jugador | Ninguno |

## Datos de lectura por pantalla

### Tablón (`fullGuildQuestPoolProvider`)
```sql
-- guild_quest_pool
SELECT * FROM guild_quest_pool
WHERE is_active = TRUE
  AND language_id = <langId>
  AND id NOT IN (SELECT quest_id FROM player_completed_quests WHERE user_id = <uid>)
ORDER BY game_rank, quest_type;
```

### Detalle (`getGuildQuestById`)
```sql
SELECT * FROM guild_quest_pool WHERE id = '<questId>' AND is_active = TRUE LIMIT 1;
```

### Activas (estados de pergaminos)
```sql
SELECT quest_id FROM mission_instances WHERE user_id = <uid> AND status = 'active';
```

### Aceptar (`acceptGuildQuest`)
```sql
INSERT INTO mission_instances
  (user_id, quest_id, mission_type, title, description, objective_type,
   target_value, xp_reward, gem_reward, item_reward, status)
VALUES (...);
```

### Completar (al llegar al target en `updateProgress`)
```sql
INSERT INTO player_completed_quests (user_id, quest_id, completed_at)
VALUES (..., ...) ON CONFLICT (user_id, quest_id) DO NOTHING;
```

## Datos derivados (NO en BD)
Estos son presentacionales y se derivan en runtime — no requieren columnas:
- **Rareza** ← de `game_rank`.
- **NPC asignador** ← de `category`.
- **Tiempo estimado** ← de `quest_type`.
- **Estado** ← combinación de `player_completed_quests`, `mission_instances`, `canAcceptRank`.

## Idioma
`guild_quest_pool.language_id` (1=en, 2=fr, 3=de, 4=it) se filtra con el `learningLanguage` del jugador (mapeo en `_languageCodeToId`). Las 48 misiones existen en los 4 idiomas (192 filas, migración `supabase/misionesgremio/20260805_serie_48_misiones_gremio.sql`).

## Migraciones involucradas (ya aplicadas)
1. `supabase/misionesgremio/20260805_serie_48_misiones_gremio.sql` — serie 48×4 idiomas + `language_id` + `quest_id`.
2. Políticas RLS de `player_completed_quests` (SELECT/INSERT/UPDATE) — necesarias para el historial y el upsert.

## Verificación de integridad
- La app **no** añade columnas nuevas en esta refactorización.
- No hay hardcodeo de misiones en el código: todo se lee de `guild_quest_pool`.
- `getGuildQuestById` es el único método nuevo y es solo lectura.
