# Fase 3 — Database

> Esquema de datos del Dashboard.

## Tablas consumidas

### `public.users`
- `bio`: contiene stats del cazador con formato `[Stats|STR:n|INT:n|DEX:n|LUK:n] texto`.
- `display_name`, `avatar_url`, `native_language`.

### `public.user_language_profiles`
- `xp_points`, `current_streak`, `cefr_level_id`.

### `public.user_progress` (referenciado por HunterStatusScreen)
- `level_code`, `xp`, `equipped_title_code`.
- ⚠️ Verificar existencia real de esta tabla/columnas en migraciones.

### `public.cefr_levels`
- `code`, `name`, `order_index` (para el rango mostrado).

## Observaciones

- El formato de stats embebido en `bio` es frágil (regex) — candidato a tabla `hunter_stats`
  (user_id, str, int, dex, luk, points_pool) en implementación futura.
- Verificar `equipped_title_code` esté en el esquema de `user_progress` antes de depender de él.
