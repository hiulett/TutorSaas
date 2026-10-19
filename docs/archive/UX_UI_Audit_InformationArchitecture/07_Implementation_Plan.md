# Plan de Implementación Priorizado — Hallazgo 07

> **Ámbito:** Ejecución de los hallazgos 01–06 de la serie `docs/UX_UI_Audit_InformationArchitecture/`
> **Documentos de referencia:**
> - `01_Current_State.md` (estado verificado, rutas y flujos)
> - `03_Dashboard_Redesign.md` (dashboard: hero, banner voz, MissionBoard)
> - `04_Guild_Redesign.md` (gremio: mesas primero, NPC, trofeos, prestigio, misiones, rango)
> - `05_Player_Status_Redesign.md` (estado: radar + compactación de atributos)
> - `06_Onboarding_Developer_Mode.md` (modo desarrollador / mostrar onboarding siempre)
> **Estado:** Plan — sin cambios de código
> **Regla de oro:** NO usar `git checkout`/`git restore` sobre archivos `.dart` (el repo tiene 1 solo commit y todo el trabajo vive como ediciones sin commitear). Corregir siempre editando.

---

## 0. Priorización y dependencias

| Prioridad | Tarea | Coste estimado | Depende de |
|-----------|-------|----------------|------------|
| **P1** | Modo desarrollador en Configuración | Bajo (modelo + provider + switch + migración) | — |
| **P2** | Dashboard: quitar hero duplicado + banner chat de voz + mover MissionBoard | Bajo (eliminación + reorden) | — |
| **P3** | Gremio: mesas primero + NPC compacto + trofeos abajo + prestigio compacto | Medio (reorden y compactación en `chat_rooms_screen.dart`) | Documento 04 |
| **P4** | Estado: radar + compactación de atributos | Medio (mover `SkillsRadarChart` + cuadrícula de atributos) | Documento 05 |
| **P5** | QA de regresión | — | P1–P4 |

Orden lógico de ejecución: **P1 → P2 → P3 → P4 → P5**. Cada tarea termina con `flutter analyze` en verde (0 errores) antes de pasar a la siguiente.

---

## 1. P1 — Modo desarrollador en Configuración

**Objetivo:** switch «Modo desarrollador / Mostrar onboarding siempre» que fuerce `/onboarding` en el welcome, persistido por usuario.

### 1.1 Archivos afectados

| Archivo | Cambio |
|---------|--------|
| `supabase/migrations/<timestamp>_add_always_show_onboarding.sql` (nuevo) o SQL editor | `alter table public.user_settings add column if not exists always_show_onboarding boolean not null default false;` |
| `lib/features/dashboard/domain/models/user_settings.dart` | Nuevo campo `alwaysShowOnboarding` + `initial()`/`fromJson`/`toJson`/`copyWith` |
| `lib/features/dashboard/presentation/providers/dashboard_providers.dart` | Nuevo `alwaysShowOnboardingProvider` (`FutureProvider.autoDispose<bool>`) leyendo `user_settings.always_show_onboarding` con fallback `false` |
| `lib/features/dashboard/presentation/screens/settings_screen.dart` | Nueva sección QA/DEVELOPER con tile `GlassCard` + `Switch` (persistencia inmediata vía `userSettingsProvider.notifier.updateSetting('always_show_onboarding', value)`) |
| `lib/features/onboarding/presentation/screens/welcome_screen.dart` | En `_redirectUser` (`:25-49`): `await` del flag antes de decidir; si `true` → `context.go('/onboarding')` |
| `lib/l10n/app_en.arb` / `app_es.arb` / `app_pt.arb` | Claves del tile (etiqueta + subtítulo) → **ejecutar `flutter gen-l10n`** |

### 1.2 Widgets afectados
- `settings_screen.dart`: patrón `_buildNotificationTiles` (`:676-795`) como plantilla del tile+switch.
- `welcome_screen.dart`: `_redirectUser` (`:25-49`).

### 1.3 Navegación afectada
- `/` (Welcome): rama nueva de redirección forzada a `/onboarding`. Sin cambios de rutas en `router.dart`.

### 1.4 Componentes reutilizables
- `GlassCard` (`lib/core/widgets/glass_card.dart`), `AppColors` (`lib/core/theme/app_colors.dart`), `supabaseClientProvider` (`auth_providers.dart:6-8`), `currentUserProvider` (`auth_providers.dart:20-26`).

