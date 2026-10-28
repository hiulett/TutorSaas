-- P-07 (#92): el cobro de maná pasa al servidor.
--
-- `consume_mana` descuenta `used_audio_seconds` Y `daily_used`; el
-- `refund_mana` original solo devolvía el saldo del plan, así que un intento
-- fallido dejaba el límite diario consumido. Se alinean ambos.
--
-- Solo service_role puede ejecutarla (la llama llm-proxy).

create or replace function public.refund_mana(p_user_id uuid, p_action_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $r$
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
    return jsonb_build_object('success', false);
  end if;

  update public.user_subscriptions
     set used_audio_seconds = greatest(0, coalesce(used_audio_seconds, 0) - v_cost),
         daily_used = greatest(0, coalesce(daily_used, 0) - v_cost),
         updated_at = now()
   where user_id = p_user_id;

  insert into public.mana_transactions (user_id, amount, type, action_code)
  values (p_user_id, v_cost, 'refund', p_action_code);

  return jsonb_build_object('success', true, 'refunded', v_cost);
end;
$r$;

revoke all on function public.refund_mana(uuid, text) from public, anon, authenticated;
grant execute on function public.refund_mana(uuid, text) to service_role;
