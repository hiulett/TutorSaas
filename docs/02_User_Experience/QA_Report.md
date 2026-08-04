# Fase 2 — QA_Report

> Reporte de QA (estado actual de la fase, sin cambios de código en esta iteración).

## Estado del build

| Check | Resultado |
|---|---|
| `flutter analyze` | 58 issues (0 errores; infos/warnings tolerados) |
| `flutter build apk --debug` | ✅ Build OK |
| `flutter test` | ⚠️ 12/13 pasan; 1 falla preexistente |

## Falla de test preexistente

`test/overflow_test.dart` → `LeagueLeaderboardWidget does not overflow at width 312`:
- Error: `pumpAndSettle timed out`.
- No relacionada con la Fase 2 (es un widget de leaderboard); se registra como deuda
  (ver `Known_Issues.md`). Se debe revalidar al tocar el dashboard.

## Validaciones de la fase

- ✅ Claves l10n balanceadas (237 en/es/pt) — sin warnings de gen-l10n pendientes.
- ✅ `/oracle-test` registrado y navegable desde onboarding (paso 2).
- ✅ Flujo de guardado de onboarding persiste en 6 tablas.
- ❌ La app NO aplica el idioma de UI (MaterialApp sin l10n wiring) — GAP P0.
- ❌ El idioma elegido en onboarding no se refleja en `userLanguageProvider` — GAP P0.

## Regresión

- No se detectaron regresiones nuevas en esta iteración (solo documentación).
