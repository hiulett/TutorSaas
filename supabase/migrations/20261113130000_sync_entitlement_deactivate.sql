-- sync_entitlement: una orden explícita de desactivar debe ganar siempre.
--
-- Bug detectado probando en dispositivo: tras cancelar y expirar la suscripción,
-- RevenueCat devolvía `active_entitlements: []`, pero la fila en Supabase seguía
-- `noble · active` y la app mantenía el botón de compra deshabilitado.
--
-- Causa: la rama `p_is_active = false` solo actualizaba si
--   `rc_expires_at is null or rc_expires_at <= now()`
-- y el valor guardado era una fecha futura equivocada (no degradada de una
-- lectura anterior). Con eso, la desactivación nunca se aplicaba.
--
-- El «no degradar» tiene sentido cuando llega un estado MENOS favorable que el
-- que ya tenemos (para no perder acceso por datos parciales), pero no cuando la
-- fuente autoritativa dice explícitamente que no hay entitlement activo.

create or replace function public.sync_entitlement(
  p_user_id uuid,
  p_plan_id text,
  p_product_id text default null,
  p_expires_at timestamptz default null,
  p_store text default 'play',
  p_is_active boolean default true,
  p_event_id text default null
)
returns boolean
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_allowance integer;
  v_cycle text;
  v_prev_expiry timestamptz;
begin
  if p_user_id is null then
    return false;
  end if;

  if p_event_id is not null
     and exists (select 1 from public.revenuecat_events where id = p_event_id) then
    return true;
  end if;

  select rc_expires_at into v_prev_expiry
  from public.user_subscriptions where user_id = p_user_id;

  if p_is_active then
    select mana_allowance into v_allowance
    from public.subscription_plans where id = p_plan_id;
    if v_allowance is null then
      return false;
    end if;

    v_cycle := case when p_product_id ilike '%yearly%' or p_product_id ilike '%annual%'
                    then 'annual' else 'monthly' end;

    insert into public.user_subscriptions as s
      (user_id, plan_id, status, billing_cycle, period_start, period_end,
       store, rc_product_id, rc_expires_at, last_event_id, updated_at)
    values
      (p_user_id, p_plan_id, 'active', v_cycle, now(),
       coalesce(p_expires_at, now() + interval '1 month'),
       p_store, p_product_id, p_expires_at, p_event_id, now())
    on conflict (user_id) do update set
      plan_id = excluded.plan_id,
      status = 'active',
      billing_cycle = excluded.billing_cycle,
      period_end = excluded.period_end,
      store = excluded.store,
      rc_product_id = excluded.rc_product_id,
      rc_expires_at = excluded.rc_expires_at,
      last_event_id = coalesce(excluded.last_event_id, s.last_event_id),
      updated_at = now()
    where s.rc_expires_at is null
       or excluded.rc_expires_at is null
       or excluded.rc_expires_at >= s.rc_expires_at;

    -- Solo repone el maná cuando cambia el periodo (no en cada sincronización).
    if v_prev_expiry is distinct from p_expires_at then
      perform public.renew_mana_cycle(p_user_id, v_allowance,
        coalesce(p_expires_at, now() + interval '1 month'));
    end if;
  else
    -- Desactivación explícita: se aplica siempre, sin la guarda de expiración.
    update public.user_subscriptions
      set plan_id = 'plebeyo', status = 'expired', billing_cycle = null,
          rc_expires_at = least(coalesce(rc_expires_at, now()), now()),
          last_event_id = coalesce(p_event_id, last_event_id), updated_at = now()
      where user_id = p_user_id
        and (status <> 'expired' or plan_id <> 'plebeyo');
  end if;

  if p_event_id is not null then
    insert into public.revenuecat_events (id, type, app_user_id)
    values (p_event_id, 'sync', p_user_id::text)
    on conflict (id) do nothing;
  end if;

  return true;
end;
$function$;

comment on function public.sync_entitlement(uuid, text, text, timestamptz, text, boolean, text) is
  'Sincroniza el entitlement. Activar no degrada fechas; desactivar siempre se aplica (#414).';

-- Verificacion:
-- select user_id, plan_id, status, rc_expires_at from public.user_subscriptions
--  order by updated_at desc limit 5;
