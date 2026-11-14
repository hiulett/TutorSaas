-- Lectura de una lección para el editor del portal (CUR-13).
--
-- El editor necesita ver el **borrador** si existe, y si no lo publicado. El
-- paquete de nivel (`get_curriculum_pack`) solo sirve contenido publicado y por
-- nivel; esto es la lectura puntual de una lección con lo que hay en la versión
-- en curso.
--
-- Devuelve también el estado y las versiones para que la interfaz pueda decir
-- «borrador sin publicar» o «versión N publicada» sin adivinar.

create or replace function public.admin_lesson(p_lesson_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_lesson      public.lessons;
  v_published   integer;
  v_draft       integer;
  v_version     integer;
  v_has_draft   boolean;
  v_objectives  integer;
begin
  if not (public.admin_can('read') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad read' using errcode = '42501';
  end if;

  select * into v_lesson from public.lessons where id = p_lesson_id;
  if not found then
    raise exception 'lección inexistente: %', p_lesson_id using errcode = '22023';
  end if;

  if v_lesson.status = 'published' then
    v_published := v_lesson.current_version;
    v_draft     := v_lesson.current_version + 1;
  else
    v_published := null;
    v_draft     := v_lesson.current_version;
  end if;

  select count(*) into v_objectives
    from public.lesson_objectives
   where lesson_id = p_lesson_id and version = v_draft;

  v_has_draft := v_objectives > 0 and v_lesson.status = 'published';
  v_version   := case when v_has_draft then v_draft else coalesce(v_published, v_draft) end;

  return jsonb_build_object(
    'id', v_lesson.id,
    'unit_id', v_lesson.unit_id,
    'title', v_lesson.title,
    'category', v_lesson.category,
    'difficulty', v_lesson.difficulty,
    'order_index', v_lesson.order_index,
    'main_objective', v_lesson.main_objective,
    'scenario_context', v_lesson.scenario_context,
    'assistant_role', v_lesson.assistant_role,
    'user_role', v_lesson.user_role,
    'initial_message', v_lesson.initial_message,
    'status', v_lesson.status,
    'published_version', v_published,
    'draft_version', case when v_has_draft then v_draft end,
    'version', v_version,
    'objectives', coalesce((
      select jsonb_agg(jsonb_build_object(
               'code', o.code,
               'description', o.description,
               'competency', o.competency,
               'criterion', o.criterion,
               'evidence_examples', o.evidence_examples,
               'is_required', o.is_required,
               'needs_review', o.needs_review,
               'review_reason', o.review_reason,
               'order_index', o.order_index
             ) order by o.order_index)
        from public.lesson_objectives o
       where o.lesson_id = p_lesson_id and o.version = v_version
    ), '[]'::jsonb),
    'phrases', coalesce((
      select jsonb_agg(jsonb_build_object(
               'order_index', p.order_index,
               'phrase', p.phrase,
               'translation', p.translation,
               'translation_status', p.translation_status
             ) order by p.order_index)
        from public.lesson_phrases p
       where p.lesson_id = p_lesson_id and p.version = v_version
    ), '[]'::jsonb),
    'activities', coalesce((
      select jsonb_agg(jsonb_build_object(
               'activity_type', a.activity_type,
               'order_index', a.order_index,
               'instructions', a.instructions,
               'payload', a.payload
             ) order by a.order_index)
        from public.lesson_activities a
       where a.lesson_id = p_lesson_id and a.version = v_version
    ), '[]'::jsonb)
  );
end;
$$;

comment on function public.admin_lesson(text) is
  'Lección con su contenido en curso para el editor del portal (CUR-13). Devuelve el borrador si existe.';

revoke all on function public.admin_lesson(text) from public;
revoke all on function public.admin_lesson(text) from anon;
grant execute on function public.admin_lesson(text) to authenticated, service_role;
