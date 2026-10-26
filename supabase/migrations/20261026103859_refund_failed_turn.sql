-- Issue #91 (P-06): si el turno falla tras agotar reintentos, el maná se
-- devuelve. `refund_mana` existente es solo para service_role, así que el
-- cliente necesita una RPC propia que valide que hubo un cobro reciente.
--
-- Idempotencia: una devolución por `turn_ref` (unique parcial). Solo se
-- reembolsan cobros de plan (`type='action'`); los ítems equipados quedan
-- fuera de este cambio.

create unique index if not exists mana_transactions_refund_turn_once
  on public.mana_transactions (ref_id)
  where type = 'refund';

create or replace function public.refund_failed_turn(
  p_turn_ref text,
  p_action_code text
)
returns jsonb
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_cost integer;
  v_debit public.mana_transactions%rowtype;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  if p_turn_ref is null or length(trim(p_turn_ref)) = 0 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_turn');
  end if;

  if exists (
    select 1 from public.mana_transactions
     where user_id = v_uid and type = 'refund' and ref_id = p_turn_ref
  ) then
    return jsonb_build_object('ok', true, 'already_refunded', true, 'refunded', 0);
  end if;

  select coalesce(cost_mana, 0) into v_cost
    from public.ai_action_costs
   where action_code = p_action_code and is_active;

  if v_cost is null or v_cost <= 0 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_action');
  end if;

  select * into v_debit
    from public.mana_transactions
   where user_id = v_uid
     and type = 'action'
     and action_code = p_action_code
     and created_at > now() - interval '5 minutes'
   order by created_at desc
   limit 1;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_recent_charge');
  end if;

  update public.user_subscriptions
     set used_audio_seconds = greatest(0, coalesce(used_audio_seconds, 0) - v_cost),
         daily_used = greatest(0, coalesce(daily_used, 0) - v_cost),
         updated_at = now()
   where user_id = v_uid;

  insert into public.mana_transactions (user_id, amount, type, action_code, ref_id)
  values (v_uid, v_cost, 'refund', p_action_code, p_turn_ref);

  return jsonb_build_object('ok', true, 'already_refunded', false, 'refunded', v_cost);
end;
$function$;

revoke all on function public.refund_failed_turn(text, text) from public, anon;
grant execute on function public.refund_failed_turn(text, text) to authenticated;
