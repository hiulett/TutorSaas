# Auditoría UX/UI · Arquitectura de la Información — 01. Estado Actual

**Proyecto:** TutorSaas / Dungeon of English (Flutter)
**Fecha de verificación:** 2026-07-31
**Método:** revisión de código (evidencia `archivo:línea`). No se modificó código.
**Alcance:** navegación y rutas, onboarding, dashboard, gremio, estado del cazador y progreso.

---

## 1. Rutas registradas (23 rutas en `lib/app/router.dart`)

| # | Ruta | Pantalla | Archivo de origen |
|---|------|----------|-------------------|
| 1 | `/` | Welcome (login/registro) | `welcome_screen.dart` (`router.dart:29-32`) |
| 2 | `/onboarding` | Onboarding (wizard) | `onboarding_screen.dart` (`router.dart:33-36`) |
| 3 | `/oracle-test` | Conversación con el Oráculo | `oracle_conversation_screen.dart` (`router.dart:37-40`) |
| 4 | `/oracle-quiz` | Test de colocación | `placement_test_screen.dart` (`router.dart:41-44`) |
| 5 | `/hunter-status` | **Edición** de stats del cazador | `hunter_status_screen.dart` (`router.dart:45-48`) |
| 6 | `/dungeon-map` | Mapa de mazmorras | `dungeon_map_screen.dart` (`router.dart:49-52`) |
| 7 | `/home` | Dashboard (4 tabs) | `dashboard_screen.dart` (`router.dart:53-56`) |
| 8 | `/voice-room` | Sala de voz (param `roomId`) | `voice_room_screen.dart` (`router.dart:57-63`) |
| 9 | `/conversation` | Conversación (params `scenarioId`, `scenarioTitle`) | `conversation_screen.dart` (`router.dart:64-74`) |
| 10 | `/summary` | Resumen de sesión | `session_summary_screen.dart` (`router.dart:75-78`) |
| 11 | `/paywall` | Paywall / planes | `paywall_screen.dart` (`router.dart:79-82`) |
| 12 | `/profile` | Perfil | `profile_screen.dart` (`router.dart:83-86`) |
| 13 | `/settings` | Ajustes | `settings_screen.dart` (`router.dart:87-90`) |
| 14 | `/profile-edit` | Edición de perfil | `profile_edit_screen.dart` (`router.dart:91-94`) |
| 15 | `/chat-rooms` | Gremio (salas de voz) | `chat_rooms_screen.dart` (`router.dart:95-98`) |
| 16 | `/level-exam` | Examen de nivel (param `level`) | `level_exam_screen.dart` (`router.dart:99-105`) |
| 17 | `/shop` | Tienda | `shop_screen.dart` (`router.dart:106-109`) |
| 18 | `/inventory` | Inventario | `inventory_screen.dart` (`router.dart:110-113`) |
| 19 | `/battle-pass` | Pase de batalla | `battle_pass_screen.dart` (`router.dart:114-117`) |
| 20 | `/collections` | Colecciones | `collections_screen.dart` (`router.dart:118-121`) |
| 21 | `/fragments-exchange` | Canje de fragmentos | `fragments_exchange_screen.dart` (`router.dart:122-125`) |
| 22 | `/leaderboard` | Clasificación | `leaderboard_screen.dart` (`router.dart:126-129`) |
| 23 | `/disruption` | Error de conexión (param `message`) | `system_mana_disruption_screen.dart` (`router.dart:130-136`) |

---

## 2. Flujo de onboarding (Welcome → Dashboard)

`welcome_screen.dart:25-49` (`_redirectUser`):

- Usuario logueado **y** `isRegisteringProvider == true` → consulta `user_language_profiles`:
  - existe perfil → `context.go('/home')` (`welcome_screen.dart:36-37`)
  - sin perfil → `context.go('/onboarding')` (`welcome_screen.dart:38-39`)
- Usuario logueado y `isRegisteringProvider == false` → **siempre** `/home`, sin comprobar perfil (`welcome_screen.dart:41-44`).
- Cualquier error en la consulta → `/onboarding` (`welcome_screen.dart:45-48`).

- `currentUserProvider` (`auth_providers.dart:20-26`) y `isRegisteringProvider` (`auth_providers.dart:28`, `StateProvider<bool> = false`).
- **No existe flag de "mostrar onboarding siempre" ni modo desarrollador.** Búsqueda exhaustiva sin coincidencias reales (única aparición: comentario no relacionado en `onboarding_screen.dart:194`).

---

## 3. Dashboard (`/home`, `dashboard_screen.dart`, 630 líneas)

`dashboardTabProvider = StateProvider<int>(0)` (`dashboard_screen.dart:33`). Los 4 tabs se resuelven en `dashboard_screen.dart:160-167`:

| Tab | Índice | Contenido | Origen |
|-----|--------|-----------|--------|
| Dungeons | 0 | SingleChildScrollView con la Home (abajo) | `:168-491` |
| Guild | 1 | `SizedBox.shrink()` — **no renderiza nada**, solo navega | `:162-163` |
| Status | 2 | `ProgressTabView` | `:164-165` |
| Config | 3 | `SettingsScreen` | `:166-167` |

