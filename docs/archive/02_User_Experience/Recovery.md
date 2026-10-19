# Fase 2 — Recovery

> Recuperación y gestión de regresiones de la Fase 2.

## ⚠️ Contexto crítico del repo

- El repo tiene **UN SOLO commit** (`8c1ef25`). Todo el trabajo de features está sin commitear.
- **PROHIBIDO** usar `git checkout`/`git restore` sobre archivos Dart (ya destruyó trabajo antes).
- Los cambios se revierten **editando**, no restaurando.

## Incidentes de esta iteración

| Fecha | Incidente | Resolución |
|---|---|---|
| 2026-07-30 | Se implementó (por error) wiring de l10n + persistencia de idioma en código | Revertido por edición: `app.dart`, `onboarding_screen.dart` restaurados; migración `20260730_phase2_language_settings.sql` borrada. Sin cambios de código en el árbol. |

## Procedimiento de recuperación de la fase

1. Antes de implementar: commitear/backup del estado actual (P0).
2. Implementar por tareas pequeñas; tras cada una: `flutter analyze` + `flutter test`.
3. Si una pantalla nueva falla, corregir editando el archivo (nunca `git checkout`).
4. Documentar cualquier regresión en `Change_Log.md` y `Known_Issues.md`.
