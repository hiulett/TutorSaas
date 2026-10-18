-- Issue #12: IDOR en RPCs de gremio.
--
-- `join_table`, `leave_table`, `claim_seat`, `request_seat`, `stand_up`,
-- `touch_presence`, `equip_mana_item`, `desequip_mana_item` y
-- `moderator_stand` recibían `p_user_id` sin comprobarlo contra `auth.uid()`.
-- Con un UUID ajeno (que el leaderboard exponía) se podía expulsar, mover de
-- sala o equipar ítems de otra persona.
--
-- Este bloque inserta la guarda en cada función existente sin reescribirlas a
-- mano: recorre `pg_proc`, inyecta la comprobación tras el primer `BEGIN` y
-- vuelve a ejecutar la definición.
--
-- `touch_presence` era LANGUAGE sql (sin BEGIN); se reescribe aparte.

do $guard$
declare
  r record;
  v_param text;
  v_def text;
begin
  for r in
    select proname, pg_get_functiondef(oid) as def
      from pg_proc
     where pronamespace = 'public'::regnamespace
       and proname in (
         'claim_seat', 'join_table', 'leave_table', 'request_seat',
         'stand_up', 'equip_mana_item', 'desequip_mana_item', 'moderator_stand'
       )
  loop
    if position('No autorizado' in r.def) > 0 then
      continue;
    end if;

    v_param := case
                 when r.proname = 'moderator_stand' then 'p_moderator_id'
                 else 'p_user_id'
               end;

    v_def := regexp_replace(
      r.def,
      '\mBEGIN\M',
      E'BEGIN\n    IF auth.uid() IS NULL OR auth.uid() <> ' || v_param ||
        E' THEN\n        RAISE EXCEPTION ''No autorizado'';\n    END IF;',
      'i'
    );

    execute v_def;
  end loop;
end;
$guard$;

create or replace function public.touch_presence(p_room_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $tp$
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  update public.chat_room_participants
     set last_seen_at = now()
   where room_id = p_room_id and user_id = p_user_id;
end;
$tp$;

-- Política laxa: permitía insertar un participante con cualquier `user_id`
-- mientras `presence_state` fuese 'standing'. La política correcta
-- (`Users can join rooms`, auth.uid() = user_id) se mantiene.
drop policy if exists "Se puede unirse de pie" on public.chat_room_participants;
