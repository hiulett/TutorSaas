# Lección de refuerzo — medición (P-42 · #127)

Consultas de solo lectura para saber si el refuerzo **se genera** y si **se
completa**. Ejecutar en el SQL Editor o por MCP (nunca `db push`).

## 1. Embudo por semana

```sql
select date_trunc('week', s.created_at)::date as semana,
       count(*)                                              as generadas,
       count(*) filter (where s.review_status = 'approved')  as aprobadas,
       count(*) filter (where lp.status = 'passed')          as completadas,
       count(*) filter (where lp.status = 'failed')          as falladas,
       count(*) filter (where lp.id is null)                 as sin_intentar,
       round(100.0 * count(*) filter (where lp.status = 'passed')
             / nullif(count(*), 0), 1)                       as pct_exito
from public.scenarios s
left join public.lesson_progress lp
       on lp.lesson_id = s.id::text
where s.is_custom
  and s.skill_focus is not null
  and s.created_by_user_id is not null
group by 1
order by 1 desc;
```

- `generadas` = borradores de refuerzo creados por `lesson-generator`.
- `completadas` = el jugador cerró la sesión con ≥ umbral de metas
  (`lesson_progress.status = 'passed'`).
- Una fila por semana; si no hay filas, no se ha generado ninguna.

## 2. Volumen total y cobertura

```sql
select count(*)                                          as generadas,
       count(distinct created_by_user_id)                as jugadores,
       count(*) filter (where review_status = 'approved') as aprobadas,
       count(*) filter (where review_status = 'draft')    as pendientes_revision
from public.scenarios
where is_custom and skill_focus is not null;
```

## 3. Coste real por lección generada

```sql
select date_trunc('month', created_at)::date as mes,
       count(*) filter (where type = 'action') as cobros,
       count(*) filter (where type = 'refund') as reembolsos,
       sum(case when type = 'action' then -amount else 0 end) as mana_cobrado
from public.mana_transactions
where action_code = 'lesson_generation'
group by 1
order by 1 desc;
```

Un `refund` por cada `action` significa que la generación está fallando y
devolviendo el maná (visible para el jugador en el resumen de sesión).

## Estado al 29-oct-2026

`generadas = 0`, `completadas = 0`: la función desplegada fallaba siempre
(`content` vacío del modelo por presupuesto de tokens) y reembolsaba el maná.
Las pruebas de #127 generaron y borraron 2 borradores temporales; el conteo
vuelve a 0.
