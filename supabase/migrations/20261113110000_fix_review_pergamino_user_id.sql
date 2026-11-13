-- Fix `open_review_pergamino`: usaba `m.user_id`, que no existe (#375).
--
-- Error en dispositivo (build 13-nov): PostgrestException 42703
--   column m.user_id does not exist
--   hint: Perhaps you meant to reference the column "c.user_id"
--
-- Verificado en produccion: `corrections` tiene `user_id`, `conversation_id`,
-- `turn_ref` y `created_at` propios; `messages` NO tiene `user_id`. El JOIN era
-- innecesario.
--
-- No cambia el contrato de respuesta: el cliente no necesita rebuild.

create or replace function public.open_review_pergamino()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid   uuid := auth.uid();
  v_used  integer;
  v_max   integer;
  v_items jsonb;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;

  insert into public.player_daily_state (user_id, date)
  values (v_uid, current_date)
  on conflict (user_id, date) do nothing;

  select coalesce(pergaminos_used, 0), coalesce(pergaminos_max, 5)
    into v_used, v_max
    from public.player_daily_state
   where user_id = v_uid and date = current_date
   for update;

  if v_used >= v_max then
    return jsonb_build_object(
      'success', false, 'reason', 'no_pergaminos',
      'remaining', 0, 'items', '[]'::jsonb
    );
  end if;

  -- Sin JOIN: `corrections` ya guarda user_id y created_at.
  select coalesce(jsonb_agg(t.item order by t.ord), '[]'::jsonb)
    into v_items
    from (
      select jsonb_build_object(
               'original', c.original_text,
               'corrected', c.corrected_text,
               'explanation', coalesce(c.explanation, ''),
               'error_type', coalesce(c.error_type, 'grammar'),
               'severity', coalesce(c.severity, 'minor')
             ) as item,
             row_number() over (order by c.created_at desc, c.id) as ord
        from public.corrections c
       where c.user_id = v_uid
         and c.created_at > now() - interval '24 hours'
       order by c.created_at desc
       limit 10
    ) t;

  if jsonb_array_length(v_items) = 0 then
    return jsonb_build_object(
      'success', false, 'reason', 'no_corrections',
      'remaining', v_max - v_used, 'items', '[]'::jsonb
    );
  end if;

  update public.player_daily_state
     set pergaminos_used = v_used + 1
   where user_id = v_uid and date = current_date;

  return jsonb_build_object(
    'success', true,
    'remaining', v_max - (v_used + 1),
    'items', v_items
  );
end;
$$;

comment on function public.open_review_pergamino() is
  'Consume 1 pergamino del cupo diario y devuelve el repaso de las correcciones de las ultimas 24 h (#375, fix user_id).';

-- Verificacion:
-- select count(*) from public.corrections where created_at > now() - interval '24 hours';
