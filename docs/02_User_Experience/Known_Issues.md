# Fase 2 — Known_Issues

> Problemas conocidos de la Experiencia de Usuario.

## P0 — Funcionalidad

| # | Issue | Archivo | Impacto |
|---|---|---|---|
| K2-1 | La app no aplica el idioma de UI: `MaterialApp.router` sin `localizationsDelegates`/`supportedLocales`/`locale` | `lib/app/app.dart` | El sistema multilenguaje no tiene efecto visible |
| K2-2 | El idioma elegido en onboarding no se persiste en `userLanguageProvider` | `onboarding_screen.dart` | Al reiniciar se pierde la preferencia UI/learning |
| K2-3 | `user_settings` no tiene columnas de idioma | `supabase/migrations/` | El upsert de `UserLanguageNotifier` a Supabase falla silenciosamente |
| K2-4 | `_selectedCountryCode` no se persiste | `onboarding_screen.dart` | Se pierde país de origen |

## P1 — Oráculo

| # | Issue | Impacto |
|---|---|---|
| K2-5 | `oracle_questions` (DB) no tiene pantalla que las consuma; el Oráculo real es quiz estático de 3 preguntas | CEFR conversacional no disponible |
| K2-6 | `PlacementTestScreen` solo alcanza B2 máximo (score 3 → B2) | No clasifica C1/C2 |

## P2 — i18n / UX

| # | Issue | Impacto |
|---|---|---|
| K2-7 | Strings hardcoded: welcome en español, onboarding en inglés | No se traducen con el locale |
| K2-8 | `t()` legacy en `locale_provider.dart` es stub (devuelve la key) | No usarlo para traducciones reales |

## QA / Tests

| # | Issue | Impacto |
|---|---|---|
| K2-9 | `overflow_test.dart`: LeagueLeaderboard `pumpAndSettle timed out` | 1 test falla (preexistente, no relacionado con Fase 2) |