### 3.1 Orden real del Tab 0 (Dungeons) — orden verificado

1. **`HunterHudHeader`** (`dashboard_screen.dart:178`).
2. **Fila de insignias**: gemas (tap → `/shop`), racha, estado premium / botón "IR PRO" (tap → `/paywall`) (`:183-305`).
3. **Accesos rápidos — `_buildQuickAccess`** (fila, `:310-344`): son **5**, no 4 → `MAZMORRAS`→`/dungeon-map`, `TIENDA`→`/shop`, `ORÁCULO`→`/oracle-test`, `RANGO`→`/level-exam`, `DIARIA`→`DailyRewardModal`.
4. **"SIGUIENTE RAID"** hero card (`:349-395`): `NextRecommendedLessonHero` con `heroLesson` = primera lección no completada de `recommendedLessonsProvider`, o por nivel CEFR, o primera del catálogo (`:64-74`).
5. **"Salas de Chat de Voz"** banner (GlassCard, `:400-471`), tap → `/chat-rooms` (`:409`).
6. **`LearningPathRoadmap`** (ruta A1–C2) (`:476-478`).
7. **`MissionBoardWidget`** (`:483`).
8. **Menú inferior flotante** (GlassCard, `:499-540`): 4 items `MAZMORRAS` / `GUILD` (tap → `/chat-rooms`) / `ESTADO` / `CONFIG`.

---

## 4. Gremio (`/chat-rooms`, `chat_rooms_screen.dart`, 1089 líneas)

### 4.1 Orden verificado de la pantalla

1. **AppBar** con título "GRAN SALÓN" y back (`chat_rooms_screen.dart:304-320`).
2. **`_GuildHallHeader`** — título + emblema por CEFR (A→hierro, B→plata, C→oro) (`:352`, definido `:779-842`).
3. **Hero banner LIVE COOP** — texto "Mesas del Gremio" + botón **INITIALIZE** (crea sala) (`:357-414`).
4. **`GuildMasterNpcBanner`** — NPC grande con sugerencia de mesa según CEFR y botón "SIGUE MI SUGERENCIA →" (`:419`; widget en `guild_master_npc_banner.dart`).
5. **`_GuildPrestigeHud`** — tarjeta "PRESTIGIO DEL GREMIO" (nivel Battle Pass + premium/libre) (`:424`, definido `:726-774`).
6. **`_GuildTrophies`** — tarjeta "TROFEOS DEL GREMIO", 4 trofeos (PRIMERA RAID / 5 RAIDS / 10 RAIDS / RAID DE ÉPICO) (`:429`, definido `:931-1007`).
7. **`GuildQuestBoard`** — "TABLÓN DEL GREMIO" con filtros TODAS/DIARIAS/SEMANALES/COLABORATIVAS (`:434`; widget `guild_quest_board.dart`).
8. **Selector de categorías** horizontal ("Todos", dinámico desde DB) (`:439-503`).
9. **2 carteles `_GuildPoster`** (`:507-531`):
   - "MISIONES DEL GREMIO" → **no navega** (sin `onTap`) (`:512-518`).
   - "TABLA DE RANGO" → navega a `/hunter-status` (`:526`).
10. **Título "MESAS DEL GREMIO"** (`:535-543`) y **ListView de salas** (`:564-707`) — la lista es el **último** bloque de la pantalla.

### 4.2 NPC del gremio (`guild_master_npc_banner.dart`)

- Sugerencia por nivel: A→"Taberna del Aprendiz", B→"Mesa Redonda de Tácticas", C→"Consejo Supremo" (`:17-47`).
- Botón "SIGUE MI SUGERENCIA →" (`:98-124`): busca salas cuyo **título** contenga la keyword y hace `context.push('/voice-room?roomId=...')` directamente; si no hay coincidencia entra en la **primera sala disponible** (`:99-106`). **Bypassa la lista de mesas.**

---

## 5. Estado del cazador (`/hunter-status`, `hunter_status_screen.dart`, 326 líneas)

Pantalla de **edición**, no de visualización:

- Atributos STR/INT/DEX/LUK con `SegmentedBar` de 10 segmentos, controles − / + (`:239-242`, `_buildStatRow` `:267-325`).
- Pool de 10 puntos ("PUNTOS DISPONIBLES") (`:215-234`).
- Bio con formato serializado `[Stats|STR:x|INT:x|DEX:x|LUK:x] <texto>` (`_parseBio` `:50-79`, `_formatBio` `:81-83`); guardado vía `updateUserProfile` (`:85-111`).
- Título equipado + rango CEFR + XP (`:125-128`, `:190-205`).
- Botón "DISTRIBUIR PUNTOS" (`:248-255`).

**El radar de habilidades NO vive aquí.** `SkillsRadarChart` está en `progress_tab_view.dart:683`, dentro de `_buildAdvancedAnalysis` (`:658-688`), junto a `FluencyLatencyChart` y `PracticeHeatmap`.

---

