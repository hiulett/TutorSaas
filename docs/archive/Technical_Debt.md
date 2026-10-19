# Technical_Debt — TutorSaas / Dungeon of English

> Actualizado: 2026-07-30 · Consolidado desde las auditorías 00–06 y las carpetas por fase.

## P0 — Críticos

| # | Deuda | Ref | Archivo |
|---|---|---|---|
| TD-1 | Repo con un solo commit; trabajo sin commitear | R1 | repo |
| TD-2 | Migraciones DB no verificadas/aplicadas al live; RPCs de economía/misiones pendientes de confirmar | R3 | `supabase/migrations/` |
| TD-3 | `claimDailyReward` asigna una `Future` como valor de `pergaminos_max` en el update | K6-1 | `economy_repository_impl.dart` |
| TD-4 | Voice room crashea con roomId no-UUID | K2-9/GUILD-001 | `voice_room_screen.dart` / repo |
| TD-5 | `MaterialApp` no aplica l10n (idioma de UI sin efecto) | K2-1 | `lib/app/app.dart` |

## P1 — Funcional

| # | Deuda | Ref |
|---|---|---|
| TD-6 | Gremio (`guild_collaborative_missions`) y eventos (`global_events`) sin acceso Flutter | K5-1 |
| TD-7 | Progresión de misiones sin incremental (salta a completed) | K5-2 |
| TD-8 | Rotación/timers sin edge function/cron | K5-3 |
| TD-9 | Battle pass e inventario sin UI | K6-4/K6-5 |
| TD-10 | Oro (`total_gold`) y "fragmentos" sin lógica | K6-3/K6-9 |
| TD-11 | Invocaciones no conectadas al inicio de conversación | K6-6 |
| TD-12 | `player_completed_quests.quest_id` VARCHAR vs `guild_quest_pool.id` UUID | K6-2 |

## P1/P2 — Diseño y calidad

| # | Deuda | Ref |
|---|---|---|
| TD-13 | `GoogleFonts.orbitron` fuera de tipografía estándar | K3-4 |
| TD-14 | Stats persistidos en `users.bio` (regex frágil) | K3-3 |
| TD-15 | Strings hardcoded en welcome/onboarding | K2-7 |
| TD-16 | `t()` legacy es stub — no usarlo | K2-8 |
| TD-17 | Test `overflow_test.dart` falla (pumpAndSettle) | K3-6 |

## Proceso

- `flutter analyze`: barra 0 errores (58 infos/warnings tolerados).
- `flutter test`: mantener verde (hoy 12/13).
- `flutter gen-l10n` tras editar `.arb`.
- Voice pipeline: NO alterar.
