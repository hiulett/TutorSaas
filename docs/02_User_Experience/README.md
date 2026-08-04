# Fase 2 — Experiencia del Usuario (Onboarding y Localización)

> Estado: **Documentación** (análisis y plan). Sin cambios de código en esta fase.
> Carpetas de referencia: `lib/features/onboarding/`, `lib/core/i18n/`, `lib/l10n/`, `supabase/migrations/`.

## Resumen

La Fase 2 cubre la experiencia de primer contacto: onboarding de 9 pasos, selección y
persistencia del idioma nativo/UI/learning, sistema multilenguaje (l10n), clasificación
CEFR mediante el Oráculo, flujo de registro y persistencia del perfil inicial.

## Estado actual

- **Onboarding de 9 pasos** implementado en `onboarding_screen.dart` (idioma nativo+país,
  idioma objetivo, nivel CEFR, meta diaria, intereses, estilo de corrección, obstáculo,
  creación de personaje, paywall dinámico).
- **Registro**: flujo Google en `welcome_screen.dart` (`signInWithGoogle`).
- **Clasificación CEFR**: `PlacementTestScreen` (quiz de 3 preguntas → nivel A1–B2),
  registrado en `/oracle-test`.
- **Persistencia del idioma**: `UserLanguageNotifier` (`lib/core/i18n/language_settings.dart`)
  persiste `ui_language` / `learning_language` / `ai_explanations_native` en SharedPreferences
  + Supabase `user_settings`. **PENDIENTE**: no está conectado al `MaterialApp` (la app no
  aplica aún el locale de la UI).
- **l10n**: `app_en/es/pt.arb` (237 claves cada uno, balanceados), generación activada
  (`pubspec.yaml: generate: true`).
- **DB**: `user_settings` NO tiene columnas `ui_language`/`learning_language`/`ai_explanations_native`.

## Documentos

| Documento | Contenido |
|---|---|
| [Analysis.md](Analysis.md) | Análisis del estado actual de onboarding, idioma y registro |
| [Implementation_Plan.md](Implementation_Plan.md) | Plan de implementación de la fase |
| [Architecture.md](Architecture.md) | Arquitectura de la feature de experiencia de usuario |
| [Database.md](Database.md) | Esquema y migraciones de DB |
| [Tasks.md](Tasks.md) | Tareas pendientes y estado |
| [QA_Report.md](QA_Report.md) | Reporte de QA |
| [Recovery.md](Recovery.md) | Recuperación/regresiones |
| [Known_Issues.md](Known_Issues.md) | Problemas conocidos |
| [Change_Log.md](Change_Log.md) | Registro de cambios |
