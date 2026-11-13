-- Dashboard de economia: vistas de solo lectura (#389).
--
-- Cuatro bloques de la historia: dinero (fuera de Supabase: Play/RevenueCat),
-- flujo, catalogo y aprendizaje. Aqui se resuelven los dos que viven en la base.
--
-- Las vistas son agregadas (sin PII por usuario) y se restringen a service_role:
-- el dashboard se consulta desde el SQL Editor o un job, no desde la app.

-- ── 1. Flujo por moneda y mes ───────────────────────────────────────────────
create or replace view public.v_economy_flow_monthly as
select
  date_trunc('month', l.created_at)::date as month,
  l.currency,
  coalesce(sum(case when l.delta > 0 and l.reason <> 'plan_allowance' then l.delta end), 0) as earned_played,
  coalesce(sum(case when l.delta > 0 and l.reason = 'plan_allowance' then l.delta end), 0) as earned_plan,
  coalesce(sum(case when l.delta < 0 then -l.delta end), 0) as spent,
  coalesce(sum(case when l.delta > 0 then l.delta end), 0) as earned_total,
  round(
    coalesce(sum(case when l.delta < 0 then -l.delta end), 0)::numeric
    / nullif(coalesce(sum(case when l.delta > 0 then l.delta end), 0), 0),
    3
  ) as sink_ratio
from public.currency_ledger l
group by 1, 2;

comment on view public.v_economy_flow_monthly is
  'Flujo mensual por moneda: ganado jugando, ganado por plan, gastado y sink_ratio (#389).';

-- ── 2. Saldos por moneda ────────────────────────────────────────────────────
create or replace view public.v_economy_balances as
select 'gold'::text as currency,
       count(*) as profiles,
       max(total_gold) as max_balance,
       percentile_cont(0.5) within group (order by total_gold) as median_balance,
       round(avg(total_gold)::numeric, 1) as avg_balance,
       sum(total_gold) as total_balance
  from public.user_language_profiles
union all
select 'gems',
       count(*),
       max(total_gems),
       percentile_cont(0.5) within group (order by total_gems),
       round(avg(total_gems)::numeric, 1),
       sum(total_gems)
  from public.user_language_profiles
union all
select 'fragments',
       count(*),
       max(fragments),
       percentile_cont(0.5) within group (order by fragments),
       round(avg(fragments)::numeric, 1),
       sum(fragments)
  from public.user_language_profiles;

comment on view public.v_economy_balances is
  'Saldos por moneda: máximo, mediana, media y total (#389).';

-- ── 3. Salud del catalogo ───────────────────────────────────────────────────
create or replace view public.v_economy_catalog_health as
select
  c.category,
  count(*) filter (where c.is_active) as active_items,
  count(*) filter (where not c.is_active) as retired_items,
  count(pi.user_id) as owners,
  count(pi.user_id) filter (where pi.is_equipped) as equipped
from public.cosmetic_catalog c
left join public.player_inventory pi on pi.item_code = c.id
group by c.category;

comment on view public.v_economy_catalog_health is
  'Items activos/retirados y cuántos se han comprado/equipado por categoría (#389).';

-- ── 4. Acceso ───────────────────────────────────────────────────────────────
revoke all on public.v_economy_flow_monthly from public, anon, authenticated;
revoke all on public.v_economy_balances from public, anon, authenticated;
revoke all on public.v_economy_catalog_health from public, anon, authenticated;

-- Verificacion:
-- select * from public.v_economy_balances;
-- select * from public.v_economy_catalog_health order by active_items desc;
-- select * from public.v_economy_flow_monthly order by month desc limit 12;
