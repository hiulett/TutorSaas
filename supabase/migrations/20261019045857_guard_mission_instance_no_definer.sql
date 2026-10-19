-- Issue #85: el guard de misiones protegía las recompensas pero dejaba
-- escribir `status`, `current_value` y `completed_at`. Con RLS de escritura,
-- un cliente podía marcar una misión como completada sin jugar y reclamar el
-- premio (claimReward solo exige `status = 'completed'`).
--
-- Se quita SECURITY DEFINER para que `current_user` refleje a quien escribe:
--   * cliente (PostgREST)                  → 'authenticated' → se preserva
--   * advance_missions_for_user (definer)   → 'postgres'      → pasa sin cambios
--
-- Se comprobó que con el definer el guard no podía distinguirlos y no
-- bloqueaba nada.

create or replace function public.guard_mission_instance()
returns trigger
language plpgsql
set search_path to 'public'
as $function$
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;

  if tg_op = 'INSERT' then
    new.status := 'active';
    new.current_value := 0;
    new.is_reward_claimed := false;
    new.completed_at := null;
    return new;
  end if;

  -- UPDATE directo del cliente: solo puede reclamar, no avanzar.
  new.xp_reward := old.xp_reward;
  new.gem_reward := old.gem_reward;
  new.target_value := old.target_value;
  new.objective_type := old.objective_type;
  new.user_id := old.user_id;
  new.status := old.status;
  new.current_value := old.current_value;
  new.completed_at := old.completed_at;

  if new.is_reward_claimed and not old.is_reward_claimed and old.status <> 'completed' then
    raise exception 'La misión no está completada';
  end if;

  return new;
end;
$function$;
