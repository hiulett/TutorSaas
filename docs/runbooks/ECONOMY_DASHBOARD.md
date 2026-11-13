# Dashboard de economía

Cuatro bloques de lectura para decidir con dato. Tres viven en Supabase (vistas
de `20261113070000_economy_dashboard_views.sql`); el de dinero vive en Play
Console y RevenueCat, porque `payments` solo recibe filas desde que el webhook
registra ingresos.

**Cómo se consulta:** SQL Editor o job con rol de servicio (las vistas están
revocadas para `anon`/`authenticated`). Son agregados, sin datos personales.

---

## 1 · Dinero (externo)

| Métrica | Fuente |
|---|---|
| MRR, conversión, churn, ARPPU | RevenueCat / Play Console |
| Ingresos registrados en la app | `payments` (vacío hasta desplegar `revenuecat-webhook`) |

```sql
select status, count(*), coalesce(sum(amount),0) as importe
  from public.payments group by status;
```

## 2 · Flujo (lo que decide precios)

```sql
select * from public.v_economy_flow_monthly order by month desc limit 12;
```

| Columna | Lectura |
|---|---|
| `earned_played` | Lo que genera el juego (sesiones, misiones, niveles) |
| `earned_plan` | Lo que genera la canasta del plan |
| `spent` | Lo que se consume |
| `sink_ratio` | `spent / earned_total` |

**Bandas**: oro entre **0.4 y 0.7** es sano.
- `< 0.2` → precios altos o catálogo poco atractivo (no bajar precios a ciegas).
- `> 0.8` → el catálogo se queda corto: hace falta más sumidero.

## 3 · Saldos y catálogo

```sql
select * from public.v_economy_balances;
select * from public.v_economy_catalog_health order by active_items desc;
```

Señales:
- Mediana de oro **creciente sin gasto** → inflación.
- `owners = 0` en una categoría → nadie compra: problema de descubrimiento, no de precio (es exactamente lo medido el 13-nov: 65/65 podían pagar el item de entrada y 0 compraron).
- `equipped / owners` bajo → se compra y no se usa: el cosmético no se ve.

## 4 · Aprendizaje (guardarraíles)

Bloque pendiente: requiere analítica de producto (lecciones completadas,
abandono, palabras nuevas). Definido en `docs/economy/ECONOMY_METRICS_AND_KPIS.md`
§5.

**Regla de decisión:** si una iniciativa sube ingresos y baja lecciones
completadas por usuario, se revierte. No se negocia.

---

## Rutina sugerida

| Frecuencia | Qué mirar |
|---|---|
| Semanal | Flujo (bloque 2) y catálogo (bloque 3) |
| Mensual | Dinero (bloque 1) y cohortes |
| Tras cada cambio de precio | `sink_ratio` de la moneda tocada, 7 días |

Estados conocidos que el dashboard debe mostrar como «sin datos» y no como cero:
- `currency_ledger` vacío → `sink_ratio` nulo.
- `player_inventory` vacío → `owners = 0` en todas las categorías.
- `payments` vacío → sin ingresos registrados en la app (no significa que no
  haya ingresos: están en Play).
