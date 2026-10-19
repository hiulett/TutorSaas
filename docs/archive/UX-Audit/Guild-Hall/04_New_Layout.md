# Nuevo Layout del Guild Hall — 04

> **Ámbito:** Pantalla `/chat-rooms` (Guild Hall)
> **Propuesta asociada:** `03_Redesign_Proposal.md`
> **Estado:** Wireframe textual — sin cambios de código
> **Fecha:** 2026-08-01

---

## 1. Orden de render propuesto (arriba → abajo)

```
┌────────────────────────────────────────────────────────────────────┐
│ 0  Fondo: CyberManhwaBackground (CyberBgMode.guildHall)             │
│    (partículas ya existentes :45–73 — el contenido no anima)        │
├────────────────────────────────────────────────────────────────────┤
│ 1  HEADER COMPACTO DEL GREMIO                                       │
│    [‹] GRAN SALÓN ........................ [👥 24] [🏆 Nv12] [RANGO]│
│        emblema CEFR (hierro/plata/oro) · prestigio-chip · contador  │
├────────────────────────────────────────────────────────────────────┤
│ 2  ANUNCIO DEL GREMIO (1 línea rotativa, fade 300ms)                │
│    «⚑ Raid de hoy 20:00 en la Mesa de Tácticas — reunión 19:45»     │
├────────────────────────────────────────────────────────────────────┤
│ 3  MESAS (NIVEL 1 — SIEMPRE VISIBLE)                               │
│    MESAS DEL GREMIO ......................... [＋ EXPEDICIÓN]       │
│    [TODAS] [VIAJES] [TRABAJO] [TECNOLOGÍA] [ARTE] [COCINA]          │
│                                                                     │
│    ┌ [🗺] Taberna del Aprendiz  [EN][LIBRE] ══▓▓▓░░ 3/6 👂4 [ENTRAR]│
│    │     [avatar mod]                                                │
│    ├ [💼] Mesa Redonda de Tácticas [EN][MANDO] ═▓▓▓░░ 2/6  0  [ENTRAR]│
│    ├ [🎨] Cazadores del Arte    [EN][LIBRE] ══░░░░░ 0/6  0  [ENTRAR]│
│    └ [🍳] Cocina Épica (llena)  [EN][EVENTO] ═▓▓▓▓▓ 6/6 12  [LLENA]│
├────────────────────────────────────────────────────────────────────┤
│ 4  EVENTOS ACTIVOS (solo si hay)  [N1]                              │
│    [🏴 RAID · HOY 20:00] [⚔️ TORNEO · SÁB 18:00]                    │
├────────────────────────────────────────────────────────────────────┤
│ 5  QUEST BOARD TIPO SOLO LEVELING (NIVEL 2)                        │
│    TABLÓN DEL GREMIO                                                │
│    [TODAS] [⚡NUEVAS] [🚨URGENTES] [⏳TEMPORALES] [👑ÉPICAS]        │
│    [🤝COMUNITARIAS] [📅SEMANALES]                                   │
│    ┌ 🚨 [warning] «Habla 10 min con un nativo»  ⏱ 45m  🚨URGENTE   │
│    │   ◆ 50 ◆ +120 XP  ▓▓▓▓▓░░░░ 3/10                              │
│    └ 👑 [flag] «Derrota al Boss de la Taberna»  ⏱ —   👑ÉPICA      │
│    ── TU GRUPO (solo si hay misiones activas) ─────────────────     │
│    ┌ 💎 «Completa 2 raids»  ▓▓▓░░ 1/2  ◆20 +40XP  [RECLAMAR]       │
│    └ ...                                                            │
├────────────────────────────────────────────────────────────────────┤
│ 6  NPC MAESTRE DE MESA — franja compacta (NIVEL 3)                  │
│    [🔮] MAESTRE · RANGO 5  «Recomiendo la Taberna del Aprendiz…» →  │
├────────────────────────────────────────────────────────────────────┤
│ 7  VITRINA DE TROFEOS — compacta (NIVEL 3)                          │
│    TROFEOS DEL GREMIO                           2/4                 │
│    [🏆] [🏆] [🔒] [🔒]   (mini-esculturas en fila)                 │
└────────────────────────────────────────────────────────────────────┘
```

> El bloque inferior de padding (`chat_rooms_screen.dart:710`, `SizedBox(height: 100)`) se conserva para el gesto de refresco.

---

## 2. Descripción de cada bloque

