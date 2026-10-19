# Plan de Implementación — Auditoría UX/UI "Dungeon of English"

Basado en la auditoría completa de `docs/UX_UI_AUDIT.md`.
**Objetivo:** Llevar la identidad RPG del 35% actual al 85%+.

---

## FASE 0 — Fundación del Sistema de Diseño (Día 1-2)
*Impacto: ~40 problemas resueltos de una sola vez*

| # | Tarea | Archivos | Prioridad |
|---|-------|----------|-----------|
| 0.1 | Definir `elevatedButtonTheme` en AppTheme | `lib/core/theme/app_theme.dart` | 🔴 |
| 0.2 | Definir `outlinedButtonTheme` en AppTheme | `lib/core/theme/app_theme.dart` | 🔴 |
| 0.3 | Definir `textButtonTheme` en AppTheme | `lib/core/theme/app_theme.dart` | 🔴 |
| 0.4 | Definir `inputDecorationTheme` (bordes 4px, fondo oscuro) | `lib/core/theme/app_theme.dart` | 🔴 |
| 0.5 | Definir `switchTheme` (cyber toggle) | `lib/core/theme/app_theme.dart` | 🟠 |
| 0.6 | Definir `chipTheme` (ChoiceChip, FilterChip) | `lib/core/theme/app_theme.dart` | 🟠 |
| 0.7 | Definir `dialogTheme` (fondo #11131B, borde 4px) | `lib/core/theme/app_theme.dart` | 🟠 |
| 0.8 | Definir `snackBarTheme` (oscuro, borde cyan) | `lib/core/theme/app_theme.dart` | 🟠 |
| 0.9 | Definir `bottomNavigationBarTheme` | `lib/core/theme/app_theme.dart` | 🟠 |
| 0.10| Agregar colores faltantes (HP bar, XP bar, rarity colors) | `lib/core/theme/app_colors.dart` | 🟡 |

---

## FASE 1 — Eliminar Emojis como Iconos UI (Día 2-3)
*Impacto: 35+ problemas crÍticos resueltos*

| # | Tarea | Archivos |
|---|-------|----------|
| 1.1 | Reemplazar emoji `'🎙️'` por `Icons.mic` o custom icon | `daily_quests_widget.dart`, `voice_room_screen.dart`, `conversation_screen.dart` |
| 1.2 | Reemplazar emoji `'📚'` por `Icons.menu_book` | `daily_quests_widget.dart` |
| 1.3 | Reemplazar emoji `'🎯'` por `Icons.ads_click` | `daily_quests_widget.dart` |
| 1.4 | Reemplazar emoji `'🥇'`, `'⚡'`, `'🗣️'`, `'🎯'` en achievements | `dashboard_screen.dart` |
| 1.5 | Reemplazar emoji `'🇺🇸'` por text-based flag component | `dashboard_screen.dart` |
| 1.6 | Reemplazar emoji `'📊'` en Profile header | `profile_screen.dart` |
| 1.7 | Reemplazar emoji `'🔮'`, `'⚡'`, `'👑'` en Paywall | `paywall_screen.dart` |
| 1.8 | Reemplazar 20 emojis del topic bar en conversación | `conversation_screen.dart` |
| 1.9 | Reemplazar `'🙈'`, `'👁️'`, `'⌨️'`, `'🎙️'` en mode toggles | `conversation_screen.dart` |
| 1.10| Reemplazar emoji `'🏰'` en Chat Rooms header | `chat_rooms_screen.dart` |
| 1.11| Reemplazar emoji `'🔴'` en live indicator | `voice_room_screen.dart` |
| 1.12| Reemplazar emoji `'🔊'`, `'✋'` en voice room | `voice_room_screen.dart` |
| 1.13| Reemplazar emoji `'😅'`, `'⚖️'`, `'😊'` en SRS | `srs_flashcard_modal.dart` |
| 1.14| Reemplazar emoji `'🎉'`, `'🚨'` en Level Exam | `level_exam_screen.dart` |
| 1.15| Reemplazar emoji `'🌟'`, `'💻'`, `'💼'`, `'✈️'`, `'☕'`, `'🍳'` en categorías | `recommended_lessons_hub.dart` |
| 1.16| Reemplazar emoji `'🔮'`, `'📜'`, `'🍻'`, `'🎙️'`, `'🐉'` en features paywall | `paywall_screen.dart` |
| 1.17| Reemplazar emoji en Placement Test | `placement_test_screen.dart` |
| 1.18| Reemplazar emoji en DraggableMonsterWidget | `draggable_monster_widget.dart` |
| 1.19| Reemplazar emoji en ManaMeterWidget | `mana_meter_widget.dart` |

---

## FASE 2 — Sistema de Avatares RPG (Día 3-4)
*Impacto: 10+ problemas crÍticos*

| # | Tarea | Archivos |
|---|-------|----------|
| 2.1 | Crear `RpgAvatar` widget con marco de clase/rank | nuevo: `core/widgets/rpg_avatar.dart` |
| 2.2 | Reemplazar DiceBear en Dashboard header | `dashboard_screen.dart` |
| 2.3 | Reemplazar DiceBear en Profile | `profile_screen.dart` |
| 2.4 | Reemplazar DiceBear en Profile Edit | `profile_edit_screen.dart` |
| 2.5 | Reemplazar DiceBear en Leaderboard | `league_leaderboard_widget.dart` |
| 2.6 | Reemplazar DiceBear en Hunter License | `hunter_license_screen.dart` |
| 2.7 | Reemplazar DiceBear en Draggable Monster | `draggable_monster_widget.dart` |
| 2.8 | Reemplazar CircleAvatar genérico en Voice Room | `voice_room_screen.dart` |
| 2.9 | Reemplazar CircleAvatar boss en Level Exam | `level_exam_screen.dart` |

---

## FASE 3 — Botones y Controles Globales (Día 4-5)
*Impacto: 20+ problemas*

| # | Tarea | Archivos |
|---|-------|----------|
| 3.1 | Reemplazar todos los `ElevatedButton` por `SystemButton` | Todos los screens (20+ instancias) |
| 3.2 | Reemplazar todos los `OutlinedButton` por `SystemButton` | Todos los screens (10+ instancias) |
| 3.3 | Reemplazar `FloatingActionButton` en Level Exam | `level_exam_screen.dart` |
| 3.4 | Reemplazar FAB blanco de mic en Conversation | `conversation_screen.dart` |
| 3.5 | Reemplazar `ChoiceChip` por custom segment control | `recommended_lessons_hub.dart`, `settings_screen.dart`, `chat_rooms_screen.dart` |
| 3.6 | Reemplazar `FilterChip` por custom selector | `recommended_lessons_hub.dart` |
| 3.7 | Reemplazar `Switch` por RPG toggle | `settings_screen.dart`, `onboarding_screen.dart` |
| 3.8 | Reemplazar `DropdownButton` por custom selector | `settings_screen.dart`, `onboarding_screen.dart`, `profile_edit_screen.dart` |
| 3.9 | Reemplazar `LinearProgressIndicator` por `ManaBar` | Todos los screens |
| 3.10| Reemplazar `CircularProgressIndicator` por custom spinner | Todos los screens |
| 3.11| Reemplazar `SnackBar` default por custom toast | Todos los screens |
| 3.12| Reemplazar `AlertDialog` por `SystemWindow` modal | Todos los screens |

---

## FASE 4 — Consistencia de Bordes y Formas (Día 5-6)
*Impacto: 15+ problemas*

| # | Tarea | Archivos |
|---|-------|----------|
| 4.1 | Fix chat bubbles: radius 20→4px | `conversation_screen.dart` |
| 4.2 | Fix mana meter: radius 16→4px | `mana_meter_widget.dart` |
| 4.3 | Fix bottom sheets: radius 24/28→4px | `settings_screen.dart`, `srs_flashcard_modal.dart`, `conversation_screen.dart` |
| 4.4 | Fix goal chips: radius 10→4px | `live_goals_tracker_bar.dart` |
| 4.5 | Fix audio rings: radius 8→4px | `voice_waveform_visualizer.dart` |
| 4.6 | Fix vocab modal: radius 8→4px | (inline styles) |
| 4.7 | Fix summary screen: radius 20→4px | `session_summary_screen.dart` |
| 4.8 | Remove all `ClipOval` on back buttons | `profile_screen.dart`, `session_summary_screen.dart` |
| 4.9 | Remove all `BoxShape.circle` from non-avatar elements | Global |

---

## FASE 5 — Pantallas Críticas (Día 6-8)

| # | Tarea | Archivos |
|---|-------|----------|
| 5.1 | Rediseñar Profile Edit como stat sheet RPG | `profile_edit_screen.dart` |
| 5.2 | Cambiar nombre "TUTORSAAS" → "DUNGEON OF ENGLISH" | `welcome_screen.dart` |
| 5.3 | Reemplazar `Icons.translate` con logo personalizado | `welcome_screen.dart` |
| 5.4 | Rediseñar Settings Screen con layout RPG | `settings_screen.dart` |
| 5.5 | Rediseñar Placement Test con temática RPG | `placement_test_screen.dart` |
| 5.6 | Rediseñar input fields con tema RPG | Global |

---

## FASE 6 — Microinteracciones y Polish (Día 8-9)

| # | Tarea | Archivos |
|---|-------|----------|
| 6.1 | Agregar animación de pulso a SystemButton activo | `system_window.dart` |
| 6.2 | Agregar transición slide entre tabs del dashboard | `dashboard_screen.dart` |
| 6.3 | Agregar animación a ManaBar (pulso de glow) | `system_window.dart` |
| 6.4 | Agregar efecto hover/active a GlassCard | `glass_card.dart` |
| 6.5 | Agregar scanline a pantallas que no lo tienen | Varios |
| 6.6 | Agregar partículas de mana al cargar datos | Varios |

---

## FASE 7 — Errores de Encoding y Textos (Día 9)

| # | Tarea | Archivos |
|---|-------|----------|
| 7.1 | Fix secciones en español en Settings | `settings_screen.dart` |
| 7.2 | Fix terminología educativa ("lección"→"misión", etc.) | Global |
| 7.3 | Unificar patrones i18n con `t('key', ref: ref)` | Global |

---

## Matriz de Prioridades — Top 10

| # | Acción | Fase | Impacto | Esfuerzo |
|---|--------|------|---------|----------|
| 1 | Theme global de componentes | F0 | 🔴 20+ problemas | 1 día |
| 2 | Reemplazar emojis por iconos | F1 | 🔴 35+ problemas | 2 días |
| 3 | Sistema de avatares RPG | F2 | 🔴 10+ problemas | 1 día |
| 4 | SystemButton global | F3 | 🔴 30+ botones | 1 día |
| 5 | Consistencia de bordes | F4 | 🟠 15+ formas | 1 día |
| 6 | Profile Edit RPG | F5 | 🔴 1 pantalla | 1 día |
| 7 | Branding Dungeon of English | F5 | 🔴 Welcome screen | 0.5 día |
| 8 | Settings RPG | F5 | 🟠 1 pantalla | 1 día |
| 9 | Micro-interacciones | F6 | 🟡 Polish general | 1 día |
| 10 | Fix terminología | F7 | 🟠 Textos globales | 0.5 día |

---

## Estimación Total: 7-10 días hábiles
- **Días 1-2:** Fase 0 + Fase 1 (fundación + eliminar emojis)
- **Días 3-4:** Fase 2 + Fase 3 (avatares + botones)
- **Días 5-6:** Fase 4 + Fase 5 (bordes + pantallas críticas)
- **Días 7-9:** Fase 6 + Fase 7 + QA (microinteracciones + polish)
