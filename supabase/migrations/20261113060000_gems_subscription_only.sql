-- Gemas solo por suscripcion (#372).
--
-- Hoy `claim_mission_reward` paga GEMAS. Si la gema es el valor del plan (canasta
-- mensual, #373), no puede tambien lloverse jugando.
--
-- Cambios:
--   1. Las misiones pagan ORO en lugar de gemas, y el movimiento pasa por
--      `economy_apply_currency` (con libro mayor), no por un UPDATE directo.
--   2. El contrato de respuesta mantiene `gems` (ahora siempre 0) y anade `gold`,
--      para no romper clientes viejos.
--   3. `purchase_streak_freeze_gold`: el usuario gratuito ya no tiene gemas, asi
--      que puede comprar el freeze con ORO (200). El de gemas (30) sigue igual.

-- ── 1. Recompensa de mision: oro en vez de gemas ────────────────────────────
create or replace function public.claim_mission_reward(p_instance_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.mission_instances%rowtype;
  v_mult integer;
  v_xp integer;
  v_gold integer;
  v_move jsonb;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;

  select * into v_row
    from public.mission_instances
   where id = p_instance_id and user_id = v_uid
   for update;

  if not found then
    return jsonb_build_object(
      'success', false, 'ok', false, 'already_claimed', false,
      'xp', 0, 'gems', 0, 'gold', 0, 'reason', 'not_found'
    );
  end if;

  if v_row.status <> 'completed' then
    return jsonb_build_object(
      'success', false, 'ok', false, 'already_claimed', false,
      'xp', 0, 'gems', 0, 'gold', 0, 'reason', 'not_completed'
    );
  end if;

  if v_row.is_reward_claimed then
    return jsonb_build_object(
      'success', true, 'ok', true, 'already_claimed', true,
      'xp', 0, 'gems', 0, 'gold', 0, 'reason', null
    );
  end if;

  -- Techo duro del multiplicador (#367).
  v_mult := least(2, greatest(1, coalesce(v_row.reward_multiplier, 1)));
  v_xp := coalesce(v_row.xp_reward, 0) * v_mult;
  -- #372: el valor de la recompensa se paga en oro.
  v_gold := coalesce(v_row.gem_reward, 0) * v_mult;

  update public.mission_instances
     set is_reward_claimed = true
   where id = v_row.id;

  if v_xp <> 0 then
    update public.user_language_profiles
       set xp_points = coalesce(xp_points, 0) + v_xp
     where user_id = v_uid;
  end if;

  if v_gold > 0 then
    v_move := public.economy_apply_currency(
      v_uid, 'gold', v_gold, 'mission_reward', 'mission:' || v_row.id::text);
    if coalesce((v_move ->> 'ok')::boolean, false) is not true then
      raise exception 'No se pudo acreditar la recompensa: %', v_move;
    end if;
  end if;

  insert into public.reward_history (user_id, source_type, source_id, xp_earned, gems_earned, item_code)
  values (v_uid, 'mission', v_row.id::text, v_xp, 0, v_row.item_reward);

  return jsonb_build_object(
    'success', true, 'ok', true, 'already_claimed', false,
    'xp', v_xp, 'gems', 0, 'gold', v_gold, 'reason', null
  );
end;
$$;

comment on function public.claim_mission_reward(uuid) is
  'Reclamo de mision. Contrato: {success, ok (legacy), already_claimed, xp, gems (siempre 0), gold, reason}. Multiplicador acotado a [1,2] (#367). Paga oro, no gemas (#372).';

-- ── 2. Freeze de racha con oro, para el usuario sin gemas ───────────────────
create or replace function public.purchase_streak_freeze_gold(
  p_user_id uuid,
  p_ref_key text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_cost    constant integer := 200;
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
    p_user_id, 'gold', -v_cost, 'streak_freeze_gold', p_ref_key);

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

revoke execute on function public.purchase_streak_freeze_gold(uuid, text) from public, anon;
grant execute on function public.purchase_streak_freeze_gold(uuid, text) to authenticated;

-- ── 3. Verificacion ─────────────────────────────────────────────────────────
-- Ya no debe haber recompensas de mision pagadas en gemas nuevas:
--   select count(*) from public.reward_history
--    where source_type = 'mission' and gems_earned > 0;   -- historico, no crece
--
-- Los movimientos de oro de misiones quedan auditados:
--   select reason, count(*) from public.currency_ledger
--    where reason in ('mission_reward','streak_freeze_gold') group by reason;
