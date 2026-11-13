-- Repaso con pergaminos (#375).
--
-- Modelo real (verificado en produccion): los pergaminos son un CUPO diario en
-- `player_daily_state` (`pergaminos_used` / `pergaminos_max`, 5 por defecto), no
-- un saldo. `player_pergaminos` (contenido jsonb) quedo como stub: solo tiene
-- politica SELECT, asi que el INSERT del cliente fallaba en silencio.
--
-- Este cambio implementa el repaso de verdad:
--   * `open_review_pergamino()`: consume 1 del cupo diario y devuelve ejercicios
--     derivados de las correcciones de las ultimas 24 h (sin LLM, sin maná).
--   * El cliente deja de insertar pergaminos placeholder.

create or replace function public.open_review_pergamino()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_used integer;
  v_max integer;
  v_items jsonb;
begin
  if v_uid is null then raise exception 'No autorizado'; end if;

  -- Fila del dia (idempotente).
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

  -- Ejercicios desde las correcciones recientes. Sin LLM: se reutiliza lo que
  -- el Oraculo ya corrigio en la sesion.
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
             row_number() over (order by m.created_at desc, c.id) as ord
        from public.corrections c
        join public.messages m on m.id = c.message_id
       where m.user_id = v_uid
         and m.created_at > now() - interval '24 hours'
       order by m.created_at desc
       limit 10
    ) t;

  -- Sin correcciones recientes no se consume el cupo.
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

revoke execute on function public.open_review_pergamino() from public, anon;
grant execute on function public.open_review_pergamino() to authenticated;

comment on function public.open_review_pergamino() is
  'Consume 1 pergamino del cupo diario y devuelve el repaso derivado de las correcciones de las ultimas 24 h (#375).';

-- Verificacion (solo lectura):
-- select pergaminos_used, pergaminos_max, date from public.player_daily_state order by date desc limit 5;
