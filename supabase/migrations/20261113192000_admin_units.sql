-- Unidades: lectura, alta/edición con reordenación y mover lecciones (CUR-12).
--
-- El criterio de la historia es «reordenar y asignar lecciones», y ahí está el
-- problema real: `curriculum_units` tiene `unique (level_id, order_index)` y
-- `lessons` tiene `unique (unit_id, order_index)`. Intercambiar dos posiciones
-- con updates directos choca con la restricción a mitad de camino, así que la
-- renumeración va en **dos pasadas**: primero posiciones negativas temporales,
-- después las definitivas. Es la forma de reordenar sin poder violar el índice.

-- ── Lectura ─────────────────────────────────────────────────────────────────
create or replace function public.admin_units(p_level text default null)
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
    'levels', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', lv.id,
               'cefr', lv.cefr,
               'name', lv.name,
               'order_index', lv.order_index,
               'units', coalesce((
                 select jsonb_agg(jsonb_build_object(
                          'id', u.id,
                          'slug', u.slug,
                          'title', u.title,
                          'description', u.description,
                          'order_index', u.order_index,
                          'lessons', coalesce((
                            select jsonb_agg(jsonb_build_object(
                                     'id', l.id,
                                     'title', l.title,
                                     'order_index', l.order_index,
                                     'status', l.status
                                   ) order by l.order_index)
                              from public.lessons l
                             where l.unit_id = u.id
                               and l.status <> 'archived'
                          ), '[]'::jsonb)
                        ) order by u.order_index)
                   from public.curriculum_units u
                  where u.level_id = lv.id
               ), '[]'::jsonb)
             ) order by lv.order_index)
        from public.curriculum_levels lv
       where p_level is null or lv.id = p_level
    ), '[]'::jsonb)
  );
end;
$$;

