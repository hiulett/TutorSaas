-- Canasta del plan: una sola acreditación por mes, con prorrateo al subir de plan.
--
-- Bug: el `ref_key` era `plan_allowance:<plan>:<YYYY-MM>:<moneda>`. Al cambiar de
-- plan dentro del mismo mes (noble -> realeza), el servidor acreditaba OTRA
-- canasta completa, regalando moneda por el simple hecho de mejorar el plan.
--
-- Nuevo comportamiento:
--   * La clave depende del mes, no del plan: `plan_allowance:<YYYY-MM>:<moneda>`.
--   * Si ya se acreditó algo este mes, solo se entrega la DIFERENCIA si el nuevo
--     plan da más (upgrade). Nunca se resta al bajar de plan.
--   * La diferencia se registra con su propia clave `plan_allowance_topup:...`
--     para no chocar con la restricción única (user_id, ref_key).

create or replace function public.grant_plan_allowance()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid      uuid := auth.uid();
  v_plan     text;
  v_status   text;
  v_allow    jsonb;
  v_period   text := to_char(now(), 'YYYY-MM');
  v_currency text;
  v_amount   integer;
  v_already  integer;
  v_delta    integer;
  v_ref      text;
  v_result   jsonb;
  v_applied  jsonb := '{}'::jsonb;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;

  select plan_id, status
    into v_plan, v_status
    from public.user_subscriptions
   where user_id = v_uid
   limit 1;

  if v_plan is null or v_status is distinct from 'active' then
    return jsonb_build_object('granted', false, 'reason', 'no_plan');
  end if;

  select monthly_allowance into v_allow
    from public.subscription_plans
   where id = v_plan;

  if v_allow is null or v_allow = '{}'::jsonb then
    return jsonb_build_object('granted', false, 'reason', 'no_allowance', 'plan', v_plan);
  end if;

  foreach v_currency in array array['gold', 'gems', 'fragments'] loop
    v_amount := coalesce((v_allow ->> v_currency)::int, 0);
    continue when v_amount <= 0;

    -- Ya acreditado este mes (venga del plan que venga).
    select coalesce(sum(delta), 0) into v_already
      from public.currency_ledger
     where user_id = v_uid
       and currency = v_currency
       and reason in ('plan_allowance', 'plan_allowance_topup')
       and ref_key like 'plan_allowance%' || v_period || '%';

    v_delta := v_amount - v_already;
    continue when v_delta <= 0;

    v_ref := case
      when v_already = 0 then format('plan_allowance:%s:%s', v_period, v_currency)
      else format('plan_allowance_topup:%s:%s:%s', v_period, v_currency, v_delta)
    end;

    v_result := public.economy_apply_currency(
      v_uid, v_currency, v_delta,
      case when v_already = 0 then 'plan_allowance' else 'plan_allowance_topup' end,
      v_ref
    );
    v_applied := v_applied || jsonb_build_object(v_currency, v_result);
  end loop;

  return jsonb_build_object(
    'granted', true,
    'plan', v_plan,
    'period', v_period,
    'applied', v_applied
  );
end;
$$;

comment on function public.grant_plan_allowance() is
  'Acredita la canasta mensual: una vez por mes y moneda, con prorrateo al subir de plan (#373, fix upgrade).';

-- El dashboard debe contar el top-up como «ganado por plan», no como juego.
create or replace view public.v_economy_flow_monthly as
select
  date_trunc('month', l.created_at)::date as month,
  l.currency,
  coalesce(sum(case when l.delta > 0 and l.reason not like 'plan_allowance%' then l.delta end), 0) as earned_played,
  coalesce(sum(case when l.delta > 0 and l.reason like 'plan_allowance%' then l.delta end), 0) as earned_plan,
  coalesce(sum(case when l.delta < 0 then -l.delta end), 0) as spent,
  coalesce(sum(case when l.delta > 0 then l.delta end), 0) as earned_total,
  round(
    coalesce(sum(case when l.delta < 0 then -l.delta end), 0)::numeric
    / nullif(coalesce(sum(case when l.delta > 0 then l.delta end), 0), 0),
    3
  ) as sink_ratio
from public.currency_ledger l
group by 1, 2;

-- Verificacion:
-- select ref_key, sum(delta) from public.currency_ledger
--  where reason like 'plan_allowance%' group by ref_key order by ref_key;