### Bloque 1 — Header compacto del gremio (N1)
**Nace de:** `_GuildHallHeader` (`chat_rooms_screen.dart:811`) + `_GuildPrestigeHud` (`:758`) compactado + ranking como botón.
- Fila 1: título «GRAN SALÓN» (`l10n.guild_hall`) + a la derecha **chip de conectados** `[👥 24]` y **chip de prestigio** `[🏆 Nv12 PREMIUM]` y **botón RANGO** (abre `_showRankModal`, `:139`).
- Fila 2: emblema de rango CEFR (sin cambios, `:848–869`).
- Los tres chips usan `GlassCard` minúsculo (padding 8–10) o contenedores 4px; **no** hay tarjeta de prestigio completa.
- **Objetivo:** todo el estado del jugador en una línea, sin ocupar viewport.

### Bloque 2 — Anuncio del gremio (N2 · opcional)
- Franja mono de **una sola línea** bajo el header, con `AnimatedSwitcher` (fade 250–300 ms) que rota cada ~8 s.
- Fuente: array local o tabla `guild_announcements` (decisión abierta en `03_Redesign_Proposal.md` §13).
- **Sin** animaciones de slide/zoom ni fondos; solo texto con icono pequeño.

### Bloque 3 — Mesas (N1 · siempre visible)
**Nace de:** título MESAS + INITIALIZE (`:399–423`) + selector de categorías (`:427–492`) + lista de mesas (`:496–660`), reescritos como componente compacto.
- Header de sección con `RunicButton` **«＋ EXPEDICIÓN»** (antes `ElevatedButton.icon`, `:411`) que abre el diálogo-expedición (`_showCreateRoomDialog` reescrito, §5 de la propuesta).
- Selector de categorías horizontal, altura reducida (36–40 px) y mismo estado `_selectedCategory` (`:54`).
- **Lista compacta** de filas de una línea (§4.1 de la propuesta): nombre, chips idioma/nivel, `SegmentedBar`, `x/6`, oyentes, botón ENTRAR (`l10n.guild_join`). Mesas llenas → opacidad 0.6 y botón deshabilitado.
- Tap de fila → `context.push('/voice-room?roomId=...')` (`:527`).
- Estados posibles del contenedor: carga (spinner `runeViolet`, `:646`), vacío (`l10n.guild_no_rooms`, `:507`), error (`:655`).

### Bloque 4 — Eventos activos (N1 · condicional)
- Solo se renderiza si hay mesas con `room_type == 'event'` (`repo:95`).
- Chips estáticos `[🏴 RAID · HOY 20:00]` con borde `royalGold`; tap → abre la mesa correspondiente.
- **No** ocupa espacio si no hay eventos.

### Bloque 5 — Quest Board tipo Solo Leveling (N2)
**Nace de:** `GuildQuestBoard` (`guild_quest_board.dart:13–108`) + `MissionBoardWidget` (`mission_board_widget.dart`) unificados.
- Tablón del gremio con filtros por **badge de prioridad** (§7.1 de la propuesta): TODAS / ⚡NUEVAS / 🚨URGENTES / ⏳TEMPORALES / 👑ÉPICAS / 🤝COMUNITARIAS / 📅SEMANALES.
- Tarjetas compactas con un badge de prioridad en la esquina, recompensas (`_GemChip`/`_XpChip`, `guild_quest_board.dart:355–404`) y `SegmentedBar` de progreso.
- Sub-sección «TU GRUPO» solo si hay misiones activas/emergencia del jugador (`mission_board_widget.dart:81–122`), incluyendo el banner de EMERGENCIA (`:37–78`) y las recompensas por reclamar (`:125–153`).
- Se **elimina** el cartel «MISIONES DEL GREMIO» decorativo sin `onTap` (`chat_rooms_screen.dart:689–694`).

### Bloque 6 — NPC Maestre de Mesa compacto (N3)
**Nace de:** `GuildMasterNpcBanner` (`guild_master_npc_banner.dart`) reducido a una franja.
- Avatar pequeño (24 px) + nombre «MAESTRE · RANGO 5» + sugerencia en una línea + CTA «SIGUE MI SUGERENCIA →» (`:96–126`).
- Conserva `_suggestForLevel`/`_suggestedRoomKeyword` (`:17–47`).

### Bloque 7 — Vitrina de trofeos compacta (N3)
**Nace de:** `_GuildTrophies` (`chat_rooms_screen.dart:963–1039`), presentación horizontal.
- Cuenta `unlocked/4` (`:1011–1017`) y mini-esculturas en fila (icono 28 px + nombre debajo).
- Desbloqueados con acento (`:1057`), bloqueados en grises con candado (`:1111–1119`).
- La colección completa (si se aprueba) pasa al perfil del cazador.

---

## 3. Comparación Antes → Después

