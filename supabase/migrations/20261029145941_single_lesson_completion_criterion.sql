-- P-38 (#123): una sola regla de "lección completada".
--
-- Diagnóstico previo (solo lectura): el 100 % de las claves de progreso
-- (user_scenario_goals.scenario_id, lesson_progress.lesson_id,
-- scenario_progress.scenario_id) son ids de texto del catálogo Dart
-- (prea1_*, a1_*). scenarios.id es uuid y ninguna columna lo enlaza, así que
-- ninguna de las dos partes puede deducir el total de metas de la otra.
-- Esta migración no mueve el currículo: unifica el criterio y deja vistas de
-- diagnóstico. La clave lesson_key y el mapeo quedan para la fase 2.
--
-- Versión aplicada: 20261029145941 (MCP apply_migration).

create or replace function public.lesson_completion_passed(
  p_completed integer,
  p_total integer
)
returns boolean
language sql
immutable
parallel safe
set search_path = public
as $$
  select case
    when coalesce(p_total, 0) <= 0 then true
    when coalesce(p_completed, 0) >= p_total then true
    when p_total <= 4 and coalesce(p_completed, 0) >= p_total - 1 then true
    else (coalesce(p_completed, 0)::numeric / p_total) >= 0.75
  end
$$;

comment on function public.lesson_completion_passed(integer, integer) is
  'P-38 (#123): criterio único de lección superada. Réplica exacta de LessonCompletion.isPassed en Dart: sin metas, todas, una fallada con <=4 metas, o 75 %.';

create or replace function public.lesson_completion_stars(
  p_completed integer,
  p_total integer,
  p_phrases_used integer,
  p_phrases_total integer
)
returns integer
language sql
immutable
parallel safe
set search_path = public
as $$
  select case
    when not public.lesson_completion_passed(p_completed, p_total) then 0
    when coalesce(p_phrases_total, 0) > 0
         and coalesce(p_phrases_used, 0) >= p_phrases_total then 3
    when coalesce(p_phrases_total, 0) > 0
         and coalesce(p_phrases_used, 0) >= ceil(p_phrases_total / 2.0) then 2
    else 1
  end
$$;

comment on function public.lesson_completion_stars(integer, integer, integer, integer) is
  'P-38 (#123): estrellas 0-3 derivadas de lesson_completion_passed. Réplica de LessonCompletion.stars.';

revoke all on function public.lesson_completion_passed(integer, integer) from public, anon;
grant execute on function public.lesson_completion_passed(integer, integer)
  to authenticated, service_role;
revoke all on function public.lesson_completion_stars(integer, integer, integer, integer)
  from public, anon;
grant execute on function public.lesson_completion_stars(integer, integer, integer, integer)
  to authenticated, service_role;

-- El servidor marcaba 'success' solo al 100 %, mientras el cliente ya daba la
-- lección por superada al 75 % (y con una meta fallada en lecciones cortas).
create or replace function public.record_scenario_outcome(
  p_scenario_id text,
  p_completed integer,
  p_total integer
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_ratio numeric;
  v_outcome text;
  v_row public.scenario_progress%rowtype;
  v_first_success boolean := false;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  if p_scenario_id is null or p_total is null or p_total <= 0 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_args');
  end if;

  v_ratio := least(1, greatest(0, coalesce(p_completed, 0)::numeric / p_total));
  -- P-38: misma regla que el cliente (LessonCompletion.isPassed).
  if public.lesson_completion_passed(p_completed, p_total) then
    v_outcome := 'success';
  elsif v_ratio >= 0.5 then
    v_outcome := 'partial';
  else
    v_outcome := 'failure';
  end if;

  select * into v_row from public.scenario_progress
   where user_id = v_uid and scenario_id = p_scenario_id;

  if not found then
    insert into public.scenario_progress (
      user_id, scenario_id, last_outcome, best_ratio, attempts,
      unlocked_next, first_success_at
    ) values (
      v_uid, p_scenario_id, v_outcome, v_ratio, 1,
      v_outcome = 'success',
      case when v_outcome = 'success' then now() else null end
    );
    v_first_success := v_outcome = 'success';
  else
    v_first_success := v_row.first_success_at is null and v_outcome = 'success';
    update public.scenario_progress set
      last_outcome = v_outcome,
      best_ratio = greatest(v_row.best_ratio, v_ratio),
      attempts = v_row.attempts + 1,
      unlocked_next = v_row.unlocked_next or v_outcome = 'success',
      first_success_at = coalesce(v_row.first_success_at,
                                  case when v_outcome = 'success' then now() end),
      updated_at = now()
     where user_id = v_uid and scenario_id = p_scenario_id;
  end if;

  return jsonb_build_object(
    'ok', true, 'outcome', v_outcome, 'ratio', v_ratio,
    'first_success', v_first_success
  );
end;
$$;

-- Diagnóstico: comparación de los dos criterios históricos por lección.
create or replace view public.lesson_completion_state
with (security_invoker = true) as
with latest_progress as (
  select distinct on (user_id, lesson_id)
         user_id, lesson_id, status, completed_at
    from public.lesson_progress
   order by user_id, lesson_id, completed_at desc
),
goal_counts as (
  select user_id, scenario_id,
         count(*) filter (where is_completed) as goals_done,
         count(*) as goals_seen
    from public.user_scenario_goals
   group by user_id, scenario_id
),
phrase_counts as (
  select user_id, scenario_id,
         count(*) filter (where is_completed) as phrases_done,
         count(*) as phrases_seen
    from public.user_scenario_phrases
   group by user_id, scenario_id
),
lesson_keys as (
  select user_id, lesson_id as lesson_key from latest_progress
  union
  select user_id, scenario_id from public.scenario_progress
  union
  select user_id, scenario_id from goal_counts
)
select
  k.user_id,
  k.lesson_key,
  coalesce(g.goals_done, 0) as goals_done,
  g.goals_seen,
  coalesce(p.phrases_done, 0) as phrases_done,
  p.phrases_seen,
  lp.status as client_status,
  sp.last_outcome as server_outcome,
  sp.best_ratio,
  sp.unlocked_next as server_unlocked,
  (lp.status = 'passed') as client_passed,
  (sp.last_outcome = 'success') as server_passed,
  ((lp.status = 'passed') is distinct from (sp.last_outcome = 'success')) as criteria_disagree
from lesson_keys k
left join latest_progress lp
       on lp.user_id = k.user_id and lp.lesson_id = k.lesson_key
left join public.scenario_progress sp
       on sp.user_id = k.user_id and sp.scenario_id = k.lesson_key
left join goal_counts g
       on g.user_id = k.user_id and g.scenario_id = k.lesson_key
left join phrase_counts p
       on p.user_id = k.user_id and p.scenario_id = k.lesson_key;

comment on view public.lesson_completion_state is
  'P-38 (#123): compara el criterio del cliente (lesson_progress.status) con el del servidor (scenario_progress.last_outcome). Con la regla única, criteria_disagree solo puede ser true en filas históricas.';

-- Diagnóstico: claves de progreso (texto) frente a scenarios.id (uuid).
create or replace view public.curriculum_progress_keys
with (security_invoker = true) as
with progress_keys as (
  select distinct scenario_id as lesson_key, 'user_scenario_goals'::text as source
    from public.user_scenario_goals
  union all
  select distinct lesson_id, 'lesson_progress'::text
    from public.lesson_progress
  union all
  select distinct scenario_id, 'scenario_progress'::text
    from public.scenario_progress
)
select
  k.lesson_key,
  k.source,
  exists (select 1 from public.scenarios s where s.id::text = k.lesson_key) as matched_by_uuid,
  exists (select 1 from public.scenarios s where s.title = k.lesson_key) as matched_by_title
from progress_keys k;

comment on view public.curriculum_progress_keys is
  'P-38 (#123): claves de progreso (catálogo Dart) frente a scenarios.id (uuid). matched_by_uuid=false confirma que la BD no referencia el catálogo por id.';

create or replace view public.curriculum_alignment_summary
with (security_invoker = true) as
select
  (select count(*) from public.scenarios where deleted_at is null) as scenario_rows,
  (select count(*) from public.curriculum_progress_keys) as progress_key_rows,
  (select count(*) from public.curriculum_progress_keys where matched_by_uuid) as matched_by_uuid,
  (select count(*) from public.curriculum_progress_keys where not matched_by_uuid) as orphan_keys;

comment on view public.curriculum_alignment_summary is
  'P-38 (#123): resumen del desalineamiento entre progreso (ids Dart) y scenarios (uuid).';

do $$
begin
  assert public.lesson_completion_passed(0, 0);
  assert not public.lesson_completion_passed(0, 3);
  assert not public.lesson_completion_passed(1, 3);
  assert public.lesson_completion_passed(2, 3);
  assert not public.lesson_completion_passed(2, 4);
  assert public.lesson_completion_passed(3, 4);
  assert public.lesson_completion_passed(4, 4);
  assert not public.lesson_completion_passed(7, 10);
  assert public.lesson_completion_passed(8, 10);
  assert not public.lesson_completion_passed(5, 7);
  assert public.lesson_completion_passed(6, 7);
  assert public.lesson_completion_stars(2, 3, 0, 4) = 1;
  assert public.lesson_completion_stars(2, 3, 2, 4) = 2;
  assert public.lesson_completion_stars(3, 3, 4, 4) = 3;
  assert public.lesson_completion_stars(2, 4, 4, 4) = 0;
  assert public.lesson_completion_stars(3, 3, 0, 0) = 1;
end $$;
