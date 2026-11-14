-- Prerrequisitos de lección en el paquete del nivel (CUR-18).
--
-- `lesson_prerequisites` existe desde CUR-01, pero `get_curriculum_pack` no la
-- exponía: la app solo podía bloquear por orden de catálogo. Esta migración:
--
-- 1. añade `prerequisites` a cada lección del pack, para que el desbloqueo sea
--    dato y no una convención de orden;
-- 2. siembra la cadena secuencial actual (cada lección requiere la anterior de
--    su nivel), que es el mismo comportamiento que ya tiene la app. Así el
--    encendido no cambia lo que ve el alumno; el portal podrá editarlo después
--    (CUR-20 y siguientes).
--
-- Idempotente: reejecutarla no duplica filas ni cambia la firma de la función.
-- No toca `lessons`, versiones, objetivos ni frases.

-- ── 1 · Sembrar la cadena secuencial por nivel ──────────────────────────────
-- 7 niveles × 20 lecciones = 140; el primero de cada nivel no tiene requisito,
-- luego se esperan 133 filas. `on conflict do nothing` la hace reejecutable.
with ordered as (
  select
    l.id,
    lag(l.id) over (
      partition by u.level_id
      order by u.order_index, l.order_index
    ) as previous_id
  from public.lessons l
  join public.curriculum_units u on u.id = l.unit_id
  where l.status = 'published'
)
insert into public.lesson_prerequisites (lesson_id, requires_lesson_id, kind)
select id, previous_id, 'required'
  from ordered
 where previous_id is not null
on conflict (lesson_id, requires_lesson_id) do nothing;

-- ── 2 · Exponer los prerrequisitos en el pack ───────────────────────────────
create or replace function public.get_curriculum_pack(
  p_level text,
  p_since_version integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_level           public.curriculum_levels%rowtype;
  v_content_version bigint;
  v_units           jsonb;
begin
  select *
    into v_level
    from public.curriculum_levels
   where id = p_level
     and is_active;

  if not found then
    raise exception 'nivel desconocido o inactivo: %', p_level
      using errcode = 'P0002';
  end if;

  select coalesce(extract(epoch from max(l.updated_at)), 0)::bigint
    into v_content_version
    from public.lessons l
    join public.curriculum_units u on u.id = l.unit_id
   where u.level_id = v_level.id
     and l.status = 'published';

  select coalesce(jsonb_agg(unit_pack order by unit_order), '[]'::jsonb)
    into v_units
    from (
      select
        u.order_index as unit_order,
        jsonb_build_object(
          'id', u.id,
          'slug', u.slug,
          'title', u.title,
          'description', u.description,
          'order_index', u.order_index,
          'lessons', coalesce((
            select jsonb_agg(lesson_pack order by lesson_order)
              from (
                select
                  l.order_index as lesson_order,
                  jsonb_build_object(
                    'id', l.id,
                    'title', l.title,
                    'category', l.category,
                    'difficulty', l.difficulty,
                    'order_index', l.order_index,
                    'estimated_minutes', l.estimated_minutes,
                    'version', l.current_version,
                    'main_objective', l.main_objective,
                    'scenario_context', l.scenario_context,
                    'assistant_role', l.assistant_role,
                    'user_role', l.user_role,
                    'initial_message', l.initial_message,
                    'prerequisites', coalesce((
                      select jsonb_agg(
                               jsonb_build_object(
                                 'lesson_id', pr.requires_lesson_id,
                                 'kind', pr.kind
                               )
                               order by pr.kind, pr.requires_lesson_id
                             )
                        from public.lesson_prerequisites pr
                       where pr.lesson_id = l.id
                    ), '[]'::jsonb),
                    'objectives', coalesce((
                      select jsonb_agg(
                               jsonb_build_object(
                                 'code', o.code,
                                 'description', o.description,
                                 'competency', o.competency,
                                 'criterion', o.criterion,
                                 'evidence_examples', o.evidence_examples,
                                 'common_errors', o.common_errors,
                                 'is_required', o.is_required,
                                 'order_index', o.order_index
                               )
                               order by o.order_index
                             )
                        from public.lesson_objectives o
                       where o.lesson_id = l.id
                         and o.version = l.current_version
                    ), '[]'::jsonb),
                    'phrases', coalesce((
                      select jsonb_agg(
                               jsonb_build_object(
                                 'order_index', p.order_index,
                                 'phrase', p.phrase,
                                 'translation', p.translation,
                                 'translation_status', p.translation_status,
                                 'audio_url', p.audio_url
                               )
                               order by p.order_index
                             )
                        from public.lesson_phrases p
                       where p.lesson_id = l.id
                         and p.version = l.current_version
                    ), '[]'::jsonb),
                    'activities', coalesce((
                      select jsonb_agg(
                               jsonb_build_object(
                                 'activity_type', a.activity_type,
                                 'order_index', a.order_index,
                                 'instructions', a.instructions,
                                 'payload', a.payload,
                                 'scoring', a.scoring,
                                 'feedback_good', a.feedback_good,
                                 'feedback_bad', a.feedback_bad
                               )
                               order by a.order_index
                             )
                        from public.lesson_activities a
                        join public.activity_types t on t.code = a.activity_type
                       where a.lesson_id = l.id
                         and a.version = l.current_version
                         and t.is_enabled
                    ), '[]'::jsonb)
                  ) as lesson_pack
                  from public.lessons l
                 where l.unit_id = u.id
                   and l.status = 'published'
                   and (
                     coalesce(p_since_version, 0) <= 0
                     or extract(epoch from l.updated_at)::bigint > p_since_version
                   )
              ) per_lesson
          ), '[]'::jsonb)
        ) as unit_pack
        from public.curriculum_units u
       where u.level_id = v_level.id
    ) per_unit;

  return jsonb_build_object(
    'level', jsonb_build_object(
      'id', v_level.id,
      'name', v_level.name,
      'cefr', v_level.cefr,
      'order_index', v_level.order_index,
      'narrative_world', v_level.narrative_world,
      'description', v_level.description,
      'estimated_hours', v_level.estimated_hours
    ),
    'content_version', v_content_version,
    'units', v_units
  );
end;
$$;

comment on function public.get_curriculum_pack(text, integer) is
  'Paquete de un nivel para la app (CUR-07, prerrequisitos CUR-18): nivel, unidades, lecciones publicadas con prerrequisitos y contenido vigente, y content_version como etag.';

revoke all on function public.get_curriculum_pack(text, integer) from public;
revoke all on function public.get_curriculum_pack(text, integer) from anon;
grant execute on function public.get_curriculum_pack(text, integer)
  to authenticated, service_role;
