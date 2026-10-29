-- Issue #107 (P-22): canal de retorno por email para usuarios inactivos.
--
-- Que hace este cambio:
--   * `user_settings.reactivation_emails` (opt-out, default true) con token de
--     baja propio. La politica `user_settings_self` (FOR ALL del dueno) ya
--     cubre lectura y escritura de las columnas nuevas.
--   * `reactivation_emails`: registro de cada intento de envio. Sin PII (no
--     guarda el email, solo el id del usuario y el id del proveedor).
--     `unique (user_id, sent_on)` limita a 1 email/dia y
--     `unique (user_id, stage_days, last_activity_on)` limita a 1 email por
--     etapa (3 y 7 dias) por episodio de inactividad.
--   * `reactivation_candidates(...)`: seleccion server-side (service role).
--   * `reactivation_unsubscribe(...)`: baja idempotente por token, sin login.
--
-- El envio lo hace la Edge Function `reactivation-email`; el cliente no tiene
-- acceso a ninguna de estas funciones ni a la tabla.

-- ---------------------------------------------------------------------------
-- 1. Preferencias y token de baja
-- ---------------------------------------------------------------------------

alter table public.user_settings
  add column if not exists reactivation_emails boolean not null default true;

alter table public.user_settings
  add column if not exists reactivation_unsubscribed_at timestamptz;

alter table public.user_settings
  add column if not exists reactivation_unsubscribe_token uuid not null default gen_random_uuid();

create unique index if not exists user_settings_reactivation_token_key
  on public.user_settings (reactivation_unsubscribe_token);

comment on column public.user_settings.reactivation_emails is
  'Opt-in a emails de reactivación. false = el usuario se dio de baja.';
comment on column public.user_settings.reactivation_unsubscribed_at is
  'Momento de la baja por email (null si nunca se dio de baja).';
comment on column public.user_settings.reactivation_unsubscribe_token is
  'Token opaco del enlace de baja; no adivinable y sin login.';

-- ---------------------------------------------------------------------------
-- 2. Registro de envios
-- ---------------------------------------------------------------------------

create table if not exists public.reactivation_emails (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  sent_on date not null default current_date,
  stage_days integer not null check (stage_days in (3, 7)),
  last_activity_on date not null,
  locale text not null default 'es' check (locale in ('es', 'en', 'pt')),
  provider text not null default 'resend',
  provider_message_id text,
  status text not null default 'sending'
    check (status in ('sending', 'sent', 'failed')),
  error_code text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, sent_on),
  unique (user_id, stage_days, last_activity_on)
);

comment on table public.reactivation_emails is
  'Intentos de email de reactivación (issue #107). Sin PII: no guarda direcciones.';
comment on column public.reactivation_emails.last_activity_on is
  'Fecha de última actividad del episodio; identifica el episodio de inactividad.';
comment on column public.reactivation_emails.error_code is
  'Código corto del fallo (http_500, provider_error, ...), nunca el email ni el cuerpo.';

create index if not exists reactivation_emails_user_sent_idx
  on public.reactivation_emails (user_id, sent_on desc);

alter table public.reactivation_emails enable row level security;

-- Sin politicas: solo service role (la Edge Function) escribe y lee.
revoke all on public.reactivation_emails from anon, authenticated;
grant select, insert, update on public.reactivation_emails to service_role;

-- ---------------------------------------------------------------------------
-- 3. Seleccion de candidatos (service role)
-- ---------------------------------------------------------------------------

