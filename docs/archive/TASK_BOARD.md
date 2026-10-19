# 📋 TASK BOARD — TutorSaas / Dungeon of English

> Seguimiento visual del backlog de desarrollo. Fuente: `docs/BACKLOG.md`.
> Leyenda: ⬜ Pendiente · 🔄 En curso · ✅ Completada · ⛔ Bloqueada · 🧪 En QA

## 🧱 Épica 0 — Transversal (P0)

| ID | Tarea | Estado | Prioridad | Aceptación |
|----|-------|--------|-----------|------------|
| T-000 | Aplicar migraciones pendientes a DB live | ✅ | P0 | RPCs + columnas idioma + 8 tablas mission + 29 plantillas en live |
| T-001 | Fix overflow_test LeagueLeaderboard | ✅ | P0 | flutter test 13/13 |
| T-002 | Fix voice room roomId no-UUID | ✅ | P0 | apertura con slug sin crash |

## 👤 Épica 1 — Fase 2 · Experiencia del Usuario

| ID | Tarea | Estado | Prioridad | Aceptación |
|----|-------|--------|-----------|------------|
| T-100 | Localización aplicada en MaterialApp | ✅ | P0 | analyze 0 errores; UI responde al idioma |
| T-101 | Persistir idioma desde onboarding | ✅ | P0 | persiste en prefs + Supabase |
| T-102 | Migración columnas de idioma user_settings | ✅ | P0 | columnas aplicadas en live |
| T-103 | Oracle conversacional (oracle_questions) | ✅ | P1 | evalúa CEFR A1-C1, navegable |
| T-104 | Persistir país de origen | ✅ | P1 | se guarda en users.country_code (aplicado en live) |
| T-105 | i18n strings hardcoded welcome/onboarding | ✅ | P2 | sin strings sueltos |

## 🏠 Épica 2 — Fase 3 · Dashboard

| ID | Tarea | Estado | Prioridad | Aceptación |
|----|-------|--------|-----------|------------|
| T-200 | HUD central del dashboard | ✅ | P0 | paridad hunter_control_center_dashboard |
| T-201 | Mapa de mazmorras (gateways) | ✅ | P0 | mapa interactivo navegable |
| T-202 | Refinar Hunter Status (tipografía/barras) | ✅ | P1 | tipografía estándar |
| T-203 | Accesos rápidos y badges | ✅ | P1 | quick access funcional |

## 🗣️ Épica 3 — Fase 4 · Conversaciones

| ID | Tarea | Estado | Prioridad | Aceptación |
|----|-------|--------|-----------|------------|
| T-300 | Header/HUD del Oráculo | ✅ | P0 | paridad combat battle, pipeline intacto |
| T-301 | Barra de progreso unificada (SegmentedBar) | ✅ | P0 | barra 10 segmentos |
| T-302 | Recompensas visuales FloatingReward | ✅ | P1 | +XP al completar objetivo |
| T-303 | Tácticas → summary → recompensas | ✅ | P1 | bonus XP coherente |

## 🎯 Épica 4 — Fase 5 · Misiones

| ID | Tarea | Estado | Prioridad | Aceptación |
|----|-------|--------|-----------|------------|
| T-400 | Repo misiones de gremio | ✅ | P0 | acceso a guild_collaborative_missions |
| T-401 | Repo eventos globales | ✅ | P0 | acceso a global_events |
| T-402 | Progresión parcial incremental | ✅ | P1 | progress incremental |
| T-403 | Mission Board integrado + filtros | ✅ | P1 | board visible en dashboard |
| T-404 | Rotación/timers (edge function) | ✅ | P1 | generación diaria automática |

## 💰 Épica 5 — Fase 6 · Economía

| ID | Tarea | Estado | Prioridad | Aceptación |
|----|-------|--------|-----------|------------|
| T-500 | Fix claimDailyReward | ✅ | P0 | RPC pergaminos ejecuta bien |
| T-501 | Pantalla inventario + ruta | ✅ | P0 | /inventory navegable |
| T-502 | Battle Pass repo + UI | ✅ | P0 | pase visible y claimable |
| T-503 | Daily Rewards UI | ✅ | P1 | modal + streak visual |
| T-504 | Lógica oro + fragmentos | ✅ | P1 | recursos operativos |
| T-505 | Loot/drops conversaciones | ✅ | P1 | items al completar |
| T-506 | Invocaciones ↔ IA conversación | ✅ | P1 | límite aplicado |
| T-507 | Balance económico | ✅ | P2 | curva ajustada |

---

## 🏁 Métricas
- **Total tareas:** 27
- **P0:** 16 · **P1:** 8 · **P2:** 3
- **Completadas:** 27 / 27 ✅
