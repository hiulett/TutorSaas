# Fase 2 — Analysis

> Análisis del estado actual de la Experiencia de Usuario (onboarding, idioma, registro).

## 1. Onboarding

`lib/features/onboarding/presentation/screens/onboarding_screen.dart` implementa un flujo
de 9 pasos mediante `PageView` (sin scroll libre):

| Paso | Pantalla | Contenido |
|---|---|---|
| 0 | `_buildNativeLanguageAndCountryPage` | Idioma nativo (8 opciones), país (11), switch "interface en idioma nativo" |
| 1 | `_buildTargetLanguagePage` | Idioma objetivo: en/fr/de/it |
| 2 | `_buildLevelPage` | Nivel CEFR A1–C2 + botón "EXAMEN DEL ORÁCULO" → `/oracle-test` |
| 3 | `_buildGoalPage` | Meta diaria 10/15/30/45 min |
| 4 | `_buildInterestsPage` | Intereses (multiselección, validación ≥1) |
| 5 | `_buildCorrectionStylePage` | Estilo de corrección + idioma de explicación gramatical |
| 6 | `_buildPlacementObstaclePage` | Obstáculo principal (obligatorio) |
| 7 | `_buildCharacterCreationPage` | Wizard de personaje (`character_creation_wizard.dart`) |
| 8 | `_buildPaywallScreenPage` | Planes dinámicos desde Supabase `subscription_plans` |

**Flujo de guardado** (`_completeOnboardingAndPurchase`):
1. `saveOnboardingData` → users, languages, cefr_levels, user_language_profiles, user_settings, user_ai_profiles.
2. `updateUserProfile` → displayName/avatarUrl/nativeLanguage/bio.
3. Compra si plan de pago; luego `context.go('/home')`.

**Observaciones:**
- El onboarding está en inglés hardcoded en su mayoría; el `welcome_screen` en español hardcoded.
- La persistencia del idioma elegido NO se refleja en `userLanguageProvider` (el switch
  "Switch App Interface Language" no persiste nada fuera de `_switchInterfaceToNative`).
- `_selectedCountryCode` no se persiste en DB.

## 2. Clasificación CEFR / Oráculo

`placement_test_screen.dart` (ruta `/oracle-test`):
- 4 pasos: objetivo → obstáculo → quiz de 3 preguntas → resultado con nivel y plan de estudio.
- Nivel computado por puntuación: 0→A1, 1→A2, 2→B1, 3→B2.
- `savePlacementResult` actualiza `user_language_profiles.cefr_level_id` y `users.bio`.
- Existe `oracle_question.dart` (modelo) y migración `20260730_oracle_questions.sql`
  (7 preguntas conversacionales), pero **no hay pantalla que las consuma** — el Oracle
  conversacional aún no se usa.

## 3. Sistema de idioma / multilenguaje

`lib/core/i18n/language_settings.dart`:
- `UserLanguageSettings` { uiLanguage, learningLanguage, aiExplanationsInNative }.
- `UserLanguageNotifier` persiste en SharedPreferences + Supabase `user_settings`.
- **GAP CRÍTICO**: `MaterialApp.router` (`lib/app/app.dart`) **no** tiene
  `localizationsDelegates` / `supportedLocales` / `locale` reactivo. La app no aplica el l10n.
- l10n: `app_en/es/pt.arb` generados (237 claves c/u). `use-deferred-loading: false`.

## 4. Registro

`welcome_screen.dart`: estados initial/login/register, `signInWithGoogle`, redirect
a `/onboarding` (si no hay `user_language_profiles`) o `/home`. `isRegisteringProvider`
marca el flujo de registro.

## 5. Conclusión

La Fase 2 está ~70% implementada en UI; faltan:
1. Conectar `userLanguageProvider` con `MaterialApp` (aplicar locale real).
2. Persistir la elección de idioma del onboarding en el provider.
3. Columnas de idioma en `user_settings` (migración).
4. Pantalla del Oracle conversacional usando `oracle_questions`.
5. Persistir país de origen.
