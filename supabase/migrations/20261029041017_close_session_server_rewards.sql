-- Issue #4: cierre de sesion con recompensas calculadas en servidor.
--
-- Antes `apply_session_rewards` recibia `p_objectives`, `p_minutes` y
-- `p_level_code` del cliente: validaba rangos e idempotencia, pero un cliente
-- modificado podia inflar objetivos/minutos por cada session_id.
--
-- `close_session` deriva todo de hechos verificables:
--   - la conversacion debe existir y pertenecer al usuario;
--   - los minutos salen de started_at/ended_at de la conversacion;
--   - los objetivos, de user_scenario_goals completados de esa conversacion;
--   - el nivel y el idioma, de user_language_profiles.
-- Sigue siendo idempotente por conversacion (session_reward_ledger).

create or replace function public.close_session(p_session_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_conv public.conversations%rowtype;
  v_dup public.session_reward_ledger%rowtype;
  v_objectives integer;
  v_minutes integer;
  v_level text;
  v_bonus integer;
  v_xp integer;
  v_gold integer;
  v_fragments integer;
  v_language_id integer;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  select * into v_conv
    from public.conversations
   where id = p_session_id and user_id = v_uid and deleted_at is null;

  if not found then
    raise exception 'Sesion no valida';
  end if;

  select * into v_dup
    from public.session_reward_ledger
   where session_id = p_session_id::text;

  if found then
    return jsonb_build_object(
      'success', true, 'duplicated', true,
      'xp', v_dup.xp_awarded, 'gold', v_dup.gold_awarded,
      'fragments', v_dup.fragments_awarded
    );
  end if;

  select least(12, count(*)) into v_objectives
    from public.user_scenario_goals
   where conversation_id = p_session_id
     and user_id = v_uid
     and is_completed;

  v_minutes := greatest(0, least(240,
    ceil(extract(epoch from (coalesce(v_conv.ended_at, now()) - v_conv.started_at)) / 60)::int));

  v_language_id := coalesce(v_conv.language_id, 1);

  select coalesce(l.code, 'A1') into v_level
    from public.user_language_profiles p
    left join public.cefr_levels l on l.id = p.cefr_level_id
   where p.user_id = v_uid and p.language_id = v_language_id
   limit 1;
  v_level := coalesce(v_level, 'A1');

  v_bonus := case upper(v_level)
               when 'A2' then 1 when 'B1' then 2 when 'B2' then 3
               when 'C1' then 4 when 'C2' then 5 else 0 end;

  -- Se mantiene la regla efectiva anterior: sin objetivos no hay XP.
  v_xp        := case when v_objectives > 0 then v_minutes * 10 else 0 end;
  v_gold      := v_objectives * (10 + v_bonus);
  v_fragments := v_objectives * (5 + v_bonus);

  insert into public.session_reward_ledger (
    session_id, user_id, language_id, objectives, minutes,
    xp_awarded, gold_awarded, fragments_awarded
  ) values (
    p_session_id::text, v_uid, v_language_id, v_objectives, v_minutes,
    v_xp, v_gold, v_fragments
  );

  update public.user_language_profiles
     set xp_points  = coalesce(xp_points, 0) + v_xp,
         total_gold = coalesce(total_gold, 0) + v_gold,
         fragments  = coalesce(fragments, 0) + v_fragments
   where user_id = v_uid and language_id = v_language_id;

  return jsonb_build_object(
    'success', true, 'duplicated', false,
    'xp', v_xp, 'gold', v_gold, 'fragments', v_fragments
  );
end;
$$;

revoke all on function public.close_session(uuid) from public, anon;
grant execute on function public.close_session(uuid) to authenticated;

-- La version que confiaba en importes del cliente queda solo para service_role.
revoke execute on function public.apply_session_rewards(uuid, text, integer, integer, text, integer) from authenticated;
