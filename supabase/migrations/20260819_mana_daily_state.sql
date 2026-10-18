-- 20260819_mana_daily_state.sql
-- get_mana_state ahora devuelve también los datos del LÍMITE DIARIO (free).
-- El maná de plan free se rige por el límite diario (daily_limit=200): la barra
-- del dashboard mostrará daily_remaining/daily_limit en lugar del saldo mensual.
CREATE OR REPLACE FUNCTION public.get_mana_state(p_user_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
DECLARE
    v_allowance BIGINT; v_purchased BIGINT; v_used BIGINT; v_expires TIMESTAMPTZ;
    v_plan TEXT; v_class TEXT; v_plan_id TEXT;
    v_daily_limit INTEGER; v_daily_used INTEGER; v_daily_date DATE;
BEGIN
    IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
        RETURN jsonb_build_object('error', 'unauthorized');
    END IF;

    SELECT COALESCE(sp.mana_allowance, 1800), COALESCE(sp.class_name, 'plebeyo'),
           COALESCE(sp.name, 'Plan Gratuito'), COALESCE(us.plan_id, 'plebeyo')
    INTO v_allowance, v_class, v_plan, v_plan_id
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;

    SELECT COALESCE(us.purchased_mana_balance, 0), COALESCE(us.used_audio_seconds, 0),
           us.mana_expires_at, COALESCE(us.daily_limit, 200), COALESCE(us.daily_used, 0),
           us.daily_reset_date
    INTO v_purchased, v_used, v_expires, v_daily_limit, v_daily_used, v_daily_date
    FROM public.user_subscriptions us WHERE us.user_id = p_user_id;

    IF v_allowance IS NULL THEN v_allowance := 1800; END IF;
    IF v_purchased IS NULL THEN v_purchased := 0; END IF;
    IF v_used IS NULL THEN v_used := 0; END IF;
    IF v_daily_limit IS NULL THEN v_daily_limit := 200; END IF;
    IF v_daily_used IS NULL THEN v_daily_used := 0; END IF;

    -- Reset diario lazy (mismo criterio que consume_mana).
    IF v_daily_date IS DISTINCT FROM CURRENT_DATE THEN
        v_daily_used := 0;
        UPDATE public.user_subscriptions
        SET daily_used = 0, daily_reset_date = CURRENT_DATE, updated_at = now()
        WHERE user_id = p_user_id;
    END IF;

    RETURN jsonb_build_object(
        'allowance', v_allowance,
        'purchased', v_purchased,
        'used', v_used,
        'remaining', GREATEST(0, (v_allowance + v_purchased) - v_used),
        'expires_at', v_expires,
        'plan', COALESCE(v_plan, 'Plan Gratuito'),
        'class', COALESCE(v_class, 'plebeyo'),
        'is_free', (v_plan_id = 'plebeyo'),
        'daily_limit', v_daily_limit,
        'daily_used', v_daily_used,
        'daily_remaining', GREATEST(0, v_daily_limit - v_daily_used)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.get_mana_state(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_mana_state(uuid) TO authenticated;
