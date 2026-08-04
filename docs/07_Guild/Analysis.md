# Fase 7 — Guild · Análisis del estado actual

> Fuente oficial de verdad: `/docs`. Auditoría basada en Graphify + código real (`lib/features/chat_rooms/`) + esquema Supabase verificado (2026-07-30).

## 1. Arquitectura actual del Guild

```
lib/features/chat_rooms/
├── data/repositories/chat_rooms_repository_impl.dart   # 364 líneas
├── domain/repositories/chat_rooms_repository.dart       # interfaz (9 métodos)
└── presentation/
    ├── providers/chat_rooms_providers.dart              # 4 providers
    ├── screens/chat_rooms_screen.dart                   # Gran Salón (529 líneas)
    └── screens/voice_room_screen.dart                   # Sala de voz (759 líneas)
```

### Flujo
1. Dashboard tab GUILD → `/chat-rooms` (Gran Salón).
2. Gran Salón lista mesas (`chat_rooms` DB + 4 mesas default hardcodeadas).
3. Tap en mesa → `/voice-room?roomId=...` (sala de voz con chat + moderación IA simulada).
4. Crear mesa → modal `SystemWindow` → insert `chat_rooms` → auto-join moderador.

### Tablas DB (verificadas en live)
| Tabla | Estado |
|---|---|
| `chat_rooms` | ✅ 14 columnas (title, category, moderator_id, max_speakers, has_ai_moderator, mana_cost_per_min, is_active, moderator_type, assigned_moderator_id, …) |
| `chat_room_participants` | ✅ |
| `chat_room_messages` | ✅ |
| `guild_quest_pool` | ✅ (13 quests seed) |
| `guild_collaborative_missions` | ✅ (repo T-400) |
| `guild_battle_pass` | ✅ (repo T-502) |
| `player_completed_quests` | ✅ |

## 2. Problemas detectados

### P0 — Críticos (bloquean el Guild como centro de experiencia)
| ID | Problema | Evidencia |
|---|---|---|
| G-01 | **4 mesas default hardcodeadas** en el repo (`guild_table_1..4`) con datos falsos (speakers 3-5, listeners 12-45) | `chat_rooms_repository_impl.dart:51-100` — no son salas reales, simulan actividad |
| G-02 | **Moderación IA simulada**: `_aiTips` rotan cada 8s con frases fijas; no hay moderación IA real | `voice_room_screen.dart:38-45,84-90` |
| G-03 | **Hablar es simulado**: `_speakingSimState` con `Random()` marca "hablando" falsos cada 2s | `voice_room_screen.dart:69-82` — no hay audio real entre jugadores |

### P1 — Experiencia RPG / inmersión
| ID | Problema |
|---|---|
| G-04 | **Sin sistema de mesas con propósito**: todas las mesas son "discussion tables" genéricas; sin conversación IA por mesa, NPC, mentorías, eventos |
| G-05 | **Sin Guild Quest Board en pantalla**: `guild_quest_pool` y `guild_collaborative_missions` existen en DB pero el Gran Salón no los muestra |
| G-06 | **Sin economía visible del gremio**: no se ven prestigio/reputación del jugador en el salón; `guild_battle_pass` existe pero no está integrado al Guild |
| G-07 | **`orbitron` en hero banner** (fuera de tipografía estándar) | `chat_rooms_screen.dart:290` |
| G-08 | **Strings hardcoded en inglés** en el salón (vs. app en español): "THE GRAND GUILD HALL", "ACTIVE GATES", "ESTABLISH GUILD TABLE" |
| G-09 | **Sin storytelling ambiental**: el salón es una lista; no hay NPC del gremio, lore, "zona activa" |

### P2 — UX / escalabilidad
| ID | Problema |
|---|---|
| G-10 | **Categorías hardcodeadas** en el salón (`['Todos','Viajes','Trabajo',...]`) vs. slugs en DB — frágil |
| G-11 | **Sin paginación**: `getRooms` trae TODAS las salas + 4 queries anidadas por sala (N+1) | `chat_rooms_repository_impl.dart:103-131` |
| G-12 | **`is_active` no se respeta** en `getRooms` (no filtra salas cerradas) |
| G-13 | **Realtime duplicado**: la pantalla del salón hace suscripción propia a `chat_rooms` + el provider ya invalida |
| G-14 | **Sin estado de recompensas del gremio** en la sala (mana_cost, XP de guild) |

## 3. Mejoras propuestas (priorizadas)

### P0 — Fundamentos
1. **G-01 → Migrar mesas default a DB**: crear las 4 mesas en `chat_rooms` con seed SQL, eliminar el hardcode. (beneficio: datos reales, Realtime real)
2. **G-03 → Modo práctica individual real**: al unirse como oyente, ofrecer "hablar con el Oráculo (IA)" dentro de la mesa (reutiliza pipeline de voz). (beneficio: la mesa tiene valor aunque no haya 6 jugadores)

### P1 — Experiencia RPG
3. **G-05 → Guild Quest Board**: widget en el Gran Salón que consume `guild_quest_pool` + `guild_collaborative_missions` (repo T-400) con filtros y progreso. (alta reutilización)
4. **G-06 → HUD de prestigio del gremio**: mostrar battle pass + reputación en el salón.
5. **G-08 → i18n del salón** (usar `AppLocalizations`).
6. **G-07 → Reemplazar `orbitron`** por `spaceGrotesk`.
7. **G-09 → NPC del Gremio**: introducir "Maestre de Mesa" (NPC) que da la bienvenida y sugiere mesas según CEFR.

### P2 — UX / escalabilidad
8. **G-10 → Categorías desde DB** (tabla `room_categories` o columna distinct).
9. **G-11 → Paginación / evitar N+1** en `getRooms`.
10. **G-12 → Filtrar `is_active = true`**.
11. **G-04 → Tipos de mesa**: `ai_practice` | `player_practice` | `mentorship` | `event` — columna `room_type`.

## 4. Plan de implementación (tareas atómicas)

| # | Tarea | Prioridad | Dependencias | Complejidad |
|---|---|---|---|---|
| G-A | Seed SQL: mesas default en DB + columna `room_type` | P0 | — | Baja |
| G-B | Refactor `getRooms`: leer mesas desde DB, filtrar `is_active`, sin hardcode | P0 | G-A | Media |
| G-C | Guild Quest Board widget en el Gran Salón | P1 | — | Media |
| G-D | i18n del Gran Salón + quitar `orbitron` | P1 | — | Baja |
| G-E | Modo práctica IA en sala (hablar con el Oráculo) | P1 | T-506 | Alta |
| G-F | NPC Maestre de Mesa (bienvenida + sugerencias CEFR) | P1 | — | Media |
| G-G | HUD de prestigio del gremio (battle pass + reputación) | P2 | T-502 | Media |
| G-H | Categorías desde DB + paginación / anti N+1 | P2 | — | Media |

## 5. Documentación de Fase 7
- `docs/07_Guild/` (este análisis + planes por tarea + Change_Log)
