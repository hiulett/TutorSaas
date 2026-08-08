# 10 — Reporte final (Final Report)

## Resumen ejecutivo
El **Tablón de Misiones del Gremio** dejó de ser un bloque embebido en el Salón y ahora es una **pantalla independiente e inmersiva** con cuadrícula de pergaminos medievales. Se mantuvo la identidad visual fantasy RPG y se reutilizó toda la lógica existente de misiones (modelos, repositorios, providers, CEFR, asset).

### Mejoras v2 (post-rediseño)
1. **Historial CUMPLIDAS**: toggle en el header del tablón que muestra las misiones completadas por el jugador (`player_completed_quests`).
2. **Mini-barra de progreso**: en pergaminos de misiones activas se muestra `currentValue/targetValue` con barra de progreso (`MissionInstance.progress`).
3. **Orden inteligente**: `sortQuestSmart` coloca recomendadas (rango del jugador) → aceptables → bloqueadas, desempatando por rango menor requerido.
4. **Filtro por rareza**: segunda fila de chips (COMÚN / POCO COMÚN / RARO / ÉPICO / LEGENDARIO / ESPECIAL DEL GREMIO) además del filtro por tipo.

### Mejoras v3 (inmersión)
5. **Skeleton loading** con `shimmer` (`MissionBoardSkeleton`) en lugar de spinners.
6. **Animación de entrada**: cada pergamino hace fade + leve rotación escalonada por índice (efecto "pergaminos clavados").
7. **Badge NUEVA** (disponibles top-3) y **RECOMENDADA** con acento.
8. **Haptic feedback** (`HapticFeedback.mediumImpact()`) al aceptar una misión.
9. **Confirmación** en diálogo para misiones de rango alto (S/SS/SSS) antes de aceptar.

### Mejoras v4 (profundidad)
10. **COBRAR recompensa**: al completar una misión, el detalle muestra botón "COBRAR RECOMPENSA" → `claimReward` (XP + oro + historial) + `FloatingReward`.
11. **Búsqueda por texto**: campo sobre la cuadrícula que filtra por nombre.
12. **Retrato del NPC**: el detalle muestra el avatar del Oráculo junto al asignador.
13. **Estados visuales ricos**: sello de cera rojo (BLOQUEADA) y franjas "pergamino enrollado" (COMPLETADA).
14. **Rareza editorial desde BD**: columna `rarity` en `guild_quest_pool` con prioridad sobre la derivación por rango.
15. **Botón "EN PROGRESO · IR AL CHAT"** cuando la misión ya está activa (en vez de volver a aceptar).

### Correcciones v5
16. **Cuota de gremio independiente** (`maxActiveGuildQuests = 3`): antes, un jugador con las 10 misiones diarias activas no podía aceptar ninguna misión del gremio (ni de su propio rango) porque `canAcceptMission` limitaba a 10 globales. Ahora las misiones del pool tienen su propia cuota de 3, sin competir con las diarias.
17. **Paginación incremental**: el tablón muestra 6 pergaminos por defecto (orden inteligente: recomendadas/aceptables primero) con botón "VER MÁS MISIONES" que amplía de 6 en 6. Reduce la saturación visual.

### Corrección v6 (duplicados BD)
18. **`guild_quest_pool` tenía 36 filas duplicadas** (el seed de la serie se re-aplicó parcialmente): 192 filas pero solo 156 combinaciones únicas. Script `supabase/misionesgremio/20260805_fix_duplicates.sql` que hace `TRUNCATE` + re-aplica los 192 INSERTs → **48 títulos únicos por idioma × 4 idiomas = 192 filas limpias**. Pendiente de aplicar en el SQL Editor.

## Criterios de aceptación — resultado

