-- Cola de traducciones del portal (CUR-15).
--
-- Lista las frases que necesitan trabajo editorial: las que repiten el texto
-- (`identical`) y las que no tienen traducción (`pending`). Es la cola de las
-- 481 que dejó la importación, y no corrige nada: solo las expone ordenadas.
--
-- La corrección **no** se escribe aquí. Cambiar una traducción es cambiar
-- contenido, así que pasa por el camino normal: borrador (`admin_save_lesson`)
-- y publicación (`admin_publish_lesson`). Un atajo que escribiera directo sobre
-- lo publicado se saltaría la revisión y la auditoría.

create or replace function public.admin_translations(
  p_level text default null,
  p_status text default 'identical',
  p_limit integer default 100,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_status  text;
  v_limit   integer;
  v_offset  integer;
begin
  if not (public.admin_can('read') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad read' using errcode = '42501';
  end if;

  v_status := coalesce(nullif(btrim(p_status), ''), 'identical');
  if v_status not in ('identical', 'pending', 'ok', 'all') then
    raise exception 'estado de traducción inválido: %', p_status using errcode = '22023';
  end if;

  v_limit := greatest(1, least(coalesce(p_limit, 100), 500));
  v_offset := greatest(0, coalesce(p_offset, 0));

  return jsonb_build_object(
    'status', v_status,
    'limit', v_limit,
    'offset', v_offset,
    'totals', jsonb_build_object(
      'identical', (
        select count(*) from public.lesson_phrases p
          join public.lessons l on l.id = p.lesson_id and p.version = l.current_version
          join public.curriculum_units u on u.id = l.unit_id
         where l.status = 'published' and p.translation_status = 'identical'
           and (p_level is null or u.level_id = p_level)
      ),
      'pending', (
        select count(*) from public.lesson_phrases p
          join public.lessons l on l.id = p.lesson_id and p.version = l.current_version
          join public.curriculum_units u on u.id = l.unit_id
         where l.status = 'published' and p.translation_status = 'pending'
           and (p_level is null or u.level_id = p_level)
      ),
      'ok', (
        select count(*) from public.lesson_phrases p
          join public.lessons l on l.id = p.lesson_id and p.version = l.current_version
          join public.curriculum_units u on u.id = l.unit_id
         where l.status = 'published' and p.translation_status = 'ok'
           and (p_level is null or u.level_id = p_level)
      )
    ),
    'rows', coalesce((
      select jsonb_agg(row_json order by level_order, unit_order, lesson_order, phrase_order)
        from (
          select
            lv.order_index as level_order,
            u.order_index  as unit_order,
            l.order_index  as lesson_order,
            p.order_index  as phrase_order,
            jsonb_build_object(
              'level', lv.cefr,
              'level_id', lv.id,
              'unit_slug', u.slug,
              'lesson_id', l.id,
              'lesson_title', l.title,
              'order_index', p.order_index,
              'phrase', p.phrase,
              'translation', p.translation,
              'status', p.translation_status,
              'has_draft', exists (
                select 1 from public.lesson_objectives o
                 where o.lesson_id = l.id and o.version = l.current_version + 1
              )
            ) as row_json
            from public.lesson_phrases p
            join public.lessons l on l.id = p.lesson_id and p.version = l.current_version
            join public.curriculum_units u on u.id = l.unit_id
            join public.curriculum_levels lv on lv.id = u.level_id
           where l.status = 'published'
             and (p_level is null or u.level_id = p_level)
             and (v_status = 'all' or p.translation_status = v_status)
           order by lv.order_index, u.order_index, l.order_index, p.order_index
           limit v_limit offset v_offset
        ) ordered
    ), '[]'::jsonb)
  );
end;
$$;

comment on function public.admin_translations(text, text, integer, integer) is
  'Cola de traducciones (CUR-15): frases identical/pending con su ubicación. Solo lectura; la corrección va por borrador y publicación.';

revoke all on function public.admin_translations(text, text, integer, integer) from public;
revoke all on function public.admin_translations(text, text, integer, integer) from anon;
grant execute on function public.admin_translations(text, text, integer, integer) to authenticated, service_role;
