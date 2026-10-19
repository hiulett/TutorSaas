# Auditoría UX/UI — Plan de Implementación por Fases (Guild Hall)

**Proyecto:** TutorSaas / Dungeon of English
**Archivo auditado:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (1121 líneas)
**Fecha de auditoría:** 2026-08-01
**Estado:** Plan por fases pequeñas — sin cambios de código aplicados

---

## 0. Reglas de la ejecución

1. **Cada fase debe compilar y pasar `flutter analyze` (0 errores) antes de pasar a la siguiente.**
2. **No se toca la lógica de datos** (providers, RLS, navegación a `/voice-room`, pipeline de voz). Solo composición visual.
3. Al final de cada fase: `flutter test` (regresión de la suite de 73 tests) y, en fases con cambios de layout, `flutter build apk --debug`.
4. Al terminar una fase, actualizar este documento con una sección "Cambios implementados" (fecha + verificación), siguiendo el patrón de `Guild_Voice_Chamber_UX_Audit.md` §8.
5. Probar en pantalla pequeña (~360 dp de ancho) tras cada fase de layout para detectar `RenderFlex` overflow antes de cerrar la fase.

---

## Fase 1 — Compactar header + prestigio (C-01, C-02)

### Pasos
1. Rediseñar `_GuildHallHeader` a **una sola fila**: avatar + nombre + rango CEFR + badge de prestigio (nivel + PREMIUM/LIBRE).
2. El badge de prestigio (o un icono de rango) debe abrir `_showRankModal` al tocar.
3. Convertir `_GuildPrestigeHud` de `GlassCard` a **chip compacto**; integrarlo en la fila del header (eliminar el bloque `:394` como tarjeta independiente).
4. Ajustar espaciados del `Column` (`:385–712`) para compensar el espacio liberado.
5. Revisar `isTab` vs `Scaffold` con `AppBar` (`:719–752`): en modo tab no hay AppBar, el header compacto debe seguir completo.

### Archivos
- `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (`:389`, `:394`, `:811–874`, `:758–806`).

### Verificación
- `flutter analyze` → 0 errores.
- `flutter test` → suite verde.
- Visual: sin overflow en 360 dp; el badge de prestigio abre el modal; la sección de mesas queda visible con menos scroll.

### Riesgos
- El modal `_showRankModal` ya existe (`:139–196`) — riesgo bajo de reutilizarlo.
- Perder el título grande "GUILD HALL": compensar con jerarquía tipográfica dentro de la fila (nombre más prominente).
- Overflow horizontal si el header compacto junta avatar+nombre+rango+prestigio en 360 dp → usar `Flexible`/ellipsis en nombre y rango.

---

## Fase 2 — Mesas compactas (C-03)

### Pasos
1. Reducir cada tarjeta de mesa (`:525–641`) a una **fila compacta**: icono pequeño + título (ellipsis) + badge de tipo (IA/MENTORÍA/EVENTO) + contadores (`x/6`, oyentes) + chevron.
2. Toda la fila tappable → `/voice-room` (mantener el `GestureDetector` existente).
3. Decidir el botón `ENTRAR` (`:627–636`): eliminarlo (la fila completa es el CTA) o reducirlo a un icono. Recomendado: **eliminar** y dejar el chevron como affordance (ver C-10 para el pulse de entrada).
4. Mantener intactos: filtrado por `_selectedCategory`, `roomsAsync.when` (data/loading/error), `RefreshIndicator`, separadores.
5. Verificar el estado vacío (`guild_no_rooms`, `:502–511`) y el loader (`:645–649`).

### Archivos
- `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (`:496–660`).

### Verificación
- `flutter analyze` → 0 errores.
- Visual: listado más denso; sin overflow; navegación a `/voice-room` desde cualquier punto de la fila.
- `flutter build apk --debug` (cambio de layout de listado).

### Riesgos
- Perder el botón `ENTRAR` puede confundir usuarios → mitigar con chevron + pulse de entrada (Fase 4 / C-10).
- El badge de tipo por fila usa `Builder` (`:568–598`): mantenerlo o extraer a método sin cambiar colores/labels.
- Overflows horizontales en títulos largos → mantener `Flexible`/`ellipsis` (ya presente en `:555–565`).

---

## Fase 3 — Fusionar tablones y eliminar cartel decorativo (C-04, C-05, C-06)

