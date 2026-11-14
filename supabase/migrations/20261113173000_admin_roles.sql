-- Roles y permisos del portal administrativo (CUR-10).
--
-- Seis roles (plan §13) con la matriz de permisos como **datos**, no como
-- código: añadir un permiso no debe exigir tocar cinco funciones. Lo que no
-- cambia es el rol que publica: `editor` edita borradores y **no** publica.
--
-- Las tablas `admin_*` llevan RLS sin políticas: se leen por las funciones de
-- abajo, no directamente desde el cliente. El portal (web_admin) entra con la
-- clave anónima y sesión de usuario, así que todo pasa por RPC SECURITY DEFINER.
--
-- `auth.uid()` es el usuario del JWT; sin sesión devuelve null y ninguna de
-- estas funciones concede nada. `service_role` no necesita permisos: omite RLS
-- por diseño y se usa en scripts, no en el portal.

-- ── Roles ───────────────────────────────────────────────────────────────────
create table if not exists public.admin_roles (
  code        text primary key,
  name        text not null,
  description text,
  order_index integer not null unique
);

insert into public.admin_roles (code, name, description, order_index)
values
  ('viewer',        'Observador',   'Solo lectura del contenido y del historial.',        1),
  ('reviewer',      'Revisor',      'Revisa objetivos, traducciones y lecciones en review.', 2),
  ('editor',        'Editor',       'Crea y edita borradores. No publica.',              3),
  ('publisher',     'Publicador',   'Publica contenido ya revisado.',                    4),
  ('content_admin', 'Administrador de contenido', 'Edita, revisa y publica contenido y estructura curricular.', 5),
  ('superadmin',    'Superadministrador', 'Todo lo anterior y gestión de roles.',        6)
on conflict (code) do nothing;

-- ── Matriz de permisos ──────────────────────────────────────────────────────
--   read         leer contenido y borradores
--   review       marcar revisado / aprobar
--   edit_draft   crear y editar borradores
--   publish      publicar una versión
--   manage_roles conceder o cambiar roles
create table if not exists public.admin_role_capabilities (
  role_code  text not null references public.admin_roles(code) on delete cascade,
  capability text not null,
  primary key (role_code, capability)
);

insert into public.admin_role_capabilities (role_code, capability)
values
  ('viewer',        'read'),
  ('reviewer',      'read'), ('reviewer',      'review'),
  ('editor',        'read'), ('editor',        'edit_draft'),
  ('publisher',     'read'), ('publisher',     'review'), ('publisher', 'publish'),
  ('content_admin', 'read'), ('content_admin', 'edit_draft'), ('content_admin', 'review'), ('content_admin', 'publish'),
  ('superadmin',    'read'), ('superadmin',    'edit_draft'), ('superadmin', 'review'), ('superadmin', 'publish'), ('superadmin', 'manage_roles')
on conflict (role_code, capability) do nothing;

-- ── Quién es quién ──────────────────────────────────────────────────────────
create table if not exists public.admin_users (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  role_code  text not null references public.admin_roles(code) on delete restrict,
  granted_by uuid references auth.users(id) on delete set null,
  granted_at timestamptz not null default now()
);

create index if not exists idx_admin_users_role on public.admin_users (role_code);

alter table public.admin_roles             enable row level security;
alter table public.admin_role_capabilities enable row level security;
alter table public.admin_users             enable row level security;
-- Sin políticas: lectura por RPC, escritura por `admin_set_role`.

-- ── Permisos ────────────────────────────────────────────────────────────────
create or replace function public.admin_role_can(p_role text, p_capability text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.admin_role_capabilities c
     where c.role_code = p_role
       and c.capability = p_capability
  );
$$;

create or replace function public.admin_can(p_capability text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.admin_users u
      join public.admin_role_capabilities c on c.role_code = u.role_code
     where u.user_id = auth.uid()
       and c.capability = p_capability
  );
$$;

create or replace function public.admin_session()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'user_id', u.user_id,
    'role', u.role_code,
    'capabilities', coalesce((
      select jsonb_agg(c.capability order by c.capability)
        from public.admin_role_capabilities c
       where c.role_code = u.role_code
    ), '[]'::jsonb)
  )
    from public.admin_users u
   where u.user_id = auth.uid();
$$;

create or replace function public.admin_set_role(p_user uuid, p_role text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_previous text;
begin
  if not (public.admin_can('manage_roles') or auth.role() = 'service_role') then
    raise exception 'solo un superadmin puede asignar roles'
      using errcode = '42501';
  end if;

  if not exists (select 1 from public.admin_roles where code = p_role) then
    raise exception 'rol desconocido: %', p_role
      using errcode = '22023';
  end if;

  if p_user = auth.uid() and p_role <> 'superadmin' then
    raise exception 'un superadmin no puede quitarse el rol a sí mismo'
      using errcode = '22023';
  end if;

  select role_code into v_previous
    from public.admin_users
   where user_id = p_user;

  insert into public.admin_users (user_id, role_code, granted_by)
  values (p_user, p_role, auth.uid())
  on conflict (user_id) do update
    set role_code  = excluded.role_code,
        granted_by = excluded.granted_by,
        granted_at = now();

  return jsonb_build_object(
    'user_id', p_user,
    'role', p_role,
    'previous_role', v_previous
  );
end;
$$;

comment on table public.admin_users is
  'Roles del portal (CUR-10). Sin políticas RLS: se consulta por admin_session() y se escribe por admin_set_role().';
comment on function public.admin_can(text) is
  'Capacidad del usuario del JWT (CUR-10): true solo si su rol la tiene.';
comment on function public.admin_set_role(uuid, text) is
  'Concede o cambia el rol de un usuario (CUR-10). Exige superadmin o service_role.';

revoke all on function public.admin_role_can(text, text)     from public;
revoke all on function public.admin_can(text)             from public;
revoke all on function public.admin_session()             from public;
revoke all on function public.admin_set_role(uuid, text)  from public;

revoke all on function public.admin_role_can(text, text)     from anon;
revoke all on function public.admin_can(text)             from anon;
revoke all on function public.admin_session()             from anon;
revoke all on function public.admin_set_role(uuid, text)  from anon;

grant execute on function public.admin_role_can(text, text)     to authenticated, service_role;
grant execute on function public.admin_can(text)             to authenticated, service_role;
grant execute on function public.admin_session()             to authenticated, service_role;
grant execute on function public.admin_set_role(uuid, text)  to authenticated, service_role;

-- Arranque manual, una sola vez y con tu propio usuario:
--   select public.admin_set_role('<uuid del usuario>', 'superadmin');
