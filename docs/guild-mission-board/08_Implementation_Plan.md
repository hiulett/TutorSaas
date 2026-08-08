# 08 — Plan de implementación (Implementation Plan)

## Fases ejecutadas (commits verificables)

### Fase 1 — Auditoría (completada)
- Agente UX Research: mapeó navegación y duplicación.
- Agente Game UX: extrajo patrones de Quest/Guild Boards (WoW, Skyrim, Diablo IV, GW2, FFXIV, Lost Ark, Monster Hunter, AFK Journey, Solo Leveling).
- Agente UI/Visual: definió pergamino + cuadrícula + rarezas.
- Resultado: docs 01-04.

### Fase 2 — Ruta nueva (completada)
- `router.dart`: `/guild-quest-board` → `GuildMissionBoardScreen` y `/guild-quest-detail?questId=` → `MissionDetailScreen`.

### Fase 3 — Componente pergamino (completada)
- `mission_parchment.dart`: `MissionParchment` + `QuestRarity` + `QuestStatus` + `questStatusFor`.

### Fase 4 — Tablón (completada)
- `guild_mission_board_screen.dart`: cuadrícula adaptativa (2/3/4 cols), filtros, estados, `fullGuildQuestPoolProvider`.

### Fase 5 — Detalle (completada)
- `mission_detail_screen.dart`: pergamino grande, datos, NPC, stats, ACEPTAR/RECHAZAR → `/voice-room`.
- `mission_repository.dart` + interfaz: `getGuildQuestById`.
- Providers: `fullGuildQuestPoolProvider`, `guildQuestByIdProvider`, `guildQuestIdProvider`.

### Fase 6 — Integración del Salón (completada)
- `chat_rooms_screen.dart`: `GuildQuestBoard` embebido → reemplazado por poster "TABLÓN DE MISIONES" que hace `push('/guild-quest-board')`.
- Eliminado `guild_quest_board.dart` (código muerto) y su import.

### Fase 7 — QA (completada)
- `flutter analyze`: 0 errores.
- `flutter test`: 109 passed (incluye 7 nuevos de `mission_parchment_test.dart`).
- `flutter build apk --debug`: OK.

### Fase 8 — Documentación (este documento y 09, 10).

## Backlog técnico priorizado (futuro)
| # | Ítem | Prioridad |
|---|---|---|
| 1 | Skeleton loading con `shimmer` (dependencia ya presente) | P2 |
| 2 | Paginación incremental del pool si crece >100 misiones | P3 |
| 3 | Badge "REPETIBLE" cuando una misión completada se regenera | P3 |
| 4 | Precarga de `Mision.png` en el arranque del tablón | P2 |
| 5 | Accesibilidad: contraste texto sobre pergamino + hit areas ≥44px | P1 (verificado parcial) |

## Archivos creados
```
lib/features/missions/presentation/screens/guild_mission_board_screen.dart  (NUEVO)
lib/features/missions/presentation/screens/mission_detail_screen.dart       (NUEVO)
lib/features/missions/presentation/widgets/mission_parchment.dart           (NUEVO)
test/mission_parchment_test.dart                                            (NUEVO)
```

## Archivos modificados
```
lib/app/router.dart
lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart
lib/features/missions/domain/repositories/mission_repository.dart
lib/features/missions/data/repositories/mission_repository.dart
lib/features/missions/presentation/providers/mission_providers.dart
```

## Archivos eliminados
```
lib/features/missions/presentation/widgets/guild_quest_board.dart  (reemplazado)
```