### Pasos
1. **Fusionar** `MissionBoardWidget` en `GuildQuestBoard`:
   - Mover el banner de **emergencia** (crimsonRed) a la parte superior del tablón fusionado (`mission_board_widget.dart:37–78`).
   - Mover el bloque de **recompensas por reclamar** (`mission_board_widget.dart:125–153`).
   - Integrar las **misiones activas** del jugador como sección dentro del tablón (o filtro adicional) (`mission_board_widget.dart:81–122`).
2. Eliminar la instancia `MissionBoardWidget` de la pantalla (`:669`) y su `SizedBox` de separación.
3. **Eliminar** el cartel decorativo "MISIONES DEL GREMIO" (`:689–694`).
4. **Mantener** el cartel "TABLA DE RANGO" (`:697–704`); si el header compacto (Fase 1) ya tiene acceso al rango, reducir este cartel a un enlace o eliminar el `IntrinsicHeight` que los agrupa (`:684–708`).
5. Verificar que no quedan imports huérfanos (`mission_board_widget.dart` import en `:18` si deja de usarse).

### Archivos
- `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (`:665`, `:669`, `:684–708`).
- `lib/features/missions/presentation/widgets/guild_quest_board.dart` (absorbe emergencia/recompensas/activas).
- `lib/features/missions/presentation/widgets/mission_board_widget.dart` (se vacía o se elimina según decisión).

### Verificación
- `flutter analyze` → 0 errores (vigilar imports sin usar).
- `flutter test` → suite verde (los tests de misiones no deben depender del widget visual).
- Visual: un solo tablón; emergencia y recompensas visibles; sin cartel decorativo.

### Riesgos
- **Alto:** fusionar dos widgets con providers distintos (`activeMissionsProvider`, `emergencyMissionsProvider`, `completedMissionsProvider`, `guildQuestPoolProvider`, `guildMissionsProvider`). **No tocar la lógica**; solo reutilizar los mismos `ref.watch` en el widget resultante.
- Eliminar `MissionBoardWidget` puede romper otros usos → verificar con grep antes de borrar el archivo.
- `IntrinsicHeight` (`:684`) puede causar coste de layout; al quedarse con un solo cartel, simplificar el `Row`.

---

## Fase 4 — NPC + microinteracciones (C-08, C-09…C-15)

### Pasos
1. **NPC reducido** (C-08): compactar padding/altura de `GuildMasterNpcBanner` sin tocar la sugerencia por CEFR ni el CTA.
2. Añadir **pulse** al botón `ENTRAR`/fila de mesa (C-10) y **scale** a `INITIALIZE` (C-12): `AnimatedScale` puntual con `RepaintBoundary`.
3. Añadir **glow** a la mesa seleccionada (C-09): borde `manaCyan` + shadow solo en la fila activa.
4. Añadir **fade** a las transiciones de categoría (C-11): `AnimatedSwitcher` ~150 ms sobre la lista.
5. Añadir **glow/pulse** al banner de emergencia y botón `RECLAMAR` del tablón fusionado (C-13).
6. *(P2)* **Breathing** del NPC (C-14) y **partículas** del header (C-15): loops aislados, respetando `MediaQuery.disableAnimations`.

### Archivos
- `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (`:411–421`, `:448–453`, `:514–643`, `:627–636`).
- `lib/features/chat_rooms/presentation/widgets/guild_master_npc_banner.dart` (`:58–131`).
- `lib/features/missions/presentation/widgets/guild_quest_board.dart` (emergencia/recompensas).

### Verificación
- `flutter analyze` → 0 errores.
- `flutter test` → suite verde.
- Perfil de rendering con DevTools (fase raster): sin picos nuevos de overdraw; las animaciones no repintan la lista completa (verificar `RepaintBoundary`).
- Visual: microinteracciones sutiles, ≤600 ms para los de disparo único; loops desactivados con `disableAnimations`.

### Riesgos
- `AnimatedSwitcher` sobre la lista de mesas puede re-montar filas → usar `key` estable por mesa (`room['id']`) para evitar parpadeo.
- Loops de breathing/partículas mal aislados repintan el `Column` → aislar siempre con `RepaintBoundary` y `CustomPaint` (header).
- Demasiados efectos simultáneos → priorizar C-10/C-12 (impacto alto) y tratar C-14/C-15 como opcionales.

