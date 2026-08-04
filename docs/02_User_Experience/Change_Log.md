# Fase 2 — Change_Log

> Registro de cambios de la Fase 2.

## 2026-07-30

### Implementación (iteración actual)
- **T-100**: `lib/app/app.dart` → `ConsumerWidget` con `locale` reactivo desde
  `userLanguageProvider` + `localizationsDelegates`/`supportedLocales` (l10n aplicado).
- **T-101**: `onboarding_screen.dart` → persistencia de idioma al completar onboarding
  (`setLearningLanguage`, `setAiExplanationsInNative`, `setUiLanguage`).
- **T-102**: Columnas de idioma en `user_settings` aplicadas en live (vía SQL Editor,
  Parte A de `20260730_SQL_EDITOR_pendientes.sql`).
- Corrección de import duplicado en `onboarding_screen.dart`.
- QA: `flutter analyze` 0 errores (58 issues), build apk OK, test 12/13 (falla preexistente).

### Documentación (iteración previa)
- Creada estructura `docs/02_User_Experience/` con 10 documentos.

### Corrección (iteración previa)
- Revertidos por edición cambios de código que no debían aplicarse en esa iteración
  (wiring de l10n + persistencia) — luego reimplementados correctamente en esta iteración.

## Pendiente
- T-103 Oracle conversacional con `oracle_questions`.
- T-104 Persistir país de origen.
- T-105 i18n de strings hardcoded.
