# Rediseño del Tablón del Gremio — unificación + rangos y categorías

> **Ruta:** `Docs/Guild-Quest-Redesign/GUILD_BOARD_REDESIGN.md`
> **Fecha:** 2026-08-04

---

## 1. Diagnóstico: duplicación de tablones

Ambos widgets se renderizaban **uno debajo de otro** en
`chat_rooms_screen.dart` (líneas 732 y 736), con headers casi idénticos:

| | TABLÓN DEL GREMIO (`GuildQuestBoard`) | TABLÓN DE MISIONES (`MissionBoardWidget`) |
|---|---|---|
| Fuente | `guild_quest_pool` (catálogo estático) | `mission_instances` (instancias reales del jugador) |
| Contenido | Diarias/semanales "disponibles" (progreso 0, sin onTap) | Activas del jugador con progreso real |
| Interacción | Solo filtros | Botones "ACEPTAR"/"RECLAMAR" vacíos |

**Veredicto: duplicadas.** Ambas presentaban misiones diarias/semanales, ninguna
permitía aceptar de verdad, y juntas generaban doble encabezado. La auditoría interna
(`docs/UX-Audit/Guild-Hall/01_Current_State.md`, problema C) ya lo señalaba.

## 2. Solución: un solo tablón unificado

`GuildQuestBoard` ahora muestra:

1. **TUS MISIONES ACTIVAS** (del jugador, `mission_instances`) con progreso real.
2. **MISIONES DEL POOL** (`guild_quest_pool`) con filtros (TODAS/DIARIAS/SEMANALES/
   COLABORATIVAS), cada una con su **rango requerido** y **categoría**, y botón
   **ACEPTAR MISIÓN**.

`MissionBoardWidget` se eliminó (código huérfano).

## 3. Rangos y categorías

### Modelo `GuildQuest`
- Nuevos campos: `gameRank` (rango mínimo del gremio requerido) y `category`.
- `fromMap` lee `game_rank` y `category`.

### BD — migración `20260804_guild_quest_rank.sql`
- Columnas `game_rank varchar(5)` y `category varchar(40)` en `guild_quest_pool`.
- Seeds actualizados con rango (E–B) y categoría (speaking, argumentation,
  collaborative).

### Comparador de rangos — `CefrRank`
- `rankIndex(rank)` → orden canónico E<D<C<B<A<S<SS<SSS.
- `canAcceptRank(playerRank, requiredRank)` → true si el jugador tiene rango
  igual o superior al requerido (o no hay requisito).

## 4. Gate de rango (no aceptar misiones superiores al rango)

- **UI** (`_GuildQuestCard`): si el rango del jugador es insuficiente, el botón se
  deshabilita y muestra "RANGO X REQUERIDO" en rojo.
- **Repo** (`acceptGuildQuest`): valida de nuevo `CefrRank.canAcceptRank` antes de
  crear la `mission_instance` (defensa en profundidad).

## 5. Exponer el rango del aventurero

- `userProgressProvider` ahora devuelve `game_rank` (desde
  `user_language_profiles.game_rank`, con fallback `CefrRank.gameRankFromCefr(level_code)`).
- El tablón muestra "RANGO: <jugador>" en el encabezado.

## 6. Archivos modificados

| Archivo | Cambio |
|---|---|
| `mission_models.dart` | `GuildQuest` + `gameRank`/`category`. |
| `cefr_rank.dart` | `rankIndex` + `canAcceptRank`. |
| `dashboard_repository_impl.dart` | `getUserProgress` expone `game_rank`. |
| `mission_repository.dart` (+ interfaz) | `acceptGuildQuest` con gate de rango. |
| `guild_quest_board.dart` | Reescrito: activas + pool aceptable por rango. |
| `chat_rooms_screen.dart` | Quitada la doble renderización (solo GuildQuestBoard). |
| `mission_board_widget.dart` | **Eliminado** (código huérfano). |
| `dashboard_screen.dart` | Import muerto eliminado. |
| `supabase/migrations/20260804_guild_quest_rank.sql` | Columnas + seeds de rangos/categorías. |

## 7. QA
- `flutter analyze`: 0 errores.
- `flutter test`: 83/83.
- `flutter build apk --debug`: OK.

## 8. Pendiente (depende del usuario)
Aplicar la migración `20260804_guild_quest_rank.sql` en el SQL Editor para que las
misiones del pool tengan `game_rank`/`category`. Sin ella, `game_rank` es null →
`canAcceptRank` devuelve true (no restringe) y las misiones se ven con rango "-".
