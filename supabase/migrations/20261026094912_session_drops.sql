-- Issue #87 (P-02): el drop de fin de sesión se generaba y acreditaba en el
-- cliente, así que reabrir /summary volvía a tirar el dado y a sumar XP.
--
-- Este cambio mueve el drop al servidor:
--   * una fila por (user_id, session_id) => idempotente de verdad;
--   * el importe (XP/oro) y la rareza los decide el servidor;
--   * el "objeto" decorativo desaparece: el drop es una bolsa de oro real.
--
-- Si la sesión no tiene objetivos cumplidos, no hay drop (evita farmear
-- abriendo y cerrando sesiones vacías).

create table if not exists public.session_drops (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  session_id text not null,
  rarity text not null check (rarity in ('comun', 'raro', 'epico', 'legendario')),
  xp_awarded integer not null check (xp_awarded >= 0),
  gold_awarded integer not null check (gold_awarded >= 0),
  created_at timestamptz not null default now(),
  unique (user_id, session_id)
);

alter table public.session_drops enable row level security;

drop policy if exists session_drops_select_own on public.session_drops;
create policy session_drops_select_own on public.session_drops
  for select to authenticated using (auth.uid() = user_id);

-- Solo escribe la RPC: el cliente no puede fabricar ni repetir drops.
revoke insert, update, delete on public.session_drops from authenticated, anon;

create or replace function public.claim_session_drop(
  p_session_id text,
  p_completed_goals integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_row public.session_drops%rowtype;
  v_roll integer;
  v_rarity text;
  v_mult numeric;
  v_xp integer;
  v_gold integer;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  if p_session_id is null or length(trim(p_session_id)) = 0 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_session');
  end if;

  if coalesce(p_completed_goals, 0) <= 0 then
    return jsonb_build_object('ok', false, 'reason', 'no_goals');
  end if;

  select * into v_row
    from public.session_drops
   where user_id = v_uid and session_id = p_session_id;

  if found then
    return jsonb_build_object(
      'ok', true,
      'already_claimed', true,
      'rarity', v_row.rarity,
      'xp', v_row.xp_awarded,
      'gold', v_row.gold_awarded
    );
  end if;

  -- Pesos: legendario 2%, epico 8%, raro 25%, comun 65%.
  v_roll := floor(random() * 100)::int;
  if v_roll < 2 then
    v_rarity := 'legendario'; v_mult := 3.0;
  elsif v_roll < 10 then
    v_rarity := 'epico'; v_mult := 2.0;
  elsif v_roll < 35 then
    v_rarity := 'raro'; v_mult := 1.5;
  else
    v_rarity := 'comun'; v_mult := 1.0;
  end if;

  v_xp := round(15 * v_mult);
  v_gold := round(10 * v_mult);

  insert into public.session_drops (user_id, session_id, rarity, xp_awarded, gold_awarded)
  values (v_uid, p_session_id, v_rarity, v_xp, v_gold);

  update public.user_language_profiles
     set xp_points = coalesce(xp_points, 0) + v_xp,
         total_gold = coalesce(total_gold, 0) + v_gold
   where user_id = v_uid;

  return jsonb_build_object(
    'ok', true,
    'already_claimed', false,
    'rarity', v_rarity,
    'xp', v_xp,
    'gold', v_gold
  );
exception
  when unique_violation then
    select * into v_row
      from public.session_drops
     where user_id = v_uid and session_id = p_session_id;
    return jsonb_build_object(
      'ok', true,
      'already_claimed', true,
      'rarity', v_row.rarity,
      'xp', v_row.xp_awarded,
      'gold', v_row.gold_awarded
    );
end;
$function$;

revoke all on function public.claim_session_drop(text, integer) from public, anon;
grant execute on function public.claim_session_drop(text, integer) to authenticated;