-- ── Alta y edición ──────────────────────────────────────────────────────────
create or replace function public.admin_save_unit(p_unit jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor    uuid := auth.uid();
  v_id       uuid;
  v_existing public.curriculum_units;
  v_level    text;
  v_slug     text;
  v_title    text;
  v_desc     text;
  v_order    integer;
  v_count    integer;
  v_ids      uuid[];
  v_new      uuid[];
  v_item     uuid;
  v_position integer := 0;
begin
  if not (public.admin_can('edit_draft') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad edit_draft' using errcode = '42501';
  end if;

  if p_unit is null or jsonb_typeof(p_unit) <> 'object' then
    raise exception 'p_unit debe ser un objeto jsonb' using errcode = '22023';
  end if;

  if nullif(btrim(p_unit->>'id'), '') is not null then
    begin
      v_id := (p_unit->>'id')::uuid;
    exception when others then
      raise exception 'id de unidad inválido: %', p_unit->>'id' using errcode = '22023';
    end;
    select * into v_existing from public.curriculum_units where id = v_id;
    if not found then
      raise exception 'unidad inexistente: %', v_id using errcode = '22023';
    end if;
  end if;

  v_level := coalesce(nullif(btrim(p_unit->>'level_id'), ''), v_existing.level_id);
  v_slug  := coalesce(nullif(btrim(p_unit->>'slug'), ''), v_existing.slug);
  v_title := coalesce(nullif(btrim(p_unit->>'title'), ''), v_existing.title);
  v_desc  := coalesce(p_unit->>'description', v_existing.description);

  if v_level is null then
    raise exception 'falta level_id' using errcode = '22023';
  end if;
  if not exists (select 1 from public.curriculum_levels where id = v_level) then
    raise exception 'nivel inexistente: %', v_level using errcode = '22023';
  end if;
  if v_slug is null then
    raise exception 'falta slug' using errcode = '22023';
  end if;
  if v_title is null then
    raise exception 'falta title' using errcode = '22023';
  end if;
  if exists (
    select 1 from public.curriculum_units
     where level_id = v_level and slug = v_slug and id is distinct from v_id
  ) then
    raise exception 'ya hay una unidad % en %', v_slug, v_level using errcode = '23505';
  end if;

  if v_id is null then
    v_id := gen_random_uuid();
    -- Se inserta al final y la renumeración de abajo la coloca donde toque.
    select coalesce(count(*), 0) + 1 into v_count
      from public.curriculum_units where level_id = v_level;
    insert into public.curriculum_units (id, level_id, slug, title, description, order_index)
    values (v_id, v_level, v_slug, v_title, v_desc, v_count);
  else
    update public.curriculum_units
       set level_id = v_level, slug = v_slug, title = v_title, description = v_desc
     where id = v_id;
  end if;

  -- Orden pedido (1..n+1), con la unidad dentro en esa posición.
  -- `id <> v_id` no vale cuando la unidad es nueva: comparar con NULL no
  -- descarta la fila, la elimina del resultado y dejaría el nivel vacío.
  select coalesce(array_agg(id order by order_index), '{}') into v_ids
    from public.curriculum_units
   where level_id = v_level and (v_id is null or id <> v_id);

  v_count := coalesce(array_length(v_ids, 1), 0);
  v_order := coalesce((p_unit->>'order_index')::integer, v_count + 1);
  v_order := greatest(1, least(v_order, v_count + 1));

  v_new := v_ids[1:v_order - 1] || v_id || v_ids[v_order:];

  -- Dos pasadas: negativas y luego definitivas.
  foreach v_item in array v_new loop
    v_position := v_position + 1;
    update public.curriculum_units set order_index = -v_position where id = v_item;
  end loop;
  v_position := 0;
  foreach v_item in array v_new loop
    v_position := v_position + 1;
    update public.curriculum_units set order_index = v_position where id = v_item;
  end loop;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (
    v_actor, 'unit', v_id::text, 'save_unit',
    jsonb_build_object(
      'level_id', v_level, 'slug', v_slug, 'order_index', v_order,
      'created', v_existing.id is null
    )
  );

  return jsonb_build_object(
    'id', v_id, 'level_id', v_level, 'slug', v_slug,
    'title', v_title, 'order_index', v_order
  );
end;
$$;

-- ── Borrado ─────────────────────────────────────────────────────────────────
create or replace function public.admin_delete_unit(p_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor   uuid := auth.uid();
  v_unit    public.curriculum_units;
  v_lessons integer;
begin
  if not (public.admin_can('edit_draft') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad edit_draft' using errcode = '42501';
  end if;

  select * into v_unit from public.curriculum_units where id = p_id;
  if not found then
    raise exception 'unidad inexistente: %', p_id using errcode = '22023';
  end if;

  select count(*) into v_lessons from public.lessons where unit_id = p_id and status <> 'archived';
  if v_lessons > 0 then
    raise exception 'la unidad % tiene % lecciones; muévelas antes de borrarla', v_unit.slug, v_lessons
      using errcode = '23503';
  end if;

  delete from public.curriculum_units where id = p_id;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (v_actor, 'unit', p_id::text, 'delete_unit',
          jsonb_build_object('level_id', v_unit.level_id, 'slug', v_unit.slug));

  return jsonb_build_object('id', p_id, 'deleted', true);
end;
$$;

-- ── Asignar una lección a una unidad ────────────────────────────────────────
create or replace function public.admin_move_lesson(
  p_lesson_id text,
  p_unit_id uuid,
  p_order_index integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor   uuid := auth.uid();
  v_lesson  public.lessons;
  v_unit    public.curriculum_units;
  v_ids     text[];
  v_new     text[];
  v_count   integer;
  v_order   integer;
  v_item    text;
  v_position integer := 0;
begin
  if not (public.admin_can('edit_draft') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad edit_draft' using errcode = '42501';
  end if;

  select * into v_lesson from public.lessons where id = p_lesson_id;
  if not found then
    raise exception 'lección inexistente: %', p_lesson_id using errcode = '22023';
  end if;
  select * into v_unit from public.curriculum_units where id = p_unit_id;
  if not found then
    raise exception 'unidad inexistente: %', p_unit_id using errcode = '22023';
  end if;

  select coalesce(array_agg(id order by order_index), '{}') into v_ids
    from public.lessons
   where unit_id = p_unit_id and id <> p_lesson_id and status <> 'archived';

  v_count := coalesce(array_length(v_ids, 1), 0);
  v_order := coalesce(p_order_index, v_count + 1);
  v_order := greatest(1, least(v_order, v_count + 1));

  v_new := v_ids[1:v_order - 1] || p_lesson_id || v_ids[v_order:];

  -- Dos pasadas, igual que en las unidades.
  foreach v_item in array v_new loop
    v_position := v_position + 1;
    update public.lessons set order_index = -v_position where id = v_item;
  end loop;
  v_position := 0;
  foreach v_item in array v_new loop
    v_position := v_position + 1;
    update public.lessons set order_index = v_position where id = v_item;
  end loop;

  update public.lessons
     set unit_id = p_unit_id, order_index = v_order, updated_at = now()
   where id = p_lesson_id;

  -- Compacta la unidad de origen si la lección venía de otra.
  if v_lesson.unit_id is not null and v_lesson.unit_id <> p_unit_id then
    v_position := 0;
    for v_item in
      select id from public.lessons
       where unit_id = v_lesson.unit_id and status <> 'archived'
       order by order_index
    loop
      v_position := v_position + 1;
      update public.lessons set order_index = -v_position where id = v_item;
    end loop;
    v_position := 0;
    for v_item in
      select id from public.lessons
       where unit_id = v_lesson.unit_id and status <> 'archived'
       order by order_index
    loop
      v_position := v_position + 1;
      update public.lessons set order_index = v_position where id = v_item;
    end loop;
  end if;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (
    v_actor, 'lesson', p_lesson_id, 'move_lesson',
    jsonb_build_object(
      'from_unit', v_lesson.unit_id,
      'to_unit', p_unit_id,
      'order_index', v_order
    )
  );

  return jsonb_build_object(
    'lesson_id', p_lesson_id,
    'unit_id', p_unit_id,
    'order_index', v_order,
    'previous_unit', v_lesson.unit_id
  );
end;
$$;

comment on function public.admin_units(text) is
  'Niveles con sus unidades y lecciones para el gestor del portal (CUR-12).';
comment on function public.admin_save_unit(jsonb) is
  'Crea o edita una unidad y la renumera en su nivel en dos pasadas (CUR-12).';
comment on function public.admin_move_lesson(text, uuid, integer) is
  'Asigna una lección a una unidad en la posición pedida y compacta el origen (CUR-12).';

revoke all on function public.admin_units(text)                    from public;
revoke all on function public.admin_save_unit(jsonb)               from public;
revoke all on function public.admin_delete_unit(uuid)              from public;
revoke all on function public.admin_move_lesson(text, uuid, integer) from public;

revoke all on function public.admin_units(text)                    from anon;
revoke all on function public.admin_save_unit(jsonb)               from anon;
revoke all on function public.admin_delete_unit(uuid)              from anon;
revoke all on function public.admin_move_lesson(text, uuid, integer) from anon;

grant execute on function public.admin_units(text)                    to authenticated, service_role;
grant execute on function public.admin_save_unit(jsonb)               to authenticated, service_role;
grant execute on function public.admin_delete_unit(uuid)              to authenticated, service_role;
grant execute on function public.admin_move_lesson(text, uuid, integer) to authenticated, service_role;
