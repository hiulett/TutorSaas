-- P-19 (#104): sequence_number asignado por el servidor.
--
-- Antes el cliente hacia `max(sequence_number) + 1` y luego insertaba: dos
-- inserts concurrentes en la misma conversacion podian repetir numero.
-- El trigger toma un advisory lock por conversacion y calcula el siguiente.

create or replace function public.set_message_sequence()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform pg_advisory_xact_lock(hashtextextended(new.conversation_id::text, 0));
  select coalesce(max(sequence_number), 0) + 1
    into new.sequence_number
    from public.messages
   where conversation_id = new.conversation_id;
  return new;
end;
$$;

revoke all on function public.set_message_sequence() from public, anon, authenticated;

drop trigger if exists trg_message_sequence on public.messages;
create trigger trg_message_sequence
before insert on public.messages
for each row execute function public.set_message_sequence();

-- Normaliza posibles duplicados previos de la carrera MAX+1.
with ordered as (
  select id, row_number() over (partition by conversation_id order by created_at, id) as rn
  from public.messages
)
update public.messages m
   set sequence_number = o.rn
  from ordered o
 where o.id = m.id
   and m.sequence_number <> o.rn;
