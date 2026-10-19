# Volcado del esquema

Genera un `schema.sql` reproducible desde la base enlazada.

## Requisitos

- Docker en marcha (el CLI de Supabase usa un contenedor con `pg_dump`).
- Proyecto enlazado: `supabase/.temp/project-ref` debe existir.

## Uso

```powershell
# Esquema completo de public/
powershell -ExecutionPolicy Bypass -File scripts/dump_schema.ps1

# También auth/storage (opcional, útil para reconstruir un entorno propio)
powershell -ExecutionPolicy Bypass -File scripts/dump_schema.ps1 -IncludeSystemSchemas
```

Salida:

| Archivo | Contenido |
|---|---|
| `supabase/schema.sql` | DDL de `public` |
| `supabase/schema_system.sql` | DDL de `auth`, `storage` (si se pide) |

## Cómo usar el volcado

```bash
# Entorno limpio
supabase db reset

# Aplicar el baseline encima
psql "$DATABASE_URL" -f supabase/schema.sql
```

## Estado actual

Sin Docker en marcha, este repositorio **no puede** generar el volcado. Mientras tanto:

- `docs/schema/SCHEMA_INVENTORY.md` tiene la fotografía de tablas, RLS y políticas.
- `supabase/migrations/20261018000010_baseline_missing_tables.sql` cubre las cinco tablas que faltaban.

El objetivo (issue #10) es que este script se ejecute una vez, el resultado se versione y a partir de ahí `supabase db reset` reproduzca producción sin sorpresas.
