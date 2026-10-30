-- Fix del heartbeat de presencia: el cliente llamaba a `report_presence(p_section)`
-- desde hace tiempo, pero la función nunca existió en producción (PGRST202 en cada
-- latido). Se crea la tabla + RPC mínimos para que la presencia por sección sea real.
--
-- Solo guarda una fila por usuario (última sección y último latido): no crece sin
-- control y no expone datos de otros (RLS de lectura propia).

begin;

create table if not exists public.user_presence (
  user_id uuid primary key references public.users(id) on delete cascade,
  section text not null,
  last_seen_at timestamptz not null default now()
);

alter table public.user_presence enable row level security;

drop policy if exists user_presence_select_own on public.user_presence;
create policy user_presence_select_own on public.user_presence
  for select to authenticated using (auth.uid() = user_id);

revoke insert, update, delete on public.user_presence from anon, authenticated;

create or replace function public.report_presence(p_section text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_section text := left(coalesce(nullif(trim(p_section), ''), 'unknown'), 40);
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  insert into public.user_presence (user_id, section, last_seen_at)
  values (v_uid, v_section, now())
  on conflict (user_id) do update
    set section = excluded.section,
        last_seen_at = now();
end;
$$;

revoke all on function public.report_presence(text) from public, anon;
grant execute on function public.report_presence(text) to authenticated;

comment on function public.report_presence(text) is
  'Heartbeat de presencia por seccion (una fila por usuario). Escribe con SECURITY DEFINER.';

commit;
