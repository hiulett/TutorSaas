-- P-26 (#111): turno de gracia diario para no cortar a mitad de una meta.
--
-- Decisión de producto: se mantiene el tope diario de 200 de maná para el plan
-- gratuito (~16 turnos de mazmorra) y se añade **un turno gratis al día**
-- cuando el tope diario ya se alcanzó. Así el usuario puede cerrar el
-- intercambio en curso en vez de quedarse bloqueado a mitad de la misión.
--
-- Es idempotente por día (`mana_grace_date`) y solo lo puede reclamar
-- `service_role` (lo hace `llm-proxy` cuando `consume_mana` responde
-- `daily_limit_reached`). No aplica al saldo mensual agotado del plan pago.

begin;

alter table public.user_subscriptions
  add column if not exists mana_grace_date date;

comment on column public.user_subscriptions.mana_grace_date is
  'Último día en que se usó el turno de gracia (P-26). Una vez por día.';

create or replace function public.claim_mana_grace(p_user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_updated integer := 0;
begin
  if p_user_id is null then
    raise exception 'Usuario requerido';
  end if;

  update public.user_subscriptions
     set mana_grace_date = current_date,
         updated_at = now()
   where user_id = p_user_id
     and (mana_grace_date is null or mana_grace_date < current_date);

  get diagnostics v_updated = row_count;
  return v_updated > 0;
end;
$$;

revoke all on function public.claim_mana_grace(uuid) from public, anon, authenticated;
grant execute on function public.claim_mana_grace(uuid) to service_role;

commit;
