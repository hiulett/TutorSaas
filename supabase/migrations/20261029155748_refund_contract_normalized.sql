-- Normaliza el contrato de las compensaciones de maná.
--
-- Antes había dos formas para el mismo concepto:
--   refund_failed_turn -> {ok, refunded, already_refunded, reason}
--   refund_mana        -> {success, refunded}
--
-- Ahora ambas devuelven exactamente:
--   success          bool    (siempre)
--   refunded         int     (siempre; 0 si no había nada que devolver)
--   already_refunded bool    (siempre)
--   reason           text    (null si success; si no: invalid_turn |
--                             invalid_action | no_recent_charge)
--
-- `refund_mana` no tiene idempotencia propia (no escribe ref_id): la garantía
-- de "una vez por turno" sigue en `refund_failed_turn`.

begin;

create or replace function public.refund_failed_turn(
  p_turn_ref text,
  p_action_code text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_cost integer;
  v_debit public.mana_transactions%rowtype;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  if p_turn_ref is null or length(trim(p_turn_ref)) = 0 then
    return jsonb_build_object(
      'success', false, 'refunded', 0, 'already_refunded', false,
      'reason', 'invalid_turn'
    );
  end if;

  if exists (
    select 1 from public.mana_transactions
     where user_id = v_uid and type = 'refund' and ref_id = p_turn_ref
  ) then
    return jsonb_build_object(
      'success', true, 'refunded', 0, 'already_refunded', true,
      'reason', null
    );
  end if;

  select coalesce(cost_mana, 0) into v_cost
    from public.ai_action_costs
   where action_code = p_action_code and is_active;

  if v_cost is null or v_cost <= 0 then
    return jsonb_build_object(
      'success', false, 'refunded', 0, 'already_refunded', false,
      'reason', 'invalid_action'
    );
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
    return jsonb_build_object(
      'success', false, 'refunded', 0, 'already_refunded', false,
      'reason', 'no_recent_charge'
    );
  end if;

  update public.user_subscriptions
     set used_audio_seconds = greatest(0, coalesce(used_audio_seconds, 0) - v_cost),
         daily_used = greatest(0, coalesce(daily_used, 0) - v_cost),
         updated_at = now()
   where user_id = v_uid;

  insert into public.mana_transactions (user_id, amount, type, action_code, ref_id)
  values (v_uid, v_cost, 'refund', p_action_code, p_turn_ref);

  return jsonb_build_object(
    'success', true, 'refunded', v_cost, 'already_refunded', false,
    'reason', null
  );
end;
$$;

create or replace function public.refund_mana(
  p_user_id uuid,
  p_action_code text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cost integer;
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    raise exception 'No autorizado';
  end if;

  select coalesce(cost_mana, 0) into v_cost
    from public.ai_action_costs
   where action_code = p_action_code and is_active;

  if v_cost is null or v_cost <= 0 then
    return jsonb_build_object(
      'success', false, 'refunded', 0, 'already_refunded', false,
      'reason', 'invalid_action'
    );
  end if;

  update public.user_subscriptions
     set used_audio_seconds = greatest(0, coalesce(used_audio_seconds, 0) - v_cost),
         daily_used = greatest(0, coalesce(daily_used, 0) - v_cost),
         updated_at = now()
   where user_id = p_user_id;

  insert into public.mana_transactions (user_id, amount, type, action_code)
  values (p_user_id, v_cost, 'refund', p_action_code);

  return jsonb_build_object(
    'success', true, 'refunded', v_cost, 'already_refunded', false,
    'reason', null
  );
end;
$$;

comment on function public.refund_failed_turn(text, text) is
  'Compensacion de un turno fallido. Contrato: {success, refunded, already_refunded, reason}.';
comment on function public.refund_mana(uuid, text) is
  'Compensacion (service role) usada por llm-proxy. Mismo contrato que refund_failed_turn.';

commit;