create or replace function public.reactivation_candidates(
  p_inactive_days integer default 7,
  p_window_days integer default 3,
  p_limit integer default 200
)
returns table (
  user_id uuid,
  email text,
  display_name text,
  locale text,
  streak integer,
  unsubscribe_token uuid,
  last_activity_on date,
  days_inactive integer,
  stage_days integer
)
language sql
security definer
set search_path = 'public'
as $function$
  with params as (
    select greatest(1, least(coalesce(p_inactive_days, 7), 90)) as inactive_days,
           greatest(1, least(coalesce(p_window_days, 3), 90)) as window_days,
           greatest(1, least(coalesce(p_limit, 200), 500)) as max_rows
  ),
  base as (
    select
      u.id as uid,
      au.email::text as mail,
      au.email_confirmed_at,
      coalesce(st.reactivation_emails, true) as opt_in,
      coalesce(st.ui_language, 'es') as ui_language,
      st.reactivation_unsubscribe_token as token,
      nullif(btrim(u.display_name), '') as player_name,
      coalesce(p.current_streak, 0) as streak_value,
      greatest(
        (select max(ps.practiced_on)::timestamptz
           from public.practice_sessions ps where ps.user_id = u.id),
        (select max(c.started_at)
           from public.conversations c
          where c.user_id = u.id and c.deleted_at is null),
        u.last_active_at,
        p.last_active_date::timestamptz
      ) as last_seen
    from public.users u
    join auth.users au on au.id = u.id
    left join lateral (
      select ulp.current_streak, ulp.last_active_date
        from public.user_language_profiles ulp
       where ulp.user_id = u.id
       order by coalesce(ulp.current_streak, 0) desc,
                coalesce(ulp.xp_points, 0) desc
       limit 1
    ) p on true
    left join public.user_settings st on st.user_id = u.id
    where u.deleted_at is null
      and coalesce(u.is_active, true)
  ),
  measured as (
    select b.*, (current_date - b.last_seen::date) as inactive_days
      from base b
     where b.last_seen is not null
  ),
  staged as (
    select m.*,
           case
             when m.inactive_days >= 7 then 7
             when m.inactive_days >= 3 then 3
             else null
           end as stage
      from measured m
  )
  select
    staged.uid,
    staged.mail,
    staged.player_name,
    case when staged.ui_language in ('es', 'en', 'pt')
         then staged.ui_language else 'es' end,
    staged.streak_value,
    staged.token,
    staged.last_seen::date,
    staged.inactive_days,
    staged.stage
  from staged
  cross join params
  where staged.stage is not null
    and staged.inactive_days >= params.inactive_days
    and staged.email_confirmed_at is not null
    and staged.mail ~* '^[^@[:space:]]+@[^@[:space:]]+\.[a-z]{2,}$'
    and staged.mail not ilike 'test%@mailinator.com'
    and staged.opt_in
    and staged.token is not null
    and not exists (
      select 1 from public.reactivation_emails re
       where re.user_id = staged.uid
         and re.sent_on > current_date - params.window_days
    )
    and not exists (
      select 1 from public.reactivation_emails re
       where re.user_id = staged.uid
         and re.stage_days = staged.stage
         and re.last_activity_on = staged.last_seen::date
    )
  order by staged.last_seen asc
  limit (select max_rows from params);
$function$;

comment on function public.reactivation_candidates(integer, integer, integer) is
  'Usuarios con email confirmado, opt-in activo e inactivos >= p_inactive_days. '
  'Etapa 3 o 7 dias segun antiguedad; excluye quien ya recibio esa etapa en el '
  'mismo episodio o cualquier email en los ultimos p_window_days.';

revoke all on function public.reactivation_candidates(integer, integer, integer)
  from public, anon, authenticated;
grant execute on function public.reactivation_candidates(integer, integer, integer)
  to service_role;

-- ---------------------------------------------------------------------------
-- 4. Baja por token (sin login)
-- ---------------------------------------------------------------------------

create or replace function public.reactivation_unsubscribe(p_token uuid)
returns boolean
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_rows integer := 0;
begin
  if p_token is null then
    return false;
  end if;

  update public.user_settings
     set reactivation_emails = false,
         reactivation_unsubscribed_at = coalesce(reactivation_unsubscribed_at, now())
   where reactivation_unsubscribe_token = p_token;

  get diagnostics v_rows = row_count;
  return v_rows > 0;
end;
$function$;

comment on function public.reactivation_unsubscribe(uuid) is
  'Da de baja los emails de reactivación para el token indicado (idempotente).';

revoke all on function public.reactivation_unsubscribe(uuid)
  from public, anon, authenticated;
grant execute on function public.reactivation_unsubscribe(uuid) to service_role;
