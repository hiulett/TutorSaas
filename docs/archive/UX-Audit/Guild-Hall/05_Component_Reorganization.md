# Auditoría UX/UI — Reorganización de Componentes (Guild Hall)

**Proyecto:** TutorSaas / Dungeon of English
**Archivo auditado:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (1121 líneas)
**Fecha de auditoría:** 2026-08-01
**Estado:** Borrador de auditoría — sin cambios de código aplicados

---

## 1. Contexto verificado

### 1.1 Orden de render actual (de arriba a abajo)

1. `_GuildHallHeader` (GUILD-01) — `chat_rooms_screen.dart:389` (definición `:811–874`).
2. `_GuildPrestigeHud` — `:394` (definición `:758–806`).
3. Header de sección "MESAS" + botón `INITIALIZE` — `:399–423` (diálogo `_showCreateRoomDialog` `:198–352`).
4. Selector de categorías (slider horizontal) — `:427–492`.
5. Lista de mesas (`roomsAsync.when`) — `:496–660`.
6. `GuildQuestBoard` (TABLÓN DEL GREMIO) — `:665` (`lib/features/missions/presentation/widgets/guild_quest_board.dart`).
7. `MissionBoardWidget` (TABLÓN DE MISIONES) — `:669` (`lib/features/missions/presentation/widgets/mission_board_widget.dart`).
8. `GuildMasterNpcBanner` (NPC Maestre de Mesa) — `:674` (`lib/features/chat_rooms/presentation/widgets/guild_master_npc_banner.dart`).
9. `_GuildTrophies` (TROFEOS DEL GREMIO) — `:679` (definición `:963–1039`).
10. Carteles `_GuildPoster` × 2 — `:683–708` (definición `:879–944`):
    - Poster "MISIONES DEL GREMIO" **sin `onTap`** (decorativo) — `:689–694`.
    - Poster "TABLA DE RANGO" con `onTap` → `_showRankModal` — `:697–704`.

**Componentes ya existentes (se conservan):** `_showRankModal` (modal) `:139–196`, `_GuildTrophyTile` `:1044–1121`, `guildCompletedMissionsProvider` `:25–43`.

### 1.2 Diagnóstico general

La pantalla mezcla **información de identidad del cazador** (header + prestigio, 2 bloques), **contenido principal** (mesas + categorías) y **contenido secundario** (2 tablones de misiones redundantes + NPC + trofeos + 2 carteles, 5 bloques). Hay **redundancia temática**: el cartel "MISIONES DEL GREMIO" (`:689–694`) repite lo que ya muestran los dos tablones (`:665`, `:669`), y los dos tablones compiten por el mismo espacio de "misiones". El header ocupa ~110 px en un bloque de 2 filas para información que cabe en una sola línea compacta.

---

## 2. Tabla de reorganización por componente

| Componente | Estado actual | Propuesta | Justificación | archivo:línea |
|---|---|---|---|---|
| `_GuildHallHeader` | Cabecera 2 filas (título 24px + chip de rango) | **Convertir → compacto**: 1 línea con avatar + nombre + rango + badge de prestigio | La identidad del cazador se lee de un vistazo; libera ~60 px de scroll vertical antes de las mesas (contenido principal) | `chat_rooms_screen.dart:389`, def `:811–874` |
| `_GuildPrestigeHud` | Tarjeta `GlassCard` completa (fila con label + badge nivel) | **Reducir/Convertir → chip**: nivel + premium en un chip compacto integrado en la línea del header (o junto a él) | El prestigio es dato secundario; como tarjeta compite con la sección de mesas por atención y altura | `:394`, def `:758–806` |
| Sección "MESAS" (header + `INITIALIZE`) | `Row` con título 18px + `ElevatedButton.icon` | **Mantener**, alineado con el nuevo header compacto; revisar contraste y orden (INITIALIZE no debe dominar) | Es el punto de acción principal; mantener la ubicación y la acción, solo compactar si el header libera espacio | `:399–423` |
| Selector de categorías | Slider horizontal 48px con chips seleccionables | **Mantener** (no tocar) | Ya es compacto y funcional; cambios aquí solo por alineación visual con los chips de los tablones | `:427–492` |
| Lista de mesas (rooms) | Tarjetas `GlassCard` grandes (padding 18, icono 24, botón `ENTRAR` por fila) | **Reducir → lista compacta**: fila con icono + título + contadores + chevron, toda la fila tappable; botón `ENTRAR` solo como affordance secundario (o eliminar) | Múltiples tarjetas grandes apilan el scroll; la fila compacta mantiene la acción (tap en fila → `/voice-room`) con menos altura y menos botones en pantalla | `:496–660` |
| `GuildQuestBoard` | Tablón con filtros (TODAS/DIARIAS/SEMANALES/COLABORATIVAS) + cards de quests | **Mantener** + añadir badges de prioridad por quest (ver doc 06) | Es el tablón canónico de misiones del gremio; los filtros ya existen y la estructura es correcta | `guild_quest_board.dart:13–108` |
| `MissionBoardWidget` | Segundo tablón de misiones (activas + emergencia + recompensas) | **Fusionar/Eliminar duplicado**: unificar con `GuildQuestBoard` o integrar emergencia/recompensas como sección dentro del tablón canónico | Dos tablones consecutivos (`:665` + `:669`) presentan la misma categoría de contenido; la emergencia y las recompensas por reclamar deben migrar al tablón fusionado | `:669`, `mission_board_widget.dart:11–157` |
| `GuildMasterNpcBanner` | Banner GlassCard con avatar 🔮 + sugerencia de mesa + CTA | **Mantener reducido**: compactar padding/altura; conservar avatar, sugerencia y CTA "SIGUE MI SUGERENCIA" | El NPC es valor narrativo de la experiencia; se reduce sin eliminar su funcionalidad | `:674`, `guild_master_npc_banner.dart:58–131` |
| `_GuildTrophies` | Vitrina de trofeos (GlassCard con esquinas rúnicas) | **Mantener al final** (no reordenar) | Los trofeos son recompensa de largo plazo; su posición final como "vitrina" es intencional y correcta | `:679`, def `:963–1039` |
| Cartel decorativo "MISIONES DEL GREMIO" | `_GuildPoster` **sin `onTap`** (puramente visual) | **Eliminar** | Duplica el contenido de los tablones (`:665`, `:669`) sin acción alguna; no aporta navegación ni información nueva | `:689–694`, def `:879–944` |
| Cartel "TABLA DE RANGO" | `_GuildPoster` con `onTap` → `_showRankModal` | **Mantener** (con `onTap`); evaluar mover el acceso a rango al header compacto y reducir el cartel a un enlace | Mantiene la navegación a `_showRankModal` (ya existe el modal) y reduce redundancia de accesos | `:697–704`, modal `:139–196` |
| `_showRankModal` | Modal existente (SystemWindow "ESTADO DE RANGO") | **Mantener** | Ya implementado; reaprovechar como destino del badge de rango del header compacto y del cartel "TABLA DE RANGO" | `:139–196` |