### 1.5 Dependencias
- Ninguna nueva. Solo Supabase (ya en `pubspec.yaml`).

### 1.6 Orden interno
1. Migración de la columna (aplicar vía SQL editor o rama; verificar `select always_show_onboarding ...`).
2. Modelo `UserSettings` (campo + serialización).
3. Provider `alwaysShowOnboardingProvider`.
4. Switch en `settings_screen.dart`.
5. Redirección en `welcome_screen.dart`.
6. Claves l10n + `flutter gen-l10n`.

### 1.7 Verificación
- `flutter analyze` sin errores.
- `flutter test` (incluye `dashboard_repository_test.dart` si se toca el repo; no se espera tocar).
- Manual: encender el switch → logout → login → debe entrar a `/onboarding`; apagar → login → `/home`.

### 1.8 Riesgos
- Carrera de carga del flag (ver Hallazgo 6.3): usar `FutureProvider` + `await`, no el estado interno del notifier.
- Pisar el flag al guardar configuración completa: el modelo debe incluir el campo en `toJson()`.
- Loop infinito si no se documenta que el flag es manual: el wizard no lo apaga.

---

## 2. P2 — Dashboard: eliminar hero duplicado + banner chat de voz + mover MissionBoard

**Objetivo:** dejar el tab Dungeons enfocado en la Ruta por Etapas (fuente oficial de progreso), eliminando duplicaciones (Documento 03).

### 2.1 Archivos afectados

| Archivo | Cambio |
|---------|--------|
| `lib/features/dashboard/presentation/screens/dashboard_screen.dart` | Eliminar bloque hero «SIGUIENTE RAID» (`:349-395`) y su selección de `heroLesson` (`:61-74`) si no se reutiliza; eliminar banner «Salas de Chat de Voz» (`:399-471`); **mover** `MissionBoardWidget` (`:483`) al flujo del gremio; reordenar: HUD → badges/quick access → `LearningPathRoadmap` (`:476`) |
| `lib/features/missions/presentation/widgets/mission_board_widget.dart` | Sin cambios de lógica; solo cambia el punto de montaje (dashboard → gremio) |
| `lib/features/dashboard/presentation/widgets/next_recommended_lesson_hero.dart` | Evaluar si queda sin uso → eliminar solo si `flutter analyze` no reporta referencias restantes |

### 2.2 Widgets afectados
- `NextRecommendedLessonHero` (import en `dashboard_screen.dart:14`), `MissionBoardWidget` (`:22`), `GlassCard` del banner (`:400-471`).

### 2.3 Navegación afectada
- Ninguna ruta se elimina: `/conversation` sigue accesible vía el nodo `isNextLesson` de `LearningPathRoadmap`; `/chat-rooms` sigue accesible por el ítem GUILD del bottom nav (`dashboard_screen.dart:518-523`).

### 2.4 Componentes reutilizables
- `LearningPathRoadmap` (mantener y priorizar), `HunterHudHeader` (`:178`), `_buildQuickAccess` (`:595-629`), `MissionBoardWidget` (reubicar).

### 2.5 Dependencias
- Ninguna nueva.

### 2.6 Orden interno
1. Quitar el bloque hero + lógica `heroLesson`.
2. Quitar el banner de chat de voz.
3. Reordenar: subir `LearningPathRoadmap`.
4. Montar `MissionBoardWidget` en el gremio (integración con P3).
5. `flutter analyze` → limpiar imports muertos (`next_recommended_lesson_hero.dart`).

### 2.7 Verificación
- `flutter analyze` sin errores.
- `flutter test` sin regresiones.
- Manual: primer viewport del tab Dungeons muestra HUD + ruta sin scroll; botones de acceso intactos; `/chat-rooms` accesible por GUILD.

### 2.8 Riesgos
- Perder el atajo directo a la siguiente conversación: el nodo `isNextLesson` de la ruta (`learning_path_roadmap.dart:242-243,378-386`) lo sustituye.
- Misión sin acceso: se mueve (no elimina) — validar montaje en el gremio antes de retirarla del dashboard.

---

## 3. P3 — Gremio: mesas primero + NPC compacto + trofeos abajo + prestigio compacto

