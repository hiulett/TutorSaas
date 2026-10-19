# Arquitectura de Información — Propuesta reorganizada

> **Ámbito:** Navegación global del app (Dashboard → Gremio → Estado → Config) y pantallas asociadas
> **Archivos principales:**
> `lib/features/dashboard/presentation/screens/dashboard_screen.dart`,
> `lib/features/dashboard/presentation/screens/hunter_status_screen.dart`,
> `lib/features/dashboard/presentation/widgets/progress_tab_view.dart`,
> `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart`,
> `lib/features/dashboard/presentation/screens/settings_screen.dart`,
> `lib/app/router.dart`
> **Tipo:** Información arquitectónica (IA) / reorganización de contenido
> **Estado:** Propuesta — sin cambios de código

---

## 1. Contexto y problemas detectados (de la auditoría)

La organización actual mezcla dominios en cada pantalla: el dashboard (progreso) contiene
contenido social (misiones de gremio, salas de voz), el gremio entierra su contenido principal
(las mesas) bajo decoración, y la navegación al estado del cazador apunta a un editor de stats.

| # | Problema | Evidencia |
|---|----------|-----------|
| 1 | El hero «SIGUIENTE RAID» duplica el `LearningPathRoadmap` que está debajo | Hero `NextRecommendedLessonHero` en `dashboard_screen.dart:349-395`, alimentado por `recommendedLessonsProvider` (`dashboard_screen.dart:61-74`); la ruta marca la **misma** lección como `isNextLesson` (`learning_path_roadmap.dart:242-243`) y abre el mismo flujo `/conversation?scenarioId=...` (`learning_path_roadmap.dart:378-386`) |
| 2 | El banner «Salas de Chat de Voz» duplica el botón GUILD del menú inferior | Banner → `context.push('/chat-rooms')` en `dashboard_screen.dart:409`; ítem GUILD del bottom nav → `context.push('/chat-rooms')` en `dashboard_screen.dart:518-523`. Mismo destino, dos accesos en la misma pantalla |
| 3 | `MissionBoardWidget` vive en el dashboard, pero las misiones del gremio deberían estar en el gremio | Render en `dashboard_screen.dart:483`; el widget pertenece al feature `missions` (`mission_board_widget.dart:11`). El gremio ya tiene su propio tablón (`GuildQuestBoard` en `chat_rooms_screen.dart:434`) |
| 4 | El gremio muestra NPC grande + prestigio + trofeos + tablón **antes** que las mesas | Orden actual en `chat_rooms_screen.dart`: hero (357) → `GuildMasterNpcBanner` (419) → `_GuildPrestigeHud` (424) → `_GuildTrophies` (429) → `GuildQuestBoard` (434) → carteles (507) → **mesas** (535-546). El contenido principal (las mesas) queda al final |
| 5 | `/hunter-status` es edición de stats, pero la «TABLA DE RANGO» del gremio navega ahí | `HunterStatusScreen` edita STR/INT/DEX/LUK (`hunter_status_screen.dart:239-243, 248-255`); el cartel «TABLA DE RANGO» del gremio hace `context.push('/hunter-status')` (`chat_rooms_screen.dart:522-527`). El `HunterHudHeader` también navega ahí para notificaciones/misiones (`hunter_hud_header.dart:206, 211`). Editar atributos ≠ ver rango |
| 6 | El radar de habilidades está en `progress_tab_view`, no en `hunter-status` | `SkillsRadarChart` en `progress_tab_view.dart:683`, dentro de `_buildAdvancedAnalysis()` (658-688) que **solo se renderiza dentro del modal de vocabulario** (`_showAllVocabModal`, `progress_tab_view.dart:647`). El radar queda oculto, con baja descubribilidad |

---

## 2. Principios de la reorganización

1. **Una fuente de verdad por concepto.** «Cuál es el siguiente paso» lo dice una sola pieza: el `LearningPathRoadmap`. «Dónde está el gremio» lo dice una sola pieza: el tab GUILD.
2. **Cada dominio vive en su pantalla.** Progreso → Dashboard. Social → Gremio. Identidad → Estado. Configuración → Config.
3. **Un solo acceso por acción visible.** Si el bottom nav ya cubre un destino, no se duplica el acceso en el scroll.
4. **Lo más importante primero.** La pantalla del gremio abre por las mesas (lobby), no por decoración.
5. **Se eliminan solo duplicados visuales, nunca lógica.** No se tocan providers, repositorios ni datos.

---

## 3. Propuesta por pantalla

### 3.1 Dashboard — Tab MAZMORRAS (índice 0) → `dashboard_screen.dart`

**Propósito único:** Progreso del aventurero y punto de entrada a la práctica.

