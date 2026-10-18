-- Bugfix: las mesas del gremio desaparecían al entrar y salir de ellas.
-- Causa: leave_table eliminaba la mesa cuando el usuario que salía era el
-- último participante. Ahora la mesa persiste vacía (sin participantes).
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

    -- La mesa permanece en el gremio aunque quede vacía (antes se borraba).
END;
$$;
