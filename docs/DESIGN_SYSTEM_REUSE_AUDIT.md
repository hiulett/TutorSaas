# Design System Reuse Audit (DS-S10)

> **Tarea:** DS-S10 — Detectar y documentar oportunidades de reutilización en `lib/features/` y `lib/core/widgets/`.
> **Estado:** Solo auditoría. **No se modificó ningún archivo `.dart`.**
> **Fecha:** 2026-07-31

Este documento cataloga patrones visuales duplicados (misma estructura UI, distinto archivo),
cuantifica sus ocurrencias y propone componentes reutilizables nuevos para centralizarlos en
`lib/core/widgets/`.

---

## 1. Patrón: Chips / badges con icono + texto mono

### Descripción del patrón

Container con `padding: EdgeInsets.symmetric(horizontal: 6–12, vertical: 3–7)`,
`BoxDecoration` con fondo `color.withValues(alpha: 0.10–0.15)`, `border: Border.all(color.withValues(alpha: 0.3–0.5))`,
`borderRadius` 4px, y dentro un `Row` con `Icon(size 11–18)` + `Text` en `JetBrainsMono` (bold).

### Ocurrencias confirmadas (estructura visual idéntica)

| # | Archivo | Líneas | Tipo de chip | Icono / color |
|---|---------|--------|--------------|----------------|
| 1 | `features/missions/presentation/widgets/guild_quest_board.dart` | 350–374 | `_GemChip` | `diamond_rounded` / manaCyan |
| 2 | `features/missions/presentation/widgets/guild_quest_board.dart` | 376–399 | `_XpChip` | `stars_rounded` / royalGold |
| 3 | `features/missions/presentation/widgets/guild_quest_board.dart` | 322–348 | `_StatusPill` (icono+label+color) | configurable |
| 4 | `features/missions/presentation/widgets/mission_board_widget.dart` | 220–229 | XP + gemas inline (icono + mono) | `stars_rounded`, `diamond_rounded` |
| 5 | `features/missions/presentation/widgets/mission_board_widget.dart` | 194–208 | Etiqueta de estado (tipo misión) | mono 8px, fondo alpha |
| 6 | `core/widgets/quest_card.dart` | 119–143 | Gemas (`+N GEMS`) + XP (`+N XP`) | `diamond_rounded`, `flash_on_rounded` |
| 7 | `core/widgets/quest_card.dart` | 63–79 | Rank badge (`S/A/B/C`) | color por rango |
| 8 | `features/dashboard/presentation/screens/dashboard_screen.dart` | 186–217 | Badge gemas (tappable → shop) | `diamond_rounded` / manaCyan |
| 9 | `features/dashboard/presentation/screens/dashboard_screen.dart` | 219–250 | Badge racha | `local_fire_department_rounded` / royalGold |
| 10 | `features/dashboard/presentation/screens/dashboard_screen.dart` | 252–290 | Badge PRO/IR PRO | `workspace_premium_rounded` / `star_border_rounded` |
| 11 | `features/dashboard/presentation/widgets/hunter_hud_header.dart` | 125–147 | Badge Núcleo Arcano (energía) | `auto_awesome_rounded` / runeViolet |
| 12 | `features/dashboard/presentation/widgets/hunter_hud_header.dart` | 176–191 | Badge CEFR | mono gold |
| 13 | `features/dashboard/presentation/widgets/hunter_hud_header.dart` | 193–200 | Racha `🔥 RACHA N DÍAS` | fire / royalGold |
| 14 | `features/dashboard/presentation/widgets/daily_quests_widget.dart` | 81–101 | Chip racha `${streakDays} Días` | `local_fire_department_rounded` / royalGold |
| 15 | `features/economy/presentation/screens/shop_screen.dart` | 233–254 | Balance gemas | `diamond_rounded` / manaCyan |
| 16 | `features/economy/presentation/screens/shop_screen.dart` | 256–277 | Balance oro | `monetization_on_rounded` / royalGold |
| 17 | `features/economy/presentation/screens/fragments_exchange_screen.dart` | 171–191 | Balance fragmentos | `auto_awesome_rounded` / runeViolet |
| 18 | `features/economy/presentation/screens/battle_pass_screen.dart` | 79–94 | Badge PREMIUM/GRATUITO | mono |
| 19 | `features/dashboard/presentation/widgets/lesson_preview_sheet.dart` | 77 | Nivel de lección `NIVEL ${lesson.level} …` | mono |
| 20 | `features/dashboard/presentation/widgets/recommended_lessons_hub.dart` | 409 | Nivel de lección `NIVEL ${lesson.level}` | mono |