| Acción | Elemento | Detalle |
|--------|----------|---------|
| **Mantener** | `HunterHudHeader` | `dashboard_screen.dart:178`. HUD compacto de identidad + Núcleo Arcano |
| **Mantener** | Badges gemas / racha / PRO | `dashboard_screen.dart:183-305`. Accesos rápidos de estado |
| **Mantener** | Accesos rápidos del sistema | `_buildQuickAccess`, `dashboard_screen.dart:310-344` (MAZMORRAS → `/dungeon-map`, TIENDA, ORÁCULO, RANGO, DIARIA) |
| **Mantener (fuente oficial)** | `LearningPathRoadmap` | `dashboard_screen.dart:476-478`. Pasa a ser la heroína visual del tab: ya marca `isNextLesson` con nodo resaltado, score y progreso de etapa |
| **Mantener** | Bottom nav (4 ítems) | `dashboard_screen.dart:499-540` |
| **Eliminar** | Hero «SIGUIENTE RAID» (`NextRecommendedLessonHero`) | `dashboard_screen.dart:349-395`. Duplicado visual del roadmap; la misma lección, el mismo `mainObjective` y el mismo botón `/conversation` ya están en el nodo `QuestCard` de la ruta. Libera ~1 viewport de scroll |
| **Eliminar** | Banner «Salas de Chat de Voz» | `dashboard_screen.dart:399-471`. Duplicado del ítem GUILD del bottom nav (mismo destino `/chat-rooms`); la etiqueta «EN VIVO» (`:449`) es cosmética |
| **Mover** | `MissionBoardWidget` | De `dashboard_screen.dart:483` → al gremio (ver 3.2). El dashboard ya no renderiza el tablón de misiones |

**Resultado:** Dashboard = `HunterHudHeader` → badges → quick access → `LearningPathRoadmap` → bottom nav.

---

### 3.2 Gremio — Tab GUILD → `/chat-rooms` → `chat_rooms_screen.dart`

**Propósito único:** Interacción social. El usuario entra a **unirse/crear una mesa**, y encuentra las misiones del gremio como soporte.

