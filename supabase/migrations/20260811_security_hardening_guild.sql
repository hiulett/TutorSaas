-- ============================================================================
-- HARDENING AUDITORÍA 007 — Correcciones críticas de seguridad
--
-- 1. REVOCAR EXECUTE a anon en todas las funciones SECURITY DEFINER del
--    gremio/audio. Mantener `authenticated` (los usuarios logueados sí deben
--    poder sentarse, pedir silla, etc). Sin esto, cualquiera sin sesión puede
--    llamar claim_seat, grant_next_seat, purge_stale_participants, etc.
--
-- 2. Fijar `search_path = public` en las funciones para evitar que el llamador
--    influya en la resolución de objetos (evita escalada de privilegios).
--
-- 3. Activar leaked-password protection (config de auth, vía dashboard).
-- ============================================================================

-- ── 1. Bloquear PUBLIC + revocar anon de las RPC del gremio (SECURITY DEFINER)
-- IMPORTANTE: REVOKE FROM anon NO basta porque anon hereda EXECUTE de PUBLIC.
-- Se revoca de PUBLIC y se regrantea SOLO a authenticated.
REVOKE EXECUTE ON FUNCTION public.join_table(uuid, uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.claim_seat(uuid, uuid, integer) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.request_seat(uuid, uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.stand_up(uuid, uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.leave_table(uuid, uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.grant_next_seat(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.moderator_stand(uuid, uuid, uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.touch_presence(uuid, uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.purge_stale_participants(integer) FROM PUBLIC, anon;

-- ── 2. Fijar search_path en las funciones del gremio ─────────────────────────
CREATE OR REPLACE FUNCTION public.join_table(p_room_id uuid, p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('join:' || p_user_id::text));

    DELETE FROM public.chat_room_participants
    WHERE user_id = p_user_id AND room_id <> p_room_id;

    DELETE FROM public.seat_requests
    WHERE user_id = p_user_id AND room_id <> p_room_id;

    INSERT INTO public.chat_room_participants (room_id, user_id, presence_state, speaker_slot, joined_at, last_seen_at)
    VALUES (p_room_id, p_user_id, 'standing', NULL, NOW(), NOW())
    ON CONFLICT (room_id, user_id)
    DO UPDATE SET presence_state = 'standing', speaker_slot = NULL, last_seen_at = NOW();
END;
$$;

CREATE OR REPLACE FUNCTION public.claim_seat(p_room_id uuid, p_user_id uuid, p_seat int)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_seated_count int;
    v_other_room uuid;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('table:' || p_room_id::text));

    IF p_seat < 1 OR p_seat > 8 THEN
        RETURN 'invalid_seat';
    END IF;

    SELECT room_id INTO v_other_room
    FROM public.chat_room_participants
    WHERE user_id = p_user_id
      AND presence_state = 'seated'
      AND room_id <> p_room_id
    LIMIT 1;
    IF v_other_room IS NOT NULL THEN
        RETURN 'seated_elsewhere';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.chat_room_participants
        WHERE room_id = p_room_id AND user_id = p_user_id
    ) THEN
        RETURN 'not_in_room';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.chat_room_participants
        WHERE room_id = p_room_id AND speaker_slot = p_seat AND presence_state = 'seated'
    ) THEN
        RETURN 'seat_taken';
    END IF;

    SELECT count(*) INTO v_seated_count
    FROM public.chat_room_participants
    WHERE room_id = p_room_id AND presence_state = 'seated';
    IF v_seated_count >= 8 THEN
        RETURN 'table_full';
    END IF;

    UPDATE public.chat_room_participants
    SET presence_state = 'seated', speaker_slot = p_seat, last_seen_at = NOW()
    WHERE room_id = p_room_id AND user_id = p_user_id;

    DELETE FROM public.seat_requests
    WHERE room_id = p_room_id AND user_id = p_user_id;

    RETURN 'ok';
END;
$$;

CREATE OR REPLACE FUNCTION public.request_seat(p_room_id uuid, p_user_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_free_slot int;
    v_seated_count int;
    v_result text;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('table:' || p_room_id::text));

    SELECT count(*) INTO v_seated_count
    FROM public.chat_room_participants
    WHERE room_id = p_room_id AND presence_state = 'seated';

    IF v_seated_count < 8 THEN
        SELECT speaker_slot INTO v_free_slot
        FROM generate_series(1, 8) AS speaker_slot
        WHERE NOT EXISTS (
            SELECT 1 FROM public.chat_room_participants
            WHERE room_id = p_room_id AND speaker_slot = speaker_slot AND presence_state = 'seated'
        )
        ORDER BY speaker_slot
        LIMIT 1;

        IF v_free_slot IS NOT NULL THEN
            v_result := public.claim_seat(p_room_id, p_user_id, v_free_slot);
            IF v_result = 'ok' THEN
                RETURN 'seated';
            END IF;
        END IF;
    END IF;

    INSERT INTO public.seat_requests (room_id, user_id)
    VALUES (p_room_id, p_user_id)
    ON CONFLICT (room_id, user_id)
    DO UPDATE SET status = 'pending', created_at = NOW();

    RETURN 'queued';
END;
$$;

CREATE OR REPLACE FUNCTION public.stand_up(p_room_id uuid, p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('table:' || p_room_id::text));

    UPDATE public.chat_room_participants
    SET presence_state = 'standing', speaker_slot = NULL, last_seen_at = NOW()
    WHERE room_id = p_room_id AND user_id = p_user_id AND presence_state = 'seated';

    PERFORM public.grant_next_seat(p_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.leave_table(p_room_id uuid, p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('table:' || p_room_id::text));

    DELETE FROM public.chat_room_participants
    WHERE room_id = p_room_id AND user_id = p_user_id;

    DELETE FROM public.seat_requests
    WHERE room_id = p_room_id AND user_id = p_user_id;

    PERFORM public.grant_next_seat(p_room_id);

    IF NOT EXISTS (
        SELECT 1 FROM public.chat_room_participants WHERE room_id = p_room_id
    ) THEN
        DELETE FROM public.chat_rooms WHERE id = p_room_id;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.grant_next_seat(p_room_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_next_user uuid;
    v_free_slot int;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('table:' || p_room_id::text));

    SELECT user_id INTO v_next_user
    FROM public.seat_requests
    WHERE room_id = p_room_id AND status = 'pending'
    ORDER BY created_at
    LIMIT 1;

    IF v_next_user IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT speaker_slot INTO v_free_slot
    FROM generate_series(1, 8) AS speaker_slot
    WHERE NOT EXISTS (
        SELECT 1 FROM public.chat_room_participants
        WHERE room_id = p_room_id AND speaker_slot = speaker_slot AND presence_state = 'seated'
    )
    ORDER BY speaker_slot
    LIMIT 1;

    IF v_free_slot IS NULL THEN
        RETURN NULL;
    END IF;

    UPDATE public.chat_room_participants
    SET presence_state = 'seated', speaker_slot = v_free_slot, last_seen_at = NOW()
    WHERE room_id = p_room_id AND user_id = v_next_user;

    UPDATE public.seat_requests
    SET status = 'granted'
    WHERE room_id = p_room_id AND user_id = v_next_user;

    RETURN v_next_user;
END;
$$;

CREATE OR REPLACE FUNCTION public.moderator_stand(
    p_room_id uuid,
    p_target_user_id uuid,
    p_moderator_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('table:' || p_room_id::text));

    IF NOT EXISTS (
        SELECT 1 FROM public.chat_rooms
        WHERE id = p_room_id
          AND (moderator_id = p_moderator_id OR assigned_moderator_id = p_moderator_id)
    ) THEN
        RETURN false;
    END IF;

    UPDATE public.chat_room_participants
    SET presence_state = 'standing', speaker_slot = NULL, last_seen_at = NOW()
    WHERE room_id = p_room_id AND user_id = p_target_user_id;

    DELETE FROM public.seat_requests
    WHERE room_id = p_room_id AND user_id = p_target_user_id;

    PERFORM public.grant_next_seat(p_room_id);

    RETURN true;
END;
$$;

CREATE OR REPLACE FUNCTION public.touch_presence(p_room_id uuid, p_user_id uuid)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    UPDATE public.chat_room_participants
    SET last_seen_at = NOW()
    WHERE room_id = p_room_id AND user_id = p_user_id;
$$;

CREATE OR REPLACE FUNCTION public.purge_stale_participants(
    p_max_age_seconds int DEFAULT 90
)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_room uuid;
    v_count int := 0;
BEGIN
    FOR v_room IN
        SELECT DISTINCT room_id
        FROM public.chat_room_participants
        WHERE last_seen_at < NOW() - (p_max_age_seconds * interval '1 second')
    LOOP
        DELETE FROM public.chat_room_participants
        WHERE room_id = v_room
          AND last_seen_at < NOW() - (p_max_age_seconds * interval '1 second')
          AND user_id NOT IN (
              SELECT user_id FROM public.seat_requests WHERE room_id = v_room AND status = 'pending'
          );
        GET DIAGNOSTICS v_count = ROW_COUNT;
        PERFORM public.grant_next_seat(v_room);
    END LOOP;

    DELETE FROM public.seat_requests
    WHERE user_id NOT IN (
        SELECT DISTINCT user_id FROM public.chat_room_participants
    );

    RETURN v_count;
END;
$$;

-- Re-aplicar grants a authenticated tras recrear las funciones (los grants a
-- funciones se mantienen al hacer CREATE OR REPLACE, pero por seguridad).
GRANT EXECUTE ON FUNCTION public.join_table(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.claim_seat(uuid, uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.request_seat(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.stand_up(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.leave_table(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.grant_next_seat(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.moderator_stand(uuid, uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.touch_presence(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.purge_stale_participants(integer) TO authenticated;

-- ── 4. Rate limit de emisión de tokens LiveKit (anti-abuso / DoS) ───────────
CREATE TABLE IF NOT EXISTS public.livekit_token_requests (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    requested_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS livekit_token_requests_user_time_idx
    ON public.livekit_token_requests (user_id, requested_at);

CREATE OR REPLACE FUNCTION public.check_token_rate_limit(
    p_user_id uuid,
    p_max_requests int DEFAULT 20,
    p_window_seconds int DEFAULT 60
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_count int;
BEGIN
    DELETE FROM public.livekit_token_requests
    WHERE requested_at < NOW() - (p_window_seconds * interval '1 second');

    SELECT count(*) INTO v_count
    FROM public.livekit_token_requests
    WHERE user_id = p_user_id
      AND requested_at >= NOW() - (p_window_seconds * interval '1 second');

    IF v_count >= p_max_requests THEN
        RETURN false;
    END IF;

    INSERT INTO public.livekit_token_requests (user_id)
    VALUES (p_user_id);

    RETURN true;
END;
$$;

GRANT EXECUTE ON FUNCTION public.check_token_rate_limit(uuid, int, int) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.check_token_rate_limit(uuid, int, int) FROM PUBLIC, anon;
CREATE OR REPLACE FUNCTION public.before_message_inserted_rate_limit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = public
AS $function$
BEGIN
    -- Enforce 30 requests per minute for free tier users
    IF NOT public.check_user_rate_limit(NEW.conversation_id, 30, 60) THEN
        RAISE EXCEPTION 'Rate limit exceeded. Please wait a minute or upgrade to Premium.';
    END IF;
    RETURN NEW;
END;
$function$;