| Criterio | Cumplido | Evidencia |
|---|---|---|
| Tablón independiente del Salón | ✅ | Ruta `/guild-quest-board` → `GuildMissionBoardScreen` |
| Acceso único desde el Salón | ✅ | `chat_rooms_screen.dart` → poster "TABLÓN DE MISIONES" → `push` |
| Cuadrícula de pergaminos | ✅ | `GridView.builder` 2/3/4 cols con `MissionParchment` |
| Reutiliza `Mision.png` | ✅ | `Image.asset('assets/images/avatars/Mision.png')` |
| Tap pergamino → detalle completo | ✅ | `/guild-quest-detail?questId=` → `MissionDetailScreen` |
| Aceptar / Rechazar | ✅ | Aceptar → `acceptGuildQuest` + persistencia + `/voice-room`; Rechazar → `pop` |
| Información desde BD, sin hardcodeo | ✅ | Todo leído de `guild_quest_pool` / `mission_instances` / `player_completed_quests` |
| Reutiliza lógica existente | ✅ | `GuildQuest`, `MissionInstance`, repo, providers, `CefrRank` |
| Identidad medieval consistente | ✅ | Paleta `medieval*`, `CyberBgMode.guildTable`, rarezas discretas |
| Documentación en `docs/guild-mission-board/` | ✅ | 10 documentos |
| Compila, sin regresiones, tests OK | ✅ | analyze 0 errores · 109 tests · APK OK |

## Entregables

### Código
| Tipo | Archivo |
|---|---|
| NUEVO | `lib/features/missions/presentation/screens/guild_mission_board_screen.dart` |
| NUEVO | `lib/features/missions/presentation/screens/mission_detail_screen.dart` |
| NUEVO | `lib/features/missions/presentation/widgets/mission_parchment.dart` |
| NUEVO | `test/mission_parchment_test.dart` |
| MOD | `lib/app/router.dart` (2 rutas) |
| MOD | `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (acceso único) |
| MOD | `lib/features/missions/domain/repositories/mission_repository.dart` (`getGuildQuestById`) |
| MOD | `lib/features/missions/data/repositories/mission_repository.dart` (impl) |
| MOD | `lib/features/missions/presentation/providers/mission_providers.dart` (3 providers) |
| DEL | `lib/features/missions/presentation/widgets/guild_quest_board.dart` |

### Documentación
`docs/guild-mission-board/` con 01-10 (auditoría, UX, UI, arquitectura de información, componentes, BD, API, plan, tests, reporte).

## Verificación final

```
flutter analyze            → 0 errores
flutter test               → 114 passed
flutter build apk --debug  → OK
```

## Nota BD (v4/v5)
- La columna `rarity` en `guild_quest_pool` es **opcional y retro-compatible** (aplicar sección 4 de `supabase/misionesgremio/20260805_serie_48_misiones_gremio.sql` en el SQL Editor).
- La cuota de gremio (máx 3 activas) se aplica **en el código** (`maxActiveGuildQuests`) — sin cambios de esquema. Si el jugador ya tiene misiones del gremio activas de antes, puede completarlas o esperar a que se libere espacio.
La columna `rarity` en `guild_quest_pool` es **opcional y retro-compatible**: la app la usa si existe (seeds ya la poblan derivada del rango) y cae a la derivación por rango si es null. Aplicar la sección 4 de `supabase/misionesgremio/20260805_serie_48_misiones_gremio.sql` en el SQL Editor.

## Notas de diseño
- **Pergamino**: cada misión es un `MissionParchment` que superpone overlays sobre `Mision.png` (no modifica el asset).
- **Rarezas**: E→Común, D→Poco común, C→Raro, B→Épico, A→Legendario, S/SS/SSS→Especial del Gremio. Discretas (borde + sello), nunca fluorescentes.
- **Estados**: Disponible/Aceptada/En progreso/Completada/Repetible/Bloqueada/Recomendada/Especial (derivados en runtime).
- **Responsive**: 2 cols (móvil), 3 (tablet), 4 (grande).
- **Rendimiento**: lazy grid, providers `autoDispose`, imagen cacheada.

## Deuda técnica pendiente (futuro)
- Skeleton loading con `shimmer` (dependencia ya en pubspec).
- Paginación incremental si el pool supera ~100 misiones por idioma.
- Ajuste fino de accesibilidad (contraste overlay del pergamino en pantallas OLED).