**Total:** ~20 ocurrencias en **13 archivos** (5 de ellas son componentes privados duplicados:
`_GemChip`/`_XpChip`/`_StatusPill` en `guild_quest_board.dart`).

### Componente propuesto

**Nombre:** `RewardChip` (en `lib/core/widgets/reward_chip.dart`)

```dart
RewardChip({
  required IconData icon,
  required String label,          // '123', '+50 XP', '🔥 RACHA 7 DÍAS'
  required Color color,
  IconData Function()? tapAction, // null → no interactivo
  VoidCallback? onTap,
  double fontSize = 9,
})
```

- Params: `icon`, `label`, `color`, `onTap?`, `padding?`, `radius` (default 4).
- Ubicación: `lib/core/widgets/reward_chip.dart`.
- Además: un helper estático `RewardChip.gems(int)`, `.xp(int)`, `.streak(int)`, `.cefr(String)`
  para los 4 casos más repetidos (gemas, XP, racha, nivel) — eliminaría `_GemChip`/`_XpChip`/`_StatusPill`
  y todos los badges inline.
- Reutilizar en: dashboard_screen, hunter_hud_header, daily_quests_widget, shop_screen,
  fragments_exchange_screen, quest_card, guild_quest_board, mission_board_widget, battle_pass_screen.

---

## 2. Patrón: Tarjetas de métrica KPI (valor grande mono + label small)

### Descripción del patrón

Card (GlassCard o Container con borde) que muestra: icono (16–24px) → valor grande
(mono/`SpaceGrotesk` 18–20px bold) → label pequeño (10–11px `onSurfaceVariant`).

### Ocurrencias confirmadas

| # | Archivo | Líneas | Detalle |
|---|---------|--------|---------|
| 1 | `core/widgets/stat_tile.dart` | 8–64 | **`StatTile` YA EXISTE** (GlassCard + círculo 40px + valor mono 20 w800 + label) |
| 2 | `features/dashboard/presentation/screens/session_summary_screen.dart` | 291–330 | **Usa `StatTile`** 4× (DURACIÓN, PALABRAS, PRECISIÓN, XP) — patrón canónico |
| 3 | `features/dashboard/presentation/screens/profile_screen.dart` | 201–271 | **Reimplementa el KPI inline** en 3 GlassCards (XP Total, Racha activa, Nivel CEFR) — NO usa `StatTile` |
| 4 | `features/economy/presentation/widgets/daily_reward_modal.dart` | 96–106, 151–178 | `_RewardTile` privado (variante con borde, no GlassCard circular) |
| 5 | `features/dashboard/presentation/widgets/status_window_modal.dart` | 173–184 | Métricas `🔮 Maná` / `⚡ XP` inline (texto plano, no card) |

**Total:** el componente `StatTile` está centralizado pero **solo 1 pantalla lo consume**;
otras 2+ reimplementan la misma estructura visual (profile_screen = 3 cards idénticas).

### Componente / acción propuesta

**Nombre:** `StatTile` ya existe → **adoptar, no crear.**

- Migrar `profile_screen.dart:201–271` (3 KPI) a `StatTile`.
- Unificar `_RewardTile` (`daily_reward_modal.dart:151–178`) con `StatTile` añadiendo un
  parámetro `variant: StatTileVariant.glass | box` (para los casos con `Container`+borde en vez de
  GlassCard circular) y `valueStyle` opcional.
- Ubicación: `lib/core/widgets/stat_tile.dart` (existente).
- Impacto: elimina ~3–4 implementaciones duplicadas y garantiza el mismo KPI en Dashboard, Profile,
  Daily Reward y Session Summary.

---

## 3. Patrón: Botones `ElevatedButton` con estilo custom

### Descripción del patrón

`ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: X, foregroundColor: Y,
padding: …(small), shape: RoundedRectangleBorder(radius 4)))` — reemplazo manual del tema
global en ~94 sitios. Dos sabores:

- **Compacto pequeño** (`padding h:12 v:6`, fontSize 9–11): botones de acción inline
  (ACEPTAR, RECLAMAR, GENERAR MISIONES, etc.).
- **Ancho completo** (`padding vertical: 14–16`, fontSize 14–16): botón primario de pantalla.

### Ocurrencias confirmadas (muestra representativa de las ~94)

| # | Archivo | Líneas | Estilo |
|---|---------|--------|--------|
| 1 | `features/missions/presentation/widgets/mission_board_widget.dart` | 63–67 | compacto crimson (ACEPTAR) |
| 2 | `features/missions/presentation/widgets/mission_board_widget.dart` | 94–105 | compacto cyan (GENERAR MISIONES) |
| 3 | `features/missions/presentation/widgets/mission_board_widget.dart` | 132–136 | compacto gold (RECLAMAR) |
| 4 | `features/dashboard/presentation/widgets/daily_quests_widget.dart` | 163–170 | compacto |
| 5 | `features/dashboard/presentation/widgets/lesson_preview_sheet.dart` | 296–303 | compacto |
| 6 | `features/dashboard/presentation/widgets/next_recommended_lesson_hero.dart` | 230–236, 390–392 | compacto ×2 |
| 7 | `features/dashboard/presentation/widgets/recommended_lessons_hub.dart` | 155–159, 476–491 | compacto ×2 |
| 8 | `features/dashboard/presentation/widgets/ai_pick_hero_card.dart` | 218–220 | compacto |
| 9 | `features/dashboard/presentation/screens/dashboard_screen.dart` | 761–772, 1044–1053 | icon + compacto |
| 10 | `features/dashboard/presentation/screens/profile_edit_screen.dart` | 212–238, 622–693 | icon + compacto |
| 11 | `features/dashboard/presentation/screens/profile_screen.dart` | 169–180 | full-width runeViolet |
| 12 | `features/dashboard/presentation/screens/settings_screen.dart` | 155–216 | full-width |
| 13 | `features/dashboard/presentation/screens/session_summary_screen.dart` | 491–497 | icon |
| 14 | `features/dashboard/presentation/widgets/status_window_modal.dart` | 283–294 | compacto |
| 15 | `features/economy/presentation/widgets/daily_reward_modal.dart` | 127–143 | full-width gold (RECLAMAR) |
| 16 | `features/economy/presentation/screens/shop_screen.dart` | 378–386 | compacto |
| 17 | `features/economy/presentation/screens/fragments_exchange_screen.dart` | 292–296 | compacto |
| 18 | `features/economy/presentation/screens/inventory_screen.dart` | 256–258 | compacto |
| 19 | `features/economy/presentation/screens/battle_pass_screen.dart` | 213–215 | compacto |
| 20 | `features/subscription/presentation/screens/paywall_screen.dart` | 351–353 | full-width |
| 21 | `features/onboarding/presentation/screens/welcome_screen.dart` | 199–211, 308–320, 417–424 | full-width ×3 |
| 22 | `features/onboarding/presentation/screens/onboarding_screen.dart` | 327–329 | full-width |
| 23 | `features/onboarding/presentation/screens/placement_test_screen.dart` | 662–664 | compacto |
| 24 | `features/onboarding/presentation/screens/oracle_conversation_screen.dart` | 338–340 | compacto |
| 25 | `features/onboarding/presentation/widgets/character_creation_wizard.dart` | 189–195 | full-width |
| 26 | `features/chat_rooms/presentation/screens/voice_room_screen.dart` | 888–922 | icon ×2 |
| 27 | `features/chat_rooms/presentation/screens/chat_rooms_screen.dart` | 211–239, 361–365, 591–593 | ×3 |
| 28 | `features/conversation/presentation/widgets/conversational_tactics_navigator.dart` | 94–99 | compacto |
| 29 | `features/conversation/presentation/screens/conversation_screen.dart` | 200–205 | full-width |
| 30 | `features/conversation/presentation/screens/level_exam_screen.dart` | 428–442, 493–497 | icon ×3 |
| 31 | `features/vocabulary/presentation/widgets/srs_flashcard_modal.dart` | 139–141, 255–257 | compacto ×2 |
| 32 | `core/widgets/system_mana_disruption_screen.dart` | 109–116 | icon |

