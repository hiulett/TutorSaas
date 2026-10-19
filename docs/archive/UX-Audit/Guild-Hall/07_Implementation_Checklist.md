# Auditoría UX/UI — Checklist de Implementación (Guild Hall)

**Proyecto:** TutorSaas / Dungeon of English
**Archivo auditado:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (1121 líneas)
**Fecha de auditoría:** 2026-08-01
**Estado:** Checklist priorizado — sin cambios de código aplicados

**Prioridades:** **P0** = bloquea la experiencia (hacer primero) · **P1** = mejora importante · **P2** = pulido/opcional.

---

## 1. Checklist priorizado

| ID | Tarea | Prioridad | Impacto | Riesgo | Archivos |
|---|---|---|---|---|---|
| C-01 | Compactar `_GuildHallHeader` a 1 línea: avatar + nombre + rango + badge de prestigio; el badge abre `_showRankModal` | P0 | Alto — libera ~60 px de scroll y unifica identidad del cazador | Medio — tocar un widget compartido (solo se usa en esta pantalla) | `chat_rooms_screen.dart:389`, `:811–874` |
| C-02 | Convertir `_GuildPrestigeHud` de tarjeta a chip compacto (NIVEL + PREMIUM/LIBRE), integrado en la fila del header | P0 | Medio — reduce 1 bloque vertical antes de las mesas | Bajo — dato derivado de `battlePassProvider`, sin lógica nueva | `:394`, `:758–806` |
| C-03 | Reducir la lista de mesas a filas compactas (icono + título + contadores + chevron; toda la fila tappable); re-evaluar el botón `ENTRAR` por fila | P0 | Alto — contenido principal más denso y menos scroll | Medio — cambio visual del listado; mantener `roomsAsync.when`, filtrado por categoría y navegación a `/voice-room` | `:496–660` |
| C-04 | Fusionar `MissionBoardWidget` dentro de `GuildQuestBoard` (emergencia + recompensas por reclamar + activas) y eliminar el bloque duplicado | P0 | Alto — elimina 1 bloque vertical y la redundancia de "2 tablones de misiones" | Alto — toca composición y posibles providers (`activeMissionsProvider`, `emergencyMissionsProvider`, `completedMissionsProvider`); no tocar la lógica de datos | `:665`, `:669`, `guild_quest_board.dart`, `mission_board_widget.dart` |
| C-05 | Eliminar el cartel decorativo `_GuildPoster` "MISIONES DEL GREMIO" (sin `onTap`) | P0 | Medio — quita un elemento muerto duplicado | Bajo — es puramente visual | `:689–694`, def `:879–944` |
| C-06 | Mantener (y, si aplica, compactar) el cartel "TABLA DE RANGO" con `onTap` → `_showRankModal`; evaluar mover el acceso al badge del header | P1 | Bajo — acceso secundario al modal ya existente | Bajo — solo reubicación | `:697–704`, modal `:139–196` |
| C-07 | Mantener `_GuildTrophies` al final (no reordenar) y `_showRankModal` tal cual | P1 | Bajo — conserva la vitrina y el modal existente | Bajo | `:679`, `:139–196` |
| C-08 | Reducir `GuildMasterNpcBanner` (padding/altura) conservando avatar, sugerencia y CTA | P1 | Medio — compacta el bloque narrativo sin perder función | Bajo | `guild_master_npc_banner.dart:58–131` |
| C-09 | Añadir **glow** a la mesa seleccionada (borde `manaCyan` + shadow en la fila activa, con `RepaintBoundary`) | P1 | Medio — feedback de selección | Bajo | `chat_rooms_screen.dart:514–643` |
| C-10 | Añadir **pulse** al botón `ENTRAR` / fila de mesa (scale ~300 ms) | P1 | Alto — confirma la acción principal antes de navegar | Bajo | `:525–528`, `:627–636` |
| C-11 | Añadir **fade** a las transiciones de categoría (`AnimatedSwitcher` ~150 ms) | P1 | Medio — suaviza el cambio de lista | Bajo | `:448–453`, `:496–660` |
| C-12 | Añadir **scale** al botón `INITIALIZE` (~200 ms) | P1 | Medio — feedback táctil en creación de mesa | Bajo | `:411–421`, diálogo `:198–352` |
| C-13 | Añadir **glow/pulse** al banner de emergencia y al botón `RECLAMAR` en el tablón fusionado | P1 | Medio — prioriza alertas activas | Bajo | `mission_board_widget.dart:37–78`, `:125–153` |
| C-14 | Añadir **breathing** al avatar del NPC (loop 2.5–3 s, aislado con `RepaintBoundary`, respeta `disableAnimations`) | P2 | Bajo — vida narrativa | Bajo | `guild_master_npc_banner.dart:66–74` |
| C-15 | Añadir **partículas flotantes** sutiles en el header (2–4 puntos, `CustomPaint` sobre el widget del header) | P2 | Bajo — ambiente System HUD | Medio — requiere medición de rendimiento (DevTools) antes/después | Header `:389`, propuesta doc 06 |
| C-16 | QA final: `flutter analyze` 0 errores · `flutter test` · `flutter build apk --debug` · prueba visual en pantalla pequeña (~360 dp) | P0 | Alto — puerta de calidad | — | Todo el feature `chat_rooms` + `missions` |

---

## 2. Orden de ejecución recomendado

**Ronda 1 (P0 — reorganización estructural):** C-01 → C-02 → C-03 → C-05 → C-04 → C-16 (build de control).

**Ronda 2 (P1 — microinteracciones):** C-10 → C-12 → C-09 → C-11 → C-13 → C-08 → C-06/C-07.

**Ronda 3 (P2 — pulido):** C-14 → C-15 → C-16 (QA final).

---

## 3. Criterios de "hecho" por tarea

- **C-01/C-02:** sin overflow en 360 dp; el badge de prestigio abre `_showRankModal`; `flutter analyze` 0 errores.
- **C-03:** misma navegación y filtrado que hoy; `speakers_count`/`listeners_count` visibles; sin overflow.
- **C-04:** emergencia, recompensas y misiones activas siguen visibles (en el tablón fusionado); providers intactos.
- **C-05:** cartel eliminado sin referencias huérfanas; `_GuildPoster` solo conserva el uso con `onTap`.
- **C-16:** 0 errores de analyze · tests verdes · APK debug compila.

---

*Documento de auditoría. Sin cambios de código aplicados. Referencias: `chat_rooms_screen.dart` (1121 líneas), `guild_quest_board.dart` (404 líneas), `mission_board_widget.dart` (252 líneas), `guild_master_npc_banner.dart` (133 líneas).*
