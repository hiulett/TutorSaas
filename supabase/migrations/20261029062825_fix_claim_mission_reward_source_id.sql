-- Issue #109 (P-24) · Fix del reclamo de recompensas de misión.
-- Versión real registrada por Supabase: 20261029062825
--
-- Bug reproducido en producción (29-oct-2026) dentro de una transacción con
-- rollback: claim_mission_reward() insertaba en reward_history sin source_id,
-- columna NOT NULL → ERROR 23502 y ningún reclamo podía completarse (7
-- misiones completadas, 0 reclamadas).
--
-- Fix: source_id = id de la instancia. Se mantiene SECURITY DEFINER,
-- search_path=public, el bloqueo FOR UPDATE y el short-circuit
-- already_claimed (idempotencia: un segundo reclamo devuelve xp/gems 0).
create or replace function public.claim_mission_reward(p_instance_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_row public.mission_instances%rowtype;
  v_mult integer; v_xp integer; v_gems integer;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;
  select * into v_row from public.mission_instances
   where id = p_instance_id and user_id = v_uid for update;
  if not found then return jsonb_build_object('ok', false, 'reason', 'not_found'); end if;
  if v_row.status <> 'completed' then
    return jsonb_build_object('ok', false, 'reason', 'not_completed');
  end if;
  if v_row.is_reward_claimed then
    return jsonb_build_object('ok', true, 'already_claimed', true, 'xp', 0, 'gems', 0);
  end if;
  v_mult := greatest(1, coalesce(v_row.reward_multiplier, 1));
  v_xp := coalesce(v_row.xp_reward, 0) * v_mult;
  v_gems := coalesce(v_row.gem_reward, 0) * v_mult;
  update public.mission_instances set is_reward_claimed = true where id = v_row.id;
  update public.user_language_profiles
     set xp_points = coalesce(xp_points, 0) + v_xp,
         total_gems = coalesce(total_gems, 0) + v_gems
   where user_id = v_uid;
  insert into public.reward_history (user_id, source_type, source_id, xp_earned, gems_earned, item_code)
  values (v_uid, 'mission', v_row.id::text, v_xp, v_gems, v_row.item_reward);
  return jsonb_build_object('ok', true, 'already_claimed', false, 'xp', v_xp, 'gems', v_gems);
end;
$function$;
