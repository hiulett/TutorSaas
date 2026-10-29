-- Issue #3: defensa en profundidad sobre entitlements y pagos.
--
-- RLS ya bloqueaba escrituras en estas tablas (solo existe policy SELECT),
-- pero `anon` y `authenticated` conservaban los privilegios INSERT/UPDATE/
-- DELETE/TRUNCATE. Se revocan para que una policy futura no abra escrituras
-- por accidente. Las escrituras van por webhook/RPC con service role.

revoke insert, update, delete, truncate on public.payments from anon, authenticated;
revoke insert, update, delete, truncate on public.user_subscriptions from anon, authenticated;
