# Auditoría Estratégica del Onboarding — Documento 09

# Backlog Priorizado (Task List)

> **Proyecto:** TutorSaas / Dungeon of English
> **Base:** docs 01–08. Orden sugerido para ejecución de F1→F6 (doc 08).
> **Formato:** tabla priorizada ID / prioridad / impacto / riesgo / archivos / verificación.
> **Prioridades:** P0 (crítica, primero) → P1 (alta) → P2 (media) → P3 (baja/mejora).

---

## Resumen por fases (doc 08)

| Fase | Tareas (IDs) | Foco |
|---|---|---|
| F1 — i18n | T1–T4 | Migrar textos hardcodeados → ARB |
| F2 — País | T5–T6 | Catálogo ISO completo, sin sugeridos |
| F3 — Oráculo | T7–T8 | Prompt adaptativo + UX |
| F4 — Personaje | T9–T15 | 8 clases + avatares Stitch + tarjeta |
| F5 — Persistencia | T16–T20 | avatarIndex + clase en DB + migración |
| F6 — QA | T21–T23 | analyze / test / build / gen-l10n |

---

## Backlog priorizado

| ID | Tarea | Prioridad | Impacto | Riesgo | Archivos | Verificación |
|---|---|---|---|---|---|---|
| T1 | Inventariar y migrar strings hardcodeados del onboarding a ARB (snackbars, cabeceras, tarjeta héroe, pasos clasificación) | P0 | Alto (i18n roto en en/pt) | Bajo | `onboarding_screen.dart:95,102,476,481,547,555,752,757,814,937,942,974,986,1001,1010` | Cambiar idioma a `pt`: 0 español visible; `flutter gen-l10n` sin warnings |
| T2 | Migrar textos del wizard de personaje a ARB (título, subtítulo, nombre, avatar, clase, botón) | P0 | Alto | Bajo | `character_creation_wizard.dart:70,76-77,85,91,114,155,214` | `flutter gen-l10n`; revisión en `pt` |
| T3 | Reutilizar claves ARB ya existentes no consumidas (`onboarding_lang/country/target/cefr`, `character_name`, `oracle_continue`) | P1 | Medio (limpieza de duplicados) | Bajo | `lib/l10n/app_*.arb`; `onboarding_screen.dart` | `grep` sin duplicación entre ARB y hardcode; analyze 0 errores |
| T4 | Catálogo de clases con claves l10n de nombre/desc (preparar para F4) | P1 | Medio (prepara F4) | Bajo | `lib/features/onboarding/domain/models/hunter_class.dart` | `flutter analyze` 0 errores; catálogo consumido por wizard |
| T5 | Catálogo de países ISO-3166 localizado (es/en/pt) en JSON/data | P0 | Alto (P2 del doc 02: no escalable) | Medio | `assets/data/countries_es.json` (nuevo) | Seleccionar países extremos (Åland, Zimbabwe); datos verificados |
| T6 | Reemplazar chips sugeridos + dropdown (11) por selector completo con búsqueda | P1 | Alto | Medio | `onboarding_screen.dart:740-854` | País persiste en `users.country_code` (`:192-196`); render en ≤360 dp |
| T7 | Prompt adaptativo del Oráculo (idioma nativo/objetivo + clase + dificultad progresiva) | P1 | Alto (P8: oráculo desconectado) | Medio | `oracle_conversation_screen.dart`; `oracle_prompt_builder.dart` (nuevo) | 8+ turnos con nivel coherente; **no alterar pipeline de voz** |
| T8 | Feedback en vivo de nivel detectado en el Oráculo (pistas sin score final) | P2 | Medio (narrativa) | Bajo | `oracle_conversation_screen.dart` | Smoke test del paso 3 con evaluación opcional |
| T9 | Extender `AppColors` con tokens de clase (incl. `necromancer`, evitar colisión con `mage`) | P0 | Alto (base de F4) | Bajo | `lib/core/theme/app_colors.dart` | analyze 0 errores; 8 colores distintos |
| T10 | Modelo `HunterClass` (id, icono, color, elemento, aura) + mapeo legacy `rogue→assassin` | P0 | Alto | Medio | `hunter_class.dart` (nuevo) | Unit test del mapeo legacy; `RpgAvatar` sigue resolviendo `assassin`/`necromancer` (`rpg_avatar.dart:27-28`) |
| T11 | Ampliar wizard a 8 clases con elemento/aura + estado seleccionado RPG (glow, runic corners, check animado) | P0 | Alto (P5: identidad) | Medio | `character_creation_wizard.dart:37-41,157-208` | Seleccionar las 8; colores/auras consistentes; analyze 0 errores |
| T12 | Generar avatares Stitch (8 clase + 6 jugador) con prompts versionados | P1 | Alto | Medio | `assets/images/avatars/*.webp`; `docs/Onboarding-Redesign/stitch_prompts.md` (nuevo) | Set visualmente consistente (doc 06 §3.4) |
| T13 | Registrar carpeta de avatares y crear catálogo de assets (assetPath + color) | P0 | Alto | Bajo | `pubspec.yaml:68`; `avatar_catalog.dart` (nuevo) | `flutter run` carga assets; fallback Material si falta |
| T14 | Reescribir tarjeta de héroe → carta coleccionable 3:4 (imagen, avatar, clase, Lv., rango, elemento, aura, HUD) | P0 | Alto (P5) | Medio | `onboarding_screen.dart:432-569` | Render en dispositivo ≤360 dp; offline cae a fallback |
| T15 | Consolidar `_heroClassIcon/Name/Color` (`onboarding_screen.dart:393-427`) en el catálogo | P1 | Medio (DRY) | Bajo | `onboarding_screen.dart`; `hunter_class.dart` | analyze 0 errores; tarjeta y HUD comparten catálogo |
| T16 | Migración SQL `character_identity` (4 columnas + backfill `rogue→assassin`), idempotente | P0 | Alto (cierre P7) | Medio | `supabase/migrations/2026XXXX_character_identity.sql` (nuevo) | SELECT verificación (doc 07 §4); aplicar en rama/SQL Editor |
| T17 | Ampliar `saveOnboardingData` (contrato + repo) con `characterClass`, `avatarIndex`, `element`, `aura` | P0 | Alto | Medio | `onboarding_repository.dart`; `onboarding_repository_impl.dart:98-119` | Upsert escribe las 4 columnas en `user_language_profiles` |
| T18 | Pasar clase + avatarIndex en `_completeOnboardingAndPurchase`; `updateUserProfile` deja de usar `avatar_url=clase` | P0 | Alto | Medio | `onboarding_screen.dart:170-215`; `dashboard_repository_impl.dart:776-785` | `avatar_url` guarda imagen real; clase en perfil de aprendizaje |
| T19 | Lectura en dashboard: `RpgAvatar`/HUD leen `avatar_url` imagen real con fallback a clase | P1 | Alto | Medio | `rpg_avatar.dart`; `hunter_hud_header.dart:42`; `progress_tab_view.dart:30` | Perfil y HUD muestran avatar/clase correctos post-onboarding |
| T20 | Verificación RLS + advisors tras migración | P1 | Medio (seguridad) | Bajo | DB (migración T16) | `supabase get_advisors` (security) sin hallazgos nuevos |
| T21 | `flutter gen-l10n` + `flutter analyze` (0 errores) | P0 | Alto (puerta QA) | Bajo | `lib/l10n/` | analyze 0 errores |
| T22 | `flutter test` + nuevos unit tests (mapeo clases, catálogo países) | P1 | Alto | Bajo | `test/` | `flutter test` verde (5 archivos + nuevos) |
| T23 | Smoke test completo en dispositivo (onboarding → dashboard → perfil) con modo dev | P1 | Alto | Bajo | `lib/app/router.dart`; `onboarding_providers.dart:13` | `flutter run -d RFCN80FYN6V`; flujo completo OK |

