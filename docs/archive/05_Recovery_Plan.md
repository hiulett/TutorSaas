# 05 — Recovery Plan

> Fase 0/1 · Plan priorizado para restaurar y terminar el proyecto · Fecha: 2026-07-30
> Ordenado por riesgo/valor. Sin código todavía — plan para aprobar antes de Fase 2.

## Fase R0 — Asegurar el trabajo (P0, hacer YA)

- [ ] Commitear todo el trabajo actual (o backup manual del árbol `lib/`) para eliminar el riesgo R1.
  - ⚠️ Si se commitea: revisar `git status`, `git diff`; incluir `lib/features/economy/`, `lib/features/missions/`, `lib/l10n/`, `lib/features/onboarding/` untracked y todas las ediciones sin commitear de archivos rastreados.
- [ ] Refrescar el reporte de arquitectura: `graphify update .` (R2).

## Fase R1 — Verificar estado real (P0)

- [ ] Confirmar qué archivos Dart del estado post-regresión siguen vivos y cuáles quedaron en estado inicial (comparar contra `git show HEAD:...` de los rastreados clave: `conversation_screen`, `dashboard_screen`, `chat_rooms`, `app_theme`, `app_colors`).
- [ ] Verificar migraciones de DB contra el live (R3): usar MCP Supabase (`list_migrations`, `get_advisors`) y aplicar pendientes vía SQL Editor/branch si el live rechaza DDL.
- [ ] `flutter analyze` y `flutter test` para fijar la línea base de calidad.

## Fase R2 — Core loop (P0)

| Tarea | Referencia visual |
|---|---|
| Pantalla **Estado del Cazador** (`/hunter-status`) con stats, rangos, barras | `hunter_status_profile_system` |
| **Mapa de mazmorras** (selección de escenario con progreso) | `learning_dungeon_map_gateways` |
| **Topic/tactics navigator** antes de la conversación | `conversational_tactics_navigator` |
| Cablear **oracle test** (`/oracle-test`) en onboarding | `guild_evaluation` |
| Cablear **wizard de creación de personaje** al onboarding | `hunter_class_selection` |

## Fase R3 — Features existentes sin terminar (P1)

- [ ] Integrar misiones/economía con el dashboard (recompensas, rachas, gemas).
- [ ] Shop `/shop` + inventario + battle pass + daily reward (economía).
- [ ] Modal de creación de sala en guild hall (`guild_room_creation`).
- [ ] Pantalla SRS de repaso de vocabulario (`grimoire_recalibration_srs`).

## Fase R4 — Bugs y robustez (P1)

- [ ] Voice room: soportar `roomId` no-UUID (crear sala por slug o mapear a UUID).
- [ ] Pantalla de error/sin conexión (`system_mana_disruption_error`).
- [ ] Reconciliar documentación duplicada en `docs/` (UX_UI_AUDIT, IMPLEMENTATION_PLAN, serie 001–008) con el estado real.

## Fase R5 — Monetización y premium (P2)

- [ ] Coach premium / mentor chat (`ai_mentor_chat_system`).
- [ ] Mejorar paridad del paywall (`s_rank_system_upgrade`).

## Criterios de salida de Fase 2 (definición de "hecho")

1. `flutter analyze` con 0 errores y `flutter test` verde.
2. Todas las rutas planificadas registradas en `router.dart` y navegables.
3. Core loop completo: onboarding → clase/oracle → mapa de mazmorras → conversación → summary → recompensas.
4. Sin regresiones: la regresión de `git checkout` NO puede volver a ocurrir (regla AGENTS.md).