**Total:** ~94 usos de `ElevatedButton` en ~25 archivos; la mayoría sobreescribe
`backgroundColor` + `foregroundColor` + `padding` + `shape`.

> Nota: `core/widgets/runic_button.dart` ya existe (botón primario full-width con micro-interacción)
> pero **solo se usa 1 vez** (`hunter_status_screen.dart:248`).

### Componente propuesto

**Nombre:** `HudButton` (en `lib/core/widgets/hud_button.dart`)

```dart
HudButton({
  required String label,
  IconData? icon,
  VoidCallback? onPressed,
  Color backgroundColor = AppColors.manaCyan,
  Color foregroundColor = AppColors.voidBg,
  HudButtonSize size = HudButtonSize.regular, // regular | compact | small
  bool expand = false,
})
```

- Params: `label`, `icon?`, `onPressed?`, `backgroundColor`, `foregroundColor`, `size`
  (regular / compact / small → mapea `padding` y `fontSize`), `expand` (full-width vs inline).
- Ubicación: `lib/core/widgets/hud_button.dart`.
- Refactor de `RunicButton` para delegar en `HudButton` (solo aporta la micro-interacción de escala).
- Reemplaza los ~94 `ElevatedButton.styleFrom(...)` de las features con `HudButton`,
  conservando un solo punto de cambio para radios, paddings y colores de acento.

---

## 4. Patrón: Header de pantalla con back button + título (+ subtítulo / badge derecha)

### Descripción del patrón

`Padding(h:24 v:16)` → `Row[ IconButton(Icons.arrow_back_ios_new_rounded, color: onSurface,
onPressed: context.pop) + Text('TÍTULO', spaceGrotesk 20 bold letterSpacing 1.5) ]`,
opcionalmente con subtítulo (mono 12 `onSurfaceVariant`) y/o chip de balance a la derecha.

### Ocurrencias confirmadas

| # | Archivo | Líneas | Variante |
|---|---------|--------|----------|
| 1 | `features/economy/presentation/screens/shop_screen.dart` | 207–281 | back + título + balance (gemas+oro) |
| 2 | `features/economy/presentation/screens/inventory_screen.dart` | 59–87 | back + título + contador items |
| 3 | `features/economy/presentation/screens/collections_screen.dart` | 68–96 | back + título + `n/total` |
| 4 | `features/economy/presentation/screens/fragments_exchange_screen.dart` | 149–194 | back + título + balance fragmentos |
| 5 | `features/economy/presentation/screens/battle_pass_screen.dart` | 59–96 | back + título + badge PREMIUM/GRATUITO |
| 6 | `features/dashboard/presentation/screens/hunter_status_screen.dart` | 138–156 | back + título |
| 7 | `features/dashboard/presentation/screens/dungeon_map_screen.dart` | 46–47+ | back + título |
| 8 | `features/dashboard/presentation/screens/settings_screen.dart` | 87–90+ | back + título |
| 9 | `features/dashboard/presentation/screens/leaderboard_screen.dart` | 76–113 | back + título + **subtítulo** |
| 10 | `features/dashboard/presentation/screens/session_summary_screen.dart` | 75 | back (arrow_back_rounded) + título |
| 11 | `features/dashboard/presentation/screens/profile_edit_screen.dart` | 326 | back (arrow_back_rounded) + título |
| 12 | `features/chat_rooms/presentation/screens/chat_rooms_screen.dart` | 271–287 | `AppBar` con leading back + título |
| 13 | `features/chat_rooms/presentation/screens/voice_room_screen.dart` | 264–309 | back + título + **subtítulo** + badge LIVE |
| 14 | `features/onboarding/presentation/screens/placement_test_screen.dart` | 297–298+ | back + título |
| 15 | `features/onboarding/presentation/screens/oracle_conversation_screen.dart` | 157–158+ | back + título |
| 16 | `features/onboarding/presentation/screens/onboarding_screen.dart` | 271–272+ | back + título |
| 17 | `features/conversation/presentation/screens/conversation_screen.dart` | 751–752 | back + título (HUD in-room) |

