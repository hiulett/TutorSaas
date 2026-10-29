-- Issue #74: evidencia de aprendizaje ademas de retencion.
--
-- Anade a learning_evidence():
--   - weeks_active: semanas distintas con conversaciones.
--   - progress_by_type: misiones completadas por objective_type, comparando la
--     primera y la ultima semana del usuario.
--   - transfer_types: tipos de mision donde completo >= 2 plantillas distintas
--     (proxy de transferencia a misiones no vistas).
--
-- Los valores siguen siendo null/[] cuando no hay datos; la UI muestra
-- "aun sin datos" o "necesitas 4 semanas" en vez de ceros.

create or replace function public.learning_evidence()
returns jsonb
language sql
stable security definer
set search_path = public
as $$
  with me as (select auth.uid() as u),
  rev as (
    select count(*)::numeric as total,
           count(*) filter (where days_since_last >= 7)::numeric as eligible,
           count(*) filter (where delayed_retrieval)::numeric as ok
      from public.vocabulary_reviews
     where user_id = (select u from me)
       and reviewed_at > now() - interval '90 days'
  ),
  completed as (
    select objective_type, template_id, completed_at,
           date_trunc('week', completed_at)::date as week
      from public.mission_instances
     where user_id = (select u from me)
       and status = 'completed'
       and completed_at is not null
  ),
  progress as (
    select objective_type,
           count(*) filter (where week = first_week) as first_week,
           count(*) filter (where week = last_week) as last_week,
           count(distinct week) as weeks
      from (
        select c.*,
               min(week) over (partition by objective_type) as first_week,
               max(week) over (partition by objective_type) as last_week
          from completed c
      ) s
     group by objective_type
  ),
  transfer as (
    select count(*) as types
      from (
        select objective_type
          from completed
         group by objective_type
        having count(distinct template_id) >= 2
      ) t
  )
  select jsonb_build_object(
    'reviews_90d', (select total from rev),
    'delayed_attempts', (select eligible from rev),
    'delayed_success', (select ok from rev),
    'retention_7d', case when (select eligible from rev) = 0 then null
                         else round((select ok from rev) / (select eligible from rev), 3) end,
    'mastered_words', (select count(*) from public.user_vocabulary
                        where user_id = (select u from me) and is_mastered),
    'missions_completed', (select count(*) from public.mission_instances
                           where user_id = (select u from me) and status = 'completed'),
    'missions_total', (select count(*) from public.mission_instances
                       where user_id = (select u from me)),
    'weeks_active', (select count(distinct date_trunc('week', started_at))
                       from public.conversations
                      where user_id = (select u from me) and deleted_at is null),
    'progress_by_type', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'type', objective_type,
        'first_week', first_week,
        'last_week', last_week,
        'weeks', weeks
      )), '[]'::jsonb)
        from progress
    ),
    'transfer_types', (select types from transfer)
  );
$$;
