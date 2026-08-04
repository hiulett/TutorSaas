# Fase 7 — Guild · Change_Log

> Registro de cambios de la Fase 7.

## 2026-07-30

### Implementación (8/8 tareas)

**G-A · Seed de mesas en DB + `room_type` (P0)**
- Migración `supabase/migrations/20260730_guild_g_a_seed_tables.sql`: columna `room_type` (discussion/ai_practice/mentorship/event/training) + seed de las 4 mesas del Gran Salón + índice.
- Estado: pendiente de aplicar en SQL Editor por el usuario.

**G-B · Refactor `getRooms` (P0)**
- `chat_rooms_repository_impl.dart`: `getRooms` ahora lee SOLO de `chat_rooms` (sin las 4 mesas hardcodeadas), filtra `is_active=true` y `deleted_at IS NULL`, y evita N+1 con una consulta agregada de participantes.
- Eliminados datos falsos de speakers/oyentes.

**G-D · i18n + tipografía del Gran Salón (P1)**
- `chat_rooms_screen.dart`: strings → `AppLocalizations` (título, hero, categorías, JOIN, estado vacío); `orbitron` → `spaceGrotesk` (0 usos de orbitron).

**G-C · Guild Quest Board (P1)**
- Nuevo `GuildQuest` model + `getGuildQuestPool()` en repo + `guildQuestPoolProvider`.
- Nuevo widget `guild_quest_board.dart` con filtros (todas/diarias/semanales/colaborativas), recompensas XP/gemas y tarjetas colaborativas (usa `GuildMission` de T-400).
- Integrado en el Gran Salón.

**G-F · NPC Maestre de Mesa (P1)**
- Nuevo widget `guild_master_npc_banner.dart`: bienvenida + sugerencia de mesa según CEFR del jugador + botón "SIGUE MI SUGERENCIA" que navega a la mesa recomendada.
- Integrado en el Gran Salón.

**G-E · Práctica IA en mesa (P1)**
- `voice_room_screen.dart`: botón "HABLAR CON EL ORÁCULO" (royalGold) que abre `/conversation` (práctica IA individual dentro de la mesa; respeta límite de invocaciones T-506).

**G-G · HUD de prestigio del gremio (P2)**
- `_GuildPrestigeHud` en `chat_rooms_screen.dart`: muestra nivel de Battle Pass + estado premium (usa `battlePassProvider` de T-502).

**G-H · Categorías desde DB + paginación (P2)**
- Categorías dinámicas derivadas de las salas reales (`room['category']` → etiqueta), en lugar de la lista hardcodeada. Helper `_slugForLabel`. El modal de creación usa `_categoryLabels`.

### Verificación
- `flutter analyze`: 0 errores (64 infos/warnings tolerados).
- `flutter test`: 13/13 ✅ · `flutter build apk --debug`: OK ✅.

### Pendiente (usuario)
- Aplicar `supabase/migrations/20260730_guild_g_a_seed_tables.sql` en el SQL Editor para que las mesas default aparezcan desde DB.
