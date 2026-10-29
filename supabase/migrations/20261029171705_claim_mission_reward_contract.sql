-- Normaliza el contrato del reclamo de misiones.
--
-- Antes: {ok, already_claimed, xp, gems, reason}
-- Ahora: {success, ok (alias legacy), already_claimed, xp, gems, reason}
--
-- `success` es la clave canonica (igual que en las compensaciones, #208); `ok`
-- se mantiene como alias deprecado para no romper builds antiguas.
--
-- `apply_session_rewards` queda marcada como DEPRECADA: exige
-- `auth.uid() = p_user_id` pero su EXECUTE esta revocado a `authenticated`, asi
-- que nadie puede llamarla. La via real es `close_session(uuid)`.

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
  v_gems integer;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;

  select * into v_row
    from public.mission_instances
   where id = p_instance_id and user_id = v_uid
   for update;

  if not found then
    return jsonb_build_object(
      'success', false, 'ok', false, 'already_claimed', false,
      'xp', 0, 'gems', 0, 'reason', 'not_found'
    );
  end if;

  if v_row.status <> 'completed' then
    return jsonb_build_object(
      'success', false, 'ok', false, 'already_claimed', false,
      'xp', 0, 'gems', 0, 'reason', 'not_completed'
    );
  end if;

  if v_row.is_reward_claimed then
    return jsonb_build_object(
      'success', true, 'ok', true, 'already_claimed', true,
      'xp', 0, 'gems', 0, 'reason', null
    );
  end if;

  v_mult := greatest(1, coalesce(v_row.reward_multiplier, 1));
  v_xp := coalesce(v_row.xp_reward, 0) * v_mult;
  v_gems := coalesce(v_row.gem_reward, 0) * v_mult;

  update public.mission_instances
     set is_reward_claimed = true
   where id = v_row.id;

  update public.user_language_profiles
     set xp_points = coalesce(xp_points, 0) + v_xp,
         total_gems = coalesce(total_gems, 0) + v_gems
   where user_id = v_uid;

  insert into public.reward_history (user_id, source_type, source_id, xp_earned, gems_earned, item_code)
  values (v_uid, 'mission', v_row.id::text, v_xp, v_gems, v_row.item_reward);

  return jsonb_build_object(
    'success', true, 'ok', true, 'already_claimed', false,
    'xp', v_xp, 'gems', v_gems, 'reason', null
  );
end;
$$;

comment on function public.claim_mission_reward(uuid) is
  'Reclamo de mision. Contrato: {success, ok (legacy), already_claimed, xp, gems, reason}.';

comment on function public.apply_session_rewards(uuid, text, integer, integer, text, integer) is
  'DEPRECADA. Requiere auth.uid() = p_user_id pero su EXECUTE esta revocado a authenticated: nadie puede llamarla. Usar close_session(uuid), que deriva objetivos y minutos del servidor.';
