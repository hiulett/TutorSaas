-- ============================================================================
-- TutorSaas — SEC-IDOR: Guardas auth.uid() en RPCs SECURITY DEFINER
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
--
-- Problema: add_gems, add_fragments, add_xp, spend_gems,
-- increment_pergaminos_max, check_ai_audio_quota y track_ai_audio_time
-- reciben p_user_id SIN validar que sea el usuario autenticado. Cualquier
-- usuario autenticado podía añadirse gemas/XP/fragmentos ilimitados o
-- manipular cuentas ajenas (IDOR).
--
-- Fix: guarda `auth.uid()` al inicio. El cliente legítimo siempre pasa su
-- propio user_id, así que el flujo no cambia.
-- Idempotente: CREATE OR REPLACE FUNCTION.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.add_fragments(p_user_id uuid, p_amount integer)
 RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN RAISE EXCEPTION 'No autorizado'; END IF;
  UPDATE public.user_language_profiles SET fragments = COALESCE(fragments, 0) + p_amount WHERE user_id = p_user_id;
  IF NOT FOUND THEN INSERT INTO public.user_language_profiles (user_id, fragments) VALUES (p_user_id, p_amount); END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION public.add_gems(p_user_id uuid, p_amount integer)
 RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN RAISE EXCEPTION 'No autorizado'; END IF;
  UPDATE public.user_language_profiles SET total_gems = COALESCE(total_gems, 0) + p_amount WHERE user_id = p_user_id;
  IF NOT FOUND THEN INSERT INTO public.user_language_profiles (user_id, total_gems) VALUES (p_user_id, p_amount); END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION public.add_xp(p_user_id uuid, p_amount integer)
 RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN RAISE EXCEPTION 'No autorizado'; END IF;
  UPDATE public.user_language_profiles SET xp_points = COALESCE(xp_points, 0) + p_amount WHERE user_id = p_user_id;
  IF NOT FOUND THEN INSERT INTO public.user_language_profiles (user_id, xp_points) VALUES (p_user_id, p_amount); END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION public.spend_gems(p_user_id uuid, p_amount integer)
 RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
DECLARE v_gems INTEGER;
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN RETURN FALSE; END IF;
  SELECT COALESCE(total_gems, 0) INTO v_gems FROM public.user_language_profiles WHERE user_id = p_user_id;
  IF v_gems IS NULL OR v_gems < p_amount THEN RETURN FALSE; END IF;
  UPDATE public.user_language_profiles SET total_gems = v_gems - p_amount WHERE user_id = p_user_id;
  RETURN TRUE;
END;
$function$;

CREATE OR REPLACE FUNCTION public.increment_pergaminos_max(p_user_id uuid, p_amount integer)
 RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN RAISE EXCEPTION 'No autorizado'; END IF;
  UPDATE public.player_daily_state SET pergaminos_max = COALESCE(pergaminos_max, 5) + p_amount WHERE user_id = p_user_id AND date = CURRENT_DATE;
END;
$function$;

CREATE OR REPLACE FUNCTION public.check_ai_audio_quota(p_user_id text)
 RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
DECLARE v_used_seconds INT; v_limit_minutes INT; v_plan_name TEXT;
BEGIN
  IF auth.uid() IS NULL OR auth.uid()::text <> p_user_id THEN RETURN jsonb_build_object('is_allowed', false); END IF;
  SELECT COALESCE(us.used_audio_seconds, 0), COALESCE(sp.monthly_audio_minutes_limit, 30), COALESCE(sp.name, 'Plan Gratuito')
  INTO v_used_seconds, v_limit_minutes, v_plan_name
  FROM public.user_subscriptions us JOIN public.subscription_plans sp ON us.plan_id = sp.id WHERE us.user_id = p_user_id;
  IF NOT FOUND THEN v_used_seconds := 0; v_limit_minutes := 30; v_plan_name := 'Plan Gratuito'; END IF;
  RETURN jsonb_build_object('used_seconds', v_used_seconds, 'limit_seconds', (v_limit_minutes * 60),
    'remaining_seconds', GREATEST(0, (v_limit_minutes * 60) - v_used_seconds),
    'is_allowed', ((v_limit_minutes * 60) - v_used_seconds > 0), 'plan_name', v_plan_name);
END;
$function$;

CREATE OR REPLACE FUNCTION public.track_ai_audio_time(p_user_id text, p_duration_seconds integer)
 RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
DECLARE v_plan_limit_seconds INT; v_used_seconds INT; v_remaining_seconds INT; v_plan_id VARCHAR(50);
BEGIN
  IF auth.uid() IS NULL OR auth.uid()::text <> p_user_id THEN RETURN jsonb_build_object('is_allowed', false); END IF;
  INSERT INTO public.user_subscriptions (user_id, plan_id, used_audio_seconds) VALUES (p_user_id, 'free', 0)
  ON CONFLICT (user_id) DO NOTHING;
  UPDATE public.user_subscriptions us
  SET used_audio_seconds = us.used_audio_seconds + p_duration_seconds, updated_at = timezone('utc'::text, now())
  FROM public.subscription_plans sp WHERE us.plan_id = sp.id AND us.user_id = p_user_id
  RETURNING us.used_audio_seconds, (sp.monthly_audio_minutes_limit * 60), us.plan_id
  INTO v_used_seconds, v_plan_limit_seconds, v_plan_id;
  v_remaining_seconds := GREATEST(0, v_plan_limit_seconds - v_used_seconds);
  RETURN jsonb_build_object('used_seconds', v_used_seconds, 'limit_seconds', v_plan_limit_seconds,
    'remaining_seconds', v_remaining_seconds, 'is_allowed', (v_remaining_seconds > 0), 'plan_id', v_plan_id);
END;
$function$;

-- ============================================================================
-- Verificación: las 7 funciones deben contener 'auth.uid' en su definición.
-- ============================================================================
-- SELECT p.proname,
--        (pg_get_functiondef(p.oid) ILIKE '%auth.uid%') AS has_auth_guard
-- FROM pg_proc p
-- JOIN pg_namespace n ON n.oid = p.pronamespace
-- WHERE n.nspname = 'public'
--   AND p.proname IN ('add_gems','add_fragments','add_xp','spend_gems',
--                      'increment_pergaminos_max','check_ai_audio_quota',
--                      'track_ai_audio_time')
-- ORDER BY p.proname;
