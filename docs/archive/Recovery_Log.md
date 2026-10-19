# Recovery_Log — TutorSaas / Dungeon of English

> Registro de incidentes y recuperaciones. Actualizado: 2026-07-30.

## ⚠️ Regla de oro del repo

- Repo con **UN SOLO commit** (`8c1ef25`). **PROHIBIDO** `git checkout`/`git restore` sobre Dart.
- Revertir cambios **editando**, nunca restaurando (ya destruyó trabajo una vez).

## Incidentes

| Fecha | Incidencia | Resolución |
|---|---|---|
| (previo) | `git checkout -- '*.dart'` revirtió archivos rastreados al commit inicial | Daño asumido; se reconstruyó parte del trabajo; regla documentada en AGENTS.md |
| 2026-07-30 | Se implementó (erróneamente) wiring de l10n + persistencia de idioma durante la iteración de documentación | Revertido por edición: `app.dart` restaurado, `onboarding_screen.dart` sin cambios míos, migración `20260730_phase2_language_settings.sql` eliminada. Sin cambios de código en el árbol |

## Procedimiento de recuperación

1. Antes de implementar: commit/backup del estado actual (P0).
2. Cambios por tarea pequeña; `flutter analyze` + `flutter test` tras cada una.
3. Nunca `git checkout`/`git restore`/`git clean` sobre el árbol de Dart.
4. Si una pantalla nueva falla, corregir editando.
5. Documentar cada regresión aquí y en `Change_Log.md` de la fase.
