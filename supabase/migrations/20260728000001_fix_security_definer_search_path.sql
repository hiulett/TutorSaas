-- ============================================================
-- FASE 1.1: Revoke EXECUTE from anon for SECURITY DEFINER functions
-- ============================================================
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_auth_rate_limit() FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_ai_audio_quota(p_user_id text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_user_rate_limit(p_user_id uuid, p_max_requests integer, p_interval_seconds integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon;
REVOKE EXECUTE ON FUNCTION public.track_ai_audio_time(p_user_id text, p_duration_seconds integer) FROM anon;

-- ============================================================
-- FASE 1.2: Add SET search_path to all SECURITY DEFINER functions
-- ============================================================

-- handle_new_user (already has SET search_path TO '')
-- Note: Trigger function, called by auth trigger. Already has search_path fix.

-- before_message_inserted_auth_rate_limit
CREATE OR REPLACE FUNCTION public.before_message_inserted_auth_rate_limit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
DECLARE
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NOT NULL THEN
        IF NOT public.check_user_rate_limit(v_user_id, 20, 60) THEN
            RAISE EXCEPTION 'Límite de solicitudes alcanzado. Por favor, espera un minuto o adquiere el plan Premium.';
        END IF;
    END IF;
    RETURN NEW;
END;
$function$;

-- check_ai_audio_quota
CREATE OR REPLACE FUNCTION public.check_ai_audio_quota(p_user_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
DECLARE
    v_used_seconds INT;
    v_limit_minutes INT;
    v_plan_name TEXT;
BEGIN
    SELECT COALESCE(us.used_audio_seconds, 0), COALESCE(sp.monthly_audio_minutes_limit, 30), COALESCE(sp.name, 'Plan Gratuito')
    INTO v_used_seconds, v_limit_minutes, v_plan_name
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;

    IF NOT FOUND THEN
        v_used_seconds := 0;
        v_limit_minutes := 30;
        v_plan_name := 'Plan Gratuito';
    END IF;

    RETURN jsonb_build_object(
        'used_seconds', v_used_seconds,
        'limit_seconds', (v_limit_minutes * 60),
        'remaining_seconds', GREATEST(0, (v_limit_minutes * 60) - v_used_seconds),
        'is_allowed', ((v_limit_minutes * 60) - v_used_seconds > 0),
        'plan_name', v_plan_name
    );
END;
$function$;

-- check_user_rate_limit
CREATE OR REPLACE FUNCTION public.check_user_rate_limit(p_user_id uuid, p_max_requests integer, p_interval_seconds integer)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
DECLARE
    v_request_count INTEGER;
    v_is_premium BOOLEAN;
BEGIN
    SELECT is_active INTO v_is_premium
    FROM public.users
    WHERE id = p_user_id;

    IF v_is_premium THEN
        RETURN TRUE;
    END IF;

    SELECT COUNT(*) INTO v_request_count
    FROM public.api_request_logs
    WHERE user_id = p_user_id
      AND created_at >= NOW() - (p_interval_seconds || ' seconds')::INTERVAL;

    IF v_request_count >= p_max_requests THEN
        RETURN FALSE;
    END IF;

    INSERT INTO public.api_request_logs (user_id, endpoint)
    VALUES (p_user_id, 'deepseek_chat_completion');

    RETURN TRUE;
END;
$function$;

-- track_ai_audio_time
CREATE OR REPLACE FUNCTION public.track_ai_audio_time(p_user_id text, p_duration_seconds integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
DECLARE
    v_plan_limit_seconds INT;
    v_used_seconds INT;
    v_remaining_seconds INT;
    v_plan_id VARCHAR(50);
BEGIN
    INSERT INTO public.user_subscriptions (user_id, plan_id, used_audio_seconds)
    VALUES (p_user_id, 'free', 0)
    ON CONFLICT (user_id) DO NOTHING;

    UPDATE public.user_subscriptions us
    SET used_audio_seconds = us.used_audio_seconds + p_duration_seconds,
        updated_at = timezone('utc'::text, now())
    FROM public.subscription_plans sp
    WHERE us.plan_id = sp.id AND us.user_id = p_user_id
    RETURNING us.used_audio_seconds, (sp.monthly_audio_minutes_limit * 60), us.plan_id
    INTO v_used_seconds, v_plan_limit_seconds, v_plan_id;

    v_remaining_seconds := GREATEST(0, v_plan_limit_seconds - v_used_seconds);

    RETURN jsonb_build_object(
        'used_seconds', v_used_seconds,
        'limit_seconds', v_plan_limit_seconds,
        'remaining_seconds', v_remaining_seconds,
        'is_allowed', (v_remaining_seconds > 0),
        'plan_id', v_plan_id
    );
END;
$function$;

-- trigger_set_timestamps
CREATE OR REPLACE FUNCTION public.trigger_set_timestamps()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$function$;