**Total:** ~17 headers en **14 archivos**, todos con la misma estructura
`IconButton(arrow_back_ios_new_rounded, onSurface, pop)` + título `spaceGrotesk 20 bold ltr 1.5`.

### Componente propuesto

**Nombre:** `HudScreenHeader` (en `lib/core/widgets/hud_screen_header.dart`)

```dart
HudScreenHeader({
  required String title,
  String? subtitle,
  List<Widget> trailing,     // chips de balance, contador, badges
  VoidCallback? onBack,      // default: Navigator.maybePop
  Color titleColor = AppColors.onSurface,
})
```

- Params: `title`, `subtitle?`, `trailing` (Widgets a la derecha), `onBack?`, `titleColor`.
- Ubicación: `lib/core/widgets/hud_screen_header.dart`.
- Reemplaza las ~17 instancias de `features/` (incluye la variante `AppBar` de `chat_rooms_screen`)
  y centraliza icono de back, padding y tipografía del título.

---

## 5. Patrón: Empty states (icono + mensaje + CTA opcional)

### Descripción del patrón

Cuando una lista/colección está vacía se muestra `Center(Column[ Icon grande (36–64px, tono),
titulo mono uppercase (12–18px), subtítulo Inter (11–12px `onSurfaceVariant`), opcional botón CTA ])`
o una variante simple solo-texto.

### Ocurrencias confirmadas

| # | Archivo | Líneas | Variante |
|---|---------|--------|----------|
| 1 | `features/missions/presentation/widgets/mission_board_widget.dart` | 80–108 | icon + título + desc + **CTA** (completo) |
| 2 | `features/economy/presentation/screens/collections_screen.dart` | 105–118 | icon `emoji_events_outlined` + título (sin CTA) |
| 3 | `features/economy/presentation/screens/inventory_screen.dart` | 137 | solo texto (INVENTARIO VACÍO) |
| 4 | `features/dashboard/presentation/screens/leaderboard_screen.dart` | 116–139 | icon `emoji_events_outlined` 64px + título (sin CTA) |
| 5 | `features/missions/presentation/widgets/guild_quest_board.dart` | 96–107 | GlassCard solo texto |
| 6 | `features/dashboard/presentation/screens/dashboard_screen.dart` | 1065–1076 | GlassCard solo texto (vocabulario) |
| 7 | `features/dashboard/presentation/screens/profile_screen.dart` | 385, 555 | solo texto |
| 8 | `features/dashboard/presentation/widgets/learning_path_roadmap.dart` | 229 | solo texto |

**Total:** ~8 empty states en **7 archivos**, de 2–3 formas ligeramente distintas
(completo con CTA, icono+título, solo texto).

### Componente propuesto

**Nombre:** `EmptyState` (en `lib/core/widgets/empty_state.dart`)

```dart
EmptyState({
  IconData icon,
  String title,
  String? description,
  Widget? action,             // CTA opcional
  Color iconColor = AppColors.onSurfaceVariant,
})
```

- Params: `icon`, `title`, `description?`, `action?` (botón CTA), `iconColor`.
- Ubicación: `lib/core/widgets/empty_state.dart`.
- Unifica las 3 variantes: CTA opcional (`action`), texto secundario opcional (`description`),
  y permite el mismo look-and-feel (icon 48px con alpha, título mono uppercase, subtítulo Inter).
- Reemplaza: mission_board_widget, collections_screen, inventory_screen, leaderboard_screen,
  guild_quest_board, dashboard_screen, profile_screen, learning_path_roadmap.

---

## Priorización: Top 5 oportunidades (impacto = nº duplicaciones × complejidad)

