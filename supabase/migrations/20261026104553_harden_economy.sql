-- Issue #93 (P-08): la economia dejaba que el cliente se acreditara importes
-- arbitrarios (add_xp/add_gold/add_gems/add_fragments) y no habia una RPC
-- segura para reclamar misiones.
--
-- Cambios:
--   1. claim_mission_reward(instance_id): importes desde mission_instances,
--      valida estado completed, no reclamada, e idempotente.
--   2. Se revoca EXECUTE a anon/authenticated en las RPC de credito libre.
--   3. add_mana_item y grant_next_seat dejan de ser invocables por el cliente.
--   4. ai_usage_logs: el dueno solo SELECT; escrituras solo service role.

create or replace function public.claim_mission_reward(p_instance_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_row public.mission_instances%rowtype;
  v_mult integer;
  v_xp integer;
  v_gems integer;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  select * into v_row
    from public.mission_instances
   where id = p_instance_id and user_id = v_uid
   for update;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'not_found');
  end if;

  if v_row.status <> 'completed' then
    return jsonb_build_object('ok', false, 'reason', 'not_completed');
  end if;

  if v_row.is_reward_claimed then
    return jsonb_build_object('ok', true, 'already_claimed', true, 'xp', 0, 'gems', 0);
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

  insert into public.reward_history (user_id, source_type, xp_earned, gems_earned, item_code)
  values (v_uid, 'mission', v_xp, v_gems, v_row.item_reward);

  return jsonb_build_object('ok', true, 'already_claimed', false, 'xp', v_xp, 'gems', v_gems);
end;
$function$;

revoke all on function public.claim_mission_reward(uuid) from public, anon;
grant execute on function public.claim_mission_reward(uuid) to authenticated;

-- Credito libre: solo servidor.
revoke execute on function public.add_xp(uuid, integer) from public, anon, authenticated;
revoke execute on function public.add_gold(uuid, integer) from public, anon, authenticated;
revoke execute on function public.add_gems(uuid, integer) from public, anon, authenticated;
revoke execute on function public.add_fragments(uuid, integer) from public, anon, authenticated;
revoke execute on function public.add_mana_item(uuid, text, text, integer) from public, anon, authenticated;
revoke execute on function public.grant_next_seat(uuid) from public, anon, authenticated;

-- Logs de uso de IA: lectura propia, escritura solo service role.
drop policy if exists usage_logs_self on public.ai_usage_logs;
drop policy if exists usage_logs_select_own on public.ai_usage_logs;
create policy usage_logs_select_own on public.ai_usage_logs
  for select to authenticated using (auth.uid() = user_id);
revoke insert, update, delete on public.ai_usage_logs from authenticated, anon;
