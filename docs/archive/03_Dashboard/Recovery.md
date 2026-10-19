# Fase 3 — Recovery

> Recuperación y gestión de regresiones de la Fase 3.

## ⚠️ Contexto crítico del repo

- Repo con UN SOLO commit; trabajo sin commitear.
- **PROHIBIDO** `git checkout`/`git restore` sobre Dart — revertir editando.

## Procedimiento

1. Backup/commit antes de refactorizar el tab GUILD (cambio grande sobre `dashboard_screen.dart`).
2. Trabajar por widgets pequeños; `flutter analyze` + `flutter test` tras cada cambio.
3. Si una pantalla no compila, corregir editando; nunca restaurar.
4. Registrar regresiones en `Change_Log.md` / `Known_Issues.md`.

## Riesgos específicos de Fase 3

- `dashboard_screen.dart` es muy grande (2018 líneas) → alto riesgo de regresión al tocarlo.
  Dividir en widgets antes de refactors profundos.
- El test de overflow (`LeagueLeaderboard`) es sensible a animaciones infinitas
  (`pumpAndSettle` timeout) → revisar si hay animaciones repetitivas en el widget.
