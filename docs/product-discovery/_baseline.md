# Baseline verificado (punto de partida común)

> Medido el 31-oct-2026 sobre `origin/master` del worktree
> `C:\Users\GbitCorp\.local\share\opencode\worktree\6708f0\p14-ai-usage`.
> Si un documento de esta carpeta contradice esta tabla, **manda el código** y
> actualiza la tabla.

## Cifras

| Dato | Valor | Fuente |
|---|---|---|
| Pantallas (`*_screen.dart`) | **20** | `Get-ChildItem lib -Recurse -Filter *_screen.dart` |
| Rutas registradas | **20** | `lib/app/router.dart` |
| Features | **16** | `lib/features/*` |
| Tablas `public` | **84** | `information_schema.tables` |
| Funciones `public` | **82** | `pg_proc` |
| Políticas RLS | **130** | `pg_policies` |
| Vistas | **13** | `information_schema.views` |
| Migraciones aplicadas | **104+** | `supabase_migrations.schema_migrations` |
| Pruebas | **741** | `flutter test` |
| Analyze | 0 errores · 0 warnings | `flutter analyze` |
| Edge Functions | `llm-proxy`, `evaluate-placement`, `lesson-generator`, `livekit-token`, `missions-cron`, `revenuecat-webhook`, `sync-entitlement`, `reactivation-email` | `supabase functions list` |

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
