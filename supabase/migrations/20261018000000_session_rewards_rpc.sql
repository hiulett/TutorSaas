-- Issue #3 / #4: recompensas de sesión calculadas y aplicadas en servidor.
--
-- Antes el cliente calculaba XP/oro/fragmentos y llamaba a RPC de crédito libre
-- (add_xp, add_gold, add_fragments), que solo validaban identidad y aceptaban
-- cualquier importe.
--
-- Este RPC:
--   * valida que el llamante sea el dueño del perfil;
--   * acota objetivos y minutos a rangos razonables;
--   * calcula los importes en servidor (el cliente ya no los elige);
--   * es idempotente por session_id (doble cierre no duplica la recompensa).

begin;

create table if not exists public.session_reward_ledger (
    session_id      text primary key,
    user_id         uuid not null references auth.users (id) on delete cascade,
    language_id     integer not null default 1,
    objectives      integer not null,
    minutes         integer not null,
    xp_awarded      integer not null,
    gold_awarded    integer not null,
    fragments_awarded integer not null,
    created_at      timestamptz not null default now()
);

alter table public.session_reward_ledger enable row level security;

drop policy if exists "session_rewards_select_own" on public.session_reward_ledger;
create policy "session_rewards_select_own"
    on public.session_reward_ledger
    for select
    to authenticated
    using (auth.uid() = user_id);

create index if not exists idx_session_reward_ledger_user
    on public.session_reward_ledger (user_id, created_at desc);

create or replace function public.apply_session_rewards(
    p_user_id       uuid,
    p_session_id    text,
    p_objectives    integer,
    p_minutes       integer,
    p_level_code    text default 'A1',
    p_language_id   integer default 1
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_bonus     integer;
    v_xp        integer;
    v_gold      integer;
    v_fragments integer;
    v_dup       public.session_reward_ledger%rowtype;
begin
    if auth.uid() is null or auth.uid() <> p_user_id then
        raise exception 'No autorizado';
    end if;

    if p_session_id is null or length(trim(p_session_id)) = 0 then
        raise exception 'session_id requerido';
    end if;

    if p_objectives is null or p_objectives < 0 or p_objectives > 12 then
        raise exception 'objetivos fuera de rango';
    end if;

    if p_minutes is null or p_minutes < 0 or p_minutes > 240 then
        raise exception 'minutos fuera de rango';
    end if;

    -- Idempotencia: una sesión paga una sola vez.
    select * into v_dup
      from public.session_reward_ledger
     where session_id = p_session_id;

    if found then
        return jsonb_build_object(
            'success', true,
            'duplicated', true,
            'xp', v_dup.xp_awarded,
            'gold', v_dup.gold_awarded,
            'fragments', v_dup.fragments_awarded
        );
    end if;

    v_bonus := case upper(coalesce(p_level_code, 'A1'))
                   when 'A2' then 1
                   when 'B1' then 2
                   when 'B2' then 3
                   when 'C1' then 4
                   when 'C2' then 5
                   else 0
               end;

    v_xp        := p_minutes * 10;
    v_gold      := p_objectives * (10 + v_bonus);
    v_fragments := p_objectives * (5 + v_bonus);

    insert into public.session_reward_ledger (
        session_id, user_id, language_id, objectives, minutes,
        xp_awarded, gold_awarded, fragments_awarded
    ) values (
        p_session_id, p_user_id, p_language_id, p_objectives, p_minutes,
        v_xp, v_gold, v_fragments
    );

    update public.user_language_profiles
       set xp_points   = coalesce(xp_points, 0) + v_xp,
           total_gold  = coalesce(total_gold, 0) + v_gold,
           fragments   = coalesce(fragments, 0) + v_fragments
     where user_id = p_user_id
       and language_id = p_language_id;

    return jsonb_build_object(
        'success', true,
        'duplicated', false,
        'xp', v_xp,
        'gold', v_gold,
        'fragments', v_fragments
    );
end;
$$;

revoke all on function public.apply_session_rewards(uuid, text, integer, integer, text, integer) from public, anon;
grant execute on function public.apply_session_rewards(uuid, text, integer, integer, text, integer) to authenticated;

commit;
