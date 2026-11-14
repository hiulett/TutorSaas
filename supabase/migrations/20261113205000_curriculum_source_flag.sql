-- Interruptor de origen del currículo (CUR-16).
--
-- La app necesita saber si lee el catálogo Dart o PostgreSQL. Ese flag es lo
-- que permite activar y **revertir** sin publicar una versión nueva, que es la
-- condición para que la migración sea reversible (plan §7.2 y §24).
--
-- Arranca en `dart`: el contenido ya está importado, pero la app todavía no lee
-- de la base, así que encenderlo antes de tiempo la dejaría sin currículo.

create table if not exists public.app_config (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by uuid
);

insert into public.app_config (key, value)
values ('curriculum_source', '"dart"'::jsonb)
on conflict (key) do nothing;

alter table public.app_config enable row level security;
-- Sin políticas: se lee por RPC y se escribe por RPC con capacidad.

create or replace function public.get_curriculum_source()
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_value text;
begin
  if auth.role() is null then
    raise exception 'se requiere sesión' using errcode = '42501';
  end if;

  select value #>> '{}' into v_value
    from public.app_config
   where key = 'curriculum_source';

  -- Si alguien vacía la tabla, el defecto seguro es el catálogo Dart.
  return coalesce(v_value, 'dart');
end;
$$;

create or replace function public.admin_set_curriculum_source(p_value text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor   uuid := auth.uid();
  v_value   text := lower(btrim(coalesce(p_value, '')));
  v_previous text;
begin
  if not (public.admin_can('publish') or auth.role() = 'service_role') then
    raise exception 'se requiere la capacidad publish' using errcode = '42501';
  end if;

  if v_value not in ('dart', 'db') then
    raise exception 'curriculum_source inválido: % (usa dart o db)', p_value
      using errcode = '22023';
  end if;

  select value #>> '{}' into v_previous
    from public.app_config where key = 'curriculum_source';

  insert into public.app_config (key, value, updated_at, updated_by)
  values ('curriculum_source', to_jsonb(v_value), now(), v_actor)
  on conflict (key) do update set
    value      = excluded.value,
    updated_at = now(),
    updated_by = excluded.updated_by;

  insert into public.content_audit_logs (actor_id, entity, entity_id, action, diff)
  values (v_actor, 'app_config', 'curriculum_source', 'set_curriculum_source',
          jsonb_build_object('from', v_previous, 'to', v_value));

  return jsonb_build_object('key', 'curriculum_source', 'value', v_value, 'previous', v_previous);
end;
$$;

comment on function public.get_curriculum_source() is
  'Origen del currículo para la app: dart | db (CUR-16). Devuelve dart si no hay valor.';
comment on function public.admin_set_curriculum_source(text) is
  'Cambia el origen del currículo con la capacidad publish y lo audita (CUR-16). Reversible sin publicar app.';

revoke all on function public.get_curriculum_source() from public;
revoke all on function public.get_curriculum_source() from anon;
revoke all on function public.admin_set_curriculum_source(text) from public;
revoke all on function public.admin_set_curriculum_source(text) from anon;

grant execute on function public.get_curriculum_source() to authenticated, service_role;
grant execute on function public.admin_set_curriculum_source(text) to authenticated, service_role;
