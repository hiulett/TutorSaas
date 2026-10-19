-- Issue #5: el motor de misiones no tenía ningún camino desde el cliente.
--
-- `advance_missions_for_user(p_user_id, p_type, p_delta)` es SECURITY DEFINER
-- pero solo ejecutable por service_role, así que `updateProgress` (sin
-- llamadores) nunca llegaba a aplicarse. Resultado: 533 instancias de misión
-- en `active` y ninguna completada.
--
-- Se expone una versión ligada a la sesión: toma el usuario de `auth.uid()` y
-- no acepta un id ajeno.

create or replace function public.advance_my_missions(
  p_type text,
  p_delta integer default 1
)
returns integer
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    return 0;
  end if;
  if p_type is null or p_delta is null or p_delta <= 0 then
    return 0;
  end if;

  return public.advance_missions_for_user(v_uid, p_type, p_delta);
end;
$function$;

revoke all on function public.advance_my_missions(text, integer) from public, anon;
grant execute on function public.advance_my_missions(text, integer) to authenticated;