---

## 3. Detalle de propuestas

### 3.1 Header compacto (1 línea)

- **Antes:** título grande + chip de rango apilados (`:833–871`).
- **Después:** fila única con avatar (reutilizar `RpgAvatar` si aplica o icono de rango), nombre de cazador, rango CEFR y badge de prestigio (nivel + premium). El badge abre `_showRankModal` al tocarlo.
- **Justificación:** el bloque actual suma ~110 px antes del contenido. Compactarlo a una fila respeta la jerarquía Nivel 1 (siempre visible: identidad + mesas) sin scroll adicional.

### 3.2 Prestigio como chip

- **Antes:** `GlassCard` completa con "PRESTIGIO DEL GREMIO" + `NIVEL x` + `PREMIUM/LIBRE` (`:768–804`).
- **Después:** chip de una sola línea (`NIVEL x · PREMIUM/LIBRE`) integrado en la fila del header o inmediatamente debajo.
- **Justificación:** el label "PRESTIGIO DEL GREMIO" es redundante con el contexto del Guild Hall; el chip conserva la información (nivel de Battle Pass y estado premium) en la mitad de la altura.

### 3.3 Lista de mesas compacta

- **Antes:** `GlassCard` con padding 18, icono en contenedor, título, badge de tipo (IA/MENTORÍA/EVENTO), contadores y `ElevatedButton` `ENTRAR` (`:525–641`).
- **Después:** fila compacta: icono pequeño + título (ellipsis) + badge de tipo + contadores (`x/6`, oyentes) + chevron `>` ; tap en toda la fila → `/voice-room`. El botón `ENTRAR` puede eliminarse o reducirse a un icono tappable (docs 06–07).
- **Justificación:** reduce altura por mesa (~35–40 %) y elimina la dispersión de puntos tappables. La acción principal queda clara (toda la fila).

### 3.4 Tablones de misiones (fusionar)

- **Antes:** `GuildQuestBoard` (`:665`) y `MissionBoardWidget` (`:669`) consecutivos.
- **Después:** un solo tablón canónico (`GuildQuestBoard`) que absorba:
  - el banner de **emergencia** (crimsonRed) de `mission_board_widget.dart:37–78`,
  - las **recompensas por reclamar** (`mission_board_widget.dart:125–153`),
  - las misiones activas del jugador como sección/tab adicional del tablón fusionado (`mission_board_widget.dart:81–122`).
- **Justificación:** elimina duplicación conceptual (ambos renderizan misiones) y libera 1 bloque vertical completo. Se conserva la lógica de datos (providers) intacta; solo cambia la composición visual.

### 3.5 NPC reducido

- **Antes:** GlassCard con padding 14, avatar 22px en contenedor circular, 2 textos y CTA (`guild_master_npc_banner.dart:58–131`).
- **Después:** mantener estructura pero reducir padding y interlineado; el CTA permanece (usa `_suggestedRoomKeyword` para entrar a la mesa sugerida).
- **Justificación:** es el toque narrativo del salón; se compacta sin perder la sugerencia contextual por nivel CEFR.

### 3.6 Carteles

- **Eliminar** el cartel "MISIONES DEL GREMIO" (`:689–694`) por decorativo y redundante.
- **Mantener** "TABLA DE RANGO" (`:697–704`) como acceso secundario al modal ya existente; cuando el header compacto tenga su badge de rango, evaluar reducir este cartel a un enlace simple.

---

## 4. Orden de render propuesto (tras reorganización)

```
Header compacto (avatar + nombre + rango + prestigio badge)  → `_showRankModal` al tocar
Categorías (slider horizontal)  [sin cambios]
MESAS — lista compacta (fila tappable + INITIALIZE)
TABLÓN DEL GREMIO (fusionado: pool + emergencia + recompensas + activas)
NPC Maestre de Mesa (reducido)
TROFEOS DEL GREMIO  [al final, sin cambios]
TABLA DE RANGO (enlace → modal, si no se mueve al header)
```

Se elimina: cartel decorativo "MISIONES DEL GREMIO", segundo tablón duplicado, tarjeta de prestigio y filas grandes de mesa.

---

*Documento de auditoría. Sin cambios de código aplicados. Referencias verificadas: `chat_rooms_screen.dart` (1121 líneas), `guild_quest_board.dart`, `mission_board_widget.dart`, `guild_master_npc_banner.dart`.*
