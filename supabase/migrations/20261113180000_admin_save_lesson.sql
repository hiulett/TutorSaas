-- RPC de guardado de borradores del portal (CUR-08).
--
-- `admin_save_lesson` valida el borrador, lo escribe como **borrador** y lo
-- audita. No publica: publicar es `admin_publish_lesson` (CUR-09), y esa
-- separación es la que hace que `editor` no pueda saltarse la revisión.
--
-- Regla que evita el peor fallo posible: **editar una lección publicada no la
-- despublica**. El borrador vive en `current_version + 1` y la lección sigue
-- con `status='published'`, así que `get_curriculum_pack` la sigue sirviendo con
-- la versión vigente mientras hay cambios en curso. Si el guardado cambiara el
-- estado a `draft`, editar una lección la haría desaparecer de la app.
--
-- El borrador es idempotente por versión: guardar dos veces sobre la misma
-- versión en curso reemplaza las filas de esa versión, no acumula duplicados.

-- ── Auditoría ───────────────────────────────────────────────────────────────
create table if not exists public.content_audit_logs (
  id         bigserial primary key,
  actor_id   uuid,
  entity     text not null,
  entity_id  text not null,
  action     text not null,
  diff       jsonb,
  created_at timestamptz not null default now()
);

-- `actor_id` sin clave foránea a propósito: el registro de auditoría debe
-- sobrevivir al borrado del usuario, y un `on delete set null` sería un UPDATE
-- que choca con la inmutabilidad de abajo.
create index if not exists idx_content_audit_logs_entity
  on public.content_audit_logs (entity, entity_id, created_at desc);

create or replace function public.content_audit_logs_immutable()
returns trigger
language plpgsql
as $$
begin
  raise exception 'content_audit_logs es inmutable (no admite UPDATE ni DELETE)'
    using errcode = '42501';
end;
$$;

drop trigger if exists trg_content_audit_logs_immutable on public.content_audit_logs;
create trigger trg_content_audit_logs_immutable
  before update or delete on public.content_audit_logs
  for each row execute function public.content_audit_logs_immutable();

alter table public.content_audit_logs enable row level security;
-- Sin políticas: se lee por RPC del portal y solo se escribe desde funciones.

