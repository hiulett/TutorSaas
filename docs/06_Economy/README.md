# Fase 6 — Economía del Juego

> Estado: **Documentación** (análisis y plan). Sin cambios de código en esta fase.
> Carpetas de referencia: `lib/features/economy/`, `supabase/migrations/20260730_economy_and_ia_system.sql`.

## Resumen

Economía completa desacoplada de la UI: oro, cristales (gemas), núcleos (invocaciones),
fragmentos, loot, inventario, recompensas, tienda, battle pass, daily rewards, integración
con IA y preparación para monetización.

## Estado actual

- **Interfaz** `EconomyRepository` (13 métodos) + **impl** `EconomyRepositoryImpl` (355 líneas).
- **Providers**: dailyState, streak, gemBalance, canInvoke, inventory.
- **Pantalla**: `shop_screen.dart` (301 líneas, ruta `/shop`) + `nucleo_arcano_limit_screen.dart`.
- **DB** (`20260730_economy_and_ia_system.sql`): player_inventory, cosmetic_catalog (23 items),
  player_daily_state, player_streaks, guild_quest_pool (13 quests), player_completed_quests,
  guild_battle_pass, player_pergaminos + columnas total_gems/total_gold/player_class en
  user_language_profiles + RLS + Realtime.

## Documentos

| Documento | Contenido |
|---|---|
| [Analysis.md](Analysis.md) | Análisis del sistema económico |
| [Implementation_Plan.md](Implementation_Plan.md) | Plan de implementación |
| [Architecture.md](Architecture.md) | Arquitectura del módulo economía |
| [Database.md](Database.md) | Esquema de DB de economía |
| [Tasks.md](Tasks.md) | Tareas y estado |
| [QA_Report.md](QA_Report.md) | Reporte de QA |
| [Recovery.md](Recovery.md) | Recuperación/regresiones |
| [Known_Issues.md](Known_Issues.md) | Problemas conocidos |
| [Change_Log.md](Change_Log.md) | Registro de cambios |
