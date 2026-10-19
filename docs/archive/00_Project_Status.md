# 00 — Project Status Audit

> Fase 0/1 · Estado real del proyecto · Fecha: 2026-07-30
> Fuente primaria: `graphify-out/GRAPH_REPORT.md` (244 archivos, 3462 nodos, construido sobre commit `8c1ef25e` — **puede estar desactualizado**, refrescar con `graphify update .`), lectura del árbol `lib/`, y `lib/app/router.dart`.

## 1. Contexto crítico (leer primero)

- El repo tiene **UN SOLO commit** (`8c1ef25 "Firtcomit"`). **Todo el trabajo de features está sin commitear**.
- Ya ocurrió un `git checkout -- '*.dart'` que revirtió archivos rastreados al estado inicial y destruyó horas de trabajo → **PROHIBIDO** usar `git checkout`/`git restore` sobre Dart. Ver `AGENTS.md`.
- `git status` / `git diff` **NO reflejan** el trabajo reciente en archivos ya rastreados: mucho código vive solo como ediciones sin commitear y archivos untracked nuevos (`lib/features/economy/`, `lib/features/missions/`, `lib/l10n/`, `lib/features/onboarding/` parcial).
- `docs/` ya contiene documentación previa que **debe reconciliarse**: `architecture.md`, `UX_UI_AUDIT.md`, `IMPLEMENTATION_PLAN.md`, `PLAN_DE_IMPLEMENTACION.md`, serie `001–008`, etc. Algunas pueden describir un estado ya superado (pre-regresión).

## 2. Stack verificado

| Capa | Tecnología | Estado |
|---|---|---|
| App | Flutter (Dart), dark-only | Compila OK: `flutter build apk --debug` → `app-debug.apk` |
| Estado | flutter_riverpod (StateNotifier/Future.autoDispose/StateProvider) | En uso |
| Routing | go_router | 12 rutas registradas |
| Backend | Supabase (Postgres, Auth, RLS, Realtime) | Migraciones en `supabase/migrations/` (11 SQL) — **estado de aplicación al live DB no verificado** |
| Web admin | `web_admin/` React/Vite + Supabase JS | Existe; precios editables |
| STT | Groq Whisper `whisper-large-v3-turbo` (en forzado) | — |
| LLM | DeepSeek `deepseek-chat` (SSE streaming) | — |
| TTS | flutter_tts (rate 0.48) | — |

## 3. Estado por módulo (feature-first)

| Feature | Estado | Notas |
|---|---|---|
| `auth` | Funcional | Welcome + login |
| `onboarding` | **Parcial / sin cablear** | `character_creation_wizard`, `oracle_test_screen` existen como untracked pero **no** están registrados en el router ni conectados al flujo de onboarding |
| `dashboard` | Funcional | 4 tabs: MAZMORRAS / GUILD (→`/chat-rooms`) / ESTADO / CONFIG |
| `conversation` | Funcional | Oracle NPC, pipeline de voz, barra de progreso = `completedGoals/totalGoals`, `_AnimatedMessage` |
| `chat_rooms` | Funcional con bug | El voice room crashea para IDs de sala no-UUID (`guild_table_1` → PostgrestException invalid uuid) |
| `economy` | **Nuevo / desconectado** | Providers + repositorios existen como untracked; sin pantallas de shop/inventario/battle pass ni wiring |
| `missions` | **Nuevo / conectado parcialmente** | Motor de misiones + `mission_board_widget` compila; integración con dashboard pendiente de verificar |
| `subscription` | Funcional | Paywall; precios $1.99/mes configurables desde web_admin → `subscription_plans` |
| `vocabulary` | **Existe parcialmente** | SM-2 SRS según AGENTS.md; sin pantalla SRS cableada |
| `l10n` | Funcional | `app_en/es/pt.arb` + localizaciones generadas; `AppLocalizations` en uso |

## 4. Estado del tema / diseño

- `lib/core/theme/app_colors.dart` ya usa la paleta Isekai/abyssal: `voidBg` #05070E, `manaCyan` #00E5FF, `royalGold` #FFC700, `runeViolet` #9D4EDD, `emeraldGreen` #00E676 (la paleta vieja #0B1326/#B76DFF quedó deprecada).
- `app_theme.dart` ColorScheme: `primary: manaCyan`.
- Widgets reutilizables creados y verificados: `SegmentedBar`, `AnimatedCounter`, `FloatingReward`, `GlassCard` (con `borderColor`/`showRunicCorners`/`runicColor`), `RpgAvatar`, `CyberManhwaBackground` (13 `CyberBgMode`).

## 5. Rutas actuales vs planificadas

Registradas (12): `/` `/onboarding` `/home` `/voice-room` `/conversation` `/summary` `/paywall` `/profile` `/settings` `/profile-edit` `/chat-rooms` `/level-exam`

**Planificadas pero NO cableadas**: `/hunter-status`, `/oracle-test`, `/shop`, más inventario/battle pass/daily reward.

## 6. Hallazgos clave

1. **Riesgo máximo**: trabajo sin commitear + historial de un solo commit. Cualquier `checkout`/`restore`/`clean` borra todo. → backup manual o commit temprano es P0.
2. **Screens planificadas que no existen**: `hunter_status_screen`, shop, inventory, battle pass, daily reward, guild quest board, premium coach.
3. **Screens untracked sin cablear**: oracle test, character creation wizard.
4. **Bug conocido**: voice room con roomId no-UUID.
5. **Migraciones de DB**: existen como archivos, probablemente no aplicadas al live (y el live puede rechazar DDL con "read-only transaction"; aplicar vía SQL Editor/branch).
6. **Reporte Graphify** construido sobre el commit inicial: no refleja economía/misiones/l10n. Refrescar antes de confiar en métricas de arquitectura.

## 7. Métricas

- `flutter analyze`: ~56 infos/warnings, **0 errores** (barra de calidad).
- `flutter test`: 5 archivos de test en `test/`.
- Build debug Android: **éxito verificado**.
