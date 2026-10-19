# Epic Roadmap — TutorSaas / Dungeon of English

> Actualizado: 2026-07-30 — Las Fases 2–6 están **analizadas y documentadas** (ver carpetas por fase en `/docs`).
> La implementación se realizará en el orden de esta hoja de ruta, fase por fase, sin mezclar.

## Fase 2 — Experiencia del Usuario
**Estado: documentada** (`docs/02_User_Experience/`). Implementación pendiente.
- [ONB-003] Aplicar l10n en MaterialApp (P0)
- [ONB-004] Persistir idioma del onboarding (P0)
- [ONB-005] Migración `user_settings` idioma (P0)
- [ONB-002] Oracle conversacional con `oracle_questions` (P1)

## Fase 3 — Dashboard
**Estado: documentada** (`docs/03_Dashboard/`). Implementación pendiente.
- [DSH-003] HUD central (P0)
- [DSH-002] Mapa de mazmorras (P0)
- Refinar Hunter Status (tipografía estándar + SegmentedBar) (P1)
- Accesos rápidos y badges (P1)

## Fase 4 — Conversaciones
**Estado: documentada** (`docs/04_Conversations/`). Implementación pendiente.
- Header/HUD del Oráculo (P0)
- Barra de progreso unificada (P0)
- Recompensas visuales `FloatingReward` (P1)
- Coherencia con economía (P1)

## Fase 5 — Misiones
**Estado: documentada** (`docs/05_Missions/`). Implementación pendiente.
- Misiones de gremio (P0)
- Eventos globales (P0)
- Progresión parcial (P1)
- Mission Board integrado + rotación/timers (P1)

## Fase 6 — Economía
**Estado: documentada** (`docs/06_Economy/`). Implementación pendiente.
- Fix `claimDailyReward` (P0)
- Inventario UI (P0)
- Battle Pass (P0)
- Daily rewards UI, oro, drops, integración IA (P1)
- Balance económico (P2)

## Fase 1 (base) — Deuda transversal
- [DB-001] Auditoría de migraciones y RPCs en live (P0)
- [GUILD-001] Fix voice room roomId no-UUID (P0)
- QA: `overflow_test.dart` LeagueLeaderboard (P1)

## Dependencias
```
[Fase 2 l10n] ──► [Fase 3 HUD] ──► [Fase 4 conv] ──► [Fase 5 misiones] ──► [Fase 6 economía]
                    │                                     │                     │
                    └──► [Fase 1 transversal: DB-001, GUILD-001, QA] ◄─────────┘
```
Regla: no iniciar una fase hasta que la anterior esté completa (compilación + QA + docs).
