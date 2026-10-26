-- Issue #88 (P-03): la racha y los minutos se calculaban en el cliente y el
-- trigger de guarda descartaba esas escrituras. Ahora hay una sola fuente de
-- verdad en servidor y una RPC idempotente por sesion.
--
-- Reglas acordadas:
--   * Cuenta como practica del dia si se cumplio >= 1 objetivo o >= 3 minutos.
--   * El "dia" es el local del usuario: el cliente envia su offset en minutos.
--   * Practicar dos veces el mismo dia no sube la racha.
--   * Saltarse un dia reinicia a 1 (los freezes quedan fuera de este cambio).
--   * `longest_streak` nunca disminuye.

create table if not exists public.practice_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  session_id text not null,
  minutes integer not null default 0 check (minutes >= 0 and minutes <= 240),
  objectives integer not null default 0 check (objectives >= 0 and objectives <= 12),
  practiced_on date not null,
  created_at timestamptz not null default now(),
  unique (user_id, session_id)
);

alter table public.practice_sessions enable row level security;

drop policy if exists practice_sessions_select_own on public.practice_sessions;
create policy practice_sessions_select_own on public.practice_sessions
  for select to authenticated using (auth.uid() = user_id);

revoke insert, update, delete on public.practice_sessions from authenticated, anon;

create or replace function public.register_practice(
  p_session_id text,
  p_minutes integer,
  p_objectives integer,
  p_tz_offset_minutes integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = 'public'
as $function$
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

  select * into v_profile
    from public.user_language_profiles
   where user_id = v_uid
   order by language_id
   limit 1
   for update;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_profile');
  end if;

  if exists (
    select 1 from public.practice_sessions
     where user_id = v_uid and session_id = p_session_id
  ) then
    return jsonb_build_object(
      'ok', true,
      'already_registered', true,
      'counted_today', true,
      'streak', coalesce(v_profile.current_streak, 0),
      'longest_streak', coalesce(v_profile.longest_streak, 0),
      'last_practice_date', v_profile.last_practice_date,
      'minutes_added', 0
    );
  end if;

  insert into public.practice_sessions (user_id, session_id, minutes, objectives, practiced_on)
  values (v_uid, p_session_id, v_minutes, v_objectives, v_local_date);

  if v_profile.last_practice_date is null
     or v_profile.last_practice_date < v_local_date - 1 then
    v_streak := 1;
  elsif v_profile.last_practice_date = v_local_date - 1 then
    v_streak := coalesce(v_profile.current_streak, 0) + 1;
  else
    -- Mismo dia (o fecha futura por desfase de reloj): no incrementa.
    v_streak := greatest(coalesce(v_profile.current_streak, 0), 1);
  end if;

  v_longest := greatest(coalesce(v_profile.longest_streak, 0), v_streak);

  update public.user_language_profiles
     set total_minutes = coalesce(total_minutes, 0) + v_minutes,
         last_practice_date = v_local_date,
         current_streak = v_streak,
         longest_streak = v_longest
   where id = v_profile.id;

  return jsonb_build_object(
    'ok', true,
    'already_registered', false,
    'counted_today', true,
    'streak', v_streak,
    'longest_streak', v_longest,
    'last_practice_date', v_local_date,
    'minutes_added', v_minutes
  );
end;
$function$;

revoke all on function public.register_practice(text, integer, integer, integer) from public, anon;
grant execute on function public.register_practice(text, integer, integer, integer) to authenticated;
