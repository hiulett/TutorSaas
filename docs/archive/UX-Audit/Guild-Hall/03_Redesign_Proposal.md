# Propuesta de Rediseño del Guild Hall — 03

> **Ámbito:** Pantalla `/chat-rooms` (Guild Hall)
> **Archivo principal:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (1.121 líneas)
> **Base:** Estado actual documentado en `01_Current_State.md` y problemas priorizados en `02_UX_Problems.md`
> **Estado:** Propuesta — sin cambios de código
> **Fecha:** 2026-08-01

---

## 0. Contexto verificado

La pantalla renderiza actualmente **11 bloques** en un único `SingleChildScrollView` (`chat_rooms_screen.dart:382–711`):

| # | Bloque | Render | Definición |
|---|--------|--------|-----------|
| 1 | `_GuildHallHeader` (título + emblema CEFR) | `:389` | `:811` |
| 2 | `_GuildPrestigeHud` (tarjeta completa) | `:394` | `:758` |
| 3 | Título «MESAS DEL GREMIO» + botón INITIALIZE | `:399–423` | botón `:411`; diálogo `:198` |
| 4 | Selector de categorías horizontal (48 px) | `:427–492` | `_categoryLabels` `:58` |
| 5 | Lista de mesas (`roomsAsync.when` + `ListView.separated`) | `:496–660` | — |
| 6 | `GuildQuestBoard` (tablón 1) | `:665` | widget externo |
| 7 | `MissionBoardWidget` (tablón 2) | `:669` | widget externo |
| 8 | `GuildMasterNpcBanner` (NPC) | `:674` | widget externo |
| 9 | `_GuildTrophies` (vitrina) | `:679` | `:963` |
| 10a | Cartel «MISIONES DEL GREMIO» (sin `onTap`) | `:689–694` | `_GuildPoster` `:879` |
| 10b | Cartel «TABLA DE RANGO» (→ `_showRankModal`) | `:698–704` | `_showRankModal` `:139` |

**Datos disponibles por sala** (desde `chatRoomsListProvider`, `chat_rooms_repository_impl.dart:88–106`): `id`, `title`, `category`, `room_type`, `description`, `moderator_id`, `moderator_type`, `has_ai_moderator`, `mana_cost_per_min`, `max_speakers`, `speakers_count`, `listeners_count`, `created_at`.
> ⚠️ **No existen campos `language` ni `level` por sala** en el mapa actual. Cualquier propuesta que los muestre debe derivarlos (p. ej. de `category`/`room_type`) o añadirlos al repo/DB (ver §4.3).

**Design system disponible:** `GlassCard` (`lib/core/widgets/glass_card.dart`), `RunicButton` (`runic_button.dart`), `CyberManhwaBackground` con `CyberBgMode.guildHall` (acento `royalGold`, `cyber_manhwa_background.dart:100–102`), `SegmentedBar` (`segmented_bar.dart`), `RpgAvatar` (`rpg_avatar.dart`), `SystemSnack` (`system_snack.dart`), `AppTypography` (`app_typography.dart`), `AppColors` (`app_colors.dart`). Reglas: radio 4px, sin hex hardcodeados, `GlassCard` como única identidad de tarjeta (`AppColors.glassOpacity 0.94`, `glassBlur 4.0`).

---

## 1. Principio rector

> **Ordenar el scroll por intención:** actuar (mesas) → progresar (misiones) → reconocer (rango/prestigio) → coleccionar (trofeos).

La acción principal del gremio —**entrar a una mesa a conversar**— debe estar visible en el primer viewport, no tras 8 bloques de ambientación. Todo lo que no es acción se compacta a franjas, chips o se mueve a modales/perfil.

---

## 2. Jerarquía por niveles de contenido

Se clasifica cada elemento según su prioridad funcional. Nivel 1 = siempre visible; Nivel 2 = visible con scroll corto o tras un toque; Nivel 3 = oculto/colección.

| Nivel | Contenido | Formato propuesto | Justificación |
|-------|-----------|-------------------|---------------|
| **N1 — Siempre visible** | Mesas (lista) · Crear mesa (expedición) · Eventos activos (badges) | Header compacto + lista de mesas + chips de eventos | Es la razón de existir del gremio: el usuario entra, ve mesas y decide en contexto. |
| **N2 — Scroll corto / modal** | Quest Board (tablón) · Ranking (modal `_showRankModal`) · Prestigio (chip) | Tablón tras las mesas; ranking como modal; prestigio como chip en el header | Misiones alimentan retención; ranking y prestigio son consultas puntuales, no foco. |
| **N3 — Colección / decoración** | Trofeos · NPC · carteles | Vitrina compacta al final; NPC como franja de una línea; decoración como contenedores de bajo ruido | Reconocimiento y ambientación no deben competir con la acción. |

