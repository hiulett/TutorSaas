# Fase 5 — Recovery

> Recuperación y gestión de regresiones de la Fase 5.

## ⚠️ Contexto crítico del repo

- Repo con UN SOLO commit; trabajo sin commitear.
- **PROHIBIDO** `git checkout`/`git restore` sobre Dart — revertir editando.

## Procedimiento

1. Backup/commit antes de ampliar `mission_repository.dart`.
2. Cambios pequeños; `flutter analyze` + `flutter test` tras cada uno.
3. Antes de tocar la migración `20260730_mission_engine.sql`, verificar si ya fue aplicada al
   live (`list_migrations`) para evitar conflictos de RLS/índices.
4. Si el live rechaza DDL ("read-only transaction"), aplicar vía SQL Editor/branch.

## Riesgos específicos de Fase 5

- `updateProgress` que sobrescribe status directamente: si se cambia a progresión parcial,
  las misiones ya completadas podrían regresionar — migrar con cuidado.
- RLS: al añadir repo para gremio/eventos, mantener políticas por `auth.uid()`.
