-- P-43 (#128) — informe semanal del progreso.
--
-- `get_weekly_report()` calcula en servidor el informe de una semana con datos
-- reales:
--   - `user_vocabulary` / `vocabulary_reviews`: palabras nuevas, repasadas y
--     dominadas.
--   - `corrections`: errores corregidos y el tipo mas frecuente.
--   - `practice_sessions`: minutos, sesiones y dias practicados.
--   - `lesson_progress`: lecciones superadas.
--   - `user_language_profiles` + `cefr_levels`: nivel estimado.
--
-- Si la semana no tiene actividad `has_data` viene en false y la UI lo dice:
-- aqui no se rellenan ceros falsos.
--
-- La semana se corta en lunes con el desfase horario del cliente
-- (`p_tz_offset_minutes`), igual que `get_daily_goal_progress` y
-- `register_practice`, para que "semana" signifique lo mismo en toda la app.
--
-- Verificado en produccion (2026-10-29): el usuario b5a2d0d9... devuelve
-- has_data=false en la semana en curso, y en la semana del 2026-08-17 devuelve
-- 24 palabras nuevas y 18 lecciones, que coinciden con los conteos directos.

create index if not exists practice_sessions_user_practiced_idx
  on public.practice_sessions (user_id, practiced_on);

create or replace function public.get_weekly_report(
  p_week_offset integer default 0,
  p_tz_offset_minutes integer default 0,
  p_language_id integer default 1
)
returns jsonb
language plpgsql
stable security definer
set search_path = public
as $function$
declare
  v_user uuid := auth.uid();
  v_offset integer := greatest(-840, least(coalesce(p_tz_offset_minutes, 0), 840));
  v_week integer := greatest(0, least(coalesce(p_week_offset, 0), 52));
  v_start date;
  v_end date;
  v_start_ts timestamptz;
  v_end_ts timestamptz;
  v_level text;
  v_level_name text;
  v_rank text;
  v_assessed boolean := false;
begin
  if v_user is null then
    raise exception 'No autorizado';
  end if;

  v_start := date_trunc('week', (now() + make_interval(mins => v_offset))::date)::date
             - (v_week * 7);
  v_end := v_start + 6;
  v_start_ts := (v_start::timestamp - make_interval(mins => v_offset)) at time zone 'UTC';
  v_end_ts := ((v_end + 1)::timestamp - make_interval(mins => v_offset)) at time zone 'UTC';

  select upper(cl.code), cl.name, ulp.game_rank,
         (ulp.placement_assessed_at is not null)
    into v_level, v_level_name, v_rank, v_assessed
    from public.user_language_profiles ulp
    left join public.cefr_levels cl on cl.id = ulp.cefr_level_id
   where ulp.user_id = v_user
   order by (ulp.language_id = coalesce(p_language_id, 1)) desc, ulp.language_id
   limit 1;

  return (
    with bounds as (
      select v_start as cur_start_day, v_end as cur_end_day,
             v_start_ts as cur_start_ts, v_end_ts as cur_end_ts,
             v_start - 7 as prev_start_day, v_end - 7 as prev_end_day,
             v_start_ts - interval '7 days' as prev_start_ts,
             v_start_ts as prev_end_ts
    ),
    cur as (
      select
        (select count(*)
           from public.user_vocabulary
          where user_id = v_user and deleted_at is null
            and created_at >= b.cur_start_ts and created_at < b.cur_end_ts) as new_words,
        (select count(*)
           from public.user_vocabulary
          where user_id = v_user and is_mastered
            and last_reviewed_at >= b.cur_start_ts
            and last_reviewed_at < b.cur_end_ts) as words_mastered,
        (select count(distinct vocabulary_id)
           from public.vocabulary_reviews
          where user_id = v_user
            and reviewed_at >= b.cur_start_ts and reviewed_at < b.cur_end_ts) as words_reviewed,
        (select count(*)
           from public.corrections
          where user_id = v_user
            and created_at >= b.cur_start_ts and created_at < b.cur_end_ts) as corrections,
        (select error_type
           from public.corrections
          where user_id = v_user and error_type is not null
            and created_at >= b.cur_start_ts and created_at < b.cur_end_ts
          group by error_type
          order by count(*) desc, error_type
          limit 1) as top_error_type,
        (select count(*)
           from public.lesson_progress
          where user_id = v_user and status = 'passed'
            and completed_at >= b.cur_start_ts and completed_at < b.cur_end_ts) as lessons_completed,
        (select coalesce(sum(minutes), 0)::int
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.cur_start_day and b.cur_end_day) as minutes,
        (select count(*)
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.cur_start_day and b.cur_end_day) as sessions,
        (select count(distinct practiced_on)
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.cur_start_day and b.cur_end_day) as practice_days
      from bounds b
    ),
    prev as (
      select
        (select count(*)
           from public.user_vocabulary
          where user_id = v_user and deleted_at is null
            and created_at >= b.prev_start_ts and created_at < b.prev_end_ts) as new_words,
        (select count(*)
           from public.corrections
          where user_id = v_user
            and created_at >= b.prev_start_ts and created_at < b.prev_end_ts) as corrections,
        (select count(*)
           from public.lesson_progress
          where user_id = v_user and status = 'passed'
            and completed_at >= b.prev_start_ts and completed_at < b.prev_end_ts) as lessons_completed,
        (select coalesce(sum(minutes), 0)::int
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.prev_start_day and b.prev_end_day) as minutes
      from bounds b
    )
    select jsonb_build_object(
      'week_offset', v_week,
      'start_date', v_start,
      'end_date', v_end,
      'language_id', p_language_id,
      'has_data', (c.new_words + c.words_reviewed + c.corrections
                   + c.lessons_completed + c.sessions) > 0,
      'new_words', c.new_words,
      'words_reviewed', c.words_reviewed,
      'words_mastered', c.words_mastered,
      'corrections', c.corrections,
      'top_error_type', c.top_error_type,
      'lessons_completed', c.lessons_completed,
      'minutes', c.minutes,
      'sessions', c.sessions,
      'practice_days', c.practice_days,
      'level', case when v_assessed then v_level else null end,
      'level_name', case when v_assessed then v_level_name else null end,
      'level_assessed', v_assessed,
      'game_rank', case when v_assessed then nullif(v_rank, '') else null end,
      'previous', jsonb_build_object(
        'new_words', p.new_words,
        'corrections', p.corrections,
        'lessons_completed', p.lessons_completed,
        'minutes', p.minutes
      ),
      'server_time', now()
    )
    from cur c, prev p
  );
end;
$function$;

revoke all on function public.get_weekly_report(integer, integer, integer) from public, anon;
grant execute on function public.get_weekly_report(integer, integer, integer) to authenticated;

comment on function public.get_weekly_report(integer, integer, integer) is
  'P-43 (#128): informe semanal (palabras, correcciones, minutos, lecciones y nivel) calculado en servidor; has_data=false cuando la semana no tiene actividad.';
