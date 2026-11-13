-- Cerrar la acuñación de moneda desde el cliente (#405).
--
-- `add_gems(p_user_id, p_amount)`, `add_xp` y `add_fragments` son SECURITY DEFINER
-- y el unico control es que el usuario sea el dueño de la fila: el IMPORTE lo
-- ponia el cliente. Cualquier usuario autenticado podia llamar
-- `add_gems(<su uid>, 999999999)`.
--
-- No hay llamadores en `lib/` para esos metodos (verificado: 0 usos de
-- `.addGems(`/`.addXp(`/`.addFragments(`), asi que revocarlos no rompe flujos.
-- La unica via viva era la recompensa diaria, que ahora calcula el servidor.

-- ── 1. Revocar las RPC de importe libre ─────────────────────────────────────
revoke execute on function public.add_gems(uuid, integer) from public, anon, authenticated;
revoke execute on function public.add_xp(uuid, integer) from public, anon, authenticated;
revoke execute on function public.add_fragments(uuid, integer) from public, anon, authenticated;

-- `increment_pergaminos_max` tenia el mismo patron: el cliente elegia cuantos
-- pergaminos regalarse (cupo de repaso ilimitado). La recompensa diaria ya no la
-- llama: el cupo se incrementa dentro de `claim_daily_reward`. Los consumibles
-- que la usaban fueron retirados en #368.
revoke execute on function public.increment_pergaminos_max(uuid, integer) from public, anon, authenticated;

-- ── 2. Recompensa diaria calculada en servidor ──────────────────────────────
create or replace function public.claim_daily_reward()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid   uuid := auth.uid();
  v_days  integer;
  v_gems  integer;
  v_perg  integer;
  v_state public.player_daily_state%rowtype;
  v_move  jsonb;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;

  insert into public.player_daily_state (user_id, date)
  values (v_uid, current_date)
  on conflict (user_id, date) do nothing;

  select * into v_state
    from public.player_daily_state
   where user_id = v_uid and date = current_date
   for update;

  if v_state.daily_reward_claimed then
    return jsonb_build_object('success', true, 'already_claimed', true,
                              'gems', 0, 'pergaminos', 0);
  end if;

  select coalesce(current_streak, 0) into v_days
    from public.player_streaks where user_id = v_uid;
  v_days := coalesce(v_days, 0);

  v_gems := case when v_days >= 30 then 300
                 when v_days >= 14 then 100
                 when v_days >= 7  then 50
                 else 5 end;
  v_perg := case when v_days >= 30 then 15
                 when v_days >= 14 then 8
                 when v_days >= 7  then 5
                 else 2 end;

  -- Gemas por el libro mayor: idempotente por fecha y auditable.
  v_move := public.economy_apply_currency(
    v_uid, 'gems', v_gems, 'daily_reward',
    'daily_reward:' || current_date::text);

  if coalesce((v_move ->> 'ok')::boolean, false) is not true then
    return jsonb_build_object('success', false,
      'reason', coalesce(v_move ->> 'reason', 'credit_failed'));
  end if;

  update public.player_daily_state
     set daily_reward_claimed = true,
         pergaminos_max = coalesce(pergaminos_max, 5) + v_perg
   where user_id = v_uid and date = current_date;

  return jsonb_build_object('success', true, 'already_claimed', false,
                            'gems', v_gems, 'pergaminos', v_perg);
end;
$$;

revoke execute on function public.claim_daily_reward() from public, anon;
grant execute on function public.claim_daily_reward() to authenticated;

comment on function public.claim_daily_reward() is
  'Recompensa diaria calculada en servidor (gemas por racha + pergaminos), una vez por día, con libro mayor (#405).';

-- Verificacion:
-- select count(*) from public.currency_ledger where reason = 'daily_reward';
-- select daily_reward_claimed, pergaminos_max from public.player_daily_state
--  order by date desc limit 5;