### 3.1 Orden de render
| # | ANTES (`chat_rooms_screen.dart`) | DESPUÉS (propuesto) | Cambio |
|---|----------------------------------|----------------------|--------|
| 1 | `_GuildHallHeader` `:389` | Header compacto (título + emblema + prestigio-chip + conectados + RANGO) | Mantiene identidad, integra 3 bloques |
| 2 | `_GuildPrestigeHud` tarjeta `:394` | → dentro del header (chip) | ⬇ comprimido |
| 3 | Título MESAS + INITIALIZE `:399` | MESAS + `RunicButton` EXPEDICIÓN `:399-equivalente` | Se mantiene como N1, botón DS |
| 4 | Selector de categorías `:427` | Selector compacto (36–40 px) | ⬇ altura |
| 5 | Lista de mesas `:496` | Lista compacta horizontal | ⬇ altura por fila |
| 6 | `GuildQuestBoard` `:665` | Quest Board Solo Leveling | ⬆ sube antes de NPC/trofeos |
| 7 | `MissionBoardWidget` `:669` | Sub-sección «TU GRUPO» dentro del tablón | ⬇ unificado |
| 8 | `GuildMasterNpcBanner` `:674` | Franja compacta | ⬇ comprimido |
| 9 | `_GuildTrophies` `:679` | Vitrina compacta al final | Mantiene posición, comprime |
| 10a | Cartel «MISIONES» sin tap `:689` | — | 🗑 eliminado |
| 10b | Cartel «TABLA DE RANGO» `:698` | Botón RANGO en header | ⬇ comprimido a botón |

### 3.2 Estimación de altura del primer viewport (pantalla ~800 px útiles)
| Métrica | ANTES | DESPUÉS |
|---------|-------|---------|
| Bloques antes de la primera mesa | 2 (header + prestigio tarjeta) | 1 (header compacto) + anuncio opcional |
| Altura aproximada antes de la lista de mesas | ~250–300 px (header 90 + prestigio ~90 + gap) | ~120–160 px (header compacto + anuncio) |
| Mesas visibles sin scroll | 0–1 | 2–3 (filas de ~60 px) |
| Scroll para llegar al Quest Board | ~1.5–2 viewports | ~0.5–1 viewport |
| Bloques totales de pantalla | 11 | ~7 (con 2 condicionales y 2 eliminados) |

> Estimaciones en px a escala de diseño actual (`EdgeInsets.symmetric(horizontal: 24)` `:384`); los valores exactos dependen del device. La clave es estructural: **la acción (mesa) precede a toda ambientación**.

### 3.3 Carga cognitiva
| Dimensión | ANTES | DESPUÉS |
|-----------|-------|---------|
| Mensajes de estatus repetidos | Prestigio (tarjeta) + emblema header + cartel TABLA DE RANGO (3 representaciones de rango) | 1 header compacto con chips; 1 modal de detalle |
| Tablones de misiones | 2 consecutivos + 1 cartel decorativo | 1 tablón unificado |
| Botones de acción | `ElevatedButton` INITIALIZE + `ElevatedButton` ENTRAR + CTA NPC | `RunicButton` (EXPEDICIÓN/ENTRAR) + CTA NPC inline |
| Sensación de «vivo» | Ninguna (bloques estáticos) | Chip conectados + anuncio rotativo + badges de evento (sin animación invasiva) |

---

## 4. Reglas de implementación (para la fase de código)

1. **No** tocar `_subscribeToRoomsRealtime` (`chat_rooms_screen.dart:73–88`) ni `chatRoomsListProvider` (origen de datos único).
2. Mantener `_showRankModal` (`:139`) y `_showCreateRoomDialog` (`:198`) como métodos, rediseñando solo su contenido/UI.
3. Radio **4px** en chips, filas y badges; `GlassCard` para toda tarjeta; `AppColors`/`AppTypography` para color/tipografía (sin hex inline).
4. Los chips y badges son **estáticos** (sin animación). La única animación nueva permitida es el fade del anuncio (`AnimatedSwitcher`).
5. Mesas llenas: fila atenuada + botón deshabilitado (accesible por estado, no por bloqueo visual puro).
6. Vacíos (sin mesas / sin misiones) conservan mensajes existentes (`l10n.guild_no_rooms`, `_empty()` de `guild_quest_board.dart:96–107`).
7. Conservar el `SizedBox(height: 100)` final (`:710`) y el `RefreshIndicator` (`:379–381`).

---

## 5. Resumen del cambio de experiencia

- **Antes:** el usuario hacía scroll pasando prestigio, NPC y trofeos para llegar a una mesa; la pantalla parecía un catálogo estático de vitrinas.
- **Después:** el usuario entra y **en un vistazo** ve cuántos hay conectados, qué mesas hay abiertas, cuáles están libres o llenas, y el evento del día; las misiones y el ranking quedan a un scroll o un toque; los trofeos y la decoración cierran la experiencia sin robar foco.
