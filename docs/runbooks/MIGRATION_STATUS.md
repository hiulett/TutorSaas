# Estado de las migraciones (auditoría real)

_Actualizado: 30-oct-2026 (recuento aplicado y desglose de archivos verificados ese día)._

> Estado actual verificado: **103 migraciones aplicadas**. La foto completa del
> esquema esta en [SCHEMA_BASELINE.md](SCHEMA_BASELINE.md).

## Resumen

| Métrica | Valor |
|---|---|
| Archivos `.sql` en `supabase/migrations/` | **169** |
| De ellos, con prefijo de 14 dígitos válido | 94 |
| Sin prefijo (el CLI los ignora) | **75** |
| En subcarpetas (`archive/`, `audit/`) | 40 |
| Migraciones aplicadas según `supabase_migrations.schema_migrations` | **103** |
| Aplicadas **con** archivo correspondiente | 61 |
| Aplicadas **sin** archivo en el repo | **39** |
| Archivos con prefijo que **no** están aplicados | 33 |

> Recuento de archivos (169 totales, 94 con prefijo, 40 en subcarpetas),
> migraciones aplicadas (103) y archivos con prefijo (94) reverificado por MCP
> y shell el 30-oct-2026 (tras P-40-c/#222). Las filas de correspondencia
> archivo↔historial (61/39) se ajustaron con la migración nueva y siguen
> apoyadas en el desglose anterior: no se recontaron una a una.

## Por qué el repo no reproduce el esquema

1. **39 migraciones se aplicaron desde el SQL Editor / dashboard / MCP** y no tienen
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
| `20261030005704_plans_capabilities_p44_p45.sql` | ✔ (nuevo, P-44/P-45) |
| `20261030035724_ai_action_costs_correction_turn_free_p40c.sql` | ✔ (nuevo, P-40-c/#222) |

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
