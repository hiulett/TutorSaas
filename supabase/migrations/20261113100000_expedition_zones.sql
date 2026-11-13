-- Expedicion: desbloqueo de zonas con oro (#403).
--
-- Sumidero de oro basado en ACCESO a contenido extra, nunca en ventaja ni en
-- bloquear el plan de estudios base. Mismo patron que el santuario: libro mayor
-- e idempotencia por `ref_key`.

create table if not exists public.player_expeditions (
  user_id     uuid not null references public.users(id) on delete cascade,
  zone_code   text not null check (zone_code in ('costa', 'ruinas', 'cumbre')),
  unlocked_at timestamptz not null default now(),
  primary key (user_id, zone_code)
);

alter table public.player_expeditions enable row level security;

drop policy if exists select_own_expeditions on public.player_expeditions;
create policy select_own_expeditions on public.player_expeditions
  for select using (auth.uid() = user_id);

comment on table public.player_expeditions is
  'Zonas de expedicion desbloqueadas por jugador (#403). Escritura solo por RPC.';

-- Coste y prerrequisito de cada zona, decididos en servidor.
create or replace function public.zone_def(p_zone_code text)
returns jsonb
language sql
immutable
as $$
  select case p_zone_code
    when 'costa'  then jsonb_build_object('cost', 300, 'cefr_min', 'A2', 'position', 1)
    when 'ruinas' then jsonb_build_object('cost', 600, 'cefr_min', 'B1', 'position', 2)
    when 'cumbre' then jsonb_build_object('cost', 900, 'cefr_min', 'B2', 'position', 3)
  end;
$$;

create or replace function public.unlock_zone(p_zone_code text, p_ref_key text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid   uuid := auth.uid();
  v_def   jsonb;
  v_cost  integer;
  v_move  jsonb;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;
  if p_ref_key is null or length(trim(p_ref_key)) = 0 then
    return jsonb_build_object('success', false, 'reason', 'bad_ref');
  end if;

  v_def := public.zone_def(p_zone_code);
  if v_def is null then
    return jsonb_build_object('success', false, 'reason', 'unknown_zone');
  end if;

  if exists (
    select 1 from public.player_expeditions
     where user_id = v_uid and zone_code = p_zone_code
  ) then
    return jsonb_build_object('success', true, 'already_unlocked', true,
                              'zone', p_zone_code);
  end if;

  v_cost := (v_def ->> 'cost')::integer;

  v_move := public.economy_apply_currency(
    v_uid, 'gold', -v_cost, 'expedition_unlock', p_ref_key);

  if coalesce((v_move ->> 'duplicated')::boolean, false) then
    return jsonb_build_object('success', true, 'duplicated', true,
                              'zone', p_zone_code,
                              'balance', (v_move ->> 'balance')::integer);
  end if;

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object('success', false,
      'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'cost', v_cost, 'balance', coalesce((v_move ->> 'balance')::integer, 0));
  end if;

  insert into public.player_expeditions (user_id, zone_code)
  values (v_uid, p_zone_code);

  return jsonb_build_object('success', true, 'already_unlocked', false,
                            'zone', p_zone_code, 'cost', v_cost,
                            'balance', (v_move ->> 'balance')::integer);
end;
$$;

revoke execute on function public.unlock_zone(text, text) from public, anon;
grant execute on function public.unlock_zone(text, text) to authenticated;

comment on function public.unlock_zone(text, text) is
  'Desbloquea una zona de expedicion pagando oro; idempotente por ref_key (#403).';

-- Verificacion:
-- select * from public.player_expeditions;
-- select reason, count(*) from public.currency_ledger
--  where reason = 'expedition_unlock' group by reason;
