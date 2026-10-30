-- P-40a (#220) — productor de la ruta recomendada por alumno.
-- P-40b (#221) — la banda CEFR del escenario se adapta al nivel real.
--
-- Verificado contra producción (MCP supabase, solo lectura) antes de escribir:
--   * `scenarios` tiene 20 escenarios por nivel y idioma (140 en inglés). Los
--     títulos coinciden con el catálogo Dart en PRE-A1…B1 y C2; B2 y C1
--     divergieron (ver docs/runbooks/CURRICULUM_ALIGNMENT.md).
--   * Los ids NO coinciden: `scenarios.id` es uuid, mientras que
--     `lesson_progress.lesson_id` y `user_scenario_goals.scenario_id` guardan
--     los ids de texto del catálogo (`prea1_hello_hello`,
--     `a1_ordering_coffee_at_a_cafe`...). Ese es el motivo de `lesson_key`:
--     el puente estable entre los dos currículos.
--   * `user_ai_profiles.recommended_path_scenarios` existía sin productor ni
--     lector (11 filas, 0 con valor). Aquí pasa a tener ambos.
--
-- Coste: cero llamadas nuevas a IA. Todo se calcula con datos que ya existen.

-- ── 1. Puente catálogo Dart ↔ `scenarios` ────────────────────────────────────
alter table public.scenarios
  add column if not exists lesson_key text;

comment on column public.scenarios.lesson_key is
  'P-40a (#220): id del catálogo Dart equivalente (prea1_hello_hello, a1_ordering_coffee_at_a_cafe...). Permite cruzar lesson_progress/user_scenario_goals con scenarios sin duplicar contenido.';

create index if not exists scenarios_language_lesson_key_idx
  on public.scenarios (language_id, lesson_key)
  where lesson_key is not null;

-- La mayoría de los ids del catálogo son el nivel + slug del título. Se genera
-- con esa regla y se corrigen los 10 que no la siguen. Las claves que no
-- existan en el catálogo se eliminan en la migración siguiente
-- (`lesson_catalog_index_p40a`). No se usa un índice único: un escenario
-- generado por el alumno puede repetir título.
update public.scenarios s
   set lesson_key = lower(replace(s.difficulty_level, '-', '')) || '_' ||
                    btrim(regexp_replace(
                      regexp_replace(lower(replace(s.title, '''', '')),
                                     '[^a-z0-9]+', '_', 'g'),
                      '^_|_$', '', 'g'), '_')
 where s.lesson_key is null;

with overrides(level, title, lesson_key) as (
  values
    ('PRE-A1', 'First Greetings',              'prea1_hello_hello'),
    ('PRE-A1', 'Introducing Your Name',        'prea1_my_name_is'),
    ('PRE-A1', 'Saying Yes and No',            'prea1_yes_no'),
    ('PRE-A1', 'Please and Thank You',         'prea1_please_thank_you'),
    ('PRE-A1', 'Good Morning and Good Night',  'prea1_good_morning'),
    ('PRE-A1', 'Saying Goodbye',               'prea1_goodbye'),
    ('PRE-A1', 'Ordering a Drink',             'prea1_one_water_please'),
    ('PRE-A1', 'Days of the Week',             'prea1_days_of_week'),
    ('PRE-A1', 'Making a Simple Sentence',     'prea1_this_is'),
    ('C2',     'Geo-Engineering Ethics & Solar Radiation Management',
                                               'c2_geo_engineering_ethics_solar_radiation_managemen')
)
update public.scenarios s
   set lesson_key = o.lesson_key
  from overrides o
 where s.difficulty_level = o.level
   and s.title = o.title;

-- ── 2. Ruta recomendada: cálculo + persistencia idempotente ──────────────────
create or replace function public.refresh_recommended_path(p_user_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid := coalesce(p_user_id, auth.uid());
  v_role text := coalesce(auth.role(), 'service_role');
  v_level text;
  v_language_id integer;
  v_interests text[] := '{}'::text[];
  v_weak_terms text[] := '{}'::text[];
  v_daily_minutes integer;
  v_path jsonb;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  -- Mismo patrón que get_dashboard_state/record_scenario_outcome: el cliente
  -- solo puede refrescar su propia ruta; service_role (cron, MCP) cualquiera.
  if v_role not in ('service_role', 'authenticated')
     or (v_role = 'authenticated' and auth.uid() is distinct from v_uid) then
    raise exception 'No autorizado';
  end if;

  select c.code, lp.language_id
    into v_level, v_language_id
    from public.user_language_profiles lp
    left join public.cefr_levels c on c.id = lp.cefr_level_id
   where lp.user_id = v_uid
   order by lp.updated_at desc nulls last, lp.id
   limit 1;
  v_level := coalesce(v_level, 'A1');
  v_language_id := coalesce(v_language_id, 1);

  -- Intereses: los dos orígenes que escribe el onboarding.
  select coalesce(array_agg(distinct term order by term), '{}'::text[])
    into v_interests
    from (
      select lower(btrim(i)) as term
        from public.user_settings s,
             unnest(coalesce(s.interests, '{}'::text[])) as i
       where s.user_id = v_uid
      union all
      select lower(btrim(a))
        from public.user_ai_profiles p,
             unnest(coalesce(p.focus_areas, '{}'::text[])) as a
       where p.user_id = v_uid
    ) t
   where term <> '';

  -- Errores recurrentes (P-29): solo las palabras suficientemente repetidas.
  -- Con 0 filas (producción hoy) no aporta señal y la ruta sigue siendo válida.
  select coalesce(array_agg(distinct term), '{}'::text[])
    into v_weak_terms
    from (
      select (regexp_matches(
                lower(coalesce(e.last_original, '') || ' ' ||
                      coalesce(e.normalized_corrected, '')),
                '[a-z]{4,}', 'g'
              ))[1] as term
        from public.user_recurring_errors e
       where e.user_id = v_uid
         and e.occurrences >= 2
       order by e.occurrences desc
       limit 12
    ) t;

  select s.daily_goal_minutes
    into v_daily_minutes
    from public.user_settings s
   where s.user_id = v_uid;
  v_daily_minutes := coalesce(v_daily_minutes, 15);

  with base as (
    select s.id,
           s.lesson_key,
           s.title,
           s.difficulty_level,
           s.category,
           coalesce(s.estimated_minutes, 15) as minutes,
           (
             (s.lesson_key is not null and exists (
               select 1
                 from public.lesson_progress lp
                where lp.user_id = v_uid
                  and lp.lesson_id = s.lesson_key
                  and lp.status = 'passed'
             ))
             or exists (
               select 1
                 from public.user_scenario_goals g
                where g.user_id = v_uid
                  and g.is_completed
                  and (g.scenario_id = s.id::text
                       or (s.lesson_key is not null and g.scenario_id = s.lesson_key))
                group by g.scenario_id
               having coalesce(jsonb_array_length(s.goals), 0) > 0
                  and public.lesson_completion_passed(
                        count(distinct g.goal_id)::integer,
                        coalesce(jsonb_array_length(s.goals), 0)
                      )
             )
           ) as completed,
           (
             select count(*)
               from unnest(v_interests) as i
              where strpos(
                      lower(s.title || ' ' || coalesce(s.description, '') || ' ' ||
                            coalesce(s.category, '') || ' ' || coalesce(s.main_objective, '')),
                      i) > 0
           ) as interest_hits,
           (
             select count(*)
               from unnest(v_weak_terms) as w
              where strpos(
                      lower(s.title || ' ' || coalesce(s.description, '') || ' ' ||
                            coalesce(s.category, '')),
                      w) > 0
           ) as error_hits
      from public.scenarios s
     where s.language_id = v_language_id
       and s.is_active
       and s.deleted_at is null
       and (s.review_status = 'approved' or s.created_by_user_id = v_uid)
       and s.difficulty_level = v_level
  ),
  ranked as (
    select base.*,
           case
             when base.completed then 'review'
             when base.error_hits > 0 then 'recurring_error'
             when base.interest_hits > 0 then 'interest'
             else 'next'
           end as reason,
           row_number() over (
             order by base.completed asc,
                      base.interest_hits desc,
                      base.error_hits desc,
                      abs(base.minutes - v_daily_minutes) asc,
                      base.title asc,
                      base.id asc
           ) as position
      from base
  )
  select coalesce(
           jsonb_agg(
             jsonb_build_object(
               'scenario_id', ranked.id,
               'lesson_key', ranked.lesson_key,
               'title', ranked.title,
               'level', ranked.difficulty_level,
               'category', ranked.category,
               'estimated_minutes', ranked.minutes,
               'position', ranked.position,
               'reason', ranked.reason
             ) order by ranked.position
           ),
           '[]'::jsonb
         )
    into v_path
    from ranked
   where ranked.position <= 20;

  -- Idempotente: solo escribe si la ruta cambió. El orden es determinista
  -- (desempate final por título e id), así que dos ejecuciones con los mismos
  -- datos producen exactamente el mismo jsonb y no hay escritura.
  insert into public.user_ai_profiles (
    user_id,
    pedagogical_summary,
    tutor_prompt_instructions,
    recommended_path_scenarios
  )
  values (v_uid, '', '', v_path)
  on conflict (user_id) do update
     set recommended_path_scenarios = excluded.recommended_path_scenarios,
         updated_at = now()
   where public.user_ai_profiles.recommended_path_scenarios
         is distinct from excluded.recommended_path_scenarios;

  return v_path;
end;
$function$;

comment on function public.refresh_recommended_path(uuid) is
  'P-40a (#220): calcula y persiste la ruta recomendada del alumno (nivel real, intereses, errores recurrentes y lecciones superadas) sobre escenarios existentes. Sin llamadas de IA; idempotente.';

-- Lectura barata para consumidores que no deben escribir (tests, informes).
create or replace function public.get_recommended_path(p_user_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid := coalesce(p_user_id, auth.uid());
  v_role text := coalesce(auth.role(), 'service_role');
  v_path jsonb;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  if v_role not in ('service_role', 'authenticated')
     or (v_role = 'authenticated' and auth.uid() is distinct from v_uid) then
    raise exception 'No autorizado';
  end if;

  select recommended_path_scenarios
    into v_path
    from public.user_ai_profiles
   where user_id = v_uid;

  if v_path is null
     or jsonb_typeof(v_path) <> 'array'
     or jsonb_array_length(v_path) = 0 then
    return public.refresh_recommended_path(v_uid);
  end if;
  return v_path;
end;
$function$;

comment on function public.get_recommended_path(uuid) is
  'P-40a (#220): devuelve la ruta recomendada guardada; si aún no existe, la calcula con refresh_recommended_path.';

revoke all on function public.refresh_recommended_path(uuid) from public, anon;
revoke all on function public.get_recommended_path(uuid) from public, anon;
grant execute on function public.refresh_recommended_path(uuid) to authenticated, service_role;
grant execute on function public.get_recommended_path(uuid) to authenticated, service_role;