-- ── Guardado del borrador ───────────────────────────────────────────────────
create or replace function public.admin_save_lesson(
  p_lesson jsonb,
  p_changelog text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor      uuid := auth.uid();
  v_id         text;
  v_title      text;
  v_unit       uuid;
  v_difficulty integer;
  v_existing   public.lessons;
  v_status     text;
  v_current    integer;
  v_draft      integer;
  v_item       jsonb;
  v_position   integer;
  v_codes      text[] := array[]::text[];
  v_orders     integer[] := array[]::integer[];
  v_objectives integer := 0;
  v_phrases    integer := 0;
  v_activities integer := 0;
begin
  if not (public.admin_can('edit_draft') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad edit_draft' using errcode = '42501';
  end if;

  if p_lesson is null or jsonb_typeof(p_lesson) <> 'object' then
    raise exception 'p_lesson debe ser un objeto jsonb' using errcode = '22023';
  end if;

  v_id := nullif(btrim(p_lesson->>'id'), '');
  if v_id is null then
    raise exception 'falta el id de la lección' using errcode = '22023';
  end if;

  v_title := nullif(btrim(p_lesson->>'title'), '');
  if v_title is null then
    raise exception 'falta el título de la lección' using errcode = '22023';
  end if;

  if nullif(btrim(p_lesson->>'unit_id'), '') is not null then
    begin
      v_unit := (p_lesson->>'unit_id')::uuid;
    exception when others then
      raise exception 'unit_id no es un uuid válido: %', p_lesson->>'unit_id'
        using errcode = '22023';
    end;
    if not exists (select 1 from public.curriculum_units where id = v_unit) then
      raise exception 'unidad inexistente: %', v_unit using errcode = '22023';
    end if;
  end if;

  if nullif(btrim(p_lesson->>'difficulty'), '') is not null then
    begin
      v_difficulty := (p_lesson->>'difficulty')::integer;
    exception when others then
      raise exception 'difficulty no es un entero: %', p_lesson->>'difficulty'
        using errcode = '22023';
    end;
    if v_difficulty not between 1 and 6 then
      raise exception 'difficulty fuera del rango 1..6: %', v_difficulty
        using errcode = '22023';
    end if;
  end if;

  select * into v_existing from public.lessons where id = v_id;

  if found then
    v_current := v_existing.current_version;
    v_status  := v_existing.status;
    if v_status = 'published' then
      v_status  := 'published';          -- editar no despublica
      v_draft   := v_current + 1;
    else
      v_status  := 'draft';
      v_draft   := v_current;            -- se reescribe el borrador en curso
    end if;
  else
    v_current := 1;
    v_status  := 'draft';
    v_draft   := 1;
  end if;

  insert into public.lessons (
    id, unit_id, title, category, difficulty, order_index,
    main_objective, scenario_context, assistant_role, user_role, initial_message,
    status, current_version
  )
  values (
    v_id,
    v_unit,
    v_title,
    coalesce(nullif(btrim(p_lesson->>'category'), ''), 'daily'),
    v_difficulty,
    coalesce((p_lesson->>'order_index')::integer, v_existing.order_index, 0),
    nullif(btrim(p_lesson->>'main_objective'), ''),
    nullif(btrim(p_lesson->>'scenario_context'), ''),
    nullif(btrim(p_lesson->>'assistant_role'), ''),
    nullif(btrim(p_lesson->>'user_role'), ''),
    nullif(btrim(p_lesson->>'initial_message'), ''),
    v_status,
    v_current
  )
  on conflict (id) do update set
    unit_id           = excluded.unit_id,
    title             = excluded.title,
    category          = excluded.category,
    difficulty        = excluded.difficulty,
    order_index       = excluded.order_index,
    main_objective    = excluded.main_objective,
    scenario_context  = excluded.scenario_context,
    assistant_role    = excluded.assistant_role,
    user_role         = excluded.user_role,
    initial_message   = excluded.initial_message,
    status            = excluded.status,
    current_version   = excluded.current_version,
    updated_at        = now();

  -- El borrador se reemplaza entero: guardar dos veces no acumula filas.
  delete from public.lesson_objectives where lesson_id = v_id and version = v_draft;
  delete from public.lesson_phrases    where lesson_id = v_id and version = v_draft;
  delete from public.lesson_activities where lesson_id = v_id and version = v_draft;

  v_position := 0;
  for v_item in select * from jsonb_array_elements(coalesce(p_lesson->'objectives', '[]'::jsonb))
  loop
    v_position := v_position + 1;
    if nullif(btrim(v_item->>'code'), '') is null then
      raise exception 'objetivo % sin code', v_position using errcode = '22023';
    end if;
    if nullif(btrim(v_item->>'description'), '') is null then
      raise exception 'objetivo % sin description', v_position using errcode = '22023';
    end if;
    if v_item->>'code' = any (v_codes) then
      raise exception 'code de objetivo repetido: %', v_item->>'code' using errcode = '22023';
    end if;
    v_codes := v_codes || (v_item->>'code');

    if coalesce(v_item->>'competency', 'communication') not in (
      'speaking', 'vocabulary', 'grammar', 'listening',
      'reading', 'writing', 'pronunciation', 'communication'
    ) then
      raise exception 'competency inválida en el objetivo %: %', v_item->>'code', v_item->>'competency'
        using errcode = '22023';
    end if;

    insert into public.lesson_objectives (
      lesson_id, version, code, description, competency, criterion,
      evidence_examples, common_errors, is_required, needs_review, review_reason, order_index
    )
    values (
      v_id, v_draft, v_item->>'code', v_item->>'description',
      coalesce(v_item->>'competency', 'communication'),
      nullif(btrim(v_item->>'criterion'), ''),
      v_item->'evidence_examples', v_item->'common_errors',
      coalesce((v_item->>'is_required')::boolean, true),
      coalesce((v_item->>'needs_review')::boolean, false),
      nullif(btrim(v_item->>'review_reason'), ''),
      coalesce((v_item->>'order_index')::integer, v_position)
    );
    v_objectives := v_objectives + 1;
  end loop;

  v_position := 0;
  for v_item in select * from jsonb_array_elements(coalesce(p_lesson->'phrases', '[]'::jsonb))
  loop
    v_position := v_position + 1;
    if nullif(btrim(v_item->>'phrase'), '') is null then
      raise exception 'frase % sin texto', v_position using errcode = '22023';
    end if;
    if coalesce((v_item->>'order_index')::integer, v_position) = any (v_orders) then
      raise exception 'order_index de frase repetido: %', v_position using errcode = '22023';
    end if;
    v_orders := v_orders || coalesce((v_item->>'order_index')::integer, v_position);

    insert into public.lesson_phrases (
      lesson_id, version, phrase, translation, translation_status, audio_url, order_index
    )
    values (
      v_id, v_draft, v_item->>'phrase',
      nullif(btrim(v_item->>'translation'), ''),
      coalesce(
        nullif(btrim(v_item->>'translation_status'), ''),
        case
          when nullif(btrim(v_item->>'translation'), '') is null then 'pending'
          when lower(btrim(v_item->>'translation')) = lower(btrim(v_item->>'phrase')) then 'identical'
          else 'ok'
        end
      ),
      nullif(btrim(v_item->>'audio_url'), ''),
      coalesce((v_item->>'order_index')::integer, v_position)
    );
    v_phrases := v_phrases + 1;
  end loop;

  v_position := 0;
  for v_item in select * from jsonb_array_elements(coalesce(p_lesson->'activities', '[]'::jsonb))
  loop
    v_position := v_position + 1;
    if not exists (
      select 1 from public.activity_types t
       where t.code = v_item->>'activity_type' and t.is_enabled
    ) then
      raise exception 'tipo de actividad inexistente o deshabilitado: %', coalesce(v_item->>'activity_type', '(vacío)')
        using errcode = '22023';
    end if;
    if jsonb_typeof(coalesce(v_item->'payload', 'null'::jsonb)) <> 'object' then
      raise exception 'la actividad % necesita un payload objeto', v_position
        using errcode = '22023';
    end if;

    insert into public.lesson_activities (
      lesson_id, version, activity_type, order_index,
      instructions, payload, scoring, feedback_good, feedback_bad
    )
    values (
      v_id, v_draft, v_item->>'activity_type',
      coalesce((v_item->>'order_index')::integer, v_position),
      nullif(btrim(v_item->>'instructions'), ''),
      v_item->'payload',
      v_item->'scoring',
      nullif(btrim(v_item->>'feedback_good'), ''),
      nullif(btrim(v_item->>'feedback_bad'), '')
    );
    v_activities := v_activities + 1;
  end loop;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (
    v_actor, 'lesson', v_id, 'save_draft',
    jsonb_build_object(
      'draft_version', v_draft,
      'lesson_status', v_status,
      'objectives', v_objectives,
      'phrases', v_phrases,
      'activities', v_activities,
      'changelog', p_changelog
    )
  );

  return jsonb_build_object(
    'lesson_id', v_id,
    'draft_version', v_draft,
    'lesson_status', v_status,
    'published_version', case when v_status = 'published' then v_current else null end,
    'objectives', v_objectives,
    'phrases', v_phrases,
    'activities', v_activities
  );
end;
$$;

comment on function public.admin_save_lesson(jsonb, text) is
  'Guarda un borrador de lección y lo audita (CUR-08). No publica: eso es CUR-09. Editar una lección publicada no la despublica.';

revoke all on function public.admin_save_lesson(jsonb, text) from public;
revoke all on function public.admin_save_lesson(jsonb, text) from anon;
grant execute on function public.admin_save_lesson(jsonb, text) to authenticated, service_role;
