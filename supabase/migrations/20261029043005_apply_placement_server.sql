-- Issue #73: el placement (CEFR + rango) lo aplica el servidor con validacion.
--
-- El trigger guard_language_profile revierte cefr_level_id, game_rank y los
-- campos placement_* en cualquier UPDATE hecho por authenticated/anon. Eso
-- hacia que el examen del Oraculo no persistiera el ascenso en usuarios
-- existentes. Esta funcion SECURITY DEFINER escribe con el rol del owner, asi
-- que el trigger la deja pasar, y valida el codigo CEFR y el rango.

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
declare
  v_uid uuid := auth.uid();
  v_cefr_id integer;
  v_rank text;
  v_code text;
begin
  if v_uid is null then
    raise exception 'No autorizado';
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
    v_uid, p_language_id, v_cefr_id, v_rank,
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

revoke all on function public.apply_placement(text, text, jsonb, jsonb, jsonb, text, text, integer) from public, anon;
grant execute on function public.apply_placement(text, text, jsonb, jsonb, jsonb, text, text, integer) to authenticated;
