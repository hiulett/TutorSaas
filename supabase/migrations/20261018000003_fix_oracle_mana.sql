-- Issue #6: el resultado final del Oráculo no se persistía.
-- `oracle_assessments` tenía SELECT e INSERT pero ninguna política UPDATE, así
-- que el UPDATE con el nivel definitivo era rechazado y la fila se quedaba con
-- el A1/E provisional.

drop policy if exists "oracle_assessments_update_own" on public.oracle_assessments;
create policy "oracle_assessments_update_own"
    on public.oracle_assessments
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Issue #7: doble cobro de maná.
--
-- `track_ai_audio_time` escribía los segundos de grabación en
-- `used_audio_seconds`, que es la MISMA columna que usa `consume_mana` para
-- debitar. Resultado: cada turno costaba `coste_accion + segundos_hablados`.
-- Además insertaba la fila con `plan_id = 'free'`, lo que desactivaba la rama
-- del límite diario (`IF v_plan_id = 'plebeyo'`).
--
-- Fix: la telemetría va a su propia columna y la función no crea filas.

alter table public.user_subscriptions
    add column if not exists audio_seconds_logged bigint not null default 0;

create or replace function public.track_ai_audio_time(
    p_user_id text,
    p_duration_seconds integer
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn$
declare
    v_used     bigint := 0;
    v_limit    bigint := 0;
    v_plan_id  text;
    v_seconds  integer;
begin
    if auth.uid() is null or auth.uid()::text <> p_user_id then
        return jsonb_build_object('is_allowed', false);
    end if;

    -- Sin valores negativos (permitían "reembolsar" cuota) ni picos absurdos.
    v_seconds := coalesce(p_duration_seconds, 0);
    if v_seconds < 0 then v_seconds := 0; end if;
    if v_seconds > 600 then v_seconds := 600; end if;

    update public.user_subscriptions
       set audio_seconds_logged = coalesce(audio_seconds_logged, 0) + v_seconds,
           updated_at = timezone('utc', now())
     where user_id = auth.uid();

    select coalesce(us.used_audio_seconds, 0),
           coalesce(sp.monthly_audio_minutes_limit * 60, 0),
           us.plan_id
      into v_used, v_limit, v_plan_id
      from public.user_subscriptions us
      left join public.subscription_plans sp on sp.id = us.plan_id
     where us.user_id = auth.uid()
     limit 1;

    return jsonb_build_object(
        'used_seconds', v_used,
        'limit_seconds', v_limit,
        'remaining_seconds', greatest(0, v_limit - v_used),
        'is_allowed', (v_limit = 0 or v_used < v_limit),
        'plan_id', v_plan_id
    );
end;
$fn$;

-- Una sola allowance de referencia para el plan gratuito (antes: 1800 en
-- get_mana_state, 3000 en consume_mana). El valor real del plan es 3000.

create or replace function public.get_mana_state(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn2$
declare
    v_allowance   bigint;
    v_purchased   bigint;
    v_used        bigint;
    v_expires     timestamptz;
    v_plan        text;
    v_class       text;
    v_plan_id     text;
    v_daily_limit integer;
    v_daily_used  integer;
    v_daily_date  date;
begin
    if auth.uid() is null or auth.uid() <> p_user_id then
        return jsonb_build_object('error', 'unauthorized');
    end if;

    select coalesce(sp.mana_allowance, 3000), coalesce(sp.class_name, 'plebeyo'),
           coalesce(sp.name, 'Plan Gratuito'), coalesce(us.plan_id, 'plebeyo')
      into v_allowance, v_class, v_plan, v_plan_id
      from public.user_subscriptions us
      join public.subscription_plans sp on us.plan_id = sp.id
     where us.user_id = p_user_id;

    select coalesce(us.purchased_mana_balance, 0), coalesce(us.used_audio_seconds, 0),
           us.mana_expires_at, coalesce(us.daily_limit, 200), coalesce(us.daily_used, 0),
           us.daily_reset_date
      into v_purchased, v_used, v_expires, v_daily_limit, v_daily_used, v_daily_date
      from public.user_subscriptions us where us.user_id = p_user_id;

    if v_allowance is null then v_allowance := 3000; end if;
    if v_purchased is null then v_purchased := 0; end if;
    if v_used is null then v_used := 0; end if;
    if v_daily_limit is null then v_daily_limit := 200; end if;
    if v_daily_used is null then v_daily_used := 0; end if;

    if v_daily_date is null or v_daily_date < current_date then
        v_daily_used := 0;
        update public.user_subscriptions
           set daily_used = 0, daily_reset_date = current_date, updated_at = now()
         where user_id = p_user_id;
    end if;

    return jsonb_build_object(
        'allowance', v_allowance,
        'purchased', v_purchased,
        'used', v_used,
        'remaining', greatest(0, (v_allowance + v_purchased) - v_used),
        'expires_at', v_expires,
        'plan', coalesce(v_plan, 'Plan Gratuito'),
        'class', coalesce(v_class, 'plebeyo'),
        'is_free', (v_plan_id = 'plebeyo'),
        'daily_limit', v_daily_limit,
        'daily_used', v_daily_used,
        'daily_remaining', greatest(0, v_daily_limit - v_daily_used)
    );
end;
$fn2$;