**Objetivo:** aplicar la jerarquía del Documento 04: actuar → progresar → reconocer.

### 3.1 Archivos afectados

| Archivo | Cambio |
|---------|--------|
| `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` | Reordenar `Column` (`:348-708`): mesas + filtros primero, tablón de misiones segundo, NPC compacto, prestigio badge, cartel/botón de rango, trofeos al final; eliminar cartel «MISIONES DEL GREMIO» sin `onTap` (`:512-518`) |
| `lib/features/chat_rooms/presentation/widgets/guild_master_npc_banner.dart` | Compactar a franja de una línea manteniendo sugerencia CEFR (`:17-47`) y CTA (`:96-126`) |
| `lib/features/missions/presentation/widgets/guild_quest_board.dart` | Añadir filtro «EVENTOS» (aliado a `room_type = 'event'`) si se aprueba; sin cambios de lógica base |
| `lib/features/dashboard/presentation/screens/dashboard_screen.dart` | Alojar `MissionBoardWidget` aquí (integración con P2) o dejar el tablón de gremio como única fuente |

### 3.2 Widgets afectados
- `_GuildHallHeader` (`:779-842`), `GuildMasterNpcBanner`, `_GuildPrestigeHud` (`:726-774`), `_GuildTrophies` (`:931-1007`), `GuildQuestBoard`, `_GuildPoster` (`:847-912`), selector de categorías (`:439-503`), ListView de salas (`:564-707`).

### 3.3 Navegación afectada
- `/voice-room` (entrar a sala, `:575-577`, `:672-684`), `/hunter-status` (cartel de rango, `:526`). Se mantienen los destinos; solo cambia la ubicación/forma del acceso.

### 3.4 Componentes reutilizables
- `GlassCard`, `SegmentedBar` (en misiones), `_GuildTrophyData`/`_GuildTrophyTile` (reubicar), `chatRoomsListProvider`, `guildCompletedMissionsProvider` (`:24-42`), `guildQuestPoolProvider`.

### 3.5 Dependencias
- Ninguna nueva.

### 3.6 Orden interno
1. Mover ListView de salas + selector de categorías al inicio.
2. Subir `GuildQuestBoard` tras las mesas.
3. Compactar `GuildMasterNpcBanner`.
4. Reducir `_GuildPrestigeHud` a badge.
5. Mover `_GuildTrophies` al final.
6. Convertir «TABLA DE RANGO» en botón/modal.
7. Eliminar cartel duplicado de misiones.
8. Integrar `MissionBoardWidget` del dashboard si aplica.

### 3.7 Verificación
- `flutter analyze` sin errores.
- `flutter test` sin regresiones.
- Manual: primera mesa visible sin scroll; crear sala (INITIALIZE) funcional; trofeos siguen desbloqueando (GUILD-03); sugerencia del NPC conservada; back → dashboard.

### 3.8 Riesgos
- Romper la creación de salas (`_showCreateRoomDialog`, `:137-291`): mantener el botón de crear en el header de mesas.
- Romper el realtime de salas (`_subscribeToRoomsRealtime`, `:71-86`): no tocarlo.
- Perder el conteo de trofeos: conservar `guildCompletedMissionsProvider`.
- Regresión de layout: respetar design system (GlassCard, radio 4px, `AppColors`).

---

## 4. P4 — Estado: radar + compactación

**Objetivo:** cumplir la promesa «radar de poder» en `/hunter-status` y compactar los 4 atributos (Documento 05).

### 4.1 Archivos afectados

| Archivo | Cambio |
|---------|--------|
| `lib/features/dashboard/presentation/widgets/charts/skills_radar_chart.dart` | **Mover** (no copiar) a `/hunter-status` como sección «RADAR DE PODER» |
| `lib/features/dashboard/presentation/screens/hunter_status_screen.dart` | Insertar radar; compactar atributos STR/INT/DEX/LUK (`:267-325`) en cuadrícula 2×2 o 4×1 con badge numérico + mini-control −/+; elevar rango/XP; añadir sección de logros alimentada por `userAchievementsProvider` |
| `lib/features/dashboard/presentation/widgets/progress_tab_view.dart` | Retirar el radar de `_buildAdvancedAnalysis` (`:658-688`, `:683`); ajustar copy del botón «VENTANA DE ESTADO DEL MONARCA» (`:218-233`) |