### Mapa elemento → nivel
| Elemento actual | Nivel propuesto | Transformación |
|-----------------|-----------------|----------------|
| `_GuildPrestigeHud` (tarjeta, `:758`) | N2 | → chip/badge compacto en el header (§6) |
| Título MESAS + INITIALIZE (`:399`) | N1 | Header de sección con `RunicButton` «EXPEDICIÓN» (§4.2, §5) |
| Selector de categorías (`:427`) | N1 | Se conserva arriba de la lista, más compacto (36–40 px) |
| Lista de mesas (`:496`) | N1 | Tarjetas horizontales compactas estilo Discord/MMORPG (§4.1) |
| `GuildQuestBoard` (`:665`) | N2 | Tablón tipo Solo Leveling con badges de color (§7) |
| `MissionBoardWidget` (`:669`) | N2 | Se fusiona/se muestra solo con misiones activas (§7.1) |
| `GuildMasterNpcBanner` (`:674`) | N3 | Franja de una línea (avatar pequeño + sugerencia + CTA inline) (§8) |
| `_GuildTrophies` (`:679`) | N3 | Vitrina compacta al final (§9) |
| Cartel «MISIONES DEL GREMIO» (`:689`, sin `onTap`) | — | **Eliminar** (redundante con el tablón) |
| Cartel «TABLA DE RANGO» (`:698`) | N2 | → botón/modal `_showRankModal` ya existente (§7.2) |

---

## 3. Orden de render objetivo (resumen)

```
Header (título + emblema + prestigio-chip + contador conectados)
  ↓
Anuncio del gremio (1 línea rotativa)      [N2 · opcional]
  ↓
MESAS (header + EXPEDICIÓN + filtros)
  ↓
Lista compacta de mesas                    [N1]
  ↓
Eventos activos (badges)                   [N1 · si hay]
  ↓
Quest Board tipo Solo Leveling             [N2]
  ↓
NPC franja compacta                        [N3]
  ↓
Ranking (modal) + prestigio detalle        [N2 · accesible desde header]
  ↓
Vitrina de trofeos (compacta)              [N3]
```

Detalle de cada bloque y wireframe en `04_New_Layout.md`.

---

## 4. Mesas como componente principal

### 4.1 Lista compacta estilo Discord / MMORPG

Sustituir la tarjeta vertical actual (`GlassCard` con icono grande + texto, `chat_rooms_screen.dart:525–640`) por una **fila horizontal compacta de una línea**, una por mesa, que se reutiliza también en estado de «mesa llena/vacía».

Campos por mesa (fuente actual entre paréntesis):
| Campo | Fuente | Presentación |
|-------|--------|--------------|
| Nombre | `title` (`repo:93`) | `Text` mono/body, `maxLines: 1`, ellipsis |
| Idioma | `category` derivado o campo nuevo (ver §4.3) | chip 8px: «ES», «EN», «PT» |
| Nivel | derivado de `room_type` (IA=libre, MENTORÍA, EVENTO) o `level` nuevo | chip 8px con acento por tipo |
| Moderador | `moderator_type` (`repo:98`) o `moderator_id` | `RpgAvatar` 20–24 px (si `moderator_type == 'ai'` → `HunterCatalog.oracle`) |
| Participantes | `speakers_count` + `max_speakers` (`repo:101–102`) | `SegmentedBar` 5 segmentos + `x/6` mono |
| Oyentes | `listeners_count` (`repo:103`) | icono 👂 + número, solo si > 0 |
| Estado | derivado de `speakers_count` vs `max_speakers` | pill: «VACÍA» / «DISPONIBLE» / «LLENA» |
| Acción | — | botón «ENTRAR» (`l10n.guild_join`) o chevron si llena |

Estructura de la fila (compacta, alto ≈ 56–64 px):
```
[icono categoría] Nombre          [ES][NIVEL]     ══▓▓▓░░  3/6  👂4  [ENTRAR]
[avatar mod]                        (SegmentedBar)  mono  oyentes   RunicButton
```

