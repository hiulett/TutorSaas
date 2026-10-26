---
description: Deriva migraciones ↔ producción, RLS y funciones expuestas
agent: db-auditor
---

Audita la base de datos de TutorSaas en modo solo lectura.

Alcance de esta pasada: $ARGUMENTS

Método:

1. Lee `docs/runbooks/MIGRATION_STATUS.md` y cuenta las migraciones del repo.
2. Consulta el estado real con el MCP `supabase` (solo `SELECT`; nunca DDL).
3. Compara: tablas, columnas, políticas RLS, funciones `SECURITY DEFINER` y jobs de cron.
4. Reporta solo diferencias accionables.

Formato (máximo 600 palabras):

| Hallazgo | Producción | Repo | Riesgo | Acción |
|---|---|---|---|---|

Cierra con: `Deriva: ninguna | menor | bloqueante` y las consultas que usaste.
No ejecutes `supabase db push`, ni `apply_migration`, ni escrituras.
