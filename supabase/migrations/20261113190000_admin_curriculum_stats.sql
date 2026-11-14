-- Dashboard curricular: conteos por nivel y estado (CUR-11).
--
-- Devuelve todo lo que pinta el panel en una sola llamada, para que la pantalla
-- no encadene cinco consultas ni calcule totales en el cliente.
--
-- Los conteos de contenido se hacen sobre la **versión vigente** de cada
-- lección (`current_version`), no sobre todas las versiones: si no, cada
-- publicación inflaría los totales con el histórico.
--
-- Requiere la capacidad `read`, que tienen los seis roles del portal.

create or replace function public.admin_curriculum_stats()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_result jsonb;
begin
  if not (public.admin_can('read') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad read' using errcode = '42501';
  end if;

  with lesson_stats as (
    select
      l.id,
      l.unit_id,
      l.status,
      l.current_version,
      (select count(*) from public.lesson_objectives o
        where o.lesson_id = l.id and o.version = l.current_version) as objectives,
      (select count(*) from public.lesson_objectives o
        where o.lesson_id = l.id and o.version = l.current_version and o.needs_review) as weak,
      (select count(*) from public.lesson_phrases p
        where p.lesson_id = l.id and p.version = l.current_version) as phrases,
      (select count(*) from public.lesson_phrases p
        where p.lesson_id = l.id and p.version = l.current_version
          and p.translation_status = 'identical') as identical,
      (select count(*) from public.lesson_activities a
        where a.lesson_id = l.id and a.version = l.current_version) as activities
      from public.lessons l
  ),
  by_level as (
    select
      u.level_id,
      count(distinct u.id) as units,
      count(ls.id) as lessons,
      count(ls.id) filter (where ls.status = 'published') as published,
      coalesce(sum(ls.objectives), 0) as objectives,
      coalesce(sum(ls.phrases), 0) as phrases,
      coalesce(sum(ls.identical), 0) as identical,
      coalesce(sum(ls.weak), 0) as weak,
      coalesce(sum(ls.activities), 0) as activities
      from public.curriculum_units u
      left join lesson_stats ls on ls.unit_id = u.id
     group by u.level_id
  )
  select jsonb_build_object(
    'levels', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', lv.id,
               'name', lv.name,
               'cefr', lv.cefr,
               'order_index', lv.order_index,
               'units', coalesce(bl.units, 0),
               'lessons', coalesce(bl.lessons, 0),
               'published', coalesce(bl.published, 0),
               'objectives', coalesce(bl.objectives, 0),
               'phrases', coalesce(bl.phrases, 0),
               'identical', coalesce(bl.identical, 0),
               'weak', coalesce(bl.weak, 0),
               'activities', coalesce(bl.activities, 0)
             ) order by lv.order_index)
        from public.curriculum_levels lv
        left join by_level bl on bl.level_id = lv.id
    ), '[]'::jsonb),
    'totals', jsonb_build_object(
      'levels', (select count(*) from public.curriculum_levels),
      'units', (select count(*) from public.curriculum_units),
      'lessons', (select count(*) from lesson_stats),
      'published', (select count(*) from lesson_stats where status = 'published'),
      'draft', (select count(*) from lesson_stats where status = 'draft'),
      'review', (select count(*) from lesson_stats where status = 'review'),
      'archived', (select count(*) from lesson_stats where status = 'archived'),
      'versions', (select count(*) from public.lesson_versions),
      'objectives', (select coalesce(sum(objectives), 0) from lesson_stats),
      'phrases', (select coalesce(sum(phrases), 0) from lesson_stats),
      'identical', (select coalesce(sum(identical), 0) from lesson_stats),
      'weak', (select coalesce(sum(weak), 0) from lesson_stats),
      'activities', (select coalesce(sum(activities), 0) from lesson_stats)
    )
  )
  into v_result;

  return v_result;
end;
$$;

comment on function public.admin_curriculum_stats() is
  'Conteos del currículo por nivel y estado para el panel (CUR-11). Cuenta sobre la versión vigente de cada lección.';

revoke all on function public.admin_curriculum_stats() from public;
revoke all on function public.admin_curriculum_stats() from anon;
grant execute on function public.admin_curriculum_stats() to authenticated, service_role;
