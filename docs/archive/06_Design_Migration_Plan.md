# 06 — Design Migration Plan

> Fase 0/1 · Plan paso a paso para alcanzar paridad visual con `PlantillaHtml/` · Fecha: 2026-07-30
> Regla: el diseño oficial está en las plantillas. Esta es la hoja de ruta de migración (orden de menor a mayor riesgo).

## Paso 1 — Cerrar el sistema de diseño base

Objetivo: que cualquier pantalla nueva pueda consumir tokens oficiales sin improvisar.

- [ ] Añadir token `danger/error` = `#FF1744` y usarlo en `ColorScheme.error`.
- [ ] Crear constantes de espaciado (grid 4px, gutter 16px, margen móvil 20px, padding ventana 24px) en un lugar único (ej. `app_spacing.dart`).
- [ ] Crear `SystemWindow` = `GlassCard` + header de sistema (título mono + runic corners) para unificar todas las "ventanas del sistema".
- [ ] Crear `QuestCard`/`RankCard` (letra de rango + `SegmentedBar` + glifo) — base de misiones, guild y summary.
- [ ] Verificar cero hex hardcodeados fuera de `AppColors` (auditar con grep `0xFF` / `Color(`).

## Paso 2 — Pantallas de núcleo con paridad alta

| Orden | Pantalla | Plantilla | Detalles clave a replicar |
|---|---|---|---|
| 1 | Estado del Cazador `/hunter-status` | `hunter_status_profile_system` | S-Rank profile: stats con `SegmentedBar`, rank letter, AnimatedCounter en números |
| 2 | Mapa de mazmorras | `learning_dungeon_map_gateways` | Roadmap por niveles con bloqueos y progreso; entradas a `conversation` |
| 3 | Topic navigator | `conversational_tactics_navigator` | Selección de táctica/tema antes de `conversation` |
| 4 | Onboarding conectado | `hunter_class_selection` + `level_exam_screen` | Wizard → clase → oracle test → `/home` |

## Paso 3 — Elevar pantallas existentes

| Pantalla | Plantilla | Mejora |
|---|---|---|
| Dashboard | `hunter_control_center_dashboard` | HUD central: mana gem, notifications, party strip, runas |
| Conversation | `combat_system_english_battle` | Estética battle HUD sobre el flujo de voz existente (sin tocar pipeline) |
| Summary | `session_summary_screen` | Composición "Quest Clear" + recompensas con `FloatingReward` |
| Chat rooms | `social_hall_guild` + `guild_room_creation` | Raid rooms + modal de creación |
| Paywall | `s_rank_system_upgrade` | Upgrade framing + plans |

## Paso 4 — Pantallas de soporte

- Error/sin red → `system_mana_disruption_error`
- SRS review → `grimoire_recalibration_srs`
- Coach premium → `ai_mentor_chat_system`
- Evaluación de gremio → `guild_evaluation` (oracle test)

## Paso 5 — Validación

- [ ] Recorrido visual: cada ruta nueva/retocada comparada contra su `code.html` (paridad de layout, color, tipografía).
- [ ] `flutter analyze` 0 errores + `flutter test` verde tras cada PR de migración.
- [ ] `flutter gen-l10n` si se tocan strings de UI.
- [ ] Actualizar `docs/01_UI_Audit.md` marcando paridad ✅.

## Orden de ejecución sugerido en Fase 2

1. Paso 1 (sistema de diseño) → 2. Paso 2 (núcleo) → 3. Paso 3 (elevar) → 4. Paso 4 (soporte) → 5. Paso 5 (validación).

Cada paso debe quedar navegable y sin regresiones antes de pasar al siguiente.
