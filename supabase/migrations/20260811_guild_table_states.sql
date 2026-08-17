-- ============================================================================
-- MESAS DEL GREMIO — Estados de presencia (de pie / sentado) + cola de sillas
--
-- Reglas:
--   1. Estado "de pie" (standing): escucha + chat, NO transmite audio.
--   2. Estado "sentado" (seated): transmite + recibe audio y participa en chat.
--   3. Capacidad: 8 sentados + 8 de pie por mesa.
--   4. Solo los sentados publican audio (canPublish) en LiveKit.
--   5. Silla libre → auto-asiento del primero en la cola (FIFO).
--   6. Un usuario solo puede estar activo en UNA mesa a la vez.
--   7. Moderador humano puede expulsar ("poner de pie") a cualquier participante.
--   8. Heartbeat (last_seen_at) + purga de participantes fantasma (evicción).
--
-- Concurrencia: las mutaciones de asientos pasan por RPC SECURITY DEFINER con
-- advisory lock por mesa (pg_advisory_xact_lock), eliminando races.
-- ============================================================================

-- ── 1. chat_rooms: columnas de capacidad ──────────────────────────────────────
ALTER TABLE public.chat_rooms
    ADD COLUMN IF NOT EXISTS max_seats    INTEGER NOT NULL DEFAULT 8,
    ADD COLUMN IF NOT EXISTS max_standing INTEGER NOT NULL DEFAULT 8;

-- ── 2. chat_room_participants: presencia + heartbeat + sillas 1-8 ───────────
ALTER TABLE public.chat_room_participants
    ADD COLUMN IF NOT EXISTS presence_state TEXT NOT NULL DEFAULT 'standing'
        CHECK (presence_state IN ('standing', 'seated')),
    ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ DEFAULT NOW();

-- El slot de silla pasa de 1-10 a 1-8 (8 sillas de la mesa).
ALTER TABLE public.chat_room_participants
    DROP CONSTRAINT IF EXISTS chat_room_participants_speaker_slot_check;

ALTER TABLE public.chat_room_participants
    ADD CONSTRAINT chat_room_participants_speaker_slot_check
    CHECK (speaker_slot BETWEEN 1 AND 8);

-- Backfill: los participantes con silla pasan a seated; el resto standing.
UPDATE public.chat_room_participants
SET presence_state = 'seated'
WHERE speaker_slot IS NOT NULL
  AND presence_state = 'standing';

-- ── 3. Cola FIFO de petición de silla ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.seat_requests (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id      UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id      UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    status       TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'granted', 'cancelled')),
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (room_id, user_id)
);

CREATE INDEX IF NOT EXISTS seat_requests_room_status_idx
    ON public.seat_requests (room_id, status, created_at);

-- ── 4. Índices de presencia / sillas ─────────────────────────────────────────
CREATE INDEX IF NOT EXISTS participants_room_presence_idx
    ON public.chat_room_participants (room_id, presence_state);

CREATE INDEX IF NOT EXISTS participants_room_seat_idx
    ON public.chat_room_participants (room_id, speaker_slot)
    WHERE speaker_slot IS NOT NULL;

CREATE INDEX IF NOT EXISTS participants_user_idx
    ON public.chat_room_participants (user_id);

-- ── 5. Realtime ──────────────────────────────────────────────────────────────
-- chat_room_participants YA pertenece a la publicación (migración original);
-- añadirla de nuevo da error 42710. Solo se agrega seat_requests, idempotente.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime'
          AND schemaname = 'public'
          AND tablename = 'seat_requests'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.seat_requests;
    END IF;
END $$;

-- ============================================================================
-- RPCs (SECURITY DEFINER con advisory lock por mesa)
-- ============================================================================

-- Unirse a la mesa en estado "de pie". Abandona cualquier otra mesa activa
-- (regla: una mesa activa por sesión).
CREATE OR REPLACE FUNCTION public.join_table(p_room_id uuid, p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('join:' || p_user_id::text));

    -- Abandonar cualquier otra mesa donde el usuario esté presente.
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

