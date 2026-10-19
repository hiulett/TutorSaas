-- Issue #74: métrica de evidencia de aprendizaje para el usuario actual.
--
-- `retention_7d` = aciertos tras ≥ 7 días / repasos elegibles (últimos 90 días).
-- Devuelve `null` cuando aún no hay repasos elegibles: un 0 sería una
-- afirmación falsa, no una ausencia de datos.

create or replace function public.learning_evidence()
returns jsonb
language sql
stable
security definer
set search_path to 'public'
as $function$
  with me as (select auth.uid() as u),
  rev as (
    select count(*)::numeric as total,
           count(*) filter (where days_since_last >= 7)::numeric as eligible,
           count(*) filter (where delayed_retrieval)::numeric as ok
      from public.vocabulary_reviews
     where user_id = (select u from me)
       and reviewed_at > now() - interval '90 days'
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
                       where user_id = (select u from me))
  );
$function$;

revoke all on function public.learning_evidence() from public, anon;
grant execute on function public.learning_evidence() to authenticated;