**Reglas de la lista:**
- Tarjetas **horizontales compactas**, no verticales enormes: alto fijo, menos padding (12 en vez de 18, `:532`), tipografía reducida.
- El tap de la fila mantiene `context.push('/voice-room?roomId=${room['id']}')` (`:527`).
- **Mesas llenas** (`speakers_count >= max_speakers`): el botón queda deshabilitado/difuminado y la fila con opacidad 0.6 → el usuario escanea rápido las disponibles.
- **Agrupar por estado** dentro de la categoría seleccionada: disponibles primero, luego llenas (usa el orden del repo `order('created_at')` como tie-break, `repo:64`).
- Mantener el estado `_selectedCategory` (`:54`) y el filtrado actual (`:498–500`).

### 4.2 Header de mesas con acción única

Un único punto de creación. El botón `ElevatedButton.icon` INITIALIZE actual (`:411–421`) se reemplaza por `RunicButton` (consistencia DS, ver problema E en `01_Current_State.md`), con label corto tipo **«EXPEDICIÓN»** o «CREAR MESA» (`l10n.initialize_room`).

### 4.3 Idioma y nivel por mesa: fuentes de datos

- **Opción A (cero cambios de DB):** derivar «idioma» del `category` (p. ej. `travel → EN` según `progress['language']` del jugador o un mapa estático) y «nivel» del `room_type` (`ai_practice` → NIVEL LIBRE; `mentorship` → por CEFR del moderador; `event` → ESPECIAL).
- **Opción B (precisa, requiere migración):** añadir columnas `language` y `target_cefr` a `chat_rooms` y exponerlas en `getRooms` (`chat_rooms_repository_impl.dart:88–106`) y `createRoom` (`:113–135`).
- **Recomendación:** empezar con A (no bloqueante, sin RLS/DDL) y migrar a B cuando se cree la mesa-expedición con nivel objetivo (§5).

---

## 5. Crear mesa como «expedición»

Rediseñar `_showCreateRoomDialog` (`chat_rooms_screen.dart:198–352`) para que la acción se sienta como **abrir una expedición**, no como un formulario CRUD. Mantiene `SystemWindow`, radio 4px y los colores existentes.

| Paso | Campo actual (`:198–352`) | Propuesta |
|------|---------------------------|-----------|
| 1 | Título «GUILD TABLE TITLE» (`:226`) | Label «NOMBRE DE LA EXPEDICIÓN» + placeholder narrativo («Ejem. Cazar dragones en pasado simple») |
| 2 | Categoría «CATEGORY PATH» (`:243`) | «TERRITORIO» — se mantiene, renombrado |
| 3 | Tipo «TABLE TYPE» (`:266–291`) | «RANGO DE LA EXPEDICIÓN»: `ai_practice` → «LIBRE · CUALQUIER NIVEL», `mentorship` → «MANDO · NIVEL X», `event` → «RAID · EVENTO ESPECIAL» |
| 4 | — | **Nuevo (opcional):** selector de nivel objetivo CEFR (A1–C2) usando chips 4px (patrón `_FilterChip`, `guild_quest_board.dart:110–148`) → alimentaría el campo `target_cefr` de la Opción B |
| 5 | Botones CANCEL / INITIALIZE (`:293–343`) | Botón primario `RunicButton` «INICIAR EXPEDICIÓN»; al éxito `SystemSnack` de tipo `reward` con el nombre de la mesa (en lugar del `SnackBar` genérico de error/success) |

**Feedback post-creación:** conservar `ref.invalidate(chatRoomsListProvider)` + `context.push('/voice-room?roomId=...')` (`:322–323`). Añadir `SystemSnack.show(context, 'Expedición ${title} abierta', type: SystemSnackType.reward)` antes del push.

**No romper:** la firma `createRoom(title, category, moderatorId, roomType)` (`repo:113`) y la auto-join del moderador al slot 1 (`repo:126–132`).

---

## 6. Prestigio como chip en el header

`_GuildPrestigeHud` (`chat_rooms_screen.dart:758–806`) deja de ser una tarjeta completa y pasa a ser un **badge compacto** integrado en `_GuildHallHeader` (`:811`), a la derecha del emblema de rango CEFR.

Formato propuesto (una línea, al lado del emblema `:848–869`):
```
[🏆] PRESTIGIO  Nv12  PREMIUM    ← GlassCard pequeño, borderColor royalGold/manaCyan
```
- Reutiliza la lógica de `battlePassProvider` y los campos `level`/`is_premium` (`:763–766`) sin cambios.
- Si se desea detalle (XP del pase, próximo hito), el tap del chip abre un modal pequeño (mismo patrón `SystemWindow` de `_showRankModal` `:139–196`).
- **Libera ~1 bloque** de altura para las mesas.

---

## 7. Quest Board tipo «Solo Leveling»