---

## Notas de ejecución

- **Orden obligatorio:** T1→T4 (F1) y T9→T10 antes de T11–T15 (F4) para que todo el texto
  nuevo ya use ARB y los tokens de clase existan.
- **T16 (migración) puede adelantarse** a cualquier momento tras T9: es idempotente y no rompe
  el código actual (columnas nuevas con default).
- **F3 (T7/T8) es paralelizable** con F4/F5 (no comparte archivos críticos), pero su prompt
  debe consumir la clase elegida → coordinar con T17 (paso de clase al Oráculo).
- **No reintroducir:** hex hardcodeados (usar `AppColors`), `HankenGrotesk`, patrones
  BLoC/Redux, alteración del pipeline de voz (AGENTS.md).
- **Frontera de la tarea:** ninguna tarea ejecuta cambios de código por sí misma; son
  unidades de un plan para implementar en sesión de ejecución (doc 08).

---

## Resumen por prioridad

| Prioridad | Total | Tareas |
|---|---|---|
| P0 | 9 | T1, T2, T5, T9, T10, T11, T13, T14, T16, T17, T18, T21 |
| P1 | 9 | T3, T4, T6, T7, T12, T15, T19, T20, T22, T23 |
| P2 | 2 | T8 |

**Camino crítico mínimo (P0):** T1·T2 (i18n) → T5·T6 (país) → T9·T10·T11 (clases UI) →
T13·T14 (assets + tarjeta) → T16·T17·T18 (persistencia) → T21 (analyze) → T23 (smoke).
