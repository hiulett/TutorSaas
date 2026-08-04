# Fase 2 — Tasks

> Lista de tareas y estado. Leyenda: ⬜ pendiente · 🔄 en curso · ✅ completado · ❌ bloqueado
> Actualizado: 2026-07-30 (implementación iniciada)

## P0 — Localización aplicada
- ✅ `TutorSaaSApp` → `ConsumerWidget` y `locale` reactivo desde `userLanguageProvider` (T-100).
- ✅ `localizationsDelegates` + `supportedLocales` en `MaterialApp.router` (T-100).
- ✅ Verificado: `flutter analyze` 0 errores; build apk OK; claves balanceadas (237 en/es/pt).

## P0 — Persistencia del idioma
- ✅ En `_completeOnboardingAndPurchase`: `setLearningLanguage`, `setAiExplanationsInNative`,
      `setUiLanguage` (si switch) (T-101).
- ✅ Persistir `_selectedCountryCode` en `users.country_code` (T-104) — script
      `20260730_phase2_country_code.sql` pendiente de aplicar en SQL Editor.

## P0 — Migración DB
- ✅ Columnas de idioma aplicadas en `user_settings` live (T-102) — vía SQL Editor (script
      `20260730_SQL_EDITOR_pendientes.sql` Parte A).

## P1 — Oráculo conversacional
- ✅ Nueva `OracleConversationScreen` consume `oracle_questions` (con fallback offline)
      (T-103). Ruta `/oracle-test` → conversacional; `/oracle-quiz` → quiz estático.
- ✅ Evaluación CEFR por heurística de longitud de respuesta (A1–C1).
- ✅ Guardar resultado vía `savePlacementResult` (nivel + quizScore).

## P1 — Registro y perfil
- ⬜ Verificar creación de `users` + `user_language_profiles` post-registro Google.
- ⬜ Robustecer redirección welcome → onboarding/home.

## P2 — i18n de pantallas
- ⬜ Reemplazar strings hardcoded de `welcome_screen` y `onboarding_screen` por
      `AppLocalizations.of(context)!` (T-105).

## QA
- ✅ `flutter analyze` 0 errores (58 issues tolerados).
- ⚠️ `flutter test` 12/13 (1 falla preexistente LeagueLeaderboard — T-001).
- ✅ Build apk debug OK.