Transformar `GuildQuestBoard` (`guild_quest_board.dart:13–108`) en un **tablón de avisos clasificado por urgencia** en vez de filtros de tipo planos. Mantiene los providers `guildQuestPoolProvider` y `guildMissionsProvider` (`:25–26`) y el orden por estado (`_sortByRank`, `:314–324`).

### 7.1 Taxonomía visual con badges de color

En lugar de los 4 filtros actuales (`:50–53`), se presentan **categorías con badges** y un filtro «TODAS»:
| Badge | Tipo | Color propuesto (AppColors) | Icono |
|-------|------|----------------------------|-------|
| ⚡ NUEVAS | `questType` no visto | `manaCyan` | `flash_on_rounded` |
| 🚨 URGENTES | `emergencyMissionsProvider` (`mission_board_widget.dart:17`) | `crimsonRed` | `warning_amber_rounded` |
| ⏳ TEMPORALES | con `expiresAt` próximo | `guildAmber` | `schedule_rounded` |
| 👑 ÉPICAS | `room_type == 'event'` aliado | `royalGold` | `military_tech_rounded` |
| 🤝 COMUNITARIAS | `questType == 'collaborative'` | `runeViolet` | `groups_rounded` |
| 📅 SEMANALES | `questType == 'weekly'` | `collabBlue` | `calendar_month_rounded` |

- Cada tarjeta muestra **un** badge de prioridad en la esquina superior derecha (reutilizando el patrón `_StatusPill`, `guild_quest_board.dart:327–352`).
- Los badges son **contenedores estáticos de 4px**, sin animación; solo el badge URGENTE puede tener un `pulse` muy sutil (uno por pantalla, sin parpadeo agresivo).

### 7.2 Evitar duplicidad con `MissionBoardWidget`

Actualmente hay **dos tablones consecutivos** (`chat_rooms_screen.dart:665` y `:669`). Propuesta:
- Unificar en **un único tablón**: `GuildQuestBoard` como el bloque principal (misiones del gremio), y `MissionBoardWidget` solo muestra las misiones **activas/urgentes** del jugador como sub-sección «TU GRUPO» cuando existan (`mission_board_widget.dart:81–122`).
- Alternativa mínima: renderizar `MissionBoardWidget` solo si `activeMissions`/`emergency` no está vacío (ya devuelve `SizedBox.shrink()` si está vacío en `:39`, `:83`), evitando el doble encabezado «TABLÓN DE MISIONES»/«TABLÓN DEL GREMIO».
- **Eliminar** el cartel decorativo «MISIONES DEL GREMIO» sin `onTap` (`chat_rooms_screen.dart:689–694`): es redundancia pura.

---

## 8. Ranking como modal (no compite con mesas)

- Mantener `_showRankModal` (`chat_rooms_screen.dart:139–196`) como **única** representación del ranking: ya abre un `SystemWindow` «ESTADO DE RANGO» con CEFR, XP e idioma.
- El acceso deja de ser el cartel grande `_GuildPoster` (`:698–704`) y pasa a ser un **botón compacto** junto al prestigio-chip del header (icono `military_tech_rounded`, label «RANGO»), o un `RunicButton` pequeño al pie del bloque de prestigio.
- Si se quiere escalafón del gremio (ladder CEFR hierro/plata/oro), se amplía el contenido del modal, pero **sin** convertirlo en pantalla que robe el foco del lobby.
- Eliminar el cartel «TABLA DE RANGO» como bloque de pantalla completa (su función vive en el header).

---

## 9. Trofeos: mover al perfil + vitrina compacta al final

**Evaluación:** los trofeos (`_GuildTrophies`, `chat_rooms_screen.dart:963–1039`) son estado/reconocimiento (N3), no acción.

- **Recomendado:** mover la colección completa de trofeos al **perfil del cazador** (pantalla `hunter-status`/`status_window_modal.dart` o colecciones del jugador), siguiendo el patrón de las colecciones del cazador (economy/collections_screen). El Gremio mantiene solo una **vitrina compacta**.
- **Vitrina compacta al final del Guild Hall:** en vez de 4 tiles verticales (`:1029–1033`), una fila horizontal de **mini-esculturas** (icono 28 px + nombre debajo), con la cuenta `unlocked/4` como ya existe (`:1011–1017`). El tile desbloqueado conserva el acento del trofeo; el bloqueado, la escala de grises (`:1111–1119`).
- Fuente de datos intacta: `guildCompletedMissionsProvider` (`:25–43`) y cálculo `unlocked` (`:977`).
- **No eliminar** la lógica ni el widget; solo cambiar su presentación y posición.