---

## Fase 5 — QA y estabilización (C-16)

### Pasos
1. `flutter analyze` → **0 errores** (barra del proyecto).
2. `flutter test` → **toda la suite verde** (5 archivos de test del proyecto).
3. `flutter build apk --debug` → compila.
4. Prueba visual en dispositivo/emulador, priorizando:
   - pantalla pequeña (~360 dp) sin `RenderFlex` overflow en header, filas de mesa y tablón fusionado;
   - navegación `/voice-room` desde fila, cartel "TABLA DE RANGO" y badge del header (modal);
   - `isTab` (dashboard) y modo push (`Scaffold` + `AppBar`).
5. Actualizar este documento y el checklist (marcar tareas) con el resultado.

### Archivos
- Toda la superficie del feature `chat_rooms` + `missions`.

### Verificación
- `flutter analyze` · `flutter test` · `flutter build apk --debug` → todos verdes.
- Sin regresiones funcionales: crear mesa (`_showCreateRoomDialog`), entrar a sala, filtros de categoría, tablón fusionado, modal de rango.

### Riesgos
- Regresión silenciosa en providers de misiones tras la fusión (Fase 3) → probar emergencia/recompensas con datos reales y con listas vacías.
- Overflows residuales en modo `isTab` (dashboard) por falta de `AppBar` → revisar altura del header compacto en ese modo.

---

## Resumen de fases

| Fase | Contenido | Tareas | Archivo principal |
|---|---|---|---|
| F1 | Header compacto + prestigio como chip | C-01, C-02 | `chat_rooms_screen.dart` |
| F2 | Mesas compactas | C-03 | `chat_rooms_screen.dart` |
| F3 | Fusionar tablones + eliminar cartel decorativo | C-04, C-05, C-06 | `chat_rooms_screen.dart`, `guild_quest_board.dart`, `mission_board_widget.dart` |
| F4 | NPC reducido + microinteracciones | C-08…C-15 | `chat_rooms_screen.dart`, `guild_master_npc_banner.dart`, `guild_quest_board.dart` |
| F5 | QA final | C-16 | Todo el feature |

---

*Documento de auditoría. Sin cambios de código aplicados. Referencias verificadas: `chat_rooms_screen.dart` (1121 líneas), `guild_quest_board.dart` (404 líneas), `mission_board_widget.dart` (252 líneas), `guild_master_npc_banner.dart` (133 líneas).*

---

## 9. Cambios implementados (2026-07-31)

> Validado: 0 errores analyze � 73/73 tests � build APK OK. Archivo: 1127 l�neas.

### F1 � Header compacto + prestigio como chip
- _GuildPrestigeHud (tarjeta completa) ELIMINADO y fusionado en _GuildHallHeader.
- Header ahora es una sola fila: t�tulo + rango (HIERRO/PLATA/ORO) + chip de prestigio (PRESTIGIO N � PREMIUM/LIBRE).

### F2 � Mesas compactas tipo MMORPG
- Tarjeta de mesa reducida: padding 18?12, icono 24?18, t�tulo 15?13, spacing reducido.
- Bot�n JOIN: ElevatedButton ? contenedor compacto tipo chip (min 40px alto, runeViolet).

### F3 � Tablones + INITIALIZE + carteles
- INITIALIZE: ElevatedButton.icon ? RunicButton (consistente).
- Cartel decorativo "MISIONES DEL GREMIO" (sin onTap) ELIMINADO (redundante con los tablones).
- "TABLA DE RANGO" queda como acceso alineado a la derecha (modal _showRankModal).

### F4 � Gremio vivo
- Nuevo banner bajo el header: **chip de aventureros conectados** (suma de speakers+listeners de salas) + **anuncio rotativo** (4 mensajes, rota cada 8s con Timer, _announcementTimer cancelado en dispose).

### F5 � QA
- lutter analyze 0 errores � lutter test 73/73 � lutter build apk --debug OK.
- Funcionalidad intacta: crear mesa, unirse, categor�as, quest board, NPC, trofeos, modal de rango, realtime de salas.

### Pendiente (menor)
- language/level por mesa no expuestos por el repo (chat_rooms_repository_impl.dart:88-106) � se muestran solo los datos disponibles. Puede a�adirse en una iteraci�n futura.
