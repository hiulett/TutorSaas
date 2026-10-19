# Fase 6 — Recovery

> Recuperación y gestión de regresiones de la Fase 6.

## ⚠️ Contexto crítico del repo

- Repo con UN SOLO commit; trabajo sin commitear.
- **PROHIBIDO** `git checkout`/`git restore` sobre Dart — revertir editando.

## Procedimiento

1. Backup/commit antes de tocar `economy_repository_impl.dart`.
2. Cambios pequeños; `flutter analyze` + `flutter test` tras cada uno.
3. Verificar RPCs y esquema live antes de confiar en la migración de economía.
4. El `claimDailyReward` debe corregirse editando la línea del update, no restaurando el archivo.

## Riesgos específicos de Fase 6

- **Gastos**: `purchaseItem`/`spendGems` tocan gemas reales — no probar contra producción con
  datos reales sin aislamiento.
- Migración grande (8 tablas + ALTERs): aplicar en orden; si el live rechaza DDL, usar branch.
