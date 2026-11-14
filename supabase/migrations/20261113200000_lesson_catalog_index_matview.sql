-- `lesson_catalog_index` servida desde `lessons` (CUR-06).
--
-- La tabla actual se pobló desde el catálogo Dart. Ahora que el contenido vive
-- en PostgreSQL, el índice se deriva de `lessons` como **vista materializada**
-- con el mismo nombre y las mismas columnas, para no romper a quien la lee:
-- `refresh_recommended_path` la consulta (`lesson_id`, `title`, `category`).
--
-- La tabla vieja no se borra: se renombra a `lesson_catalog_index_legacy`, que
-- es el rollback inmediato. La vista no tiene RLS (no se puede), así que el
-- acceso se controla con `grant`: solo `authenticated`, que es lo que veía
-- contenido (con la clave anónima devolvía 0 filas por RLS).
--
-- Se mantiene fresca con un trigger sobre `lessons`: publicar o editar mueve el
-- índice sin que nadie tenga que acordarse de refrescarlo. Son 140 filas, así
-- que un refresh completo por sentencia es barato.

-- ── La tabla pasa a legacy (solo la primera vez) ─────────────────────────────
do $$
begin
  if exists (
    select 1
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public'
       and c.relname = 'lesson_catalog_index'
       and c.relkind = 'r'
  ) then
    alter table public.lesson_catalog_index rename to lesson_catalog_index_legacy;
  end if;
end;
$$;

-- ── Vista materializada ─────────────────────────────────────────────────────
create materialized view if not exists public.lesson_catalog_index as
select
  l.id          as lesson_id,
  lv.cefr       as level,
  l.title,
  l.category,
  l.updated_at
  from public.lessons l
  join public.curriculum_units u on u.id = l.unit_id
  join public.curriculum_levels lv on lv.id = u.level_id
 where l.status = 'published';

create unique index if not exists lesson_catalog_index_lesson_id_key
  on public.lesson_catalog_index (lesson_id);

grant select on public.lesson_catalog_index to authenticated;

comment on materialized view public.lesson_catalog_index is
  'Índice de lecciones publicado derivado de lessons (CUR-06). Se refresca por trigger; la tabla anterior queda como lesson_catalog_index_legacy.';

-- ── Refresco ────────────────────────────────────────────────────────────────
create or replace function public.admin_refresh_catalog_index()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not (public.admin_can('publish') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad publish' using errcode = '42501';
  end if;

  refresh materialized view public.lesson_catalog_index;

  return jsonb_build_object(
    'rows',
    (select count(*) from public.lesson_catalog_index)
  );
end;
$$;

-- Trigger de refresco. `refresh` normal y no `concurrently`: el concurrente no
-- puede ejecutarse dentro de una transacción, y esto corre dentro de la del
-- change. Con 140 filas el bloqueo es despreciable.
create or replace function public.trg_refresh_catalog_index()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  refresh materialized view public.lesson_catalog_index;
  return null;
end;
$$;

drop trigger if exists trg_lessons_refresh_catalog_index on public.lessons;
create trigger trg_lessons_refresh_catalog_index
  after insert or update or delete on public.lessons
  for each statement execute function public.trg_refresh_catalog_index();

refresh materialized view public.lesson_catalog_index;

revoke all on function public.admin_refresh_catalog_index() from public;
revoke all on function public.admin_refresh_catalog_index() from anon;
grant execute on function public.admin_refresh_catalog_index() to authenticated, service_role;
