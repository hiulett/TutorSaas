-- Issue #9: cuota de uso de IA por usuario.
--
-- `llm-proxy` no tenía rate limit ni cuota: cualquier usuario autenticado podía
-- consumir DeepSeek/Groq sin tope y elegir el modelo. El maná se cobraba en el
-- cliente, así que llamar al proxy directamente lo evitaba.
--
-- Este esquema implementa una ventana deslizante de 60 s. La comprobación se
-- hace desde la Edge Function con `service_role`, antes de gastar tokens.

create table if not exists public.llm_quota_events (
    id         bigserial primary key,
    user_id    uuid not null,
    created_at timestamptz not null default now()
);

create index if not exists idx_llm_quota_user_time
    on public.llm_quota_events (user_id, created_at desc);

alter table public.llm_quota_events enable row level security;
revoke all on public.llm_quota_events from public, anon, authenticated;

create or replace function public.check_llm_quota(
    p_user_id uuid,
    p_limit   integer default 30
)
returns boolean
language plpgsql
security definer
set search_path = public
as $q$
declare
    v_count integer;
begin
    -- service_role (la Edge Function) u el propio usuario.
    if coalesce(auth.role(), '') <> 'service_role' then
        if auth.uid() is null or auth.uid() <> p_user_id then
            return false;
        end if;
    end if;

    -- Limpieza oportunista: la tabla no crece sin control.
    delete from public.llm_quota_events where created_at < now() - interval '1 hour';

    select count(*) into v_count
      from public.llm_quota_events
     where user_id = p_user_id
       and created_at > now() - interval '1 minute';

    if v_count >= greatest(1, coalesce(p_limit, 30)) then
        return false;
    end if;

    insert into public.llm_quota_events (user_id) values (p_user_id);
    return true;
end;
$q$;

revoke all on function public.check_llm_quota(uuid, integer) from public, anon;
grant execute on function public.check_llm_quota(uuid, integer) to authenticated, service_role;