---

## 10. «Gremio vivo» sin saturar

El gremio debe sentirse vivo **sin** animaciones invasivas ni bloques nuevos grandes. Propuestas de bajo ruido:

| Recurso | Implementación | Fuente | Ruido |
|---------|----------------|--------|-------|
| **Contador de aventureros conectados** | Chip en el header: `[👥 24]`, actualizado por realtime | Suma de `speakers_count + listeners_count` de `chatRoomsListProvider` (ya invalida en realtime, `:73–88`) | Nulo (1 línea) |
| **Anuncios del gremio (1 línea rotativa)** | Franja mono de una línea bajo el header; rota cada ~8 s con `AnimatedSwitcher` (fade, no slide) | Array local de strings o tabla `guild_announcements` | Bajo (solo texto, sin fondos) |
| **Eventos activos (badges)** | Chips bajo la lista de mesas: `[RAID · HOY 20:00]` | Mesas con `room_type == 'event'` (`repo:95`) que aún no hayan expirado | Bajo (solo si hay eventos) |
| **Decoración sutil (tapices/vitrales)** | Contenedores decorativos detrás de bloques N3 (NPC/trofeos) usando `GlassCard` con `borderColor`/`showRunicCorners`; **sin** `CustomPainter` complejo ni fondos animados extra | `glass_card.dart:15–18,23–24` | Nulo |
| **Maná / partículas** | NO añadir: `CyberManhwaBackground` ya anima partículas de fondo (`cyber_manhwa_background.dart:45–73`). El contenido debe quedarse quieto. | existente | — |

**Regla anti-invasiva:** ninguna de estas adiciones usa animaciones repetidas a bucle, zoom, parallax en contenido ni efectos que compitan con la lectura. El único movimiento aprobado es el `AnimatedSwitcher` de 250–300 ms de los anuncios.

---

## 11. Impacto esperado

- La **primera mesa y el botón ENTRAR** quedan en el primer viewport → se elimina el scroll de 8 bloques hasta la acción principal.
- El scroll queda ordenado por intención: **actuar → progresar → reconocer → coleccionar**.
- Prestigio y NPC pasan de bloques completos a franjas/chips: ~2 viewports liberados.
- Se eliminan 2 elementos redundantes (cartel de misiones muerto + doble tablón).
- El «gremio vivo» se percibe con contador de conectados, anuncios de 1 línea y badges de eventos, sin sacrificar densidad ni rendimiento.
- Consistencia de design system: `RunicButton` en lugar de `ElevatedButton` para crear mesa/entrar.

---

## 12. Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|-----------|
| Romper la creación de salas | Conservar `_showCreateRoomDialog` (`:198`) y la firma `createRoom` (`repo:113`); solo cambiar la UI del diálogo. |
| Romper el realtime | No tocar `_subscribeToRoomsRealtime` (`:73–88`) ni `_roomsChannel`; la lista sigue consumiendo `chatRoomsListProvider`. |
| Añadir `language`/`level` sin columna en DB | Empezar con derivación (Opción A, §4.3); la columna es opcional y aplazable. |
| Perder sugerencia del NPC | La franja compacta conserva `_suggestForLevel`/`_suggestedRoomKeyword` (`guild_master_npc_banner.dart:17–47`) y el CTA `:96–126`. |
| Perder acceso al ranking | `_showRankModal` (`:139`) se conserva y gana acceso desde el header. |
| Perder el conteo de trofeos | `guildCompletedMissionsProvider` (`:25–43`) y `unlocked` (`:977`) intactos; solo cambia presentación. |
| Regresión de diseño | Seguir `GlassCard`, radio 4px, `AppColors`, `AppTypography`; sin hex hardcodeados ni radios >20 px. |
| Doble render de misiones | Unificar en un único tablón (§7.1) o condicionar `MissionBoardWidget` a tener contenido (`:39`, `:83`). |

---

## 13. Decisiones abiertas

- ¿Idioma/nivel por mesa: **derivar** (A) o **columna nueva** (B) en `chat_rooms`?
- ¿La mesa-expedición incluye **nivel objetivo CEFR** en el diálogo (paso 4, §5) desde el inicio o en una iteración posterior?
- ¿Los trofeos **se mueven al perfil** del todo (recomendado) o solo se compactan en el Guild Hall?
- ¿Los anuncios del gremio son un array local temporal o una tabla `guild_announcements` administrada?
- ¿El chip de contador de conectados cuenta solo mesas activas o incluye a los que están en el salón sin mesa?
