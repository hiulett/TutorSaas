-- P-43 (#128) — mini-chequeo periodico del nivel.
--
-- `boss_exam_status()` mantiene su contrato (P-31 / #116) y anade tres claves:
--   - `lessons_since_last_check`: lecciones superadas desde el ultimo reto del
--     jefe; si nunca hubo reto, desde `placement_assessed_at`.
--   - `check_interval`: 10 (cada ~10 lecciones).
--   - `check_due`: proporcional al aviso en la app.
--
-- El chequeo NO es automatico y NO introduce llamadas de IA nuevas: solo
-- propone repetir el examen del jefe, que sigue ejecutandose en
-- `evaluate-placement` con `action_code = oracle_eval` (mana cobrado en
-- servidor) y persiste el nivel via `apply_placement_as`. La decision sigue
-- siendo del servidor y el nivel nunca baja.
--
-- Verificado en produccion (2026-10-29) dentro de una transaccion revertida:
-- el usuario b5a2d0d9... devuelve lessons_since_last_check=5 y check_due=false;
-- anadiendo 10 lecciones sinteticas pasa a 15 y check_due=true.

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
  v_assessed boolean := false;
  v_minutes integer := 0;
  v_streak integer := 0;
  v_objectives integer := 0;
  v_lessons integer := 0;
  v_last_failure timestamptz;
  v_cooldown_until timestamptz;
  v_progress_met boolean;
  v_last_check timestamptz;
  v_lessons_since integer := 0;
  v_check_interval constant integer := 10;
  v_cooldown_hours constant integer := 12;
begin
  if v_user is null then
    return jsonb_build_object('error', 'unauthorized');
  end if;

  select upper(cl.code), upper(coalesce(ulp.game_rank, '')),
         coalesce(ulp.total_minutes, 0), coalesce(ulp.current_streak, 0),
         (ulp.placement_assessed_at is not null)
    into v_level, v_rank, v_minutes, v_streak, v_assessed
    from public.user_language_profiles ulp
    join public.cefr_levels cl on cl.id = ulp.cefr_level_id
   where ulp.user_id = v_user
     and ulp.language_id = p_language_id
   limit 1;

  -- Metas superadas: objetivos de sesion liquidados por el servidor
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

  -- Cooldown: solo despues de un intento que NO ascendio.
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

  -- P-43: referencia del mini-chequeo = ultimo reto del jefe o, si nunca hubo,
  -- el momento del placement inicial.
  select max(created_at)
    into v_last_check
    from public.boss_exam_attempts
   where user_id = v_user
     and language_id = p_language_id;

  if v_last_check is null then
    select placement_assessed_at
      into v_last_check
      from public.user_language_profiles
     where user_id = v_user
       and language_id = p_language_id
     limit 1;
  end if;

  select count(distinct lesson_id)
    into v_lessons_since
    from public.lesson_progress
   where user_id = v_user
     and status = 'passed'
     and completed_at is not null
     and (v_last_check is null or completed_at > v_last_check);

  -- "metas superadas, racha o minutos": cualquiera de las tres abre el jefe.
  v_progress_met := (v_objectives >= 6) or (v_minutes >= 30) or (v_streak >= 2);

  return jsonb_build_object(
    'current_level', case when v_assessed then v_level else null end,
    'current_rank', case when v_assessed then nullif(v_rank, '') else null end,
    'level_assessed', v_assessed,
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
      when not v_assessed then 'locked'
      when v_cooldown_until is not null then 'cooldown'
      when v_progress_met then 'ready'
      else 'locked'
    end,
    'ready', (v_assessed and v_progress_met and v_cooldown_until is null),
    -- P-43: mini-chequeo cada 10 lecciones superadas desde el ultimo reto.
    'lessons_since_last_check', v_lessons_since,
    'check_interval', v_check_interval,
    'check_due', (v_assessed and v_lessons_since >= v_check_interval),
    'requirements', jsonb_build_array(
      jsonb_build_object(
        'id', 'level',
        'met', v_assessed,
        'current', case when v_assessed then 1 else 0 end,
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
  'P-31 (#116) + P-43 (#128): requisitos del jefe y mini-chequeo cada 10 lecciones desde el ultimo reto.';
