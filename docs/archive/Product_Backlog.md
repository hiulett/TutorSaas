# Product Backlog — TutorSaas / Dungeon of English

> Actualizado: 2026-07-30 — Fases 2–6 **documentadas** (análisis/plan), implementación pendiente.
> Estado por fase y detalles en `/docs/02_User_Experience`, `/docs/03_Dashboard`, `/docs/04_Conversations`,
> `/docs/05_Missions`, `/docs/06_Economy`.

## Epic 1: Core Design System & Theme Alignment
### [DS-001] Introduce Danger Token & Spacing Constants — ⬜ Pendiente
### [DS-002] Create Custom QuestCard / RankCard Widget — ✅ Widget creado (`lib/core/widgets/quest_card.dart`)
### [DS-003] Create SystemWindow Wrapper Widget — ✅ Widget creado (`lib/core/widgets/system_window.dart`)

---

## Epic 2: Onboarding & User Customization Flow *(Fase 2 — 02_User_Experience)*
### [ONB-001] Wire Character Creation Wizard and Class Selection Screen — ✅ Conectado (9º paso del onboarding)
### [ONB-002] Wire Oracle Placement Test Screen — ✅ Ruta `/oracle-test` → `PlacementTestScreen`
### [ONB-003] Aplicar l10n en MaterialApp — ⬜ Pendiente (K2-1)
### [ONB-004] Persistir idioma del onboarding en `userLanguageProvider` — ⬜ Pendiente (K2-2)
### [ONB-005] Migración `user_settings` idioma — ⬜ Pendiente (K2-3)

---

## Epic 3: Dashboard & Hunter Profile System *(Fase 3 — 03_Dashboard)*
### [DSH-001] Build Hunter Status Profile Screen (`/hunter-status`) — ✅ Implementada (316 líneas)
### [DSH-002] Create Dungeon Gateways Selection Map — ⬜ Pendiente
### [DSH-003] HUD central (mana gem, party, notifications) — ⬜ Pendiente (K3-5)

---

## Epic 4: Conversation Engine & Voice Experience *(Fase 4 — 04_Conversations)*
### [CONV-001] Visual Polish for Combat System Battle Screen — ⬜ Pendiente (K4-1)
### [CONV-002] Integrate Conversational Tactics Selector — ✅ Implementado (`conversational_tactics_navigator`)
### [CONV-003] Recompensas visuales en flujo — ⬜ Pendiente (K4-2)

---

## Epic 5: Economy & Progression Integrations *(Fase 6 — 06_Economy)*
### [ECON-001] Verify & Integrate Economy Modules — ✅ Repo + providers + migración
### [ECON-002] Build Shop & Shop Inventory Screen — ✅ `/shop`; ⬜ inventario UI (K6-5)
### [ECON-003] Battle Pass — ⬜ Pendiente (K6-4)
### [ECON-004] Fix `claimDailyReward` — ⬜ Pendiente (K6-1)

---

## Epic 6: Guild & Raid Rooms
### [GUILD-001] Fix Voice Room roomId Non-UUID Crash — ⬜ Pendiente
### [GUILD-002] Create Guild Room Builder Dialog — ⬜ Pendiente

---

## Epic 7: Database & Migrations Sync
### [DB-001] Database Migration Audit and Live Sync — ⬜ Pendiente (verificar RPCs add_xp/add_gems/spend_gems en live)

---

## Epic 8: Sistema de Misiones *(Fase 5 — 05_Missions)*
### [MIS-001] Motor de misiones (templates/instancias/secretas/emergencias) — ✅ ~80% (repo 358 líneas + migración)
### [MIS-002] Misiones de gremio (repo/UI) — ⬜ Pendiente (K5-1)
### [MIS-003] Eventos globales (repo/UI) — ⬜ Pendiente (K5-1)
### [MIS-004] Progresión parcial — ⬜ Pendiente (K5-2)
### [MIS-005] Rotación/timers (edge function) — ⬜ Pendiente (K5-3)
