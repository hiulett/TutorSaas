-- Publicación atómica de una lección (CUR-09).
--
-- `admin_publish_lesson` convierte el borrador en versión publicada en **una
-- sola transacción**: o se publica todo o no se publica nada. Un cuerpo de
-- función en plpgsql es atómico, así que cualquier excepción deshace también
-- las escrituras ya hechas; lo que hay que cuidar es validar antes de escribir
-- y no dejar estados intermedios tras un fallo.
--
-- Publicar no reescribe historia: crea la fila de `lesson_versions` de esa
-- versión y sube `current_version`. Las versiones anteriores siguen ahí y una
-- versión nueva no revoca una completada.
--
-- Requiere la capacidad `publish`: `editor` no la tiene, así que este es el
-- punto donde la revisión no se puede saltar.

create or replace function public.admin_publish_lesson(
  p_lesson_id text,
  p_changelog text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor      uuid := auth.uid();
  v_lesson     public.lessons;
  v_version    integer;
  v_objectives integer;
  v_phrases    integer;
  v_activities integer;
  v_snapshot   jsonb;
begin
  if not (public.admin_can('publish') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad publish' using errcode = '42501';
  end if;

  select * into v_lesson from public.lessons where id = p_lesson_id;
  if not found then
    raise exception 'lección inexistente: %', p_lesson_id using errcode = '22023';
  end if;

  if v_lesson.status = 'published' then
    v_version := v_lesson.current_version + 1;
  else
    v_version := v_lesson.current_version;
  end if;

  select count(*) into v_objectives
    from public.lesson_objectives
   where lesson_id = p_lesson_id and version = v_version;
  select count(*) into v_phrases
    from public.lesson_phrases
   where lesson_id = p_lesson_id and version = v_version;
  select count(*) into v_activities
    from public.lesson_activities
   where lesson_id = p_lesson_id and version = v_version;

  -- Validación antes de escribir nada: si esto falla, no queda rastro.
  if v_objectives = 0 then
    raise exception 'no se puede publicar %: no hay borrador pendiente o no tiene objetivos', p_lesson_id
      using errcode = '22023';
  end if;
  if v_phrases = 0 then
    raise exception 'no se puede publicar %: el borrador no tiene frases de apoyo', p_lesson_id
      using errcode = '22023';
  end if;
  if nullif(btrim(v_lesson.title), '') is null then
    raise exception 'no se puede publicar %: la lección no tiene título', p_lesson_id
      using errcode = '22023';
  end if;
  if v_lesson.difficulty is null or v_lesson.difficulty not between 1 and 6 then
    raise exception 'no se puede publicar %: difficulty fuera de 1..6 (%)', p_lesson_id, v_lesson.difficulty
      using errcode = '22023';
  end if;
  if exists (
    select 1 from public.lesson_versions
     where lesson_id = p_lesson_id and version = v_version
  ) then
    raise exception 'la versión % de % ya está publicada', v_version, p_lesson_id
      using errcode = '22023';
  end if;

  v_snapshot := jsonb_build_object(
    'id', v_lesson.id,
    'source', 'portal',
    'title', v_lesson.title,
    'category', v_lesson.category,
    'difficulty', v_lesson.difficulty,
    'order_index', v_lesson.order_index,
    'main_objective', v_lesson.main_objective,
    'scenario_context', v_lesson.scenario_context,
    'assistant_role', v_lesson.assistant_role,
    'user_role', v_lesson.user_role,
    'initial_message', v_lesson.initial_message,
    'objectives', coalesce((
      select jsonb_agg(jsonb_build_object(
               'code', o.code,
               'description', o.description,
               'competency', o.competency,
               'criterion', o.criterion,
               'evidence_examples', o.evidence_examples,
               'common_errors', o.common_errors,
               'is_required', o.is_required,
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
               'translation_status', p.translation_status,
               'audio_url', p.audio_url
             ) order by p.order_index)
        from public.lesson_phrases p
       where p.lesson_id = p_lesson_id and p.version = v_version
    ), '[]'::jsonb),
    'activities', coalesce((
      select jsonb_agg(jsonb_build_object(
               'activity_type', a.activity_type,
               'order_index', a.order_index,
               'instructions', a.instructions,
               'payload', a.payload,
               'scoring', a.scoring,
               'feedback_good', a.feedback_good,
               'feedback_bad', a.feedback_bad
             ) order by a.order_index)
        from public.lesson_activities a
       where a.lesson_id = p_lesson_id and a.version = v_version
    ), '[]'::jsonb)
  );

  insert into public.lesson_versions (
    lesson_id, version, snapshot, changelog, published_at, published_by
  )
  values (
    p_lesson_id, v_version, v_snapshot, p_changelog, now(), v_actor
  );

  update public.lessons
     set current_version = v_version,
         status          = 'published',
         updated_at      = now()
   where id = p_lesson_id;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (
    v_actor, 'lesson', p_lesson_id, 'publish',
    jsonb_build_object(
      'version', v_version,
      'previous_version', v_lesson.current_version,
      'previous_status', v_lesson.status,
      'objectives', v_objectives,
      'phrases', v_phrases,
      'activities', v_activities,
      'changelog', p_changelog
    )
  );

  return jsonb_build_object(
    'lesson_id', p_lesson_id,
    'version', v_version,
    'previous_version', v_lesson.current_version,
    'objectives', v_objectives,
    'phrases', v_phrases,
    'activities', v_activities,
    'published_by', v_actor
  );
end;
$$;

comment on function public.admin_publish_lesson(text, text) is
  'Publica el borrador en una transacción y congela el snapshot (CUR-09). Exige la capacidad publish. Falla entera si algo no valida.';

revoke all on function public.admin_publish_lesson(text, text) from public;
revoke all on function public.admin_publish_lesson(text, text) from anon;
grant execute on function public.admin_publish_lesson(text, text) to authenticated, service_role;