| # | Oportunidad | Duplicaciones | Archivos afectados | Complejidad (1–5) | Impacto estimado |
|---|-------------|---------------|--------------------|--------------------|------------------|
| 1 | **`HudButton`** (botones ElevatedButton custom) | ~94 usos / ~25 archivos | missions, dashboard, economy, onboarding, chat_rooms, conversation, subscription, vocabulary, core | 4 | **Muy alto** |
| 2 | **`RewardChip`** (chips icono + texto mono) | ~20 usos / 13 archivos | missions, dashboard, economy, core | 3 | **Alto** |
| 3 | **`HudScreenHeader`** (header back + título) | ~17 usos / 14 archivos | economy, dashboard, chat_rooms, onboarding, conversation | 2 | **Alto** |
| 4 | **`EmptyState`** (icono + mensaje + CTA) | ~8 usos / 7 archivos | missions, economy, dashboard | 2 | **Medio** |
| 5 | **Adoptar `StatTile`** (KPI card, ya existe en core) | ~5 usos / 4 archivos | profile, daily_reward, session_summary, status_window | 2 | **Medio** |

### Justificación

1. **HudButton** (#1): la mayor superficie de duplicación (94 usos). Cada cambio de estilo del
   sistema (radio, padding, colores de acento) exige tocar ~25 archivos. Además `RunicButton`
   (que ya encapsula micro-interacción) está prácticamente sin adopción — hay dos "caminos" de
   botón en el código.
2. **RewardChip** (#2): la identidad del producto (gemas/XP/racha) se re-dibuja en cada pantalla.
   Ya hay 3 componentes privados duplicados (`_GemChip`, `_XpChip`, `_StatusPill`) en
   `guild_quest_board.dart` y 5+ badges inline.
3. **HudScreenHeader** (#3): baja complejidad, máximo "copia-pega" (17 headers casi idénticos).
   Alto retorno por esfuerzo mínimo.
4. **EmptyState** (#4): consistencia UX; hoy conviven 3 variantes visuales distintas para el mismo
   concepto.
5. **StatTile** (#5): no hay que crear nada — el widget existe y `session_summary_screen` ya lo
   usa; falta adopción en `profile_screen` (3 KPI inline) y variantes como `_RewardTile`.

---

## Tabla resumen

| Patrón | Ocurrencias | Archivos | Componente propuesto | Ubicación | Prioridad |
|--------|-------------|----------|----------------------|-----------|-----------|
| Chips/badges icono + mono (gemas, XP, racha, nivel, status) | ~20 | 13 | `RewardChip` (+ helpers `.gems/.xp/.streak/.cefr`) | `core/widgets/reward_chip.dart` | 2 |
| Tarjeta KPI (valor grande mono + label) | ~5 | 4 | **Adoptar `StatTile` existente** (+ variant box) | `core/widgets/stat_tile.dart` | 5 |
| `ElevatedButton` custom (bg + fg + shape + padding) | ~94 | ~25 | `HudButton` (sizes) — `RunicButton` delega | `core/widgets/hud_button.dart` | 1 |
| Header back + título (+ subtítulo / trailing) | ~17 | 14 | `HudScreenHeader` | `core/widgets/hud_screen_header.dart` | 3 |
| Empty state (icono + mensaje + CTA) | ~8 | 7 | `EmptyState` | `core/widgets/empty_state.dart` | 4 |

---

### Notas de auditoría

- **Patrón ya centralizado y respetado:** `GlassCard`, `SegmentedBar`, `AnimatedCounter`,
  `FloatingReward`, `RpgAvatar`, `CyberManhwaBackground`, tipografía `AppTypography` y temas de
  `AppTheme`. No se recomienda tocarlos.
- **Oportunidades adyacentes no priorizadas** (fuera del alcance de la tarea, solo mención):
  - Filtros tipo "chip selectable" (patrón `_FilterChip` de `guild_quest_board.dart:110–144`,
    `inventory_screen.dart:96–118`, `recommended_lessons_hub.dart:273+`) → candidato a
    `SelectableChip` / uso del `ChipTheme` global.
  - Headers de sección con icono + label mono uppercase (mission_board_widget:24–33 y
    guild_quest_board:32–41, daily_quests_widget:63–79, session_summary:334–351) → candidato a
    `SectionHeader`.
  - Cards de misión (mission_board `_MissionCard` vs guild_quest_board `_GuildQuestCard` vs
    `quest_card.dart`) comparten estructura icon-container + título + SegmentedBar + recompensas.

- **Cumplimiento de la tarea:** no se modificó ningún `.dart`; solo se creó este documento.
