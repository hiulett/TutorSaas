-- Issue #73: el placement se calcula y persiste en el servidor.
--
-- Antes de esta migración el cliente calculaba el CEFR y lo escribía con
-- `apply_placement` (RPC expuesta a `authenticated`), así que cualquiera podía
-- asignarse C2. Ahora:
--
--   1. `apply_placement_as()` es la única vía de escritura del nivel evaluado y
--      solo la puede ejecutar `service_role` (la Edge Function
--      `evaluate-placement`). `apply_placement()` queda como envoltorio cerrado
--      al cliente para no romper builds antiguas con un error de permisos.
--   2. `apply_self_declared_level()` permite una única autodeclaración de nivel
--      durante el onboarding (la UX no cambia), marcada como `self_declared`.
--      Una vez que el Oráculo evalúa (`placement_assessed_at` no nulo), la
--      autodeclaración se rechaza.
--   3. `guard_language_profile()` también protege el INSERT: sin esto, el
--      cliente podía crear su fila con `cefr_level_id` arbitrario.

begin;

-- ── 1. Escritura del placement evaluado (solo service_role) ────────────────

create or replace function public.apply_placement_as(
  p_user_id uuid,
  p_cefr_code text,
  p_rank text,
  p_scores jsonb default '{}'::jsonb,
  p_strengths jsonb default '[]'::jsonb,
  p_weaknesses jsonb default '[]'::jsonb,
  p_explanation text default null,
  p_recommended_focus text default null,
  p_language_id integer default 1
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cefr_id integer;
  v_rank text;
  v_code text;
begin
  if p_user_id is null then
    raise exception 'Usuario requerido';
  end if;

  select id, code into v_cefr_id, v_code
    from public.cefr_levels
   where upper(code) = upper(trim(p_cefr_code))
   limit 1;

  if v_cefr_id is null then
    raise exception 'CEFR invalido';
  end if;

  v_rank := upper(trim(coalesce(p_rank, '')));
  if v_rank not in ('F','E','D','C','B','A','S','SS','SSS') then
    v_rank := case upper(v_code)
      when 'PRE-A1' then 'F' when 'A1' then 'E' when 'A2' then 'D'
      when 'B1' then 'C' when 'B2' then 'B' when 'C1' then 'A' when 'C2' then 'S'
      else 'E' end;
  end if;

  insert into public.user_language_profiles (
    user_id, language_id, cefr_level_id, game_rank,
    placement_scores, placement_strengths, placement_weaknesses,
    placement_explanation, placement_recommended_focus, placement_assessed_at
  ) values (
    p_user_id, p_language_id, v_cefr_id, v_rank,
    coalesce(p_scores, '{}'::jsonb), coalesce(p_strengths, '[]'::jsonb),
    coalesce(p_weaknesses, '[]'::jsonb), p_explanation, p_recommended_focus, now()
  )
  on conflict (user_id, language_id) do update
    set cefr_level_id = excluded.cefr_level_id,
        game_rank = excluded.game_rank,
        placement_scores = excluded.placement_scores,
        placement_strengths = excluded.placement_strengths,
        placement_weaknesses = excluded.placement_weaknesses,
        placement_explanation = excluded.placement_explanation,
        placement_recommended_focus = excluded.placement_recommended_focus,
        placement_assessed_at = now();

  return jsonb_build_object('success', true, 'cefr', v_code, 'rank', v_rank);
end;
$$;

revoke all on function public.apply_placement_as(uuid, text, text, jsonb, jsonb, jsonb, text, text, integer)
  from public, anon, authenticated;
grant execute on function public.apply_placement_as(uuid, text, text, jsonb, jsonb, jsonb, text, text, integer)
  to service_role;

-- Envoltorio heredado: delega en `apply_placement_as` con `auth.uid()` y queda
-- cerrado a los roles del cliente. Las builds antiguas que lo invocan reciben
-- un error de permisos (la app lo ignora y conserva el nivel que ya tenía).
create or replace function public.apply_placement(
  p_cefr_code text,
  p_rank text,
  p_scores jsonb default '{}'::jsonb,
  p_strengths jsonb default '[]'::jsonb,
  p_weaknesses jsonb default '[]'::jsonb,
  p_explanation text default null,
  p_recommended_focus text default null,
  p_language_id integer default 1
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'No autorizado';
  end if;
  return public.apply_placement_as(
    auth.uid(), p_cefr_code, p_rank, p_scores, p_strengths,
    p_weaknesses, p_explanation, p_recommended_focus, p_language_id
  );
end;
$$;

revoke all on function public.apply_placement(text, text, jsonb, jsonb, jsonb, text, text, integer)
  from public, anon, authenticated;

-- ── 2. Autodeclaración de nivel del onboarding (una sola vez) ──────────────

create or replace function public.apply_self_declared_level(
  p_cefr_code text,
  p_language_id integer default 1
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_id integer;
  v_code text;
  v_rank text;
  v_assessed timestamptz;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  select id, code into v_id, v_code
    from public.cefr_levels
   where upper(code) = upper(trim(p_cefr_code))
   limit 1;

  if v_id is null then
    raise exception 'CEFR invalido';
  end if;

  select placement_assessed_at into v_assessed
    from public.user_language_profiles
   where user_id = v_uid and language_id = p_language_id;

  if v_assessed is not null then
    raise exception 'El nivel ya fue evaluado por el Oraculo: no se puede autodeclarar';
  end if;

  v_rank := case upper(v_code)
    when 'PRE-A1' then 'F' when 'A1' then 'E' when 'A2' then 'D'
    when 'B1' then 'C' when 'B2' then 'B' when 'C1' then 'A' when 'C2' then 'S'
    else 'E' end;

  insert into public.user_language_profiles (
    user_id, language_id, cefr_level_id, game_rank, placement_scores
  ) values (
    v_uid, p_language_id, v_id, v_rank, jsonb_build_object('source', 'self_declared')
  )
  on conflict (user_id, language_id) do update
    set cefr_level_id = excluded.cefr_level_id,
        game_rank = excluded.game_rank,
        placement_scores = excluded.placement_scores
    where public.user_language_profiles.placement_assessed_at is null;

  return jsonb_build_object('cefr', v_code, 'rank', v_rank, 'source', 'self_declared');
end;
$$;

revoke all on function public.apply_self_declared_level(text, integer) from public, anon;
grant execute on function public.apply_self_declared_level(text, integer) to authenticated;

-- ── 3. Guardia de INSERT ───────────────────────────────────────────────────
--
-- El UPDATE ya se revertía; el INSERT no. Un cliente podía crear su fila con
-- CEFR C2 y rango SSS. Ahora un INSERT desde `authenticated`/`anon` entra con
-- el nivel inicial (A1/E) y sin provenance de evaluación; el nivel real lo
-- asignan `apply_self_declared_level` (onboarding) y `apply_placement_as`
-- (Oráculo), ambos SECURITY DEFINER.

create or replace function public.guard_language_profile()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_default_cefr integer;
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;

  if tg_op = 'INSERT' then
    select id into v_default_cefr from public.cefr_levels where code = 'A1' limit 1;

    new.cefr_level_id := coalesce(v_default_cefr, new.cefr_level_id);
    new.game_rank := 'E';
    new.xp_points := 0;
    new.total_gold := coalesce(new.total_gold, 0);
    new.total_gems := 0;
    new.fragments := 0;
    new.aura_xp := 0;
    new.skill_radar := null;
    new.prestige_title_code := null;
    new.current_streak := 0;
    new.longest_streak := 0;
    new.total_minutes := 0;
    new.last_practice_date := null;
    new.placement_scores := null;
    new.placement_strengths := null;
    new.placement_weaknesses := null;
    new.placement_explanation := null;
    new.placement_recommended_focus := null;
    new.placement_assessed_at := null;

    return new;
  end if;

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
$$;

commit;
