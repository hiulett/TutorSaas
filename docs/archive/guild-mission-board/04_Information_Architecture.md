# 04 — Arquitectura de información (Information Architecture)

## Mapa de la información

### Salón del Gremio (hub social) — QUÉ SE QUEDA
| Sección | Contenido |
|---|---|
| Header | Título del Salón + RANGO + prestigio |
| Banner vivo | CONECTADOS + anuncios |
| Mesas | Crear/entrar a salas de voz |
| **Tablón de Misiones** | **SOLO acceso** (poster "TABLÓN DE MISIONES" → push) |
| Trofeos | Vitrina |
| Rango | Modal TABLA DE RANGO |
| NPC | Maestre de Mesa flotante |

### Tablón de Misiones (pantalla dedicada) — QUÉ SE MUEVE
| Sección | Contenido |
|---|---|
| Header | Título + rango del aventurero |
| Filtros | TODAS / DIARIAS / SEMANALES / COLABORATIVAS |
| Cuadrícula | Pergaminos (catálogo completo del pool por idioma) |
| Estados | Disponible/Aceptada/En progreso/Completada/Repetible/Bloqueada/Recomendada/Especial |

### Detalle de Misión (pantalla nueva)
| Sección | Contenido |
|---|---|
| Pergamino grande | Imagen + título |
| Datos | Descripción, NPC, nivel, XP, oro, tiempo, objetivo, CEFR, rareza |
| Acción | Aceptar / Rechazar |

## Árbol de navegación

```
/home (dashboard)
  └── tab Guild
        └── /chat-rooms (Salón del Gremio)
              └── /guild-quest-board (Tablón)        ← NUEVO
                    ├── /guild-quest-detail?id=X     ← NUEVO
                    │     └── aceptar → /voice-room
                    └── vuelta ← pop
```

## Datos mostrados por pantalla (desde BD)

### Pergamino (overlays)
- `title` (BD), `quest_type` (BD), `game_rank` (BD), `target_value` (BD), `xp_reward` (BD), `gem_reward` (BD).
- Estado: derivado en runtime (no hardcodeado): completada (player_completed_quests), activa (mission_instances), recomendada (rango==jugador), bloqueada (canAcceptRank).
- Rareza: derivada de `game_rank` (no columna extra, no hardcodeada por misión).

### Detalle
- `title`, `description`, `quest_type`, `objective_type`, `target_value`, `xp_reward`, `gem_reward`, `game_rank`, `category`, `language_id`.
- NPC: derivado de `category` (presentación).
- Tiempo: derivado de `quest_type` (presentación).

## Flujos de datos

```
[Pool BD] guild_quest_pool (filtrado por language_id, excluye player_completed_quests)
   └── fullGuildQuestPoolProvider  → Tablón (cuadrícula)
   └── guildQuestByIdProvider       → Detalle

[Activas] mission_instances (status=active)
   └── activeMissionsProvider → estados "en progreso" en pergaminos

[Historial] player_completed_quests
   └── (excluido del pool automáticamente)

[Aceptar] acceptGuildQuest() → mission_instances (persiste) → invalida providers
```

## Qué se eliminó/trasladó
- `GuildQuestBoard` (657 líneas embebido) → **eliminado**; reemplazado por pantalla dedicada.
- Filtros, toggle CUMPLIDAS, gate de aceptación → **trasladados** al tablón/detalle.
- Header redundante "TABLÓN DEL GREMIO" → **eliminado** del Salón.
- Rango duplicado → solo en header del Salón + tablón (contextual).
