-- Issue #68: la renovación del ciclo de maná borraba el saldo comprado.
--
-- `renew_mana_cycle` hacía `purchased_mana_balance = 0` en el ON CONFLICT, así
-- que cada INITIAL_PURCHASE / RENEWAL / PRODUCT_CHANGE del webhook eliminaba
-- el maná que el usuario hubiera comprado aparte.
--
-- Además el INSERT inicial usaba el plan 'free', que está inactivo en
-- `subscription_plans`; ahora usa 'plebeyo', el plan gratuito activo.

create or replace function public.renew_mana_cycle(
  p_user_id uuid,
  p_allowance integer,
  p_expires_at timestamp with time zone
)
returns boolean
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if p_user_id is null or p_expires_at is null then
    return false;
  end if;

  insert into public.user_subscriptions
    (user_id, plan_id, used_audio_seconds, purchased_mana_balance, mana_expires_at, updated_at)
  values
    (p_user_id, 'plebeyo', 0, 0, p_expires_at, now())
  on conflict (user_id) do update set
    used_audio_seconds = 0,
    mana_expires_at = excluded.mana_expires_at,
    updated_at = now();

  insert into public.mana_transactions (user_id, amount, type, ref_id)
  values (p_user_id, p_allowance, 'renew', 'cycle');

  return true;
end;
$function$;
