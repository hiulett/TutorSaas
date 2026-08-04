# Rediseño del Salón del Gremio — Hallazgo 04

> **Ámbito:** Pantalla `/chat-rooms` (Gran Salón del Gremio)
> **Archivo principal:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart`
> **Archivos relacionados:**
> - `lib/features/chat_rooms/presentation/widgets/guild_master_npc_banner.dart`
> - `lib/features/missions/presentation/widgets/guild_quest_board.dart`
> - `lib/features/dashboard/presentation/screens/dashboard_screen.dart` (origen del acceso al gremio)
> **Tipo:** Información arquitectónica (IA) / jerarquía de contenido / tiempo hasta la acción principal
> **Estado:** Propuesta — sin cambios de código

---

## 1. Estado actual (orden de render verificado)

`chat_rooms_screen.dart` construye la pantalla como una sola `Column` dentro de `SingleChildScrollView`. El orden real es:

| # | Bloque | Widget / evidencia |
|---|--------|--------------------|
| 1 | AppBar «GRAN SALÓN» + back (`context.pop()`) | `chat_rooms_screen.dart:304-320` |
| 2 | **Cabecera del gremio**: título + emblema de rango por CEFR (A→hierro, B→plata, C→oro) | `_GuildHallHeader`, `:352`, definido `:779-842` |
| 3 | **Hero banner LIVE COOP** con botón INITIALIZE (crear sala) | `chat_rooms_screen.dart:357-414`; diálogo de creación `:137-291` |
| 4 | **NPC grande** Maestre de Mesa con sugerencia por CEFR y CTA «SIGUE MI SUGERENCIA →» | `GuildMasterNpcBanner`, `:419`; widget en `guild_master_npc_banner.dart` |
| 5 | **HUD de prestigio** (tarjeta completa): «PRESTIGIO DEL GREMIO» + NIVEL + PREMIUM/LIBRE | `_GuildPrestigeHud`, `:424`, definido `:726-774` |
| 6 | **Trofeos del gremio** (tarjeta completa con esquinas rúnicas): PRIMERA RAID / 5 RAIDS / 10 RAIDS / RAID DE ÉPICO | `_GuildTrophies`, `:429`, definido `:931-1007`; trofeos `:934-939` |
| 7 | **Tablón del gremio** con filtros TODAS / DIARIAS / SEMANALES / COLABORATIVAS | `GuildQuestBoard`, `:434`; widget `guild_quest_board.dart:13-108` |
| 8 | **Selector de categorías** horizontal («Todos», dinámico desde DB) | `chat_rooms_screen.dart:439-503` |
| 9 | **2 carteles `_GuildPoster`** | `:507-531`: «MISIONES DEL GREMIO» sin `onTap` (`:512-518`); «TABLA DE RANGO» → `/hunter-status` (`:526`) |
| 10 | Título **«MESAS DEL GREMIO»** + **ListView de salas** — la lista es el **último** bloque | `:535-543` y `:564-707` |

### Datos disponibles por sala (para el rediseño del listado)

La lista ya lee de `chatRoomsListProvider` los campos: `id` (`:577`), `title` (`:573`), `speakers_count` (`:571`), `listeners_count` (`:572`), `category` (`:443`), `room_type` (`:619`, valores `ai_practice` / `mentorship` / `event`). El conteo de oradores se muestra como `$speakersCount/6` (`:654`). **No hay campos `idioma` ni `nivel` por sala** en el mapa actual: deberán derivarse (p. ej. `category`) o añadirse al repo si la propuesta los exige.

---

## 2. Hallazgos con evidencia

### Hallazgo 4.1 — La acción principal (unirse a una mesa) está al final de la pantalla

**Evidencia:**
- El `ListView` de salas se renderiza como el bloque 10 de 10: `chat_rooms_screen.dart:564-707`.
- Antes hay 8 bloques de ambientación/información (header, hero, NPC, prestigio, trofeos, tablón, categorías, carteles): `:352-531`.
- El botón de entrada a sala se crea en `:672-684` («UNIRSE» / `guild_join`) y el tap en la tarjeta en `:575-577`.

**Problema:**
- El objetivo primario del gremio («entrar a una mesa a conversar») exige scrollear ~8 bloques. El usuario debe leer NPC, prestigio y trofeos antes de ver la primera mesa disponible. Esto penaliza directamente la métrica de conversión del flujo (entradas a `/voice-room`).

**Justificación:**
- En un lobby MMORPG, el listado de mesas es el foco inmediato; la ambientación (NPC, prestigio, trofeos) es contextual y secundaria. Invertir la jerarquía acerca el valor a un toque.

**Impacto (qué se gana):**
- La primera mesa queda a un vistazo desde el primer viewport → menos scroll hasta la acción.
- El usuario decide en contexto (ver ocupación) sin pasar por bloques de ambientación.

### Hallazgo 4.2 — El NPC y el prestigio consumen espacio desproporcionado respecto a su valor

**Evidencia:**
- `GuildMasterNpcBanner` es un `GlassCard` completo con fila de avatar (emoji 22px en círculo), dos líneas de texto y botón CTA (`guild_master_npc_banner.dart:58-131`).
- `_GuildPrestigeHud` es una `GlassCard` completa con borde (`manaCyan`) y badge interno NIVEL/PREMIUM (`chat_rooms_screen.dart:736-772`).
- Ambos ocupan un bloque completo de la `Column`, duplicando información de rango que ya está en el `_GuildHallHeader` (emblema de hierro/plata/oro, `:779-842`).

**Problema:**
- El «prestigio» (nivel Battle Pass) es un dato de una sola línea (icono + «NIVEL x · PREMIUM») presentado como tarjeta; el NPC repite el rango CEFR ya mostrado en el header con formato más ancho.

**Justificación:**
- Reducir el NPC a una franja compacta (avatar pequeño + sugerencia en una línea + CTA inline) y el prestigio a un badge mantiene la narrativa RPG sin sacrificar viewport.

**Impacto (qué se gana):**
- ~2 bloques de alto se convierten en franjas de una línea → el contenido útil (mesas, misiones) sube dentro del primer viewport.

### Hallazgo 4.3 — Las misiones del gremio están infra-representadas como elemento «principal»

**Evidencia:**
- `GuildQuestBoard` tiene filtros funcionales TODAS / DIARIAS / SEMANALES / COLABORATIVAS y tarjetas con recompensas y progreso (`guild_quest_board.dart:44-108`, tarjetas `:150-291`).
- Sin embargo, se renderiza en el bloque 7 (`chat_rooms_screen.dart:434`), por debajo de NPC, prestigio y trofeos.
- Además hay un cartel decorativo «MISIONES DEL GREMIO» **sin `onTap`** (`:512-518`) justo debajo del tablón funcional — redundancia pura de información.

**Problema:**
- El motor de retención del gremio (misiones diarias/semanales/eventos) queda relegado a mitad de scroll y con un cartel duplicado que no navega a ninguna parte.

**Justificación:**
- La propuesta eleva el tablón como elemento principal (tras las mesas), eliminando el cartel decorativo duplicado.

**Impacto (qué se gana):**
- Las misiones (diarias/semanales/eventos) son visibles al hacer scroll corto; se elimina el cartel muerto.

### Hallazgo 4.4 — Los trofeos y el prestigio compiten por el mismo espacio en el centro de la pantalla

**Evidencia:**
- `_GuildTrophies` renderiza 4 tiles verticales completos (`chat_rooms_screen.dart:995-1002`), cada uno con fila de icono 26px, nombre, estado y check/candado (`:1012-1088`), dentro de un `GlassCard` con `showRunicCorners` (`:947-952`).
- Se sitúan justo después del prestigio (`:424`) y antes del tablón (`:434`): tres bloques «de vitrina» consecutivos.

**Problema:**
- Trofeos y prestigio son datos de estado/reconocimiento, no de acción. Ocupan el centro de la pantalla donde deberían estar las decisiones (mesa a la que entrar, misión a completar).

**Justificación:**
- Bajar los trofeos al final (zona «colección/reconocimiento») y compactar el prestigio a badge libera el centro para contenido de acción.

**Impacto (qué se gana):**
- El scroll queda ordenado por intención: **actuar** (mesas) → **progresar** (misiones) → **coleccionar** (trofeos/prestigio/rango).

### Hallazgo 4.5 — El acceso a la «tabla de rango» navega al editor de stats, no a una tabla de rango

**Evidencia:**
- El cartel «TABLA DE RANGO» hace `context.push('/hunter-status')`: `chat_rooms_screen.dart:526`.
- `/hunter-status` es un **editor** de atributos STR/INT/DEX/LUK con pool de puntos (ver Hallazgo 05), no una tabla de rangos.
- El header del gremio ya muestra el emblema de rango por CEFR (`:779-842`).

**Problema:**
- La promesa del cartel no se cumple: el usuario que toca «TABLA DE RANGO» espera ver el escalafón (hierro/plata/oro + progreso) y termina en un formulario de stats.

**Justificación:**
- La propuesta convierte la tabla de rango en un botón/modal propio (ladder CEFR) o mantiene el acceso al editor como acción explícita «EDITAR ATRIBUTOS», separando ambos conceptos.

**Impacto (qué se gana):**
- Coherencia entre la etiqueta y el destino; el escalafón del gremio pasa a ser consultable sin salir de la pantalla.

### Hallazgo 4.6 — El menú inferior no está dentro del gremio por diseño (pantalla push)

**Evidencia:**
- El menú inferior flotante (MAZMORRAS/GUILD/ESTADO/CONFIG) vive **solo** en `DashboardScreen`: `dashboard_screen.dart:499-540`.
- El gremio se abre con `context.push('/chat-rooms')` desde el banner (`:409`) y desde el ítem GUILD (`:522`), es decir, como ruta apilada (`push`), no como tab.
- `ChatRoomsScreen` ya tiene su propio `AppBar` con back (`context.pop()`): `chat_rooms_screen.dart:304-320`.

**Problema:**
- La ausencia del menú inferior **es correcta** (la pantalla es un push con stack de navegación), pero no está justificada en el diseño: el usuario no sabe si el gremio es un tab o una pantalla secundaria hasta que vuelve atrás.

**Justificación:**
- Mantener `/chat-rooms` como pantalla `push` con header+back (patrón ya usado en `/voice-room`, `/shop`, etc.). **No** añadir el bottom nav dentro del gremio: duplicaría el ítem GUILD y rompería el modelo de stack. El header con back es el patrón canónico de la app para pantallas empujadas.

**Impacto (qué se gana):**
- Coherencia de navegación (push siempre con back; tabs solo en el dashboard) y cero ambigüedad de «¿dónde estoy?» al mantener el título + back en el header.

---

## 3. Propuesta de rediseño (orden de render objetivo)

1. **Mesas primero** — listado compacto tipo lobby MMORPG inmediatamente tras el header:
   - Fila por mesa: nombre, participantes (`speakers/listeners` → `x/6`), idioma (derivado de `category` o campo nuevo), nivel (badge `room_type` o nivel objetivo), estado (derivado de `speakers_count`: vacía/disponible/llena) y botón «ENTRAR».
   - Reutilizar el `ListView` actual (`:564-707`) como primer bloque; mantener el filtro de categorías (`:439-503`) arriba de la lista.
2. **NPC reducido** — franja compacta de una línea (avatar pequeño + sugerencia CEFR + CTA inline), manteniendo la lógica de sugerencia y el botón de acción de `guild_master_npc_banner.dart:17-47,96-126`.
3. **Trofeos abajo** — `_GuildTrophies` se mueve al final (zona colección), con la misma fuente de datos `guildCompletedMissionsProvider` (`:24-42`).
4. **Prestigio compacto** — el nivel Battle Pass se reduce a un badge inline dentro del header de mesas (o del `_GuildHallHeader`), reutilizando la lógica de `_GuildPrestigeHud` (`:726-774`) sin el `GlassCard` completo.
5. **Misiones del gremio como elemento principal** — `GuildQuestBoard` asciende justo después de las mesas; añadir filtro «EVENTOS» alineado con `room_type = 'event'` si se desea; eliminar el cartel decorativo «MISIONES DEL GREMIO» sin `onTap` (`:512-518`).
6. **Tabla de rango como botón/modal** — convertir el cartel «TABLA DE RANGO» (`:520-527`) en un botón que abre un modal con el escalafón CEFR (hierro/plata/oro + progreso), o en su defecto un botón «EDITAR ATRIBUTOS» que conserve el `context.push('/hunter-status')` existente sin prometer «rango».
7. **Menú inferior: no aparece** — documentar que `/chat-rooms` es pantalla `push` con header+back (justificación del Hallazgo 4.6); el bottom nav permanece solo en el dashboard.

Orden de render objetivo: **Header → filtros + mesas → tablón de misiones → NPC compacto → prestigio (badge) → cartel/botón de rango → trofeos**.

---

## 4. Riesgos (lo que NO debe perderse)

| Riesgo | Mitigación |
|--------|-----------|
| Romper la creación de salas (INITIALIZE) | Mantener el diálogo `_showCreateRoomDialog` (`chat_rooms_screen.dart:137-291`) y el botón de crear accesible desde el nuevo header de mesas. |
| Romper la suscripción realtime (`public:chat_rooms`) | No tocar `_subscribeToRoomsRealtime` (`:71-86`) ni `_roomsChannel`; el listado reutiliza `chatRoomsListProvider`. |
| Perder el conteo de trofeos (GUILD-03) | Conservar `guildCompletedMissionsProvider` (`:24-42`) y el cálculo `unlocked` de `_GuildTrophies` (`:943-945`) sin cambios. |
| Perder la sugerencia del NPC (función de ayuda) | La franja compacta conserva `_suggestForLevel`/`_suggestedRoomKeyword` (`guild_master_npc_banner.dart:17-47`) y el CTA «SIGUE MI SUGERENCIA →» (`:96-126`). |
| Perder el acceso a `/hunter-status` | El botón/modal de rango (punto 6) mantiene el destino o lo sustituye por un modal sin eliminar la ruta del router (`router.dart:45-48`). |
| El filtro de categorías queda huérfano al mover la lista | Mover el selector (`:439-503`) junto con la lista (punto 1) manteniendo `_selectedCategory` y el filtrado `:546-550`. |
| Añadir campo «idioma»/«nivel» por sala sin columna en DB | No es bloqueante: derivar de `category`/`room_type` existentes o aplazarlo como campo opcional en el repo (`chat_rooms_repository_impl.dart`). |
| Duplicar el hero LIVE COOP y el botón INITIALIZE en el nuevo header | Un único punto de creación: el botón del header de mesas reemplaza al hero (`:397-407`). |
| Regresión de diseño (GlassCard/4px) | Seguir el design system existente: `GlassCard`, radio 4px, `AppColors` — sin reintroducir radios >20px ni hex hardcodeados. |

---

## 5. Resultado esperado

- La **primera mesa** y el botón «ENTRAR» quedan visibles en el primer viewport → reducción drástica del scroll hasta la acción principal.
- El scroll queda ordenado por intención: mesas (actuar) → misiones (progresar) → rango/trofeos (reconocer).
- Prestigio y NPC pasan de bloques completos a franjas compactas, liberando ~2 viewports.
- El tablón de misiones (diarias/semanales/eventos) se vuelve el segundo elemento en importancia.
- La navegación push + back queda justificada y documentada; no se introduce un menú inferior duplicado.

---

## 6. Decisiones abiertas

- ¿El filtro de misiones gana «EVENTOS» (aliado a `room_type = 'event'`) o se mantienen los 4 actuales (TODAS/DIARIAS/SEMANALES/COLABORATIVAS)?
- ¿La tabla de rango es un **modal** con el ladder CEFR (hierro/plata/oro) o un **botón** que sigue navegando a `/hunter-status` renombrado como «EDITAR ATRIBUTOS»?
- ¿El prestigio compacto vive como badge en el header de mesas o dentro del `_GuildHallHeader`?
- ¿El NPC compacto conserva el CTA de entrada directa a sala o solo muestra la sugerencia (delegando la acción a la lista)?
