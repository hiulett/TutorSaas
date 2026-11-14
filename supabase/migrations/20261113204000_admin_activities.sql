-- Constructor de actividades del portal (CUR-14).
--
-- Una actividad tiene `payload jsonb` validado contra el esquema del tipo
-- (`activity_types.payload_schema`). No hace falta un motor de JSON Schema
-- completo para lo que hay: los cuatro tipos declaran sus claves obligatorias
-- en `required`, y eso es lo que se comprueba aquí. Los tipos nuevos añadirán
-- más reglas y entonces se verá si hace falta más.
--
-- Solo se admiten tipos **habilitados**: `mcq`, `fill_blank` y `order_words`
-- nacen deshabilitados (CUR-01) para que nadie publique ejercicios que la app
-- todavía no sabe pintar.
--
-- Las actividades se escriben en la **versión en curso**, igual que el resto del
-- contenido: un borrador en `current_version + 1` si la lección está publicada.
-- Así publicar sigue siendo el único momento en que llegan al alumno.

-- ── Tipos disponibles ───────────────────────────────────────────────────────
create or replace function public.admin_activity_types()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not (public.admin_can('read') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad read' using errcode = '42501';
  end if;

  return jsonb_build_object(
    'types', coalesce((
      select jsonb_agg(jsonb_build_object(
               'code', t.code,
               'renderer_key', t.renderer_key,
               'schema_version', t.schema_version,
               'is_enabled', t.is_enabled,
               'required_keys', coalesce(t.payload_schema->'required', '[]'::jsonb)
             ) order by t.code)
        from public.activity_types t
    ), '[]'::jsonb)
  );
end;
$$;

-- ── Habilitar o deshabilitar un tipo ────────────────────────────────────────
create or replace function public.admin_set_activity_enabled(
  p_code text,
  p_enabled boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid := auth.uid();
  v_type  public.activity_types;
begin
  if not (public.admin_can('edit_draft') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad edit_draft' using errcode = '42501';
  end if;

  select * into v_type from public.activity_types where code = p_code;
  if not found then
    raise exception 'tipo de actividad inexistente: %', p_code using errcode = '22023';
  end if;

  update public.activity_types set is_enabled = p_enabled where code = p_code;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (v_actor, 'activity_type', p_code, 'set_activity_enabled',
          jsonb_build_object('from', v_type.is_enabled, 'to', p_enabled));

  return jsonb_build_object('code', p_code, 'is_enabled', p_enabled);
end;
$$;

-- ── Guardar una actividad ───────────────────────────────────────────────────
create or replace function public.admin_save_activity(
  p_lesson_id text,
  p_activity jsonb,
  p_order_index integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor     uuid := auth.uid();
  v_lesson    public.lessons;
  v_type      public.activity_types;
  v_code      text;
  v_payload   jsonb;
  v_required  text[];
  v_missing   text[];
  v_version   integer;
  v_order     integer;
  v_position  integer := 0;
begin
  if not (public.admin_can('edit_draft') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad edit_draft' using errcode = '42501';
  end if;

  select * into v_lesson from public.lessons where id = p_lesson_id;
  if not found then
    raise exception 'lección inexistente: %', p_lesson_id using errcode = '22023';
  end if;

  if p_activity is null or jsonb_typeof(p_activity) <> 'object' then
    raise exception 'p_activity debe ser un objeto jsonb' using errcode = '22023';
  end if;

  v_code := nullif(btrim(p_activity->>'activity_type'), '');
  select * into v_type from public.activity_types where code = v_code;
  if not found then
    raise exception 'tipo de actividad inexistente: %', coalesce(v_code, '(vacío)')
      using errcode = '22023';
  end if;
  if not v_type.is_enabled then
    raise exception 'el tipo % está deshabilitado; habilítalo antes de usarlo', v_code
      using errcode = '22023';
  end if;

  v_payload := p_activity->'payload';
  if jsonb_typeof(v_payload) <> 'object' then
    raise exception 'la actividad % necesita un payload objeto', v_code using errcode = '22023';
  end if;

  select coalesce(array_agg(value), '{}') into v_required
    from jsonb_array_elements_text(coalesce(v_type.payload_schema->'required', '[]'::jsonb));

  select coalesce(array_agg(key), '{}') into v_missing
    from unnest(v_required) as key
   where not (v_payload ? key);
  if array_length(v_missing, 1) > 0 then
    raise exception 'al payload de % le faltan: %', v_code, array_to_string(v_missing, ', ')
      using errcode = '22023';
  end if;

  if v_lesson.status = 'published' then
    v_version := v_lesson.current_version + 1;
  else
    v_version := v_lesson.current_version;
  end if;

  select coalesce(max(order_index), 0) into v_position
    from public.lesson_activities
   where lesson_id = p_lesson_id and version = v_version and order_index <> coalesce(p_order_index, -1);

  v_order := coalesce(p_order_index, v_position + 1);

  insert into public.lesson_activities (
    lesson_id, version, activity_type, order_index, instructions, payload, scoring, feedback_good, feedback_bad
  )
  values (
    p_lesson_id, v_version, v_code, v_order,
    nullif(btrim(p_activity->>'instructions'), ''),
    v_payload,
    p_activity->'scoring',
    nullif(btrim(p_activity->>'feedback_good'), ''),
    nullif(btrim(p_activity->>'feedback_bad'), '')
  )
  on conflict (lesson_id, version, order_index) do update set
    activity_type = excluded.activity_type,
    instructions  = excluded.instructions,
    payload       = excluded.payload,
    scoring       = excluded.scoring,
    feedback_good = excluded.feedback_good,
    feedback_bad  = excluded.feedback_bad;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (v_actor, 'lesson', p_lesson_id, 'save_activity',
          jsonb_build_object('activity_type', v_code, 'version', v_version, 'order_index', v_order));

  return jsonb_build_object(
    'lesson_id', p_lesson_id,
    'version', v_version,
    'activity_type', v_code,
    'order_index', v_order
  );
end;
$$;

-- ── `admin_lesson` también considera un borrador de solo actividades ────────
-- Si un borrador tiene únicamente actividades, la lectura anterior no lo veía
-- (miraba solo objetivos) y el editor enseñaba el contenido publicado.
create or replace function public.admin_lesson(p_lesson_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_lesson     public.lessons;
  v_published  integer;
  v_draft      integer;
  v_version    integer;
  v_has_draft  boolean;
  v_content    integer;
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

  select (select count(*) from public.lesson_objectives o
           where o.lesson_id = p_lesson_id and o.version = v_draft)
       + (select count(*) from public.lesson_phrases p
           where p.lesson_id = p_lesson_id and p.version = v_draft)
       + (select count(*) from public.lesson_activities a
           where a.lesson_id = p_lesson_id and a.version = v_draft)
    into v_content;

  v_has_draft := v_content > 0 and v_lesson.status = 'published';
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

comment on function public.admin_activity_types() is
  'Tipos de actividad con sus claves obligatorias y si están habilitados (CUR-14).';
comment on function public.admin_save_activity(text, jsonb, integer) is
  'Guarda una actividad en la versión en curso y valida el payload contra las claves obligatorias del tipo (CUR-14).';

revoke all on function public.admin_activity_types()                        from public;
revoke all on function public.admin_set_activity_enabled(text, boolean)     from public;
revoke all on function public.admin_save_activity(text, jsonb, integer)     from public;

revoke all on function public.admin_activity_types()                        from anon;
revoke all on function public.admin_set_activity_enabled(text, boolean)     from anon;
revoke all on function public.admin_save_activity(text, jsonb, integer)     from anon;

grant execute on function public.admin_activity_types()                     to authenticated, service_role;
grant execute on function public.admin_set_activity_enabled(text, boolean)  to authenticated, service_role;
grant execute on function public.admin_save_activity(text, jsonb, integer)  to authenticated, service_role;
