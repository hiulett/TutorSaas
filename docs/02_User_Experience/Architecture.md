# Fase 2 — Architecture

> Arquitectura de la feature de Experiencia de Usuario.

## Módulos

```
lib/
├── core/
│   ├── i18n/
│   │   └── language_settings.dart      # UserLanguageSettings + UserLanguageNotifier + provider
│   └── (l10n/)                         # app_localizations generado + .arb
├── l10n/
│   ├── app_en.arb                      # plantilla fuente
│   ├── app_es.arb
│   └── app_pt.arb
├── app/
│   ├── app.dart                        # MaterialApp.router (sin l10n wiring aún)
│   └── router.dart                     # 16 rutas; /oracle-test → PlacementTestScreen
└── features/onboarding/
    ├── data/
    │   ├── models/oracle_question.dart
    │   └── repositories/onboarding_repository_impl.dart
    ├── domain/
    │   ├── models/placement_result.dart (+freezed/g)
    │   └── repositories/onboarding_repository.dart
    └── presentation/
        ├── providers/onboarding_providers.dart
        ├── providers/placement_providers.dart
        ├── screens/{welcome,onboarding,placement_test}_screen.dart
        └── widgets/character_creation_wizard.dart
```

## Flujo de datos

```
WelcomeScreen ──signInWithGoogle──► auth ──► redirect
   │                                        ├─ profile existe → /home
   │                                        └─ sin profile → /onboarding (9 pasos)
OnboardingScreen ──saveOnboardingData──► Supabase (users, languages, cefr_levels,
   │                                      user_language_profiles, user_settings, user_ai_profiles)
   └── (pendiente) userLanguageProvider ◄── persiste SharedPreferences + user_settings
PlacementTestScreen (/oracle-test) ──savePlacementResult──► cefr_level_id + users.bio
```

## Decisiones de arquitectura

- Feature-first clean architecture (capa data/domain/presentation).
- Estado con Riverpod (`StateNotifierProvider` para `UserLanguageNotifier`).
- Rutas con go_router; el onboarding usa `context.push('/oracle-test')`.
- Repositorios con try-catch + `debugPrint` (convención del proyecto).

## Gaps detectados

1. `MaterialApp` no consume `userLanguageProvider` → el idioma de UI no se aplica.
2. El onboarding no actualiza el provider de idioma.
3. `oracle_questions` (DB) sin consumidor en UI.
