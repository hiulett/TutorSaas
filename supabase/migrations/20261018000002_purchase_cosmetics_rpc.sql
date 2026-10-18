-- Issue #2: compras y equipamiento transaccionales.
--
-- Antes: `player_inventory` solo tenía política SELECT, así que
-- `purchaseCosmeticWithGold` descontaba el oro y el INSERT era rechazado
-- (oro perdido, ítem no entregado). `toggleEquip` hacía un UPDATE que RLS
-- bloqueaba en silencio.
--
-- Ahora la escritura pasa por RPC SECURITY DEFINER: no se abre INSERT en la
-- tabla (evita que un cliente se autoentregue ítems) y la compra es atómica.

create or replace function public.purchase_cosmetic(
    p_user_id   uuid,
    p_item_id   text,
    p_currency  text default 'gold'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn$
declare
    v_item    public.cosmetic_catalog%rowtype;
    v_price   integer;
    v_gold    integer;
    v_gems    integer;
    v_lang    integer;
    v_owned   boolean;
    v_currency text := lower(coalesce(p_currency, 'gold'));
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

    select exists (
        select 1 from public.player_inventory
         where user_id = p_user_id and item_code = p_item_id
    ) into v_owned;
    if v_owned then
        return jsonb_build_object('success', false, 'reason', 'already_owned');
    end if;

    -- Bloqueo de fila: evita doble gasto con dos peticiones concurrentes.
    select language_id,
           coalesce(total_gold, 0),
           coalesce(total_gems, 0)
      into v_lang, v_gold, v_gems
      from public.user_language_profiles
     where user_id = p_user_id
     order by language_id
     limit 1
     for update;

    if v_lang is null then
        return jsonb_build_object('success', false, 'reason', 'no_profile');
    end if;

    if v_currency = 'gems' then
        if v_gems < v_price then
            return jsonb_build_object('success', false, 'reason', 'insufficient');
        end if;
        update public.user_language_profiles
           set total_gems = v_gems - v_price
         where user_id = p_user_id and language_id = v_lang;
    else
        if v_gold < v_price then
            return jsonb_build_object('success', false, 'reason', 'insufficient');
        end if;
        update public.user_language_profiles
           set total_gold = v_gold - v_price
         where user_id = p_user_id and language_id = v_lang;
    end if;

    insert into public.player_inventory (user_id, item_code, item_type, is_equipped, source)
    values (p_user_id, p_item_id, coalesce(v_item.category, 'cosmetic'), false, 'shop');

    return jsonb_build_object(
        'success', true,
        'item_id', p_item_id,
        'item_type', coalesce(v_item.category, 'cosmetic'),
        'price', v_price,
        'currency', v_currency
    );
end;
$fn$;

revoke all on function public.purchase_cosmetic(uuid, text, text) from public, anon;
grant execute on function public.purchase_cosmetic(uuid, text, text) to authenticated;

create or replace function public.equip_cosmetic(
    p_user_id  uuid,
    p_item_id  text,
    p_equip    boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn2$
declare
    v_type text;
begin
    if auth.uid() is null or auth.uid() <> p_user_id then
        raise exception 'No autorizado';
    end if;

    select item_type into v_type
      from public.player_inventory
     where user_id = p_user_id and item_code = p_item_id;

    if v_type is null then
        return jsonb_build_object('success', false, 'reason', 'not_owned');
    end if;

    if p_equip then
        -- Solo un ítem equipado por categoría (aura, marco, título…).
        update public.player_inventory
           set is_equipped = false
         where user_id = p_user_id and item_type = v_type and is_equipped;
    end if;

    update public.player_inventory
       set is_equipped = p_equip
     where user_id = p_user_id and item_code = p_item_id;

    return jsonb_build_object('success', true, 'item_type', v_type, 'equipped', p_equip);
end;
$fn2$;

revoke all on function public.equip_cosmetic(uuid, text, boolean) from public, anon;
grant execute on function public.equip_cosmetic(uuid, text, boolean) to authenticated;
