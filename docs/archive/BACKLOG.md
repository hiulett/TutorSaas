# BACKLOG DE DESARROLLO — TutorSaas / Dungeon of English

> Fuente oficial: `/docs`. Generado: 2026-07-30.
> Cada tarea sigue el ciclo: Graphify → docs → plan → implementar → compilar → analyze → test → plantilla → docs.

## Estado de la línea base (verificado)
- `flutter analyze`: 58 issues, **0 errores** · `flutter build apk --debug`: ✅ OK · `flutter test`: 12/13 (1 falla preexistente `overflow_test` LeagueLeaderboard).
- Graphify actualizado: 4113 nodos / 4879 aristas.
- **DB live (TutorSaas `sipiumfdpvnszthykyog`)**: migraciones del 30-jul **NO aplicadas** → ver tarea T-000.

---

## 🧱 ÉPICA 0 — Transversal / Fundación (P0)

### T-000 · Aplicar migraciones pendientes a la DB live
- **Objetivo:** Sincronizar esquema con el código (riesgo R3).
- **Faltan en live:** `20260730_mission_engine`, `20260730_economy_and_ia_system`, `20260730_oracle_questions`, `20260730_data_retention_job`, `20260729_full_chat_system`, `20260729_add_room_moderation`, `add_correction_level`, `fix_cefr_levels`, `seed_objectives`, `fix_rls_policies`, `fix_conversations_schema`, `fix_rls_conversations`, seeds de lessons, `add_equipped_title`.
- **Base de datos:** multiple (missions, economy, oracle_questions, chat moderation).
- **Riesgo:** ALTO (DDL sobre producción). **Estrategia:** aplicar vía branch de desarrollo + verificación, NO DDL directo si falla "read-only transaction".
- **Dependencias:** — · **Complejidad:** Alta · **~2h**
- **Criterios de aceptación:** `list_migrations` refleja el 100%; RPCs `add_xp`, `add_gems`, `spend_gems`, `increment_pergaminos_max` existen.
- **Rollback:** migración reversible / backup.

### T-001 · Fix `overflow_test.dart` (LeagueLeaderboard pumpAndSettle timeout)
- **Objetivo:** Tests verdes (deuda K3-6).
- **Archivos:** `test/overflow_test.dart`, `lib/features/dashboard/presentation/widgets/league_leaderboard_widget.dart`.
- **Riesgo:** Bajo · **Complejidad:** Baja · **~1h**
- **Aceptación:** `flutter test` 13/13.
- **Rollback:** edición invertida.

### T-002 · Fix voice room roomId no-UUID (GUILD-001)
- **Objetivo:** Salas sociales con slug (`guild_table_1`) no crashen (K2-9).
- **Archivos:** `lib/features/chat_rooms/data/repositories/chat_rooms_repository_impl.dart`, `voice_room_screen.dart`.
- **Riesgo:** Alto (feature multi-usuario) · **Complejidad:** Baja · **~3h**
- **Aceptación:** apertura de sala con slug sin PostgrestException.
- **Rollback:** revertir parseo por edición.

---

## 👤 ÉPICA 1 — Fase 2 · Experiencia del Usuario (`docs/02_User_Experience`)

### T-100 · Aplicar localización en MaterialApp (ONB-003, K2-1) — P0
- **Objetivo:** `locale` reactivo desde `userLanguageProvider`; `localizationsDelegates` + `supportedLocales`.
- **Archivos:** `lib/app/app.dart`.
- **Dependencias:** — · **Riesgo:** Bajo · **Complejidad:** Baja · **~1.5h**
- **Aceptación:** `flutter analyze` 0 errores; la UI responde al idioma.
- **Rollback:** revertir `app.dart` por edición.

