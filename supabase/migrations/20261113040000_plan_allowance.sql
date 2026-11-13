-- Canasta mensual del plan (#373).
--
-- `noble` y `realeza` solo se diferenciaban por mana e historial. Esta migracion
-- anade una canasta de recursos por plan, acreditada UNA vez por periodo y de
-- forma idempotente con `economy_apply_currency`.
--
-- Notas de esquema verificadas en produccion (13-nov-2026):
--   * `subscription_plans.id` es texto (`noble`, `realeza`, ...).
--   * `user_subscriptions` guarda `plan_id`, `status`, `period_end`.
--   * Los planes activos son `noble` y `realeza`; `plebeyo` aparece como plan de
--     las suscripciones gratuitas pero no tiene fila en `subscription_plans`.
--
-- Importante: `currency_ledger` tiene `unique(user_id, ref_key)`, asi que el
-- `ref_key` incluye la moneda. Con una sola clave para las tres, la segunda
-- acreditacion chocaria.

alter table public.subscription_plans
  add column if not exists monthly_allowance jsonb not null default '{}'::jsonb;

comment on column public.subscription_plans.monthly_allowance is
  'Canasta de recursos acreditada cada mes natural: {"gold":n,"gems":n,"fragments":n}. Solo monedas con sumidero real (#373).';

-- Valores iniciales propuestos (validar con datos antes de tocar).
update public.subscription_plans
   set monthly_allowance = '{"gold": 300, "gems": 50, "fragments": 30}'::jsonb
 where id = 'noble';

update public.subscription_plans
   set monthly_allowance = '{"gold": 800, "gems": 150, "fragments": 80}'::jsonb
 where id = 'realeza';

-- El resto de planes no entrega canasta.
update public.subscription_plans
   set monthly_allowance = '{}'::jsonb
 where id not in ('noble', 'realeza');

create or replace function public.grant_plan_allowance()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_plan text;
  v_status text;
  v_allow jsonb;
  v_period text := to_char(now(), 'YYYY-MM');
  v_currency text;
  v_amount integer;
  v_ref text;
  v_result jsonb;
  v_applied jsonb := '{}'::jsonb;
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

    v_ref := format('plan_allowance:%s:%s:%s', v_plan, v_period, v_currency);
    v_result := public.economy_apply_currency(
      v_uid, v_currency, v_amount, 'plan_allowance', v_ref
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

revoke execute on function public.grant_plan_allowance() from public, anon;
grant execute on function public.grant_plan_allowance() to authenticated;

comment on function public.grant_plan_allowance() is
  'Acredita la canasta mensual del plan activo una vez por mes natural, idempotente por ref_key (#373).';

-- Verificacion (solo lectura):
-- select id, monthly_allowance from public.subscription_plans order by id;
-- select user_id, currency, sum(delta), max(ref_key)
--   from public.currency_ledger where reason = 'plan_allowance' group by 1,2;
