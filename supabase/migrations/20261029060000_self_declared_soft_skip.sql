-- #73 (ajuste): el onboarding llama a `apply_self_declared_level` también cuando
-- el usuario acaba de completar el examen del Oráculo (el nivel ya está
-- evaluado). Lanzar excepción en ese caso ensuciaba el log de errores con un
-- fallo esperado; ahora la función devuelve `skipped` y no toca nada.
--
-- La protección real es la condición `placement_assessed_at is null` del
-- `on conflict do update`, así que el comportamiento seguro no cambia.

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
    return jsonb_build_object(
      'cefr', v_code,
      'skipped', 'already_assessed'
    );
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
