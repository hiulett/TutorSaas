-- P-32 (#117) — Fix de idempotencia real en `purchase_streak_freeze`.
--
-- Validado en produccion con `begin ... rollback` (2026-10-29, usuario
-- b5a2d0d9): llamar dos veces con la misma `p_ref_key` devolvia
-- `success=true, freezes=2` pero solo cobraba 30 gemas una vez. Es decir, la
-- referencia idempotente protegia el saldo pero no el contador de freezes.
--
-- Ahora, si la referencia ya existe, la RPC devuelve `duplicated=true` con el
-- contador REAL y no lo incrementa.

create or replace function public.purchase_streak_freeze(
  p_user_id uuid,
  p_ref_key text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_cost    constant integer := 30;
  v_cap     constant integer := 3;
  v_freezes integer;
  v_move    jsonb;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;
  if p_ref_key is null or length(trim(p_ref_key)) = 0 then
    return jsonb_build_object('success', false, 'reason', 'bad_ref');
  end if;

  insert into public.player_streaks (user_id, current_streak, longest_streak, last_active_date)
  values (p_user_id, 0, 0, current_date)
  on conflict (user_id) do nothing;

  select coalesce(streak_freezes, 0) into v_freezes
    from public.player_streaks where user_id = p_user_id for update;

  if v_freezes >= v_cap then
    return jsonb_build_object('success', false, 'reason', 'cap_reached',
                              'freezes', v_freezes, 'cap', v_cap);
  end if;

  v_move := public.economy_apply_currency(
    p_user_id, 'gems', -v_cost, 'streak_freeze', p_ref_key);

  if coalesce((v_move ->> 'duplicated')::boolean, false) then
    return jsonb_build_object('success', true, 'duplicated', true,
                              'freezes', v_freezes, 'cap', v_cap,
                              'balance', (v_move ->> 'balance')::integer);
  end if;

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object('success', false,
      'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'cost', v_cost, 'balance', coalesce((v_move ->> 'balance')::integer, 0));
  end if;

  update public.player_streaks
     set streak_freezes = v_freezes + 1
   where user_id = p_user_id;

  return jsonb_build_object('success', true, 'duplicated', false,
                            'cost', v_cost, 'freezes', v_freezes + 1,
                            'cap', v_cap,
                            'balance', (v_move ->> 'balance')::integer);
end;
$function$;

grant execute on function public.purchase_streak_freeze(uuid, text) to authenticated;
