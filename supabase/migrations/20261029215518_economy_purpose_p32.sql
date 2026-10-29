-- P-32 (#117) — Economia y progresion con proposito.
--
-- Estado verificado en produccion (2026-10-29, solo lectura):
--   * `player_inventory` = 0 filas: nadie ha comprado un cosmetico nunca.
--   * `user_language_profiles`: oro max 160 / mediana 100 (el cosmetico mas
--     barato costaba 120), gemas max 40 (el mas barato 350), fragmentos 483
--     repartidos en 5 perfiles y SIN ningun sumidero.
--   * No existia ningun libro de movimientos de oro/gemas/fragmentos: solo
--     `session_reward_ledger` (ingresos) -> gasto imposible de medir.
--   * `spendGold()` del cliente escribia `total_gold` directo, pero el trigger
--     `guard_language_profile` descarta ese campo: la funcion devolvia true y
--     no cobraba nada. Los sumideros de gemas (`purchaseItem`,
--     `purchaseStreakFreeze`) no tenian ninguna entrada en la UI.
--
-- Este cambio (todo por RPC SECURITY DEFINER, el cliente no escribe saldos):
--   1. `currency_ledger`: libro idempotente por `(user_id, ref_key)` de todo
--      movimiento de oro/gemas/fragmentos. Es la base de la metrica
--      "oro ganado vs gastado" (docs/runbooks/ECONOMY_SINKS.md).
--   2. `cosmetic_catalog.required_level` + `craft_cost_fragments`: el nivel de
--      cazador (XP/1000 + 1) desbloquea cosmeticos y los fragmentos craftean.
--   3. `level_rewards` + `claim_level_rewards()`: subir de nivel da oro y/o un
--      cosmetico, reclamable y anunciado en la app.
--   4. `spend_currency`, `craft_cosmetic`, `purchase_streak_freeze` y
--      `purchase_cosmetic` (reescrito) mueven saldo con idempotencia y
--      escriben en el libro.
--   5. `player_streaks.streak_freezes` deja de poder auto-otorgarse desde el
--      cliente (solo la RPC lo aumenta; consumir sigue permitido).
--
-- Nada de esto compra ventajas de aprendizaje: el mana de IA se sigue cobrando
-- en servidor (`consume_mana`) y el oro solo compra cosmeticos.
--
-- Validado en produccion dentro de `begin ... rollback` (2026-10-29) con el
-- usuario b5a2d0d9 (oro 100): compra de 60 oro -> 40, repetir la misma `ref`
-- devuelve duplicated=true y no vuelve a cobrar, y el nivel 1 rechaza el item
-- de nivel 2 con reason='level_locked'.

-- ── 1. Catalogo: nivel requerido y receta de fragmentos ─────────────────────
alter table public.cosmetic_catalog
  add column if not exists required_level integer not null default 1,
  add column if not exists craft_cost_fragments integer not null default 0;

alter table public.cosmetic_catalog
  drop constraint if exists chk_cosmetic_required_level;
alter table public.cosmetic_catalog
  add constraint chk_cosmetic_required_level check (required_level between 1 and 50);

alter table public.cosmetic_catalog
  drop constraint if exists chk_cosmetic_craft_cost;
alter table public.cosmetic_catalog
  add constraint chk_cosmetic_craft_cost check (craft_cost_fragments >= 0);

-- Escalones de nivel sobre lo que ya existe (nivel = 1 + xp_points / 1000).
update public.cosmetic_catalog set required_level = 1 where required_level <> 1;
update public.cosmetic_catalog set required_level = 2 where id in ('title_eloquente', 'frame_escudo');
update public.cosmetic_catalog set required_level = 3 where id in ('aura_mana', 'title_cazador_sombras');
update public.cosmetic_catalog set required_level = 4 where id = 'frame_dragón';
update public.cosmetic_catalog set required_level = 5 where id = 'aura_fuego';
update public.cosmetic_catalog set required_level = 6 where id = 'pet_lunático';
update public.cosmetic_catalog set required_level = 8 where id = 'theme_mesa_bosque';
update public.cosmetic_catalog set required_level = 10 where id = 'title_leyenda_viva';
update public.cosmetic_catalog set required_level = 12 where id = 'frame_abismo';
update public.cosmetic_catalog set required_level = 15 where id = 'pet_fénix';
update public.cosmetic_catalog set required_level = 18 where id = 'aura_sombras';
update public.cosmetic_catalog set required_level = 20 where id = 'theme_mesa_abismo';

-- Recetas de fragmentos (hoy el recurso solo se acumulaba).
update public.cosmetic_catalog set craft_cost_fragments = 120 where id = 'title_cazador_sombras';
update public.cosmetic_catalog set craft_cost_fragments = 250 where id = 'frame_escudo';
update public.cosmetic_catalog set craft_cost_fragments = 400 where id = 'aura_fuego';

-- Entrada asequible: el perfil nace con 100 de oro y el item mas barato
-- costaba 120, asi que la tienda no tenia ninguna compra posible el primer dia.
insert into public.cosmetic_catalog
  (id, name, description, category, price_gems, price_gold, rarity, required_level, craft_cost_fragments)
values
  ('emote_saludo_gremio', 'Saludo del Gremio', 'Emote de entrada al Gremio: tu primera compra con oro.', 'emote', 0, 60, 'common', 1, 0),
  ('frame_aprendiz', 'Marco del Aprendiz', 'Marco de bronce para el primer cazador que gasta su oro.', 'frame', 0, 90, 'common', 1, 0),
  ('title_aprendiz_abismo', 'Aprendiz del Abismo', 'Titulo de quien ya sabe para que sirve su oro.', 'title', 0, 80, 'common', 1, 0)
on conflict (id) do update
  set name = excluded.name,
      description = excluded.description,
      category = excluded.category,
      price_gold = excluded.price_gold,
      price_gems = excluded.price_gems,
      rarity = excluded.rarity,
      required_level = excluded.required_level,
      craft_cost_fragments = excluded.craft_cost_fragments;

-- ── 2. Libro de movimientos de moneda (idempotente) ─────────────────────────
create table if not exists public.currency_ledger (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  language_id integer not null default 1,
  currency text not null check (currency in ('gold', 'gems', 'fragments')),
  delta integer not null check (delta <> 0),
  reason text not null,
  ref_key text not null,
  balance_after integer not null check (balance_after >= 0),
  created_at timestamp with time zone not null default now(),
  unique (user_id, ref_key)
);

create index if not exists idx_currency_ledger_flow
  on public.currency_ledger (currency, created_at desc);
create index if not exists idx_currency_ledger_user
  on public.currency_ledger (user_id, created_at desc);

alter table public.currency_ledger enable row level security;

drop policy if exists currency_ledger_read_own on public.currency_ledger;
create policy currency_ledger_read_own on public.currency_ledger
  for select to authenticated using (auth.uid() = user_id);

-- Solo lectura para el cliente: escribe exclusivamente la RPC definer.
revoke insert, update, delete on public.currency_ledger from anon, authenticated;
grant select on public.currency_ledger to authenticated;

-- ── 3. Recompensas por nivel ────────────────────────────────────────────────
create table if not exists public.level_rewards (
  level integer primary key check (level between 2 and 50),
  gold integer not null default 0 check (gold >= 0),
  item_code text references public.cosmetic_catalog(id) on delete set null,
  label_es text not null,
  label_en text not null,
  label_pt text not null,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now()
);

alter table public.level_rewards enable row level security;

drop policy if exists level_rewards_read on public.level_rewards;
create policy level_rewards_read on public.level_rewards
  for select to authenticated using (true);

revoke insert, update, delete on public.level_rewards from anon, authenticated;
grant select on public.level_rewards to authenticated;

-- Las recompensas de nivel son bolsas de oro: el objeto que desbloquea cada
-- nivel ya lo da `cosmetic_catalog.required_level` (no se duplica el premio).
insert into public.level_rewards (level, gold, item_code, label_es, label_en, label_pt) values
  (2, 100, null, 'Bolsa de 100 de oro', '100 gold pouch', 'Bolsa de 100 de ouro'),
  (3, 150, null, 'Bolsa de 150 de oro', '150 gold pouch', 'Bolsa de 150 de ouro'),
  (5, 250, null, 'Bolsa de 250 de oro', '250 gold pouch', 'Bolsa de 250 de ouro'),
  (8, 400, null, 'Bolsa de 400 de oro', '400 gold pouch', 'Bolsa de 400 de ouro'),
  (12, 600, null, 'Bolsa de 600 de oro', '600 gold pouch', 'Bolsa de 600 de ouro'),
  (15, 800, null, 'Bolsa de 800 de oro', '800 gold pouch', 'Bolsa de 800 de ouro')
on conflict (level) do update
  set gold = excluded.gold,
      item_code = excluded.item_code,
      label_es = excluded.label_es,
      label_en = excluded.label_en,
      label_pt = excluded.label_pt,
      is_active = true;

-- ── 4. Nivel de cazador (misma curva que HunterLevel en Dart) ───────────────
create or replace function public.economy_level(p_xp bigint)
returns integer
language sql immutable
set search_path = public
as $function$
  select case when coalesce(p_xp, 0) <= 0 then 1 else 1 + (p_xp / 1000)::integer end;
$function$;

-- ── 5. Movimiento atomico de moneda ─────────────────────────────────────────
-- Unico punto que escribe total_gold / total_gems / fragments. Idempotente por
-- (user_id, ref_key): repetir la misma referencia devuelve el saldo ya aplicado
-- y no vuelve a mover nada.
create or replace function public.economy_apply_currency(
  p_user_id uuid,
  p_currency text,
  p_delta integer,
  p_reason text,
  p_ref_key text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_currency text := lower(coalesce(p_currency, ''));
  v_lang     integer;
  v_gold     integer;
  v_gems     integer;
  v_frags    integer;
  v_balance  integer;
  v_new      integer;
  v_dup      public.currency_ledger%rowtype;
begin
  if v_currency not in ('gold', 'gems', 'fragments') then
    return jsonb_build_object('ok', false, 'reason', 'bad_currency');
  end if;
  if p_delta is null or p_delta = 0 then
    return jsonb_build_object('ok', false, 'reason', 'bad_amount');
  end if;
  if p_ref_key is null or length(trim(p_ref_key)) = 0 then
    return jsonb_build_object('ok', false, 'reason', 'bad_ref');
  end if;

  select * into v_dup from public.currency_ledger
   where user_id = p_user_id and ref_key = p_ref_key;
  if found then
    return jsonb_build_object(
      'ok', true, 'duplicated', true,
      'currency', v_dup.currency, 'balance', v_dup.balance_after);
  end if;

  select language_id, coalesce(total_gold, 0), coalesce(total_gems, 0),
         coalesce(fragments, 0)
    into v_lang, v_gold, v_gems, v_frags
    from public.user_language_profiles
   where user_id = p_user_id
   order by language_id
   limit 1
   for update;

  if v_lang is null then
    return jsonb_build_object('ok', false, 'reason', 'no_profile');
  end if;

  v_balance := case v_currency
                 when 'gold' then v_gold
                 when 'gems' then v_gems
                 else v_frags
               end;
  v_new := v_balance + p_delta;
  if v_new < 0 then
    return jsonb_build_object('ok', false, 'reason', 'insufficient',
                              'currency', v_currency, 'balance', v_balance);
  end if;

  update public.user_language_profiles
     set total_gold  = case when v_currency = 'gold' then v_new else total_gold end,
         total_gems  = case when v_currency = 'gems' then v_new else total_gems end,
         fragments   = case when v_currency = 'fragments' then v_new else fragments end
   where user_id = p_user_id and language_id = v_lang;

  insert into public.currency_ledger
    (user_id, language_id, currency, delta, reason, ref_key, balance_after)
  values
    (p_user_id, v_lang, v_currency, p_delta, coalesce(p_reason, 'other'),
     p_ref_key, v_new);

  return jsonb_build_object('ok', true, 'duplicated', false,
                            'currency', v_currency, 'balance', v_new);
end;
$function$;

comment on function public.economy_apply_currency(uuid, text, integer, text, text) is
  'P-32: unico punto de escritura de oro/gemas/fragmentos. Idempotente por (user_id, ref_key).';

-- ── 6. Gasto desde el cliente ───────────────────────────────────────────────
create or replace function public.spend_currency(
  p_user_id uuid,
  p_currency text,
  p_amount integer,
  p_reason text default 'spend',
  p_ref_key text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;
  if p_amount is null or p_amount <= 0 then
    return jsonb_build_object('success', false, 'reason', 'bad_amount');
  end if;

  return public.economy_apply_currency(
    p_user_id, p_currency, -p_amount, p_reason,
    coalesce(nullif(trim(p_ref_key), ''), 'spend:' || gen_random_uuid()::text));
end;
$function$;

-- ── 7. Compra con oro o gemas (nivel + libro) ───────────────────────────────
create or replace function public.purchase_cosmetic(
  p_user_id uuid,
  p_item_id text,
  p_currency text default 'gold'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_item     public.cosmetic_catalog%rowtype;
  v_price    integer;
  v_currency text := lower(coalesce(p_currency, 'gold'));
  v_level    integer;
  v_owned    boolean;
  v_move     jsonb;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  if v_currency not in ('gold', 'gems') then
    return jsonb_build_object('success', false, 'reason', 'bad_currency');
  end if;

  select * into v_item from public.cosmetic_catalog where id = p_item_id;
  if not found then
    return jsonb_build_object('success', false, 'reason', 'not_found');
  end if;

  if v_item.available_from is not null and v_item.available_from > now() then
    return jsonb_build_object('success', false, 'reason', 'not_available');
  end if;
  if v_item.available_to is not null and v_item.available_to < now() then
    return jsonb_build_object('success', false, 'reason', 'not_available');
  end if;

  v_price := case when v_currency = 'gems'
                  then coalesce(v_item.price_gems, 0)
                  else coalesce(v_item.price_gold, 0) end;
  if v_price <= 0 then
    return jsonb_build_object('success', false, 'reason', 'not_purchasable');
  end if;

  select public.economy_level(xp_points) into v_level
    from public.user_language_profiles
   where user_id = p_user_id
   order by language_id
   limit 1;

  if v_level is null then
    return jsonb_build_object('success', false, 'reason', 'no_profile');
  end if;

  if v_level < coalesce(v_item.required_level, 1) then
    return jsonb_build_object(
      'success', false, 'reason', 'level_locked',
      'required_level', v_item.required_level, 'level', v_level);
  end if;

  select exists (
    select 1 from public.player_inventory
     where user_id = p_user_id and item_code = p_item_id
  ) into v_owned;
  if v_owned then
    return jsonb_build_object('success', false, 'reason', 'already_owned');
  end if;

  v_move := public.economy_apply_currency(
    p_user_id, v_currency, -v_price, 'cosmetic:' || p_item_id,
    'cosmetic:' || p_item_id || ':' || v_currency);

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object(
      'success', false, 'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'required_level', v_item.required_level, 'level', v_level);
  end if;

  insert into public.player_inventory (user_id, item_code, item_type, is_equipped, source)
  values (p_user_id, p_item_id, coalesce(v_item.category, 'cosmetic'), false, 'shop');

  return jsonb_build_object(
    'success', true, 'item_id', p_item_id,
    'item_type', coalesce(v_item.category, 'cosmetic'),
    'price', v_price, 'currency', v_currency,
    'balance', (v_move ->> 'balance')::integer,
    'required_level', v_item.required_level);
end;
$function$;

-- ── 8. Crafteo con fragmentos ───────────────────────────────────────────────
create or replace function public.craft_cosmetic(
  p_user_id uuid,
  p_item_id text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_item  public.cosmetic_catalog%rowtype;
  v_owned boolean;
  v_move  jsonb;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  select * into v_item from public.cosmetic_catalog where id = p_item_id;
  if not found then
    return jsonb_build_object('success', false, 'reason', 'not_found');
  end if;

  if coalesce(v_item.craft_cost_fragments, 0) <= 0 then
    return jsonb_build_object('success', false, 'reason', 'not_craftable');
  end if;

  select exists (
    select 1 from public.player_inventory
     where user_id = p_user_id and item_code = p_item_id
  ) into v_owned;
  if v_owned then
    return jsonb_build_object('success', false, 'reason', 'already_owned');
  end if;

  v_move := public.economy_apply_currency(
    p_user_id, 'fragments', -v_item.craft_cost_fragments,
    'craft:' || p_item_id, 'craft:' || p_item_id);

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object(
      'success', false, 'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'cost', v_item.craft_cost_fragments);
  end if;

  insert into public.player_inventory (user_id, item_code, item_type, is_equipped, source)
  values (p_user_id, p_item_id, coalesce(v_item.category, 'cosmetic'), false, 'craft');

  return jsonb_build_object(
    'success', true, 'item_id', p_item_id,
    'item_type', coalesce(v_item.category, 'cosmetic'),
    'cost', v_item.craft_cost_fragments, 'currency', 'fragments',
    'balance', (v_move ->> 'balance')::integer);
end;
$function$;

-- ── 9. Freeze de racha (gemas) ──────────────────────────────────────────────
-- Cap de 3 para que no sea un banco infinito; idempotente por p_ref_key.
create or replace function public.purchase_streak_freeze(
  p_user_id uuid,
  p_ref_key text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_cost   constant integer := 30;
  v_cap    constant integer := 3;
  v_freezes integer;
  v_move   jsonb;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;
  if p_ref_key is null or length(trim(p_ref_key)) = 0 then
    return jsonb_build_object('success', false, 'reason', 'bad_ref');
  end if;

  insert into public.player_streaks (user_id, current_streak, longest_streak, last_active_date)
  values (p_user_id, 0, 0, current_date)
  on conflict (user_id) do nothing;

  select coalesce(streak_freezes, 0) into v_freezes
    from public.player_streaks where user_id = p_user_id for update;

  if v_freezes >= v_cap then
    return jsonb_build_object('success', false, 'reason', 'cap_reached',
                              'freezes', v_freezes, 'cap', v_cap);
  end if;

  v_move := public.economy_apply_currency(
    p_user_id, 'gems', -v_cost, 'streak_freeze', p_ref_key);

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object(
      'success', false, 'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'cost', v_cost, 'balance', coalesce((v_move ->> 'balance')::integer, 0));
  end if;

  update public.player_streaks
     set streak_freezes = v_freezes + 1
   where user_id = p_user_id;

  return jsonb_build_object('success', true, 'cost', v_cost,
                            'freezes', v_freezes + 1, 'cap', v_cap,
                            'balance', (v_move ->> 'balance')::integer);
end;
$function$;

-- ── 10. El cliente no puede auto-otorgarse freezes ──────────────────────────
-- El consumo (bajar el contador al fallar un dia) sigue permitido desde el
-- cliente para no romper `updateStreak`; comprar solo por la RPC.
create or replace function public.guard_player_streak_freezes()
returns trigger
language plpgsql
set search_path = public
as $function$
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;
  new.streak_freezes := least(coalesce(new.streak_freezes, 0),
                              coalesce(old.streak_freezes, 0));
  return new;
end;
$function$;

drop trigger if exists trg_guard_player_streak_freezes on public.player_streaks;
create trigger trg_guard_player_streak_freezes
  before update on public.player_streaks
  for each row execute function public.guard_player_streak_freezes();

-- ── 11. Recompensas por nivel: estado y reclamo ─────────────────────────────
create or replace function public.level_reward_status(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_level integer;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  select public.economy_level(xp_points) into v_level
    from public.user_language_profiles
   where user_id = p_user_id
   order by language_id
   limit 1;

  if v_level is null then
    return jsonb_build_object('level', 1, 'rewards', '[]'::jsonb);
  end if;

  return jsonb_build_object(
    'level', v_level,
    'rewards', coalesce((
      select jsonb_agg(jsonb_build_object(
               'level', lr.level,
               'gold', lr.gold,
               'item_code', lr.item_code,
               'item_name', cc.name,
               'label_es', lr.label_es,
               'label_en', lr.label_en,
               'label_pt', lr.label_pt,
               'unlocked', lr.level <= v_level,
               'claimed', exists (
                 select 1 from public.currency_ledger cl
                  where cl.user_id = p_user_id
                    and cl.ref_key = 'level_reward:' || lr.level)
             ) order by lr.level)
        from public.level_rewards lr
        left join public.cosmetic_catalog cc on cc.id = lr.item_code
       where lr.is_active
    ), '[]'::jsonb));
end;
$function$;

create or replace function public.claim_level_rewards(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_level   integer;
  v_row     record;
  v_move    jsonb;
  v_granted jsonb := '[]'::jsonb;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  select public.economy_level(xp_points) into v_level
    from public.user_language_profiles
   where user_id = p_user_id
   order by language_id
   limit 1;

  if v_level is null then
    return jsonb_build_object('success', false, 'reason', 'no_profile');
  end if;

  for v_row in
    select * from public.level_rewards
     where is_active and level <= v_level
     order by level
  loop
    v_move := public.economy_apply_currency(
      p_user_id, 'gold', greatest(coalesce(v_row.gold, 0), 1),
      'level_reward', 'level_reward:' || v_row.level);

    -- Idempotente: si la referencia ya existe, ese nivel ya se cobro.
    if coalesce((v_move ->> 'duplicated')::boolean, false) then
      continue;
    end if;
    if (v_move ->> 'ok')::boolean is not true then
      return jsonb_build_object('success', false,
                                'reason', coalesce(v_move ->> 'reason', 'error'),
                                'granted', v_granted);
    end if;

    if v_row.item_code is not null then
      insert into public.player_inventory (user_id, item_code, item_type, is_equipped, source)
      select p_user_id, v_row.item_code, coalesce(cc.category, 'cosmetic'), false, 'level'
        from public.cosmetic_catalog cc
       where cc.id = v_row.item_code
         and not exists (
           select 1 from public.player_inventory pi
            where pi.user_id = p_user_id and pi.item_code = v_row.item_code);
    end if;

    v_granted := v_granted || jsonb_build_object(
      'level', v_row.level, 'gold', greatest(coalesce(v_row.gold, 0), 1),
      'item_code', v_row.item_code);
  end loop;

  return jsonb_build_object('success', true, 'level', v_level,
                            'granted', v_granted);
end;
$function$;

-- ── 12. Cartera + flujo para la app y para la metrica ───────────────────────
create or replace function public.get_economy_wallet(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_xp      integer;
  v_gold    integer;
  v_gems    integer;
  v_frags   integer;
  v_level   integer;
  v_freezes integer;
  v_claims  integer;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  select coalesce(xp_points, 0), coalesce(total_gold, 0),
         coalesce(total_gems, 0), coalesce(fragments, 0)
    into v_xp, v_gold, v_gems, v_frags
    from public.user_language_profiles
   where user_id = p_user_id
   order by language_id
   limit 1;

  v_level := public.economy_level(coalesce(v_xp, 0));

  select coalesce(streak_freezes, 0) into v_freezes
    from public.player_streaks where user_id = p_user_id;

  select count(*) into v_claims
    from public.level_rewards lr
   where lr.is_active and lr.level <= v_level
     and not exists (
       select 1 from public.currency_ledger cl
        where cl.user_id = p_user_id
          and cl.ref_key = 'level_reward:' || lr.level);

  return jsonb_build_object(
    'gold', coalesce(v_gold, 0),
    'gems', coalesce(v_gems, 0),
    'fragments', coalesce(v_frags, 0),
    'level', v_level,
    'xp', coalesce(v_xp, 0),
    'xp_per_level', 1000,
    'xp_into_level', coalesce(v_xp, 0) % 1000,
    'streak_freezes', coalesce(v_freezes, 0),
    'unclaimed_level_rewards', coalesce(v_claims, 0),
    'earned', coalesce((
      select jsonb_object_agg(currency, total)
        from (select currency, sum(delta) as total
                from public.currency_ledger
               where user_id = p_user_id and delta > 0
               group by currency) e), '{}'::jsonb),
    'spent', coalesce((
      select jsonb_object_agg(currency, total)
        from (select currency, -sum(delta) as total
                from public.currency_ledger
               where user_id = p_user_id and delta < 0
               group by currency) s), '{}'::jsonb));
end;
$function$;

-- Vista de medicion de la economia (agregada entre usuarios).
-- Sin acceso para la app: solo service role / SQL Editor.
create or replace view public.v_economy_flow as
select currency,
       reason,
       sum(case when delta > 0 then delta else 0 end) as earned,
       sum(case when delta < 0 then -delta else 0 end) as spent,
       count(*) as movements
  from public.currency_ledger
 group by currency, reason;

revoke all on public.v_economy_flow from anon, authenticated;
grant select on public.v_economy_flow to service_role;

-- ── 13. Permisos de ejecucion ───────────────────────────────────────────────
revoke all on function public.economy_apply_currency(uuid, text, integer, text, text) from anon, authenticated;
grant execute on function public.spend_currency(uuid, text, integer, text, text) to authenticated;
grant execute on function public.purchase_cosmetic(uuid, text, text) to authenticated;
grant execute on function public.craft_cosmetic(uuid, text) to authenticated;
grant execute on function public.purchase_streak_freeze(uuid, text) to authenticated;
grant execute on function public.level_reward_status(uuid) to authenticated;
grant execute on function public.claim_level_rewards(uuid) to authenticated;
grant execute on function public.get_economy_wallet(uuid) to authenticated;
grant execute on function public.economy_level(bigint) to authenticated;
