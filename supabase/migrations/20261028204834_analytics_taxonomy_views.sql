-- P-15 (#100): taxonomia minima de eventos y vistas de producto.
--
-- Las vistas usan security_invoker: el admin (app_metadata.role = 'admin')
-- ve el agregado completo; un usuario normal solo sus propias filas.

-- 1. El panel admin puede leer los eventos (mismo patron que user_language_profiles).
drop policy if exists analytics_events_select_admin on public.analytics_events;
create policy analytics_events_select_admin on public.analytics_events
  for select to authenticated
  using (((auth.jwt() -> 'app_metadata'::text) ->> 'role'::text) = 'admin'::text);

-- 2. Embudo de onboarding: empezado, pasos y completado.
create or replace view public.analytics_onboarding_funnel
with (security_invoker = true) as
select
  0 as ord,
  'started'::text as stage,
  count(distinct user_id)::bigint as users
from public.analytics_events
where event_name in ('onboarding_started', 'onboarding_step')
union all
select
  coalesce(step, 0) + 1 as ord,
  ('step_' || coalesce(step, 0))::text as stage,
  count(*)::bigint as users
from (
  select distinct user_id,
    case when (properties ->> 'step') ~ '^[0-9]+$' then (properties ->> 'step')::int end as step
  from public.analytics_events
  where event_name = 'onboarding_step' and properties ? 'step'
) s
group by step
union all
select
  99 as ord,
  'completed'::text as stage,
  count(distinct user_id)::bigint as users
from public.analytics_events
where event_name = 'onboarding_completed';

-- 3. Activacion: primera sesion dentro de las 24 h del registro.
create or replace view public.analytics_activation
with (security_invoker = true) as
with first_session as (
  select user_id, min(created_at) as first_session_at
  from public.analytics_events
  where event_name in ('session_start', 'session_end')
  group by user_id
)
select
  date_trunc('week', u.created_at)::date as signup_week,
  count(*)::bigint as users,
  count(f.first_session_at)::bigint as with_session,
  count(*) filter (
    where f.first_session_at is not null
      and f.first_session_at - u.created_at <= interval '24 hours'
  )::bigint as activated_24h
from public.users u
left join first_session f on f.user_id = u.id
group by 1
order by 1 desc;

-- 4. Retencion D1 / D7 / D30 por cohorte de registro.
create or replace view public.analytics_retention
with (security_invoker = true) as
with signup as (
  select id as user_id, created_at::date as cohort
  from public.users
),
activity as (
  select distinct user_id, created_at::date as day
  from public.analytics_events
)
select
  s.cohort,
  (a.day - s.cohort) as day_offset,
  count(distinct a.user_id)::bigint as users
from signup s
join activity a on a.user_id = s.user_id
where (a.day - s.cohort) in (0, 1, 7, 30)
group by 1, 2
order by 1 desc, 2;

-- 5. Sesiones por usuario y semana.
create or replace view public.analytics_sessions_per_week
with (security_invoker = true) as
select
  date_trunc('week', created_at)::date as week,
  count(*)::bigint as sessions,
  count(distinct user_id)::bigint as users,
  round(count(*)::numeric / nullif(count(distinct user_id), 0), 2) as sessions_per_user
from public.analytics_events
where event_name = 'session_start'
group by 1
order by 1 desc;

revoke all on public.analytics_onboarding_funnel from anon, authenticated;
revoke all on public.analytics_activation from anon, authenticated;
revoke all on public.analytics_retention from anon, authenticated;
revoke all on public.analytics_sessions_per_week from anon, authenticated;
grant select on public.analytics_onboarding_funnel to authenticated;
grant select on public.analytics_activation to authenticated;
grant select on public.analytics_retention to authenticated;
grant select on public.analytics_sessions_per_week to authenticated;
