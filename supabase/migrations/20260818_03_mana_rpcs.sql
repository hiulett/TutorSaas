-- ═══════════════════════════════════════════════════════════════════════════
-- 20260818_03_mana_rpcs.sql
-- FASE 2: RPCs del sistema de maná con doble validación + inventario equipable.
-- Ejecutar en Supabase Dashboard → SQL Editor (idempotente).
--
--   A) consume_mana (reescrito): validación por plan (free con límite diario,
--      pagos solo mensual) + gasto del ítem equipado (mana_items) como extra.
--   B) add_mana_item: compra → inventario (sin expiración hasta equipar).
--   C) equip_mana_item: equipar 1 ítem (inicia expiración 48h gema / 15d elixir).
--   D) desequip_mana_item: liberar el slot.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- A) consume_mana — valida y debita maná según el plan.
--    Orden de gasto: 1) saldo del plan (mensual) · 2) ítem equipado (mana_items).
--    Free: además valida el límite diario (daily_limit=200).
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.consume_mana(p_user_id uuid, p_action_code text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_cost       INTEGER;
    v_allowance  BIGINT;
    v_purchased  BIGINT;
    v_used        BIGINT;
    v_expires     TIMESTAMPTZ;
    v_remaining   BIGINT;
    v_daily_limit INTEGER;
    v_daily_used  INTEGER;
    v_daily_date  DATE;
    v_plan_id     TEXT;
    v_used_equipped INTEGER;
    v_equipped_id  UUID;
    v_equipped_mana INTEGER;
    v_equipped_expires TIMESTAMPTZ;
BEGIN
    IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
        RETURN jsonb_build_object('success', false, 'reason', 'unauthorized');
    END IF;

    SELECT COALESCE(cost_mana, 0) INTO v_cost
    FROM public.ai_action_costs WHERE action_code = p_action_code AND is_active;
    IF NOT FOUND OR v_cost <= 0 THEN
        RETURN jsonb_build_object('success', false, 'reason', 'invalid_action');
    END IF;

    -- Plan del usuario (free por defecto = plebeyo, 3000/mes).
    SELECT COALESCE(sp.mana_allowance, 3000), COALESCE(us.plan_id, 'plebeyo')
    INTO v_allowance, v_plan_id
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;
    IF NOT FOUND THEN v_allowance := 3000; v_plan_id := 'plebeyo'; END IF;

    SELECT COALESCE(us.purchased_mana_balance, 0), COALESCE(us.used_audio_seconds, 0),
           us.mana_expires_at, COALESCE(us.daily_limit, 200), COALESCE(us.daily_used, 0), us.daily_reset_date
    INTO v_purchased, v_used, v_expires, v_daily_limit, v_daily_used, v_daily_date
    FROM public.user_subscriptions us WHERE us.user_id = p_user_id;
    IF NOT FOUND THEN
        v_purchased := 0; v_used := 0; v_expires := NULL;
        v_daily_limit := 200; v_daily_used := 0; v_daily_date := NULL;
    END IF;

    -- Reset diario lazy: si cambió la fecha, reinicia el uso diario.
    IF v_daily_date IS DISTINCT FROM CURRENT_DATE THEN
        v_daily_used := 0;
        UPDATE public.user_subscriptions
        SET daily_used = 0, daily_reset_date = CURRENT_DATE, updated_at = now()
        WHERE user_id = p_user_id;
    END IF;

    -- Ciclo mensual expirado → sin saldo del plan (solo equipado/purchased vía items).
    IF v_expires IS NOT NULL AND v_expires < now() THEN
        v_allowance := 0;
    END IF;

    -- ══ Validación del plan ══
    -- Saldo mensual del plan (NO incluye el equipado: es extra).
    v_remaining := GREATEST(0, (v_allowance + v_purchased) - v_used);

    -- Límite diario: SOLO para free (plebeyo).
    IF v_plan_id = 'plebeyo' THEN
        IF v_daily_used + v_cost > v_daily_limit THEN
            -- ¿Puede el equipado cubrir el exceso? El maná del plan no alcanza.
            -- El equipado se valida abajo; aquí solo reportamos el tope diario.
            RETURN jsonb_build_object(
                'success', false, 'reason', 'daily_limit_reached',
                'daily_used', v_daily_used, 'daily_limit', v_daily_limit,
                'remaining', v_remaining, 'cost', v_cost);
        END IF;
    END IF;

    -- ══ Gasto 1: saldo del plan ══
    IF v_remaining >= v_cost THEN
        UPDATE public.user_subscriptions
        SET used_audio_seconds = COALESCE(used_audio_seconds, 0) + v_cost,
            daily_used = COALESCE(daily_used, 0) + v_cost,
            daily_reset_date = CURRENT_DATE,
            updated_at = now()
        WHERE user_id = p_user_id;

        INSERT INTO public.mana_transactions (user_id, amount, type, action_code)
        VALUES (p_user_id, -v_cost, 'action', p_action_code);

        RETURN jsonb_build_object('success', true, 'source', 'plan', 'cost', v_cost, 'remaining', v_remaining - v_cost);
    END IF;

    -- ══ Gasto 2: ítem equipado (mana_items) ══
    SELECT id, mana_amount, expires_at
    INTO v_equipped_id, v_equipped_mana, v_equipped_expires
    FROM public.mana_items
    WHERE user_id = p_user_id AND status = 'equipped'
    LIMIT 1;

    IF v_equipped_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'reason', 'insufficient_mana',
                                  'remaining', v_remaining, 'cost', v_cost);
    END IF;

    -- Expiración del equipado: si caducó, se pierde el maná restante y se elimina.
    IF v_equipped_expires IS NOT NULL AND v_equipped_expires < now() THEN
        DELETE FROM public.mana_items WHERE id = v_equipped_id;
        RETURN jsonb_build_object('success', false, 'reason', 'equipped_expired');
    END IF;

    IF v_equipped_mana < v_cost THEN
        -- El equipado no cubre: consumir lo que tiene y agotarlo.
        DELETE FROM public.mana_items WHERE id = v_equipped_id;
        RETURN jsonb_build_object('success', false, 'reason', 'insufficient_mana',
                                  'remaining', v_equipped_mana, 'cost', v_cost);
    END IF;

    -- Consumir del equipado (lo que "rompe el sello").
    UPDATE public.mana_items
    SET mana_amount = mana_amount - v_cost, updated_at = now()
    WHERE id = v_equipped_id;

    IF v_plan_id = 'plebeyo' THEN
        UPDATE public.user_subscriptions
        SET daily_used = COALESCE(daily_used, 0) + v_cost, daily_reset_date = CURRENT_DATE, updated_at = now()
        WHERE user_id = p_user_id;
    END IF;

    INSERT INTO public.mana_transactions (user_id, amount, type, action_code)
    VALUES (p_user_id, -v_cost, 'equipped', p_action_code);

    RETURN jsonb_build_object('success', true, 'source', 'equipped', 'cost', v_cost,
                              'remaining_equipped', v_equipped_mana - v_cost);
