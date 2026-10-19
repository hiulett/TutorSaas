# 07 — Impacto en API (API Impact)

## Superficie de API usada (Supabase REST via PostgREST)

| Operación | Endpoint | Método | Cambio |
|---|---|---|---|
| Pool de misiones | `/guild_quest_pool` | GET (select, filters, order) | Ninguno |
| Detalle por id | `/guild_quest_pool?id=eq.X` | GET | Ninguno (nuevo call, sin cambio de API) |
| Activas | `/mission_instances` | GET | Ninguno |
| Aceptar | `/mission_instances` | POST (insert) | Ninguno |
| Historial cumplidas | `/player_completed_quests` | GET | Ninguno |
| Registrar cumplida | `/player_completed_quests` | UPSERT (POST) | Ninguno |

## Nuevas llamadas en el cliente (sin API nueva en backend)
1. `getGuildQuestById(questId)` → `GET /guild_quest_pool?id=eq.$questId&is_active=eq.true` (`.maybeSingle()`).
2. `fullGuildQuestPoolProvider` → `GET /guild_quest_pool` con filtro por `language_id` + exclusión de cumplidas + order.

## Consideraciones de RLS
- `guild_quest_pool`: lectura pública (contenido del juego) — las políticas `anon`/`authenticated` existentes de solo lectura son correctas.
- `player_completed_quests`: SELECT/INSERT/UPDATE **solo del propio usuario** (`auth.uid() = user_id`) — aplicado en la migración de la serie.
- `mission_instances`: INSERT/UPDATE del propio usuario — ya existente.

## Manejo de errores
- `getGuildQuestPool` → `catch → []` (tablón vacío si falla, sin crash).
- `getGuildQuestById` → `catch → null` (detalle muestra "Misión no encontrada").
- `acceptGuildQuest` → devuelve `null` si rango insuficiente/cuota llena → el detalle muestra snack de error.
- Toda llamada envuelta en try-catch con `debugPrint` (convención del proyecto).

## Lazy loading / rendimiento
- `fullGuildQuestPoolProvider` es `autoDispose` → se libera al salir del tablón.
- La cuadrícula usa `GridView.builder` (construcción perezosa de pergaminos).
- No hay paginación por red: el pool completo es pequeño (48 misiones/idioma) y se cachea en memoria por el provider.
