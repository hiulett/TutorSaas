# Estado de las migraciones (auditoría real)

_Actualizado: 29-oct-2026 (recuento aplicado; el desglose de archivos es del 18-oct)._

> Estado actual verificado: **77 migraciones aplicadas**. La foto completa del
> esquema esta en [SCHEMA_BASELINE.md](SCHEMA_BASELINE.md).

## Resumen

| Métrica | Valor |
|---|---|
| Archivos `.sql` en `supabase/migrations/` | **116** |
| De ellos, con prefijo de 14 dígitos válido | 41 |
| Sin prefijo (el CLI los ignora) | **75** |
| En subcarpetas (`archive/`, `audit/`) | 40 |
| Migraciones aplicadas según `supabase_migrations.schema_migrations` | **48** |
| Aplicadas **con** archivo correspondiente | 15 |
| Aplicadas **sin** archivo en el repo | **33** |
| Archivos con prefijo que **no** están aplicados | 26 |

## Por qué el repo no reproduce el esquema

1. **33 migraciones se aplicaron desde el SQL Editor / dashboard** y no tienen
   archivo: quedaron guardadas en la tabla de historial con sus sentencias, pero
   el repo no las conoce.
2. **75 archivos no siguen la convención `<14 dígitos>_nombre.sql`**, así que
   `supabase db push` no los ve.
3. **40 archivos viven en subcarpetas** que el CLI no lee (`archive/`, `audit/`).
4. El orden histórico no es reconstruible: hay archivos con prefijos de julio
   que nunca se aplicaron, junto a otros del mismo día que sí.

## Lo que sí se corrigió

Las migraciones de esta sesión se renombraron para que su prefijo coincida con
la versión real registrada por Supabase:

| Archivo | Versión aplicada |
|---|---|
| `20261018062241_purge_stale_participants_cron.sql` | ✔ |
| `20261018190752_renew_mana_cycle_keep_purchased_mana.sql` | ✔ |
| `20261018192643_sync_entitlement_support.sql` | ✔ |
| `20261018192653_sync_entitlement_no_mana_double_grant.sql` | ✔ (nuevo) |
| `20261018195424_remove_stripe.sql` | ✔ (nuevo) |
| `20261018201310_add_in_grace_status.sql` | ✔ |
| `20261018234615_restrict_subscription_writes.sql` | ✔ |
| `20261019015914_oracle_turns_update_own.sql` | ✔ |

Antes tenían prefijos `202610180000xx` que **no** existían en el historial: un
`db push` las habría intentado aplicar de nuevo.

## Camino recomendado: baseline (squash)

Renombrar los 75 archivos no resuelve nada: `db push` los consideraría nuevos y
trataría de aplicarlos sobre una base que ya los tiene.

La solución estándar es **una migración base** con el esquema actual y archivar
todo lo anterior:

```sh
# 1. Volcar el esquema real (requiere Docker y la contraseña de la BD)
supabase db dump --project-ref sipiumfdpvnszthykyog \
  --schema public -f supabase/migrations/20261101000000_baseline.sql

# 2. Archivar el histórico
mkdir -p supabase/migrations/archive/pre-baseline
git mv supabase/migrations/*.sql supabase/migrations/archive/pre-baseline/

# 3. Registrar el baseline como aplicado
supabase migration repair --status applied 20261101000000 --project-ref sipiumfdpvnszthykyog
```

Con eso, un entorno nuevo se crea aplicando **un solo archivo**.

### Por qué no se hizo ahora

- `supabase db dump` necesita **Docker** y la contraseña de la base de datos;
  ninguna de las dos está disponible en este entorno.
- Generar el DDL a mano con `pg_catalog` produce un esquema incompleto
  (grants, secuencias, extensiones, ownership) y sería peor que no tenerlo.

## Mientras tanto

- No ejecutar `supabase db push` contra producción: intentaría aplicar los 26
  archivos con prefijo no registrados.
- Los cambios de esquema se siguen aplicando por el SQL Editor o por MCP, y se
  guardan como archivo con la **versión real** del historial.