END;
$$;

REVOKE ALL ON FUNCTION public.consume_mana(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.consume_mana(uuid, text) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- B) add_mana_item — compra de elixir/gema → inventario (sin expiración aún).
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.add_mana_item(
  p_user_id uuid,
  p_item_type text,     -- 'gema' | 'elixir'
  p_item_id text,       -- ref a mana_gems/mana_potions id
  p_mana_amount integer
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF p_user_id IS NULL OR p_item_type IS NULL OR p_mana_amount <= 0 THEN
        RETURN FALSE;
    END IF;

    INSERT INTO public.mana_items (user_id, item_type, item_id, mana_amount, status)
    VALUES (p_user_id, p_item_type, p_item_id, p_mana_amount, 'inventory');
    RETURN TRUE;
END;
$$;

REVOKE ALL ON FUNCTION public.add_mana_item(uuid, text, text, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.add_mana_item(uuid, text, text, integer) TO service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- C) equip_mana_item — equipa 1 ítem (desequipa el anterior), inicia expiración.
--    Gema → 48h · Elixir → 15 días.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.equip_mana_item(p_user_id uuid, p_item_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_type     text;
    v_interval interval;
BEGIN
    IF p_user_id IS NULL OR p_item_id IS NULL THEN RETURN FALSE; END IF;

    -- Verificar que el ítem es del usuario y está en inventario.
    SELECT item_type INTO v_type
    FROM public.mana_items
    WHERE id = p_item_id AND user_id = p_user_id AND status = 'inventory';
    IF NOT FOUND THEN RETURN FALSE; END IF;

    v_interval := CASE WHEN v_type = 'gema' THEN interval '48 hours'
                       ELSE interval '15 days' END;

    -- Desequipa cualquier ítem activo (vuelve a inventario sin expiración).
    UPDATE public.mana_items
    SET status = 'inventory', equipped_at = NULL, expires_at = NULL, updated_at = now()
    WHERE user_id = p_user_id AND status = 'equipped';

    -- Equipa el nuevo.
    UPDATE public.mana_items
    SET status = 'equipped', equipped_at = now(), expires_at = now() + v_interval, updated_at = now()
    WHERE id = p_item_id;

    RETURN TRUE;
END;
$$;

REVOKE ALL ON FUNCTION public.equip_mana_item(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.equip_mana_item(uuid, uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- D) desequip_mana_item — libera el slot (vuelve a inventario).
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.desequip_mana_item(p_user_id uuid, p_item_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF p_user_id IS NULL OR p_item_id IS NULL THEN RETURN FALSE; END IF;

    UPDATE public.mana_items
    SET status = 'inventory', equipped_at = NULL, expires_at = NULL, updated_at = now()
    WHERE id = p_item_id AND user_id = p_user_id AND status = 'equipped';
    RETURN FOUND;
END;
$$;

REVOKE ALL ON FUNCTION public.desequip_mana_item(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.desequip_mana_item(uuid, uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
SELECT proname FROM pg_proc
WHERE proname IN ('consume_mana','add_mana_item','equip_mana_item','desequip_mana_item')
ORDER BY proname;
