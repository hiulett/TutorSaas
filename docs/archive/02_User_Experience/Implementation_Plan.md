# Fase 2 — Implementation_Plan

> Plan de implementación (PRIORIZADO). Sin implementación realizada aún — documentación.

## Objetivo

Completar la Experiencia de Usuario: onboarding, idioma persistente, multilenguaje real,
clasificación CEFR del Oráculo, registro y perfil inicial.

## Fases del plan

### 2.1 Wiring de localización (P0)
1. Convertir `TutorSaaSApp` en `ConsumerWidget`.
2. Añadir `localizationsDelegates: AppLocalizations.localizationsDelegates`,
   `supportedLocales: AppLocalizations.supportedLocales`.
3. Conectar `locale` desde `userLanguageProvider` (mapear códigos es/en/pt).

### 2.2 Persistencia del idioma desde onboarding (P0)
1. En `_completeOnboardingAndPurchase`, llamar a `userLanguageProvider` con
   `learningLanguage`, `aiExplanationsInNative`, y (si switch activo) `uiLanguage`.
2. Persistir `_selectedCountryCode`.

### 2.3 Migración DB (P0)
1. `ALTER TABLE user_settings ADD COLUMN ui_language, learning_language, ai_explanations_native`.

### 2.4 Oracle conversacional (P1)
1. Nueva pantalla (o reutilizar `PlacementTestScreen`) que consuma `oracle_questions`.
2. Evaluar CEFR por conversación (longitud/respuesta) y guardar resultado.

### 2.5 Registro y perfil inicial (P1)
1. Verificar creación de `users` + `user_language_profiles` tras registro Google.
2. Redirección robusta welcome → onboarding/home.

### 2.6 i18n de pantallas (P2)
1. Reemplazar strings hardcoded del welcome y onboarding por `AppLocalizations`.

## Criterios de terminación

- `flutter analyze` 0 errores; `flutter test` verde.
- La app cambia de idioma de UI al elegir idioma nativo en onboarding.
- El idioma persiste entre sesiones (SharedPreferences + Supabase).
- `/oracle-test` navegable y guarda nivel CEFR.
