-- Economia P0: integridad de recompensas de mision y retirada de items muertos.
--
-- Historias: #367 (Acotar reward_multiplier y blindar mission_instances) y
-- #368 (Retirar del catalogo los 9 items sin efecto).
-- Auditoria: docs/economy/ECONOMY_TECHNICAL_AUDIT.md (F-1, F-3).
--
-- ORDEN DE DESPLIEGUE: aplicar esta migracion ANTES de publicar el build que
-- filtra por `cosmetic_catalog.is_active`. El build anterior ignora la columna
-- (no la selecciona), asi que aplicar primero no rompe nada.

-- ── 1. Recompensa de mision: techo del multiplicador ────────────────────────
-- Antes: v_mult := greatest(1, coalesce(v_row.reward_multiplier, 1));
-- Eso pone SUELO, no techo: un cliente podia escribir reward_multiplier = 1000
-- (RLS update_own_instances) y reclamar oro/gemas/xp x1000 como legitimo.
create or replace function public.claim_mission_reward(p_instance_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.mission_instances%rowtype;
  v_mult integer;
  v_xp integer;
  v_gems integer;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;

  select * into v_row
    from public.mission_instances
   where id = p_instance_id and user_id = v_uid
   for update;

  if not found then
    return jsonb_build_object(
      'success', false, 'ok', false, 'already_claimed', false,
      'xp', 0, 'gems', 0, 'reason', 'not_found'
    );
  end if;

  if v_row.status <> 'completed' then
    return jsonb_build_object(
      'success', false, 'ok', false, 'already_claimed', false,
      'xp', 0, 'gems', 0, 'reason', 'not_completed'
    );
  end if;

  if v_row.is_reward_claimed then
    return jsonb_build_object(
      'success', true, 'ok', true, 'already_claimed', true,
      'xp', 0, 'gems', 0, 'reason', null
    );
  end if;

  -- Techo duro: el unico multiplicador legitimo es 1 (normal) o 2 (modificador).
  v_mult := least(2, greatest(1, coalesce(v_row.reward_multiplier, 1)));
  v_xp := coalesce(v_row.xp_reward, 0) * v_mult;
  v_gems := coalesce(v_row.gem_reward, 0) * v_mult;

  update public.mission_instances
     set is_reward_claimed = true
   where id = v_row.id;

  update public.user_language_profiles
     set xp_points = coalesce(xp_points, 0) + v_xp,
         total_gems = coalesce(total_gems, 0) + v_gems
   where user_id = v_uid;

  insert into public.reward_history (user_id, source_type, source_id, xp_earned, gems_earned, item_code)
  values (v_uid, 'mission', v_row.id::text, v_xp, v_gems, v_row.item_reward);

  return jsonb_build_object(
    'success', true, 'ok', true, 'already_claimed', false,
    'xp', v_xp, 'gems', v_gems, 'reason', null
  );
end;
$$;

comment on function public.claim_mission_reward(uuid) is
  'Reclamo de mision. Contrato: {success, ok (legacy), already_claimed, xp, gems, reason}. Multiplicador acotado a [1,2].';

-- ── 2. Guard: el multiplicador no lo escribe el cliente ─────────────────────
-- `reward_multiplier` se quedaba fuera de la lista de campos restaurados, asi
-- que un UPDATE directo del cliente lo persistia y lo cobraba la RPC.
-- NOTA: esto desactiva la via actual de los modificadores de mision
-- (`mod_recompensa_x2` etc.), que escribian el multiplicador desde el cliente.
-- Se restableceran con una RPC de servidor que valide y consuma el item
-- (ver issue de seguimiento). Es preferible perder temporalmente el efecto a
-- dejar una via de inflacion de moneda abierta.
create or replace function public.guard_mission_instance()
returns trigger
language plpgsql
security definer
set search_path = public
as $t4$
begin
    if coalesce(auth.role(), '') <> 'service_role' then
        if tg_op = 'INSERT' then
            new.status := 'active';
            new.current_value := 0;
            new.is_reward_claimed := false;
            new.completed_at := null;
        else
            -- No se pueden alterar recompensas ni objetivos de una mision.
            new.xp_reward := old.xp_reward;
            new.gem_reward := old.gem_reward;
            new.target_value := old.target_value;
            new.objective_type := old.objective_type;
            new.user_id := old.user_id;
            -- #367: el multiplicador tampoco.
            new.reward_multiplier := old.reward_multiplier;

            if new.is_reward_claimed and not old.is_reward_claimed and old.status <> 'completed' then
                raise exception 'La misión no está completada';
            end if;
        end if;
    end if;
    return new;
end;
$t4$;

-- ── 3. Catalogo: apagar los 9 items sin efecto ──────────────────────────────
-- Se apagan en lugar de borrarse: hay inventarios historicos y FKs. El cliente
-- filtra por is_active; la RPC rechaza compras sobre items inactivos.
alter table public.cosmetic_catalog
  add column if not exists is_active boolean not null default true;

update public.cosmetic_catalog
   set is_active = false
 where id in (
   'consumible_invocacion5',
   'consumible_invocacion20',
   'consumible_pergamino10',
   'consumible_pergamino50',
   'key_mazmorra_oculta',
   'key_archivo_gremio',
   'book_phrasal_verbs',
   'book_grimorio_tiempos',
   'book_pronunciacion'
 );

comment on column public.cosmetic_catalog.is_active is
  'false = item retirado de la tienda (sin efecto verificado, #368). No borrar filas referenciadas.';

-- ── 3b. Servidor: no se puede comprar un item retirado ──────────────────────
-- El filtro del cliente es solo cosmetico; una llamada directa a la RPC podria
-- seguir comprando. Este trigger cubre cualquier camino que inserte en el
-- inventario (purchase_cosmetic, craft_cosmetic y futuros).
create or replace function public.guard_inactive_inventory_item()
returns trigger
language plpgsql
security definer
set search_path = public
as $g$
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    if exists (
      select 1 from public.cosmetic_catalog c
       where c.id = new.item_code and c.is_active = false
    ) then
      raise exception 'Item retirado de la tienda';
    end if;
  end if;
  return new;
end;
$g$;

drop trigger if exists trg_guard_inactive_inventory on public.player_inventory;
create trigger trg_guard_inactive_inventory
  before insert on public.player_inventory
  for each row execute function public.guard_inactive_inventory_item();

-- ── 4. Verificacion ─────────────────────────────────────────────────────────
-- select count(*) from public.cosmetic_catalog where is_active;                    -- activos
-- select count(*) from public.cosmetic_catalog where not is_active;                -- deben ser 9
-- select count(*) from public.mission_instances where reward_multiplier > 2;       -- debe ser 0
