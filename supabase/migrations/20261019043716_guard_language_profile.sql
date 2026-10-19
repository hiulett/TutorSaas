-- Issue #73 (y familia de #3): el cliente podía reescribir su propio perfil de
-- aprendizaje: cefr_level_id, game_rank, xp_points, total_gold, total_gems,
-- fragments, aura_xp y todo el bloque de placement.
--
-- El trigger distingue quién escribe:
--   * cliente directo (PostgREST)      → current_user = 'authenticated'
--   * funciones SECURITY DEFINER        → current_user = dueño (postgres)
--
-- IMPORTANTE: la función NO puede ser SECURITY DEFINER. Si lo fuera,
-- `current_user` sería el dueño también para el cliente y el guard no
-- aplicaría (se comprobó: la primera versión no bloqueaba nada).
--
-- El INSERT inicial se permite: es el placement del onboarding.

create or replace function public.guard_language_profile()
returns trigger
language plpgsql
set search_path to 'public'
as $function$
begin
  -- RPC y service role: sin restricciones.
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;

  -- Alta inicial: puede fijar el nivel (placement).
  if tg_op = 'INSERT' then
    return new;
  end if;

  -- UPDATE directo del cliente: se preservan los campos sensibles.
  new.cefr_level_id := old.cefr_level_id;
  new.game_rank := old.game_rank;
  new.xp_points := old.xp_points;
  new.total_gold := old.total_gold;
  new.total_gems := old.total_gems;
  new.fragments := old.fragments;
  new.aura_xp := old.aura_xp;
  new.prestige_title_code := old.prestige_title_code;
  new.skill_radar := old.skill_radar;
  new.current_streak := old.current_streak;
  new.longest_streak := old.longest_streak;
  new.total_minutes := old.total_minutes;
  new.last_practice_date := old.last_practice_date;
  new.placement_scores := old.placement_scores;
  new.placement_strengths := old.placement_strengths;
  new.placement_weaknesses := old.placement_weaknesses;
  new.placement_explanation := old.placement_explanation;
  new.placement_recommended_focus := old.placement_recommended_focus;
  new.placement_assessed_at := old.placement_assessed_at;

  return new;
end;
$function$;

drop trigger if exists trg_guard_language_profile on public.user_language_profiles;
create trigger trg_guard_language_profile
  before insert or update on public.user_language_profiles
  for each row execute function public.guard_language_profile();
