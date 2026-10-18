-- Issue #15: `lesson-generator` cobraba antes de generar, no reembolsaba y
-- permitía carrera.
--
-- Problemas del flujo anterior:
--   1. Débito manual read-modify-write sobre `used_audio_seconds`: dos
--      llamadas concurrentes pasaban la comprobación y la última escritura
--      ganaba → generación gratis.
--   2. Se cobraba incluso cuando la lección ya existía (reutilización).
--   3. Si DeepSeek fallaba o el INSERT fallaba, el maná se perdía.
--
-- Cambios en base:
--   * `consume_mana` acepta `service_role` además del dueño, para que la
--     Edge Function pueda usarla en lugar de replicar la lógica.
--   * `refund_mana` devuelve el coste de una acción (solo service_role).

do $fix$
declare
  v_def text;
begin
  select pg_get_functiondef(oid) into v_def
    from pg_proc
   where pronamespace = 'public'::regnamespace
     and proname = 'consume_mana';

  if position('service_role' in v_def) = 0 then
    v_def := replace(
      v_def,
      'auth.uid() IS NULL OR auth.uid() <> p_user_id',
      'NOT (coalesce(auth.role(), '''') = ''service_role'' OR auth.uid() = p_user_id)'
    );
    execute v_def;
  end if;
end;
$fix$;

create or replace function public.refund_mana(p_user_id uuid, p_action_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $r$
declare
  v_cost integer;
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    raise exception 'No autorizado';
  end if;

  select coalesce(cost_mana, 0) into v_cost
    from public.ai_action_costs
   where action_code = p_action_code and is_active;

  if v_cost is null or v_cost <= 0 then
    return jsonb_build_object('success', false);
  end if;

  update public.user_subscriptions
     set used_audio_seconds = greatest(0, coalesce(used_audio_seconds, 0) - v_cost),
         updated_at = now()
   where user_id = p_user_id;

  insert into public.mana_transactions (user_id, amount, type, action_code)
  values (p_user_id, v_cost, 'refund', p_action_code);

  return jsonb_build_object('success', true, 'refunded', v_cost);
end;
$r$;

revoke all on function public.refund_mana(uuid, text) from public, anon, authenticated;
grant execute on function public.refund_mana(uuid, text) to service_role;
