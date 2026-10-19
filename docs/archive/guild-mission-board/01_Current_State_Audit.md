# 01 — Estado actual (Current State Audit)

## Resumen
El Tablón de Misiones estaba **embebido** dentro del Salón del Gremio como un widget `GuildQuestBoard` en `chat_rooms_screen.dart:731`. No existía una ruta dedicada ni pantalla independiente.

## Arquitectura previa

```
Dashboard (tab Guild, dashboardTabProvider=1)
   └── ChatRoomsScreen(isTab: true)   [incrustado, sin ruta]
         └── SingleChildScrollView
               ├── _GuildHallHeader (título + rango + prestigio)
               ├── Banner conectados
               ├── Salas de voz
               ├── GuildQuestBoard  ← TABLÓN EMBEBIDO (activas + pool + filtros + CUMPLIDAS)
               ├── _GuildTrophies
               ├── _GuildPoster TABLA DE RANGO
               └── GuildMasterFloatingBanner (NPC flotante)
```

## Problemas detectados

### Navegación
- **No existe ruta** para el tablón (`/guild-quest-board` no existía).
- El tab Guild usa `dashboardTabProvider` (estado), no una ruta — inconsistente con la doc de AGENTS.md que dice "Guild→/chat-rooms".
- El tablón solo era alcanzable haciendo scroll largo en el Salón.

### UX (carga visual)
- `GuildQuestBoard` ocupaba cientos de px: hasta 3 tarjetas activas + 3 del pool, cada una con botón "ACEPTAR MISIÓN" a ancho completo + filtros + toggle CUMPLIDAS.
- Se sumaba a salas, trofeos y NPC flotante → scroll excesivo antes de ver las salas o las misiones.
- **RANGO del jugador duplicado** en 3 sitios: `_GuildHallHeader`, header del tablón, modal de rango.
- El header "TABLÓN DEL GREMIO" era redundante dentro de un Salón que ya tiene su propio `guild_hall` header.

### Controles que pertenecen al tablón (no al salón)
- Toggle "CUMPLIDAS" (historial personal).
- Filtros TODAS / DIARIAS / SEMANALES / COLABORATIVAS.
- Flujo "ACEPTAR MISIÓN" + gate de rango.
- Contador "RANGO: X".

## Componentes reutilizables identificados

| Recurso | Ubicación | Uso en el nuevo tablón |
|---|---|---|
| `Mision.png` (306×229, pergamino) | `assets/images/avatars/` | Imagen base de cada pergamino ✅ |
| Paleta medieval | `AppColors.medieval*` (L133-144) | Madera/piedra/oro/texto ✅ |
| Rarezas | `DropRarity`, `rarity*`, `_rarityColor` | Marco/sello de rareza ✅ |
| `GlassCard` / `QuestCard` | `core/widgets/` | Patrón de tarjeta (referencia) |
| `CyberBgMode.guildTable` | `cyber_manhwa_background.dart` | Fondo del tablón ✅ |
| `GuildQuest`, `MissionInstance` | `mission_models.dart` | Modelos (sin cambios) ✅ |
| `guildQuestPoolProvider` | `mission_providers.dart` | Pool por idioma ✅ |
| `activeMissionsProvider` | `mission_providers.dart` | Misiones activas ✅ |
| `acceptGuildQuest` | `mission_repository.dart` | Persistir aceptación ✅ |
| `CefrRank` | `cefr_rank.dart` | Gate de rango + descripciones ✅ |
| `shimmer` (pubspec) | dependencia no usada | Skeleton opcional |

## Deuda técnica detectada
1. Tablón embebido = acoplamiento alto entre gremio y misiones.
2. `GuildQuestBoard` (657 líneas) mezclaba 3 responsabilidades (activas, pool, historial) en un solo widget.
3. Sin tests de la lógica de rareza/estado de misiones.
4. Rutas de misiones inexistentes.
