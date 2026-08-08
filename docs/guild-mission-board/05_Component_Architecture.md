# 05 — Arquitectura de componentes (Component Architecture)

## Nuevos componentes

```
lib/features/missions/presentation/
├── screens/
│   ├── guild_mission_board_screen.dart   ← Tablón (cuadrícula) NUEVO
│   └── mission_detail_screen.dart        ← Detalle (Aceptar/Rechazar) NUEVO
└── widgets/
    └── mission_parchment.dart            ← Pergamino reutilizable NUEVO
```

### `MissionParchment` (widget reutilizable)
- Props: `quest`, `playerRank`, `status` (QuestStatus), `isRecommended`, `onTap`, `width?`.
- Usa `Image.asset('assets/images/avatars/Mision.png')` como base (se reutiliza, no se crea otro).
- Deriva rareza vía `QuestRarity.fromRank(quest.gameRank)`.
- Overlays: tipo, sello de rareza, nombre, rango, objetivo, XP, oro, estado.

### `MissionDetailScreen`
- Props: `questId`.
- Usa `guildQuestByIdProvider` → `getGuildQuestById(questId)`.
- Botones ACEPTAR/RECHAZAR. Aceptar → `acceptGuildQuest` → invalida providers → `go('/voice-room')`.

## Lógica de dominio (extraída a tests)
### `QuestRarity` (enum)
`fromRank(gameRank)`: E→common, D→uncommon, C→rare, B→epic, A→legendary, S/SS/SSS→guild.

### `QuestStatus` (enum)
`available/accepted/inProgress/completed/repeatable/blocked/recommended/special` con label + color.

### `questStatusFor(...)`
Orden de precedencia: completed → inProgress → recommended → blocked → available.

## Proveedores (reutilizados + nuevos)

### Reutilizados (sin cambios)
- `missionRepositoryProvider`
- `activeMissionsProvider`
- `guildQuestPoolProvider` (limita a 3, usado en el Salón/rotación si aplica)
- `completedGuildQuestsProvider`
- `userProgressProvider` (rango del jugador)
- `currentUserProvider`

### Nuevos
| Provider | Tipo | Uso |
|---|---|---|
| `fullGuildQuestPoolProvider` | FutureProvider.autoDispose<List<GuildQuest>> | Cuadrícula completa del tablón (sin límite 3) |
| `guildQuestByIdProvider` | FutureProvider.autoDispose<GuildQuest?> | Detalle por id |
| `guildQuestIdProvider` | StateProvider<String?> | Semilla del id desde la ruta |

## Repositorio (ampliado)
- `getGuildQuestById(questId)` → `GuildQuest?` (nuevo método, consulta a `guild_quest_pool`).

## Router (ampliado)
- `/guild-quest-board` → `GuildMissionBoardScreen`
- `/guild-quest-detail?questId=X` → `MissionDetailScreen(questId)`

## Reutilización estricta (sin duplicar)
- Modelos: `GuildQuest`, `MissionInstance` (sin cambios).
- Persistencia: `acceptGuildQuest`, `markGuildQuestCompleted`, `updateProgress` (sin cambios).
- CEFR: `CefrRank.canAcceptRank`, `rankDescription`.
- Fondo: `CyberBgMode.guildTable`.
- Asset pergamino: `Mision.png`.

## Dependencias nuevas
- `mission_parchment.dart` (nuevo) — depende de `app_colors`, `cefr_rank`, `mission_models`.
- `guild_mission_board_screen.dart` (nuevo) — depende de providers de misiones + `MissionParchment`.
- `mission_detail_screen.dart` (nuevo) — depende de providers + `MissionParchment` (rareza).