## 6. Radar de habilidades — profundidad de acceso real (hallazgo clave)

El radar es accesible solo así:

1. Tab **Status** del dashboard (`dashboard_screen.dart:165`).
2. Sección **"Vocabulario Aprendido"** — se renderiza en `progress_tab_view.dart:419-536`.
3. Botón **"VER TODO"** — solo existe si `vocabList.isNotEmpty` (`:442-458`).
4. Modal bottom sheet (`_showAllVocabModal` `:545-655`).
5. `_buildAdvancedAnalysis()` invocada al final del modal (`:647`).
6. `SkillsRadarChart` (`:683`).

Es decir: el "radar de poder" está **enterrado a 4–5 niveles** detrás de una sección de vocabulario, y no aparece si el usuario aún no tiene vocabulario acumulado.

---

## 7. Problemas de IA (redundancias e información fuera de lugar)

### 7.1 Redundancias de navegación
- **Dos accesos idénticos al gremio desde `/home`**: banner "Salas de Chat de Voz" (`dashboard_screen.dart:409`) **y** botón GUILD del menú inferior (`:522`), ambos → `/chat-rooms`.
- **Dos accesos a "rango"**: acceso rápido `RANGO` → `/level-exam` (`:335`) y cartel "TABLA DE RANGO" → `/hunter-status` (`chat_rooms_screen.dart:526`); además el header del gremio ya muestra el emblema de rango.
- **"MISIONES DEL GREMIO" duplicada**: cartel decorativo (`chat_rooms_screen.dart:512-518`) sin `onTap`, justo debajo del `GuildQuestBoard` funcional (`:434`).

### 7.2 Información fuera de lugar / jerarquía invertida
- **Lista de mesas al final del gremio** (`chat_rooms_screen.dart:564`): el objetivo primario de la pantalla (unirse a una sala) queda tras 8 bloques de ambientación/información.
- **Radar de poder oculto** dentro del modal de vocabulario (`progress_tab_view.dart:647,683`).
- **Copy engañoso**: la tarjeta "VENTANA DE ESTADO DEL MONARCA" promete "matriz de **11 atributos**, títulos equipados y **radar de poder**" (`progress_tab_view.dart:218-233`) y navega a `/hunter-status`, que solo muestra **4** atributos y **sin radar**.
- **NPC del gremio salta la lista**: "SIGUE MI SUGERENCIA →" entra directo a `/voice-room`, con fallback a la primera sala cualquiera (`guild_master_npc_banner.dart:99-106`).

### 7.3 Onboarding
- La redirección depende del **botón pulsado** (`isRegisteringProvider`), no del estado real de onboarding: un usuario logueado sin perfil que use el flujo de login va a `/home` (con fallbacks) en lugar de a `/onboarding` (`welcome_screen.dart:41-44`).

---

## 8. Tabla resumen

| Pantalla | Foco primario | Problema de IA | Evidencia |
|----------|--------------|----------------|-----------|
| `/` Welcome | Login/registro | Gating de onboarding depende del botón, no del perfil | `welcome_screen.dart:41-44` |
| `/home` tab 0 | Home de práctica | Banner de voz redundante con GUILD; 5 accesos rápidos + hero + roadmap + misiones en un solo scroll | `dashboard_screen.dart:409`, `:522`, `:310-344` |
| `/home` tab 1 (Guild) | — | `SizedBox.shrink()`: el tab no renderiza contenido, solo navega | `dashboard_screen.dart:162-163` |
| `/home` tab 2 (Status) | Progreso | Radar enterrado en el modal de vocabulario; copy "11 atributos + radar" no coincide con la realidad | `progress_tab_view.dart:647,683`, `:218-233` |
| `/chat-rooms` | Unirse a mesas | Mesas al final (8 bloques antes); cartel sin navegación; NPC salta la lista | `chat_rooms_screen.dart:564`, `:512-518`, `guild_master_npc_banner.dart:99-106` |
| `/hunter-status` | Edición de stats | "TABLA DE RANGO" lleva aquí, pero es editor de STR/INT/DEX/LUK, no tabla de rango | `chat_rooms_screen.dart:526`, `hunter_status_screen.dart:239-242` |

---

## 9. Correcciones verificadas a la descripción previa

1. **Orden del tab 0**: el hero "SIGUIENTE RAID" **no es el primer bloque**. Antes aparecen `HunterHudHeader` (`:178`), la fila de insignias gemas/racha/premium (`:183-305`) y la fila de accesos rápidos (`:310-344`).
2. **Accesos rápidos**: son **5** (`MAZMORRAS`/`TIENDA`/`ORÁCULO`/`RANGO`/`DIARIA`), no 4 (`dashboard_screen.dart:313-342`).
3. **Gremio**: entre el header y el NPC hay un hero banner LIVE COOP con botón INITIALIZE (`chat_rooms_screen.dart:357-414`), y el selector de categorías va **antes** de los carteles (`:439-503`).
4. **Radar**: está en `progress_tab_view.dart`, pero **no visible directamente** en el tab Status; solo tras abrir "VER TODO" del vocabulario (`:647,683`).
