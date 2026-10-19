# Guild — Dungeon of English

> Documento maestro del Guild. Sincronizado: 2026-07-30 (Fase 7).

## Visión
El Gran Salón es el **lobby principal MMORPG**: un gremio vivo con NPC, misiones, mesas con propósito y prestigio visible.

## Arquitectura
- `lib/features/chat_rooms/` (repo, providers, screens) + `lib/features/missions/` (quest pool, colaborativas).

## Gran Salón (`/chat-rooms`)
Componentes implementados:
1. **NPC Maestre de Mesa** (G-F): bienvenida + sugerencia de mesa según CEFR + navegación.
2. **Guild Quest Board** (G-C): misiones diarias/semanales/colaborativas con filtros y recompensas.
3. **HUD de prestigio** (G-G): nivel de Battle Pass + estado premium.
4. **Mesas reales desde DB** (G-A/G-B): sin hardcode, `room_type` (discussion/ai_practice/mentorship/event/training), filtro is_active, anti N+1.
5. **Categorías dinámicas** (G-H): derivadas de las salas reales.
6. **i18n + tipografía** (G-D): sin strings hardcoded, sin orbitron.

## Sala de voz (`/voice-room`)
- Hablar con el Oráculo (G-E): práctica IA individual dentro de la mesa (respeta invocaciones T-506).
- Moderación AI simulada (tips) — pendiente de moderación real.
- Salas locales toleran slugs no-UUID (T-002).

## DB del Guild
`chat_rooms`, `chat_room_participants`, `chat_room_messages`, `guild_quest_pool` (13 quests), `guild_collaborative_missions`, `guild_battle_pass`, `player_completed_quests`.

## Pendiente (mejoras futuras)
- Moderación IA real (no tips simulados).
- Audio real entre jugadores (hoy simulado).
- Mentorías, entrenamiento, eventos como tipos de mesa activos.
