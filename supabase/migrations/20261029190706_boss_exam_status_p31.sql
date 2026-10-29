-- P-31 (#116) — Requisitos de entrada al "Jefe de mazmorra".
--
-- `boss_exam_status()` calcula en el servidor (SECURITY DEFINER, `auth.uid()`)
-- si el jugador puede retar al Oráculo: nivel actual asignado, práctica
-- acumulada (metas superadas / minutos / racha) y cooldown tras un intento
-- fallido. La UI solo pinta lo que devuelve esta función; no inventa estado.
--
-- Umbrales (deliberadamente bajos para no cerrar la única vía de progreso):
--   - metas superadas >= 6  (session_reward_ledger.objectives)
--   - o minutos practicados >= 30 (user_language_profiles.total_minutes)
--   - o racha actual >= 2 días (user_language_profiles.current_streak)
--   - cooldown: 12 h después de un intento 'maintained'

create or replace function public.boss_exam_status(p_language_id integer default 1)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_user uuid := auth.uid();
  v_level text;
  v_rank text;
  v_minutes integer := 0;
  v_streak integer := 0;
  v_objectives integer := 0;
  v_lessons integer := 0;
  v_last_failure timestamptz;
  v_cooldown_until timestamptz;
  v_progress_met boolean;
  v_cooldown_hours constant integer := 12;
begin
  if v_user is null then
    return jsonb_build_object('error', 'unauthorized');
  end if;

  select upper(cl.code), upper(coalesce(ulp.game_rank, '')),
         coalesce(ulp.total_minutes, 0), coalesce(ulp.current_streak, 0)
    into v_level, v_rank, v_minutes, v_streak
    from public.user_language_profiles ulp
    join public.cefr_levels cl on cl.id = ulp.cefr_level_id
   where ulp.user_id = v_user
     and ulp.language_id = p_language_id
   limit 1;

  -- Metas superadas: objetivos de sesión liquidados por el servidor
  -- (`apply_session_rewards` escribe `session_reward_ledger`).
  select coalesce(sum(objectives), 0)::integer
    into v_objectives
    from public.session_reward_ledger
   where user_id = v_user
     and language_id = p_language_id;

  -- Lecciones superadas del nivel actual (prefijo del lesson_id: a2_*, prea1_*).
  if v_level is not null then
    select count(distinct lesson_id)
      into v_lessons
      from public.lesson_progress
     where user_id = v_user
       and status = 'passed'
       and lesson_id like lower(replace(v_level, '-', '')) || '_%';
  end if;

  -- Cooldown: solo después de un intento que NO ascendió.
  select max(created_at)
    into v_last_failure
    from public.boss_exam_attempts
   where user_id = v_user
     and language_id = p_language_id
     and decision = 'maintained';

  if v_last_failure is not null
     and v_last_failure + make_interval(hours => v_cooldown_hours) > now() then
    v_cooldown_until := v_last_failure + make_interval(hours => v_cooldown_hours);
  end if;

  -- "metas superadas, racha o minutos": cualquiera de las tres abre el jefe.
  v_progress_met := (v_objectives >= 6) or (v_minutes >= 30) or (v_streak >= 2);

  return jsonb_build_object(
    'current_level', v_level,
    'current_rank', nullif(v_rank, ''),
    'language_id', p_language_id,
    'objectives_completed', v_objectives,
    'objectives_target', 6,
    'minutes_practiced', v_minutes,
    'minutes_target', 30,
    'current_streak', v_streak,
    'streak_target', 2,
    'lessons_passed', v_lessons,
    'progress_met', v_progress_met,
    'cooldown_hours', v_cooldown_hours,
    'cooldown_until', v_cooldown_until,
    'state', case
      when v_level is null then 'locked'
      when v_cooldown_until is not null then 'cooldown'
      when v_progress_met then 'ready'
      else 'locked'
    end,
    'ready', (v_level is not null and v_progress_met and v_cooldown_until is null),
    'requirements', jsonb_build_array(
      jsonb_build_object(
        'id', 'level',
        'met', v_level is not null,
        'current', case when v_level is null then 0 else 1 end,
        'target', 1
      ),
      jsonb_build_object(
        'id', 'practice',
        'met', v_progress_met,
        'current', greatest(v_objectives, v_minutes, v_streak),
        'target', case
          when v_objectives >= 6 then 6
          when v_minutes >= 30 then 30
          else 2
        end
      ),
      jsonb_build_object(
        'id', 'cooldown',
        'met', v_cooldown_until is null,
        'current', case when v_cooldown_until is null then 0 else 1 end,
        'target', 1
      )
    ),
    'server_time', now()
  );
end;
$function$;

revoke all on function public.boss_exam_status(integer) from public;
grant execute on function public.boss_exam_status(integer) to authenticated;

comment on function public.boss_exam_status(integer) is
  'P-31 (#116): requisitos de entrada al jefe de mazmorra, calculados con datos del servidor.';
