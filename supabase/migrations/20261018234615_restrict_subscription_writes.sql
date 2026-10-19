-- Issue #3: el cliente podía escribir su propia suscripción.
--
-- Las políticas FOR ALL permitían a cualquier usuario autenticado hacer
-- `update` de su fila en `user_subscriptions`: plan_id, status, maná… Es
-- decir, auto-asignarse REALEZA sin pagar. `payments` tenía el mismo problema.
--
-- Verificado antes de aplicar:
--   * La app solo hace SELECT sobre `user_subscriptions` (ningún write).
--   * `payments` no se usa desde el cliente.
--   * Todas las funciones que escriben la tabla (consume_mana, get_mana_state,
--     renew_mana_cycle, sync_entitlement, grant_mana…) son SECURITY DEFINER,
--     así que no les afecta RLS.
--   * El trigger `on_auth_user_created` corre como dueño de la tabla.

drop policy if exists subscriptions_self on public.user_subscriptions;
create policy subscriptions_self_select on public.user_subscriptions
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists payments_self on public.payments;
create policy payments_self_select on public.payments
  for select to authenticated
  using (auth.uid() = user_id);

-- Pendiente (#14): `user_language_profiles` sigue siendo escribible por el
-- dueño porque el onboarding calcula el CEFR en el cliente. Mover el
-- placement al servidor es lo que permitirá cerrar esa parte de #3.