| Acción | Elemento | Detalle |
|--------|----------|---------|
| **Mantener (compacto)** | `_GuildHallHeader` | `chat_rooms_screen.dart:352`. Emblema de rango CEFR reducido a un chip |
| **Mantener (compacto)** | `_GuildPrestigeHud` | `chat_rooms_screen.dart:424` y `726`. Convertir en una fila/badge anexa al header (una sola línea: nivel + premium) |
| **Mover (prioridad #1)** | Selector de categorías + lista de mesas | Actualmente `chat_rooms_screen.dart:439-503` (categorías) y `:535-707` (mesas). Subir **inmediatamente después del header**, como lista compacta tipo lobby MMORPG (título + tipo IA/MENTORÍA/EVENTO + `X/6` oradores + botón UNIRSE). El botón «INITIALIZE» del hero (`:395-408`) puede reubicarse como botón flotante o cabecera de la lista |
| **Mover** | `GuildQuestBoard` | Se mantiene en el gremio, pero **después de las mesas** (misiones diarias/semanales/colaborativas/eventos, filtros `:50-53`) |
| **Mover (desde Dashboard)** | `MissionBoardWidget` | De `dashboard_screen.dart:483` → aquí, junto a `GuildQuestBoard`. Ambas consumen `mission_providers`; se conserva la lógica tal cual |
| **Mantener (reducido)** | `GuildMasterNpcBanner` | `chat_rooms_screen.dart:419` / `guild_master_npc_banner.dart`. Reducir a una línea de sugerencia con su CTA; el NPC grande (icono 22px + 4 líneas) no debe preceder a las mesas |
| **Mover (abajo)** | `_GuildTrophies` | `chat_rooms_screen.dart:429` y `931`. Se coloca al final (vitrina, no contenido de acción) |
| **Eliminar (destino)** | Cartel «TABLA DE RANGO» → `/hunter-status` | `chat_rooms_screen.dart:522-527`. Reemplazar por **modal/botón de rango** que muestre emblema CEFR + título equipado + liga + XP (datos de `userProgressProvider` y `HunterCatalog`), sin navegar al editor de stats |
| **Eliminar** | Hero header decorativo redundante | `chat_rooms_screen.dart:357-414`. Si las mesas pasan a ser el héroe, el GlassCard de bienvenida se fusiona con la lista o se suprime |

**Resultado (orden de render):** Header + prestigio compacto → **MESAS** (categorías + lista) → **misiones** (`GuildQuestBoard` + `MissionBoardWidget`) → NPC compacto → trofeos → modal de rango.

---

### 3.3 Estado del aventurero — Tab ESTADO (índice 2) → `progress_tab_view.dart` + `/hunter-status`

**Propósito único:** Identidad y competencias del cazador (quién soy, qué domino). La edición de atributos es una sub-tarea, no un destino de navegación.

| Acción | Elemento | Detalle |
|--------|----------|---------|
| **Mantener** | Tarjeta de perfil + stats compactas (XP / racha / nivel) | `progress_tab_view.dart:64-305`. Reducir a widgets compactos de una línea |
| **Mantener** | Práctica semanal, `DailyQuestsWidget`, `LeagueLeaderboardWidget`, vocabulario + SRS | `progress_tab_view.dart:309-536` |
| **Reincorporar** | Radar de habilidades (`SkillsRadarChart`) | Sacarlo del interior del modal (`progress_tab_view.dart:683` dentro de `_showAllVocabModal:647`) y exponerlo como sección de primer nivel del tab ESTADO, junto a `FluencyLatencyChart` y `PracticeHeatmap` (análisis `_buildAdvancedAnalysis`) |
| **Reincorporar** | XP / títulos / logros / badges | Datos ya disponibles (`userProgressProvider`, `userAchievementsProvider`, `HunterCatalog.titles`); mostrar título equipado y logros desbloqueados como badges compactos |
| **Mover (entrada)** | Edición de stats (STR/INT/DEX/LUK) | `HunterStatusScreen` (`hunter_status_screen.dart`) se conserva como superficie de **edición**, pero su entrada cambia: se accede desde el tab ESTADO («Editar atributos»), **no** desde el gremio ni desde notificaciones del HUD (`hunter_hud_header.dart:206, 211`) |
| **Mover (entrada)** | Notificaciones / misiones del HUD | Los iconos del `HunterHudHeader` que hoy apuntan a `/hunter-status` (`hunter_hud_header.dart:203-212`) pasan a apuntar a su destino real: misiones → tab GUILD; notificaciones → tab ESTADO |

**Resultado:** ESTADO = perfil compacto → stats → **radar + charts** → racha/quedas → liga → vocabulario. `/hunter-status` queda como sub-flujo de edición con botón atrás al ESTADO.

---

### 3.4 Configuración — Tab CONFIG (índice 3) → `settings_screen.dart`

**Propósito único:** Preferencias del sistema y de la cuenta.

| Acción | Elemento | Detalle |
|--------|----------|---------|
| **Mantener** | Secciones actuales | `TARGET LANGUAGE & CEFR LEVEL` (`settings_screen.dart:117`), `AI TUTOR PARAMETERS` (`:124`), `AUDIO & COMMUNICATIONS` (`:135`), `ACCOUNT` (`:140`) |
| **Agregar** | Switch **«Modo desarrollador / Mostrar onboarding siempre»** | Nueva sección (p. ej. `DEVELOPER TOOLS`) con `Switch` al estilo de los existentes (`settings_screen.dart:711, 738`). Activo → persiste la bandera (en `UserSettings` / store local) y expone la acción **«Reiniciar onboarding»** que navega a `/onboarding` (wizard + oráculo + placement) sin tocar datos del usuario |

---

## 4. Mapa de navegación propuesto (texto)

```
/ (WelcomeScreen)
├── /onboarding            wizard + oráculo + placement test
└── /home (DashboardScreen — 4 tabs, bottom nav fijo)
    ├── [MAZMORRAS]        PROGRESO: HUD → badges → quick access →
    │                      LearningPathRoadmap (fuente oficial del siguiente paso)
    │   └── /dungeon-map, /conversation (desde nodos de la ruta)
    ├── [GUILD] → /chat-rooms   SOCIAL: header+prestigio compacto → MESAS (lista) →
    │                      misiones (GuildQuestBoard + MissionBoardWidget) →
    │                      NPC compacto → trofeos → modal de rango
    │   └── /voice-room (desde cada mesa), crear mesa (modal)
    ├── [ESTADO]           IDENTIDAD: perfil → stats compactas → radar+charts →
    │                      práctica semanal → liga → vocabulario
    │   └── /hunter-status (edición de atributos, botón «Editar atributos»)
    └── [CONFIG]           PREFERENCIAS: idioma/CEFR → tutor → audio → cuenta →
                          NUEVO switch «Modo desarrollador / Mostrar onboarding»
```

**Rutas secundarias sin cambios de arquitectura** (se mantienen tal cual):
`/dungeon-map`, `/conversation`, `/summary`, `/level-exam`, `/shop`, `/inventory`,
`/battle-pass`, `/collections`, `/fragments-exchange`, `/leaderboard`, `/paywall`,
`/profile`, `/profile-edit`, `/disruption`.

**Reglas de navegación que introduce la propuesta:**
- `/chat-rooms` se alcanza **solo** desde el tab GUILD (se elimina el banner del dashboard).
- `/hunter-status` se alcanza **solo** desde el tab ESTADO (se eliminan las entradas del gremio y del HUD).
- `MissionBoardWidget` cambia de contenedor (dashboard → gremio) sin cambiar de ruta.

---

## 5. Fuera de alcance

- **No se elimina lógica**: todos los providers (`recommendedLessonsProvider`,
  `mission_providers`, `guildQuestPoolProvider`, `skillsRadarProvider`, etc.), repositorios
  y datos permanecen intactos. Solo cambia el contenedor visual o la prioridad de render.
- **No se renombra ni reubica archivos** en esta propuesta (el `MissionBoardWidget` puede
  importarse desde el gremio como hace `chat_rooms_screen.dart` hoy con `GuildQuestBoard`).
- La bandera «Modo desarrollador» es local al cliente; no introduce columnas en Supabase.
