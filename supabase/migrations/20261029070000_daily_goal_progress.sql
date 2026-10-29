-- P-23 (#108): meta diaria visible.
--
-- Hasta ahora `daily_goal_minutes` solo servía para ordenar escenarios y
-- `daily_stats` no la escribía nadie (19 filas históricas, última del 24-oct),
-- así que el anillo de la meta no tenía de dónde leer.
--
-- Esta migración:
--   1. Hace que `register_practice` alimente `daily_stats` (minutos y
--      conversaciones del día). Así el gráfico semanal y el heatmap dejan de
--      estar vacíos.
--   2. Expone `get_daily_goal_progress(tz)` con los minutos reales de hoy
--      (desde `practice_sessions`, que es el libro idempotente de P-03), la
--      meta, la racha y si ya se celebró.
--   3. Expone `claim_daily_goal_celebration(tz)`, que marca la celebración una
--      sola vez al día (clave primaria usuario+día) y la devuelve solo la
--      primera vez.

begin;

-- ── 1. Celebraciones: una fila por usuario y día ──────────────────────────

create table if not exists public.daily_goal_celebrations (
  user_id uuid not null references public.users(id) on delete cascade,
  celebrated_on date not null,
  language_id integer references public.languages(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (user_id, celebrated_on)
);

alter table public.daily_goal_celebrations enable row level security;

drop policy if exists "daily_goal_celebrations_select_own" on public.daily_goal_celebrations;
create policy "daily_goal_celebrations_select_own"
  on public.daily_goal_celebrations
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Solo escriben las RPC SECURITY DEFINER.
revoke insert, update, delete on public.daily_goal_celebrations from anon, authenticated;

create index if not exists daily_goal_celebrations_user_idx
  on public.daily_goal_celebrations (user_id, celebrated_on desc);

-- ── 2. `register_practice` alimenta `daily_stats` ─────────────────────────

create or replace function public.register_practice(
  p_session_id text,
  p_minutes integer,
  p_objectives integer,
  p_tz_offset_minutes integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_profile public.user_language_profiles%rowtype;
  v_local_date date;
  v_counts boolean;
  v_streak integer;
  v_longest integer;
  v_minutes integer := greatest(0, least(coalesce(p_minutes, 0), 240));
  v_objectives integer := greatest(0, least(coalesce(p_objectives, 0), 12));
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  if p_session_id is null or length(trim(p_session_id)) = 0 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_session');
  end if;
  v_counts := v_objectives >= 1 or v_minutes >= 3;
  if not v_counts then
    return jsonb_build_object('ok', false, 'reason', 'no_practice');
  end if;
  v_local_date := (now() + make_interval(mins => coalesce(p_tz_offset_minutes, 0)))::date;
  select * into v_profile from public.user_language_profiles
   where user_id = v_uid order by language_id limit 1 for update;
  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_profile');
  end if;
  if exists (select 1 from public.practice_sessions where user_id = v_uid and session_id = p_session_id) then
    return jsonb_build_object('ok', true, 'already_registered', true, 'counted_today', true,
      'streak', coalesce(v_profile.current_streak, 0),
      'longest_streak', coalesce(v_profile.longest_streak, 0),
      'last_practice_date', v_profile.last_practice_date,
      'minutes_added', 0);
  end if;
  insert into public.practice_sessions (user_id, session_id, minutes, objectives, practiced_on)
  values (v_uid, p_session_id, v_minutes, v_objectives, v_local_date);
  if v_profile.last_practice_date is null or v_profile.last_practice_date < v_local_date - 1 then
    v_streak := 1;
  elsif v_profile.last_practice_date = v_local_date - 1 then
    v_streak := coalesce(v_profile.current_streak, 0) + 1;
  else
    v_streak := greatest(coalesce(v_profile.current_streak, 0), 1);
  end if;
  v_longest := greatest(coalesce(v_profile.longest_streak, 0), v_streak);
  update public.user_language_profiles
     set total_minutes = coalesce(total_minutes, 0) + v_minutes,
         last_practice_date = v_local_date,
         current_streak = v_streak,
         longest_streak = v_longest
   where id = v_profile.id;

  -- P-23: serie diaria real para el gráfico semanal, el heatmap y la meta.
  insert into public.daily_stats (user_id, language_id, date, minutes_practiced, conversations_count)
  values (v_uid, v_profile.language_id, v_local_date, v_minutes, 1)
  on conflict (user_id, language_id, date) do update
    set minutes_practiced = coalesce(public.daily_stats.minutes_practiced, 0)
                            + excluded.minutes_practiced,
        conversations_count = coalesce(public.daily_stats.conversations_count, 0) + 1;

  return jsonb_build_object('ok', true, 'already_registered', false, 'counted_today', true,
    'streak', v_streak, 'longest_streak', v_longest,
    'last_practice_date', v_local_date, 'minutes_added', v_minutes);
end;
$$;

-- ── 3. Progreso de la meta diaria ─────────────────────────────────────────

create or replace function public.get_daily_goal_progress(
  p_tz_offset_minutes integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_local_date date;
  v_minutes integer;
  v_goal integer;
  v_profile public.user_language_profiles%rowtype;
  v_celebrated boolean;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  v_local_date := (now() + make_interval(mins => coalesce(p_tz_offset_minutes, 0)))::date;

  -- Minutos reales del día desde el libro idempotente de P-03.
  select coalesce(sum(minutes), 0)::int into v_minutes
    from public.practice_sessions
   where user_id = v_uid and practiced_on = v_local_date;

  select coalesce(daily_goal_minutes, 15) into v_goal
    from public.user_settings
   where user_id = v_uid;

  if v_goal is null or v_goal <= 0 then
    v_goal := 15;
  end if;

  select * into v_profile
    from public.user_language_profiles
   where user_id = v_uid
   order by language_id
   limit 1;

  select exists (
    select 1 from public.daily_goal_celebrations
     where user_id = v_uid and celebrated_on = v_local_date
  ) into v_celebrated;

  return jsonb_build_object(
    'date', v_local_date,
    'minutes_today', v_minutes,
    'goal_minutes', v_goal,
    'goal_completed', v_minutes >= v_goal,
    'practiced_today', v_minutes > 0,
    'streak', coalesce(v_profile.current_streak, 0),
    'longest_streak', coalesce(v_profile.longest_streak, 0),
    'celebrated', v_celebrated
  );
end;
$$;

-- ── 4. Celebración una sola vez al día ────────────────────────────────────

create or replace function public.claim_daily_goal_celebration(
  p_tz_offset_minutes integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_local_date date;
  v_minutes integer;
  v_goal integer;
  v_language_id integer;
  v_inserted integer := 0;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  v_local_date := (now() + make_interval(mins => coalesce(p_tz_offset_minutes, 0)))::date;

  select coalesce(sum(minutes), 0)::int into v_minutes
    from public.practice_sessions
   where user_id = v_uid and practiced_on = v_local_date;

  select coalesce(daily_goal_minutes, 15) into v_goal
    from public.user_settings
   where user_id = v_uid;
  if v_goal is null or v_goal <= 0 then
    v_goal := 15;
  end if;

  if v_minutes < v_goal then
    return jsonb_build_object('claimed', false, 'reason', 'goal_not_met',
      'minutes_today', v_minutes, 'goal_minutes', v_goal);
  end if;

  select language_id into v_language_id
    from public.user_language_profiles
   where user_id = v_uid
   order by language_id
   limit 1;

  insert into public.daily_goal_celebrations (user_id, celebrated_on, language_id)
  values (v_uid, v_local_date, v_language_id)
  on conflict (user_id, celebrated_on) do nothing;

  get diagnostics v_inserted = row_count;

  return jsonb_build_object(
    'claimed', v_inserted > 0,
    'reason', case when v_inserted > 0 then null else 'already_celebrated' end,
    'minutes_today', v_minutes,
    'goal_minutes', v_goal
  );
end;
$$;

revoke all on function public.get_daily_goal_progress(integer) from public, anon;
grant execute on function public.get_daily_goal_progress(integer) to authenticated;

revoke all on function public.claim_daily_goal_celebration(integer) from public, anon;
grant execute on function public.claim_daily_goal_celebration(integer) to authenticated;

commit;
