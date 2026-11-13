-- Santuario del cazador: base persistente y ampliaciones (#379).
--
-- Primer sumidero de oro de F2. El jugador amplía su base pagando oro; cada
-- ampliación da un slot de decoración. Es el gasto que no compite con el
-- aprendizaje y no depende de otros jugadores (a diferencia de la taberna).
--
-- Reutiliza `economy_apply_currency`, así que todo movimiento queda en
-- `currency_ledger` con `ref_key` idempotente.

create table if not exists public.player_sanctuary (
  user_id    uuid primary key references public.users(id) on delete cascade,
  level      integer not null default 1 check (level between 1 and 5),
  slots      integer not null default 3 check (slots between 3 and 20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.player_sanctuary enable row level security;

drop policy if exists select_own_sanctuary on public.player_sanctuary;
create policy select_own_sanctuary on public.player_sanctuary
  for select using (auth.uid() = user_id);

comment on table public.player_sanctuary is
  'Base persistente del cazador (#379). Escritura solo por RPC SECURITY DEFINER.';

-- Ampliar: coste creciente en oro, idempotente por ref_key.
create or replace function public.upgrade_sanctuary(p_ref_key text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid    uuid := auth.uid();
  v_level  integer;
  v_slots  integer;
  v_cost   integer;
  v_move   jsonb;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;
  if p_ref_key is null or length(trim(p_ref_key)) = 0 then
    return jsonb_build_object('success', false, 'reason', 'bad_ref');
  end if;

  insert into public.player_sanctuary (user_id)
  values (v_uid)
  on conflict (user_id) do nothing;

  select level, slots into v_level, v_slots
    from public.player_sanctuary
   where user_id = v_uid
   for update;

  if v_level >= 5 then
    return jsonb_build_object('success', false, 'reason', 'max_level',
                              'level', v_level, 'slots', v_slots);
  end if;

  -- 150, 250, 400, 600: gasto real para un usuario que gana ~10 oro/objetivo.
  v_cost := (array[150, 250, 400, 600])[v_level];

  v_move := public.economy_apply_currency(
    v_uid, 'gold', -v_cost, 'sanctuary_upgrade', p_ref_key);

  if coalesce((v_move ->> 'duplicated')::boolean, false) then
    return jsonb_build_object('success', true, 'duplicated', true,
                              'level', v_level, 'slots', v_slots,
                              'balance', (v_move ->> 'balance')::integer);
  end if;

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object('success', false,
      'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'cost', v_cost, 'balance', coalesce((v_move ->> 'balance')::integer, 0));
  end if;

  update public.player_sanctuary
     set level = v_level + 1,
         slots = least(20, v_slots + 2),
         updated_at = now()
   where user_id = v_uid;

  return jsonb_build_object('success', true, 'duplicated', false,
                            'cost', v_cost, 'level', v_level + 1,
                            'slots', least(20, v_slots + 2),
                            'balance', (v_move ->> 'balance')::integer);
end;
$$;

revoke execute on function public.upgrade_sanctuary(text) from public, anon;
grant execute on function public.upgrade_sanctuary(text) to authenticated;

-- Coste de la siguiente ampliación, para que la UI no lo invente.
create or replace function public.sanctuary_upgrade_cost(p_level integer)
returns integer
language sql
immutable
as $$
  select case when p_level >= 5 then null
              else (array[150, 250, 400, 600])[p_level] end;
$$;

-- Verificacion:
-- select * from public.player_sanctuary limit 5;
-- select user_id, count(*) from public.currency_ledger
--  where reason = 'sanctuary_upgrade' group by 1;