### 4.2 Widgets afectados
- `SkillsRadarChart`, `SegmentedBar`, `AnimatedCounter`, `_buildStatRow` (`hunter_status_screen.dart:267-325`).

### 4.3 Navegación afectada
- `/hunter-status` (pasa a ser ficha completa del aventurero). Tab Estado conserva fluidez + heatmap.

### 4.4 Componentes reutilizables
- `SkillsRadarChart`, `GlassCard`, `userProgressProvider`, `userAchievementsProvider` (`dashboard_providers.dart:42-50`), `skillsRadarProvider` (`:170-225`).

### 4.5 Dependencias
- `fl_chart` (ya en `pubspec.yaml`, usado por el radar y otros charts).

### 4.6 Orden interno
1. Mover `SkillsRadarChart` a `hunter_status_screen.dart`.
2. Compactar los 4 atributos (manteniendo aritmética `(val - 5)` y tope de 10).
3. Añadir logros (top-N + «VER TODOS»).
4. Retirar el radar del tab Estado y corregir el copy del botón.

### 4.7 Verificación
- `flutter analyze` sin errores.
- `flutter test` sin regresiones.
- Manual: `/hunter-status` muestra radar + atributos compactos + rango + título + logros; guardar puntos persiste (revisar `_saveStats`/`_formatBio`, `hunter_status_screen.dart:85-111`).

### 4.8 Riesgos
- Romper la persistencia en `bio` (`[Stats|STR:x|...]`): no tocar `_parseBio`/`_formatBio`.
- Duplicar el radar (dos instancias = dos cargas de `skillsRadarProvider`): mover, no copiar.
- El provider del radar debe resolverse en el contexto de `/hunter-status` (mismo feature `dashboard` → OK).

---

## 5. P5 — QA de regresión

**Objetivo:** validar que P1–P4 no rompen flujos existentes.

### 5.1 Archivos afectados
- Ninguno (solo ejecución de verificaciones).

### 5.2 Verificación automatizada
```sh
flutter analyze                          # barra: 0 errores (56 infos/warnings previos aceptados)
flutter test                             # suite completa (11+ archivos en test/)
flutter gen-l10n                         # tras P1 (claves nuevas de Configuración)
dart run build_runner build --delete-conflicting-outputs   # solo si se añaden clases codegen (no previsto)
```

### 5.3 Checklist manual
| Ruta/Flujo | Verificar |
|-----------|-----------|
| `/` welcome | Login con flag dev ON → `/onboarding`; OFF → `/home` (según perfil) |
| `/home` tab 0 | HUD + badges + quick access + ruta visible sin scroll; sin hero ni banner de voz; GUILD accesible |
| `/home` tab 2 (Estado) | Radar retirado del modal de vocabulario; botón «VENTANA DE ESTADO DEL MONARCA» → `/hunter-status` con radar |
| `/chat-rooms` | Mesas primero; crear sala; entrar a `/voice-room`; trofeos y misiones funcionales; back → dashboard |
| `/hunter-status` | Atributos compactos; guardar stats persiste; radar presente |
| RLS | Writes a `user_settings` (upsert del flag) y lecturas funcionan con la sesión del usuario |

### 5.4 Riesgos
- Regresión visual no cubierta por tests (no hay golden de estas pantallas): usar el checklist manual y screenshots.
- Cambio de orden de bloques sin revalidar scroll: medir que el primer viewport muestra el contenido esperado.

---

## 6. Resumen de riesgos globales

| Riesgo transversal | Mitigación |
|--------------------|-----------|
| `git checkout/restore` destruye trabajo sin commitear | Nunca usar sobre `.dart`; corregir editando (regla AGENTS.md) |
| Romper navegación existente | Mantener intactas las 23 rutas de `router.dart`; solo cambian puntos de montaje y copy |
| Romper RLS | Las columnas nuevas heredan políticas; validar con el usuario autenticado |
| Olvidar `flutter gen-l10n` tras editar `.arb` | Ejecutarlo en P1 y en cualquier tarea que toque textos |
| Acumular deuda en un solo commit | Entregar por prioridad (P1→P5), cada una con `flutter analyze` verde |