### T-101 · Persistir idioma desde onboarding (ONB-004, K2-2) — P0
- **Objetivo:** Al completar onboarding → `userLanguageProvider` (learning, aiExplanations, ui).
- **Archivos:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`.
- **Dependencias:** T-100 · **Riesgo:** Medio · **Complejidad:** Media · **~2h**
- **Aceptación:** elección persiste (SharedPreferences + Supabase).

### T-102 · Migración columnas de idioma en `user_settings` (ONB-005, K2-3) — P0
- **Base de datos:** `user_settings` + `ui_language`/`learning_language`/`ai_explanations_native`.
- **Dependencias:** T-000 · **Riesgo:** Bajo · **~0.5h**

### T-103 · Oracle conversacional (K2-5, K2-6) — P1
- **Objetivo:** Pantalla que consuma `oracle_questions` (7 preguntas) con evaluación CEFR C1/C2.
- **Archivos:** `lib/features/onboarding/` (nuevo screen) + provider.
- **Dependencias:** T-000 · **Riesgo:** Medio · **~5h**

### T-104 · Persistir país de origen (K2-4) — P1
- **Archivos:** onboarding + repo. · **~1h**

### T-105 · i18n de strings hardcoded welcome/onboarding (K2-7) — P2
- **Archivos:** `welcome_screen.dart`, `onboarding_screen.dart`. · **~4h**

---

## 🏠 ÉPICA 2 — Fase 3 · Dashboard (`docs/03_Dashboard`)

### T-200 · HUD central del dashboard (DSH-003, K3-5) — P0
- **Objetivo:** Encabezado HUD (mana gem, MP, XP/nivel, título, notificaciones) con `ManaMeterWidget`, `SegmentedBar`, `AnimatedCounter`, `GlassCard` rúnico — paridad `hunter_control_center_dashboard`.
- **Archivos:** `dashboard_screen.dart` + widgets core.
- **Dependencias:** T-100 · **Riesgo:** Alto (archivo 2018 líneas) · **~6h**

### T-201 · Mapa de mazmorras (DSH-002) — P0
- **Objetivo:** `learning_dungeon_map_gateways` como mapa interactivo.
- **Archivos:** nuevo `dungeon_map_screen.dart` + ruta.
- **Dependencias:** T-200 · **Riesgo:** Medio · **~7h**

### T-202 · Refinar Hunter Status (K3-4) — P1
- **Objetivo:** reemplazar `orbitron` por tipografía estándar; `SegmentedBar` + `AnimatedCounter`.
- **Archivos:** `hunter_status_screen.dart`. · **~2h**

### T-203 · Accesos rápidos y badges (K3-5) — P1
- **Objetivo:** quick access a /shop, /oracle-test, /level-exam, /settings + badges de misiones. · **~3h**

---

## 🗣️ ÉPICA 3 — Fase 4 · Conversaciones (`docs/04_Conversations`)

### T-300 · Header/HUD del Oráculo (CONV-001, K4-1) — P0
- **Objetivo:** paridad `combat_system_english_battle` sin tocar el pipeline de voz.
- **Archivos:** `conversation_screen.dart`.
- **Riesgo:** Alto (1175 líneas, pipeline NO alterar) · **~6h**

### T-301 · Barra de progreso unificada con SegmentedBar (K4-1) — P0
- **Archivos:** `live_goals_tracker_bar.dart` / `conversation_screen.dart`. · **~2h**

### T-302 · Recompensas visuales `FloatingReward` en logros (K4-2) — P1
- **Archivos:** `conversation_screen.dart`. · **~2h**

### T-303 · Integrar tácticas → summary → recompensas (K4-3) — P1
- **Objetivo:** bonus de XP de táctica persiste/coherente con economía. · **~3h**

---

## 🎯 ÉPICA 4 — Fase 5 · Misiones (`docs/05_Missions`)

### T-400 · Repositorio misiones de gremio (MIS-002, K5-1) — P0
- **Objetivo:** acceso Flutter a `guild_collaborative_missions`.
- **Dependencias:** T-000 · **~3h**

### T-401 · Repositorio eventos globales + player_event_progress (MIS-003, K5-1) — P0
- **Dependencias:** T-000 · **~3h**

### T-402 · Progresión parcial incremental (MIS-004, K5-2) — P1
- **Objetivo:** `updateProgress(current + delta)` sin saltar a completed.
- **Archivos:** `mission_repository.dart`. · **~2h**

### T-403 · Mission Board integrado al dashboard + filtros (K5-4) — P1
- **Archivos:** `mission_board_widget.dart`, `dashboard_screen.dart`. · **~3h**

### T-404 · Rotación/timers (MIS-005, K5-3) — P1
- **Objetivo:** edge function/cron `generateDailyMissions` + timers de expiración. · **~4h**

---

## 💰 ÉPICA 5 — Fase 6 · Economía (`docs/06_Economy`)

### T-500 · Fix `claimDailyReward` (ECON-004, K6-1) — P0
- **Objetivo:** quitar Future como valor de `pergaminos_max`; separar RPC.
- **Archivos:** `economy_repository_impl.dart`. · **~0.5h**

### T-501 · Pantalla de inventario + ruta `/inventory` (ECON-005, K6-5) — P0
- **Archivos:** nuevo `inventory_screen.dart` + router. · **~4h**

### T-502 · Battle Pass repo + UI (ECON-003, K6-4) — P0
- **Archivos:** `guild_battle_pass` repo + screen. · **~5h**

### T-503 · Daily Rewards UI (K6-6) — P1
- **Archivos:** modal de daily reward + streak visual. · **~2h**

### T-504 · Lógica de oro + fragmentos (K6-3, K6-9) — P1
- **~3h**

### T-505 · Loot/drops al completar conversaciones (K6-8) — P1
- **~3h**

### T-506 · Integración invocaciones ↔ IA conversación (K6-6) — P1
- **Objetivo:** `canInvoke`/`useInvocation` en inicio de conversación. · **~3h**

### T-507 · Balance económico (K6-11) — P2
- **~4h**

---

## 📊 Resumen de prioridades
| Prioridad | Nº tareas | Total aprox. |
|---|---|---|
| P0 | 16 | ~55h |
| P1 | 11 | ~33h |
| P2 | 3 | ~10h |

**Orden de ejecución:** T-000 → T-100 → T-101 → T-102 → (Fase 2) → T-200 → T-201 (Fase 3) → T-300 → T-301 (Fase 4) → T-400 → T-401 (Fase 5) → T-500 → T-501 → T-502 (Fase 6) → P1/P2 restantes → QA global.
