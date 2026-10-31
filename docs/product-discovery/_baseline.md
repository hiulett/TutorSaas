# Baseline verificado (punto de partida común)

> **Re-medido el 31-oct-2026** sobre `origin/master` del worktree
> `C:\Users\GbitCorp\.local\share\opencode\worktree\6708f0\p14-ai-usage`
> (código) y producción `sipiumfdpvnszthykyog` (MCP `supabase`, solo lectura).
> Si un documento de esta carpeta contradice esta tabla, **manda el código** y
> actualiza la tabla.

## Cifras

| Dato | Valor | Fuente |
|---|---|---|
| Pantallas (`*_screen.dart`) | **20** | `Get-ChildItem lib -Recurse -Filter *_screen.dart` |
| Rutas registradas | **20** | `lib/app/router.dart` |
| Features | **16** | `lib/features/*` |
| Tablas `public` | **90** | `information_schema.tables` (`BASE TABLE`) |
| Tablas con RLS | **85** | `pg_policies` (`count(distinct tablename)`) |
| Funciones `public` | **99** | `pg_proc` (0 procedimientos) |
| Políticas RLS | **135** | `pg_policies` |
| Vistas | **14** | `information_schema.views` (0 materializadas) |
| Migraciones aplicadas | **108** | `supabase_migrations.schema_migrations` |
| Pruebas | **733** | `flutter test --reporter compact` → `All tests passed!` |
| Analyze | 0 errores · 0 warnings (**no re-ejecutado** en esta medición; se conserva el último resultado) | `flutter analyze` (medición anterior) |
| Edge Functions | **8**: `llm-proxy`, `missions-cron`, `livekit-token`, `revenuecat-webhook`, `lesson-generator`, `sync-entitlement`, `evaluate-placement`, `reactivation-email` | MCP `supabase.list_edge_functions` |

> **Nota sobre cifras antiguas.** Circulan **75 tablas / 120 políticas /
> 52 funciones / 171 pruebas** (AGENTS.md) y **84 / 130 / 82 / 741** (medición
> previa de esta carpeta). Las tres son instantáneas distintas: manda la tabla de
> arriba, medida hoy contra producción y contra el worktree.

## Volumen de datos (contexto para cualquier afirmación de comportamiento)

| Dato | Valor | Fuente |
|---|---|---|
| `users` | **68** | `public.users` |
| `user_language_profiles` | **65** (55 con `game_rank` NULL) | `public.user_language_profiles` |
| Activos últimos 7 días | **1** usuario distinto · 9 `app_open` | `analytics_events` |
| `practice_sessions` | **2** | `public.practice_sessions` |
| `messages` | **771** | `public.messages` |
| `payments` | **0** | `public.payments` |
| `user_subscriptions` | **15** (1 `noble`, 14 `plebeyo`) | `public.user_subscriptions` |
| `mission_instances` | **637** (8 completadas) | `public.mission_instances` |
| `guild_quest_pool` | **199** | `public.guild_quest_pool` |
| `chat_room_participants` / `chat_room_messages` | **0 / 0** | `public.chat_room_*` |
| `boss_exam_attempts` | **0** | `public.boss_exam_attempts` |

> Con este volumen **no hay ninguna conclusión de retención válida**. Ver
> [`19` §3](19-canon-and-decisions.md#3-umbral-de-d-15-continuar--iterar--pivotar).

## Design tokens reales

- **Colores**: `voidBg #05070E`, `background/surface #11131B`, `surfaceContainerLow #191B23`, `surfaceContainer #1D1F27`, `surfaceContainerHigh #272A32`, `manaCyan #00E5FF`, `runeViolet #9D4EDD`, `royalGold`, `emeraldGreen`, `crimsonRed`.
- **Radios**: `AppRadius` sm 4 · md 8 · lg 12 · circle 999.
- **Espaciado**: `AppSpacing` xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32 · huge 48.
- **Tipografía**: Space Grotesk (títulos), Inter (cuerpo), JetBrains Mono (etiquetas), empaquetadas en `assets/google_fonts/`.

## Deuda de diseño ya medida (no repetir el análisis, citarla)

- `EdgeInsets` literales **419** vs `AppSpacing` **4** usos.
- `Color(0x…)` hardcodeados **95**; `withValues(alpha:)` **461**.
- `Semantics(` **9** en toda la app.
- `GoogleFonts.*` **384** vs `AppTypography.*` **114**.
- 4 estilos del `TextTheme` caen en Roboto (no empaquetada): `headlineSmall`, `titleSmall`, `bodySmall`, `labelSmall`.
- God files: `conversation_screen.dart` 2 362 líneas, `settings_screen.dart` 1 611, `conversation_providers.dart` 2 956.

## Documentación existente que hay que **citar, no duplicar**

- `docs/product-audit/` (25 documentos, auditoría de producto; algunas cifras ya están desfasadas).
- `docs/ui-ux-audit/` (7 documentos + backlog UX-01…UX-37, auditoría visual/UX).
- `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/OPERATIONS.md`, `docs/PRODUCT.md`, `docs/HISTORY.md`, `docs/CONTEXT_MAP.md`.
- `AGENTS.md` (reglas del repo).