-- Sentarse en una silla concreta (1-8). Valida: presencia en la mesa, silla
-- libre, tope de 8 sentados, una mesa activa. Transaccional + lock por mesa.
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

    -- Una mesa activa por sesión: no puede estar sentado en otra mesa.
    SELECT room_id INTO v_other_room
    FROM public.chat_room_participants
    WHERE user_id = p_user_id
      AND presence_state = 'seated'
      AND room_id <> p_room_id
    LIMIT 1;
    IF v_other_room IS NOT NULL THEN
        RETURN 'seated_elsewhere';
    END IF;

    -- Debe ser participante de esta mesa (de pie o ya sentado).
    IF NOT EXISTS (
        SELECT 1 FROM public.chat_room_participants
        WHERE room_id = p_room_id AND user_id = p_user_id
    ) THEN
        RETURN 'not_in_room';
    END IF;

    -- Silla ocupada.
    IF EXISTS (
        SELECT 1 FROM public.chat_room_participants
        WHERE room_id = p_room_id AND speaker_slot = p_seat AND presence_state = 'seated'
    ) THEN
        RETURN 'seat_taken';
    END IF;

    -- Tope de 8 sentados.
    SELECT count(*) INTO v_seated_count
    FROM public.chat_room_participants
    WHERE room_id = p_room_id AND presence_state = 'seated';
    IF v_seated_count >= 8 THEN
        RETURN 'table_full';
    END IF;

    UPDATE public.chat_room_participants
    SET presence_state = 'seated', speaker_slot = p_seat, last_seen_at = NOW()
    WHERE room_id = p_room_id AND user_id = p_user_id;

    -- El usuario que logra sentarse sale de la cola.
    DELETE FROM public.seat_requests
    WHERE room_id = p_room_id AND user_id = p_user_id;

    RETURN 'ok';
END;
$$;

-- Pedir silla. Si hay una libre, sienta directamente; si no, encola (FIFO).
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

    -- Encolar FIFO.
    INSERT INTO public.seat_requests (room_id, user_id)
    VALUES (p_room_id, p_user_id)
    ON CONFLICT (room_id, user_id)
    DO UPDATE SET status = 'pending', created_at = NOW();

    RETURN 'queued';
END;
$$;

-- Levantarse: libera la silla, vuelve a "de pie" y auto-asienta al primero de
-- la cola en la silla liberada.
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

-- Salir de la mesa por completo (borra la fila). Si estaba sentado, libera la
-- silla para el primero de la cola.
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

    -- Mesa vacía → eliminar (mismo comportamiento que leaveRoom del cliente).
    IF NOT EXISTS (
        SELECT 1 FROM public.chat_room_participants WHERE room_id = p_room_id
    ) THEN
        DELETE FROM public.chat_rooms WHERE id = p_room_id;
    END IF;
END;
$$;

-- Auto-asiento FIFO: asigna la primera silla libre al primer usuario en cola.
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

-- Moderador humano: pone "de pie" a un participante (expulsión suave) o lo
-- elimina. Debe ser el creador o el moderador asignado de la mesa.
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

-- Heartbeat: el cliente llama cada ~30s mientras está en la mesa.
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

-- Purga de participantes fantasma (evicción). Llama al liberar una silla a
-- grant_next_seat. Se invoca desde cron o al abrir la mesa.
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

-- ── 6. RLS ───────────────────────────────────────────────────────────────────
ALTER TABLE public.chat_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seat_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Se puede unirse de pie" ON public.chat_room_participants;
CREATE POLICY "Se puede unirse de pie"
ON public.chat_room_participants FOR INSERT
WITH CHECK (auth.role() = 'authenticated' AND presence_state = 'standing');

DROP POLICY IF EXISTS "Moderador puede poner de pie" ON public.chat_room_participants;
CREATE POLICY "Moderador puede poner de pie"
ON public.chat_room_participants FOR UPDATE
USING (
    presence_state = 'standing'
    OR EXISTS (
        SELECT 1 FROM public.chat_rooms
        WHERE id = chat_room_participants.room_id
          AND (moderator_id = auth.uid() OR assigned_moderator_id = auth.uid())
    )
);

DROP POLICY IF EXISTS "Leer cola de sillas" ON public.seat_requests;
CREATE POLICY "Leer cola de sillas"
ON public.seat_requests FOR SELECT
USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Pedir silla" ON public.seat_requests;
CREATE POLICY "Pedir silla"
ON public.seat_requests FOR INSERT
WITH CHECK (auth.role() = 'authenticated' AND user_id = auth.uid());

DROP POLICY IF EXISTS "Cancelar petición propia o moderador" ON public.seat_requests;
CREATE POLICY "Cancelar petición propia o moderador"
ON public.seat_requests FOR DELETE
USING (
    auth.uid() = user_id
    OR EXISTS (
        SELECT 1 FROM public.chat_rooms
        WHERE id = seat_requests.room_id
          AND (moderator_id = auth.uid() OR assigned_moderator_id = auth.uid())
    )
);

-- ── 7. Permisos de ejecución de RPCs ─────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.join_table(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.claim_seat(uuid, uuid, int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.request_seat(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.stand_up(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.leave_table(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.grant_next_seat(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.moderator_stand(uuid, uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.touch_presence(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.purge_stale_participants(int) TO authenticated;
